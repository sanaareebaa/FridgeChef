package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/EditIngredientServlet")
public class EditIngredientServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        String username = (String) session.getAttribute("username");

        String idStr      = request.getParameter("id");
        String name       = request.getParameter("name").trim();
        String quantityStr= request.getParameter("quantity").trim();
        String unit       = request.getParameter("unit");
        String category   = request.getParameter("category");
        String expiryStr  = request.getParameter("expiryDate");

        try {
            int    id       = Integer.parseInt(idStr);
            double quantity = Double.parseDouble(quantityStr);

            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            Connection conn = DriverManager.getConnection(
                    "jdbc:derby://localhost:1527/users", "app", "app");

            String query = "UPDATE ingredients SET name=?, quantity=?, unit=?, category=?, expiry_date=? "
                         + "WHERE id=? AND username=?";

            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, name);
            ps.setDouble(2, quantity);
            ps.setString(3, unit);
            ps.setString(4, category);

            if (expiryStr != null && !expiryStr.isEmpty()) {
                ps.setDate(5, Date.valueOf(expiryStr));
            } else {
                ps.setNull(5, java.sql.Types.DATE);
            }

            ps.setInt(6, id);
            ps.setString(7, username);

            ps.executeUpdate();
            ps.close(); conn.close();

            response.sendRedirect("viewIngredients.jsp?msg=updated");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("viewIngredients.jsp?msg=error");
        }
    }
}
