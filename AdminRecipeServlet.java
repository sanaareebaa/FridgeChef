/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package servlets;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/AdminRecipeServlet")
public class AdminRecipeServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:derby://localhost:1527/users";
    private static final String DB_USER = "app";
    private static final String DB_PASS = "app";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equalsIgnoreCase((String) session.getAttribute("username"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect("adminRecipes.jsp?error=No+action+specified");
            return;
        }

        Connection conn = null;
        try {
            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            switch (action) {
                case "add":    handleAdd(request, response, conn);    break;
                case "edit":   handleEdit(request, response, conn);   break;
                case "delete": handleDelete(request, response, conn); break;
                case "pin":    handlePin(request, response, conn);    break;
                case "unpin":  handleUnpin(request, response, conn);  break;
                case "deleteUser": handleDeleteUser(request, response, conn); break;
                default:
                    response.sendRedirect("adminRecipes.jsp?error=Unknown+action");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminRecipes.jsp?error=Server+error:+" + encodeMsg(e.getMessage()));
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ex) {}
        }
    }

    // add recipie
    private void handleAdd(HttpServletRequest req, HttpServletResponse res, Connection conn)
            throws Exception {

        String name       = req.getParameter("name").trim();
        String cuisine    = req.getParameter("cuisine").trim();
        String mealType   = req.getParameter("mealType").trim();
        String youtubeUrl = req.getParameter("youtubeUrl") != null ? req.getParameter("youtubeUrl").trim() : "";
        String[] ingNames = req.getParameterValues("ingName");
        String[] ingQtys  = req.getParameterValues("ingQty");
        String[] ingUnits = req.getParameterValues("ingUnit");
        String[] steps    = req.getParameterValues("step");
        int totalSteps    = (steps != null) ? steps.length : 0;

        // Insert recipe
        PreparedStatement psR = conn.prepareStatement(
            "INSERT INTO recipes (name, cuisine, meal_type, total_steps, youtube_url) VALUES (?, ?, ?, ?, ?)");
        psR.setString(1, name);
        psR.setString(2, cuisine);
        psR.setString(3, mealType);
        psR.setInt(4, totalSteps);
        psR.setString(5, youtubeUrl.isEmpty() ? null : youtubeUrl);
        psR.executeUpdate();
        psR.close();

        // Get auto-generated ID
        int recipeId = getLastInsertId(conn);

        insertIngredients(conn, recipeId, ingNames, ingQtys, ingUnits);
        insertSteps(conn, recipeId, steps);

        res.sendRedirect("adminRecipes.jsp?msg=Recipe+added+successfully!&tab=recipes");
    }

    // recipie edit
    private void handleEdit(HttpServletRequest req, HttpServletResponse res, Connection conn)
            throws Exception {

        int recipeId      = Integer.parseInt(req.getParameter("recipeId"));
        String name       = req.getParameter("name").trim();
        String cuisine    = req.getParameter("cuisine").trim();
        String mealType   = req.getParameter("mealType").trim();
        String youtubeUrl = req.getParameter("youtubeUrl") != null ? req.getParameter("youtubeUrl").trim() : "";
        String[] ingNames = req.getParameterValues("ingName");
        String[] ingQtys  = req.getParameterValues("ingQty");
        String[] ingUnits = req.getParameterValues("ingUnit");
        String[] steps    = req.getParameterValues("step");
        int totalSteps    = (steps != null) ? steps.length : 0;

        // Update recipe header
        PreparedStatement psU = conn.prepareStatement(
            "UPDATE recipes SET name=?, cuisine=?, meal_type=?, total_steps=?, youtube_url=? WHERE id=?");
        psU.setString(1, name);
        psU.setString(2, cuisine);
        psU.setString(3, mealType);
        psU.setInt(4, totalSteps);
        psU.setString(5, youtubeUrl.isEmpty() ? null : youtubeUrl);
        psU.setInt(6, recipeId);
        psU.executeUpdate();
        psU.close();

        // Clear old ingredients & steps, then re-insert
        conn.prepareStatement("DELETE FROM recipe_ingredients WHERE recipe_id=" + recipeId).executeUpdate();
        conn.prepareStatement("DELETE FROM recipe_steps WHERE recipe_id=" + recipeId).executeUpdate();

        insertIngredients(conn, recipeId, ingNames, ingQtys, ingUnits);
        insertSteps(conn, recipeId, steps);

        res.sendRedirect("adminRecipes.jsp?msg=Recipe+updated+successfully!&tab=recipes");
    }

    // delete recipe
    private void handleDelete(HttpServletRequest req, HttpServletResponse res, Connection conn)
            throws Exception {

        int recipeId = Integer.parseInt(req.getParameter("recipeId"));

        String[] tables = {
            "DELETE FROM recipe_steps       WHERE recipe_id=?",
            "DELETE FROM recipe_ingredients WHERE recipe_id=?",
            "DELETE FROM favourites         WHERE recipe_id=?"
        };
        for (String sql : tables) {
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, recipeId); ps.executeUpdate(); ps.close();
        }
        PreparedStatement ps4 = conn.prepareStatement("DELETE FROM recipes WHERE id=?");
        ps4.setInt(1, recipeId); ps4.executeUpdate(); ps4.close();

        // devlop later
        try {
            PreparedStatement ps5 = conn.prepareStatement(
                "DELETE FROM admin_settings WHERE setting_key='rotw' AND val=?");
            ps5.setString(1, String.valueOf(recipeId)); ps5.executeUpdate(); ps5.close();
        } catch (Exception e) { /* column may not exist — safe to ignore */ }

        res.sendRedirect("adminRecipes.jsp?msg=Recipe+deleted.&tab=recipes");
    }

    // develop laterrrr
    private void handlePin(HttpServletRequest req, HttpServletResponse res, Connection conn)
            throws Exception {

        int recipeId = Integer.parseInt(req.getParameter("recipeId"));

        // Delete any existing ROTW setting
        PreparedStatement psDel = conn.prepareStatement(
            "DELETE FROM admin_settings WHERE setting_key='rotw'");
        psDel.executeUpdate(); psDel.close();

        // Insert new pin
        PreparedStatement psIns = conn.prepareStatement(
            "INSERT INTO admin_settings (setting_key, val) VALUES ('rotw', ?)");
        psIns.setString(1, String.valueOf(recipeId));
        psIns.executeUpdate(); psIns.close();

        res.sendRedirect("adminRecipes.jsp?msg=Recipe+of+the+Week+pinned!&tab=rotw");
    }

    // function removed / develp later
    private void handleUnpin(HttpServletRequest req, HttpServletResponse res, Connection conn)
            throws Exception {

        PreparedStatement psDel = conn.prepareStatement(
            "DELETE FROM admin_settings WHERE setting_key='rotw'");
        psDel.executeUpdate(); psDel.close();

        res.sendRedirect("adminRecipes.jsp?msg=Recipe+of+the+Week+removed.&tab=rotw");
    }

    // user deleye
    private void handleDeleteUser(HttpServletRequest req, HttpServletResponse res, Connection conn)
            throws Exception {

        String userName = req.getParameter("userName");
        String[] delSqls = {
            "DELETE FROM favourites  WHERE username=?",
            "DELETE FROM ingredients WHERE username=?",
            "DELETE FROM users  WHERE username=?"
        };
        for (String sql : delSqls) {
            PreparedStatement pd = conn.prepareStatement(sql);
            pd.setString(1, userName); pd.executeUpdate(); pd.close();
        }
        res.sendRedirect("adminRecipes.jsp?msg=User+" + encodeMsg(userName) + "+removed.&tab=users");
    }

    // helpie
    private int getLastInsertId(Connection conn) throws Exception {
        PreparedStatement psId = conn.prepareStatement("VALUES IDENTITY_VAL_LOCAL()");
        ResultSet rsId = psId.executeQuery();
        int id = 0;
        if (rsId.next()) id = rsId.getInt(1);
        rsId.close(); psId.close();
        return id;
    }

    private void insertIngredients(Connection conn, int recipeId,
            String[] ingNames, String[] ingQtys, String[] ingUnits) throws Exception {
        if (ingNames == null) return;
        for (int i = 0; i < ingNames.length; i++) {
            String iName = ingNames[i].trim();
            if (iName.isEmpty()) continue;
            String iQty  = (ingQtys  != null && i < ingQtys.length)  ? ingQtys[i]  : "";
            String iUnit = (ingUnits != null && i < ingUnits.length) ? ingUnits[i] : "";
            PreparedStatement psI = conn.prepareStatement(
                "INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity_needed, unit) VALUES (?, ?, ?, ?)");
            psI.setInt(1, recipeId); psI.setString(2, iName);
            psI.setString(3, iQty);  psI.setString(4, iUnit);
            psI.executeUpdate(); psI.close();
        }
    }

    private void insertSteps(Connection conn, int recipeId, String[] steps) throws Exception {
        if (steps == null) return;
        for (int i = 0; i < steps.length; i++) {
            String stepText = steps[i].trim();
            if (stepText.isEmpty()) continue;
            PreparedStatement psS = conn.prepareStatement(
                "INSERT INTO recipe_steps (recipe_id, step_number, instruction) VALUES (?, ?, ?)");
            psS.setInt(1, recipeId); psS.setInt(2, i + 1); psS.setString(3, stepText);
            psS.executeUpdate(); psS.close();
        }
    }

    private String encodeMsg(String s) {
        if (s == null) return "";
        return s.replace(" ", "+").replace("&", "and");
    }
}
