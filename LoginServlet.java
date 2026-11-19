package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username") != null ? request.getParameter("username").trim() : "";
        String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";

        try {
            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");

            Connection conn = DriverManager.getConnection(
                   "jdbc:derby://localhost:1527/users", "app", "app");

            PreparedStatement stmt = conn.prepareStatement(
                    "SELECT * FROM users WHERE username=? AND password=?");
            stmt.setString(1, username);
            stmt.setString(2, password);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String dbUsername = rs.getString("username");
                dbUsername = dbUsername != null ? dbUsername.trim() : "";

                HttpSession session = request.getSession();
                session.setAttribute("username", dbUsername);

                rs.close();
                stmt.close();
                conn.close();

                if (dbUsername.equalsIgnoreCase("admin")) {
                    response.sendRedirect("adminRecipes.jsp");
                } else {
                    response.sendRedirect("dashboard.jsp");
                }

            } else {
                rs.close();
                stmt.close();
                conn.close();
                response.sendRedirect("login.jsp?error=Invalid username or password");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
}