package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/AddIngredientServlet")
public class AddIngredientServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get session username
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");

        //  form parameters
        String name       = request.getParameter("name").trim();
        String quantityStr= request.getParameter("quantity").trim();
        String unit       = request.getParameter("unit");
        String category   = request.getParameter("category");
        String expiryStr  = request.getParameter("expiryDate");

        // Validate
        if (name.isEmpty() || quantityStr.isEmpty()) {
            response.sendRedirect("addIngredient.jsp?error=Name and quantity are required");
            return;
        }

        try {
            double quantity = Double.parseDouble(quantityStr);

            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/users", "app", "app");

            String query = "INSERT INTO ingredients (username, name, quantity, unit, category, expiry_date, added_date) "
                         + "VALUES (?, ?, ?, ?, ?, ?, CURRENT_DATE)";

            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, name);
            ps.setDouble(3, quantity);
            ps.setString(4, unit);
            ps.setString(5, category);

            // Expiry date (nullable)
            if (expiryStr != null && !expiryStr.isEmpty()) {
                ps.setDate(6, Date.valueOf(expiryStr));
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }

            ps.executeUpdate();
            ps.close(); conn.close();

            response.sendRedirect("addIngredient.jsp?msg=added");

        } catch (NumberFormatException e) {
            response.sendRedirect("addIngredient.jsp?error=Invalid quantity value");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addIngredient.jsp?error=Failed to add ingredient. Please try again.");
        }
    }
}
