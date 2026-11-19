package servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username") != null ? request.getParameter("username").trim() : "";
        String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";
        String email    = request.getParameter("email")    != null ? request.getParameter("email").trim()    : "";

        // Basic validation
        if (username.isEmpty() || password.isEmpty() || email.isEmpty()) {
            response.sendRedirect("register.jsp?error=All+fields+are+required");
            return;
        }
        if (!email.contains("@") || !email.contains(".")) {
            response.sendRedirect("register.jsp?error=Please+enter+a+valid+email+address");
            return;
        }
        if (username.equalsIgnoreCase("admin")) {
            response.sendRedirect("register.jsp?error=That+username+is+reserved");
            return;
        }

        try {
            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/users", "app", "app");

            //  if username already exists
            PreparedStatement check = conn.prepareStatement(
                    "SELECT COUNT(*) FROM users WHERE LOWER(username)=LOWER(?)");
            check.setString(1, username);
            ResultSet rs = check.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                rs.close(); check.close(); conn.close();
                response.sendRedirect("register.jsp?error=Username+already+taken");
                return;
            }
            rs.close(); check.close();

            // Insert new user with email
            PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO users (username, password, email) VALUES (?, ?, ?)");
            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setString(3, email);
            stmt.executeUpdate();
            stmt.close();
            conn.close();

            response.sendRedirect("login.jsp?msg=registered");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=Registration+failed.+Please+try+again.");
        }
    }
}
