package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/FavouriteServlet")
public class FavouriteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        String username = (String) session.getAttribute("username");

        String action      = request.getParameter("action");
        String recipeIdStr = request.getParameter("recipeId");
        String from        = request.getParameter("from"); // "recipes", "detail", "favourites"

        try {
            int recipeId = Integer.parseInt(recipeIdStr);

            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/users", "app", "app");

            if ("add".equals(action)) {
                // Check not already saved
                PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM favourites WHERE username=? AND recipe_id=?");
                check.setString(1, username);
                check.setInt(2, recipeId);
                ResultSet rs = check.executeQuery();
                boolean exists = rs.next();
                rs.close(); check.close();

                if (!exists) {
                    PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO favourites (username, recipe_id) VALUES (?, ?)");
                    ps.setString(1, username);
                    ps.setInt(2, recipeId);
                    ps.executeUpdate();
                    ps.close();
                }

            } else if ("remove".equals(action)) {
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM favourites WHERE username=? AND recipe_id=?");
                ps.setString(1, username);
                ps.setInt(2, recipeId);
                ps.executeUpdate();
                ps.close();
            }

            conn.close();

            // Redirect back to where the user came from
            if ("favourites".equals(from)) {
                response.sendRedirect("favourites.jsp");
            } else if ("detail".equals(from)) {
                response.sendRedirect("recipeDetail.jsp?id=" + recipeId);
            } else {
                response.sendRedirect("recipes.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("recipes.jsp");
        }
    }
}
