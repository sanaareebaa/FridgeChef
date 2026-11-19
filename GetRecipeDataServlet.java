/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * Returns recipe ingredients + steps as JSON for the Edit modal.
 * Called via fetch('GetRecipeDataServlet?id=123')
 */
@WebServlet("/GetRecipeDataServlet")
public class GetRecipeDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Must be logged in as admin
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("username"))) {
            response.setStatus(403);
            response.getWriter().print("{\"error\":\"Unauthorized\"}");
            return;
        }

        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            out.print("{\"ingredients\":[],\"steps\":[]}");
            return;
        }

        int recipeId;
        try { recipeId = Integer.parseInt(idParam); }
        catch (NumberFormatException e) {
            out.print("{\"ingredients\":[],\"steps\":[]}");
            return;
        }

        StringBuilder json = new StringBuilder("{");

        Connection conn = null;
        try {
            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

            // ── Ingredients ──
            json.append("\"ingredients\":[");
            PreparedStatement pi = conn.prepareStatement(
                "SELECT ingredient_name, quantity_needed, unit " +
                "FROM recipe_ingredients WHERE recipe_id=? ORDER BY id");
            pi.setInt(1, recipeId);
            ResultSet ri = pi.executeQuery();
            boolean firstI = true;
            while (ri.next()) {
                if (!firstI) json.append(",");
                firstI = false;
                json.append("{")
                    .append("\"name\":").append(jsonStr(ri.getString("ingredient_name"))).append(",")
                    .append("\"qty\":" ).append(jsonStr(ri.getString("quantity_needed"))).append(",")
                    .append("\"unit\":").append(jsonStr(ri.getString("unit")))
                    .append("}");
            }
            ri.close(); pi.close();
            json.append("],");

            // ── Steps ──
            json.append("\"steps\":[");
            PreparedStatement ps = conn.prepareStatement(
                "SELECT instruction FROM recipe_steps WHERE recipe_id=? ORDER BY step_number");
            ps.setInt(1, recipeId);
            ResultSet rs = ps.executeQuery();
            boolean firstS = true;
            while (rs.next()) {
                if (!firstS) json.append(",");
                firstS = false;
                json.append(jsonStr(rs.getString("instruction")));
            }
            rs.close(); ps.close();
            json.append("]");

        } catch (Exception e) {
            e.printStackTrace();
            json = new StringBuilder("{\"ingredients\":[],\"steps\":[],\"error\":\"" + e.getMessage() + "\"");
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ex) {}
        }

        json.append("}");
        out.print(json.toString());
    }

    /** Safely encode a value as a JSON string (handles null, quotes, special chars). */
    private String jsonStr(String val) {
        if (val == null) return "\"\"";
        return "\"" + val
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t")
            + "\"";
    }
}
