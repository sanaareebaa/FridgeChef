package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/DeleteIngredientServlet")
public class DeleteIngredientServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        String username = (String) session.getAttribute("username");

        String idStr = request.getParameter("id");

        try {
            int id = Integer.parseInt(idStr);

            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/users", "app", "app");

            // Only delete if belongs to this user
            PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM ingredients WHERE id=? AND username=?");
            ps.setInt(1, id);
            ps.setString(2, username);
            ps.executeUpdate();

            ps.close(); conn.close();

            response.sendRedirect("viewIngredients.jsp?msg=deleted");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("viewIngredients.jsp");
        }
    }
}
