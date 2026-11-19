<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Recipe | FridgeChef Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .back-link { display:inline-flex; align-items:center; gap:.5rem; color:var(--taupe); font-size:.85rem; text-decoration:none; margin-bottom:2rem; }
        .back-link:hover { color:var(--clay); }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    // Auth check
    String username = (String) session.getAttribute("username");
    if (username == null || !"admin".equalsIgnoreCase(username)) {
        response.sendRedirect("login.jsp"); return;
    }

    // Get recipe ID from URL
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("adminRecipes.jsp?error=No+recipe+ID+provided"); return;
    }
    int recipeId;
    try { recipeId = Integer.parseInt(idParam.trim()); }
    catch (NumberFormatException e) {
        response.sendRedirect("adminRecipes.jsp?error=Invalid+recipe+ID"); return;
    }

    // Load recipe data from DB
    String rName = "", rCuisine = "", rMealType = "", rYt = "";
    java.util.List<String[]> ingredients = new java.util.ArrayList<>();
    java.util.List<String>   steps       = new java.util.ArrayList<>();

    Connection conn = null;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        // Recipe header
        PreparedStatement psR = conn.prepareStatement(
            "SELECT name, cuisine, meal_type, youtube_url FROM recipes WHERE id=?");
        psR.setInt(1, recipeId);
        ResultSet rsR = psR.executeQuery();
        if (!rsR.next()) {
            rsR.close(); psR.close(); conn.close();
            response.sendRedirect("adminRecipes.jsp?error=Recipe+not+found"); return;
        }
        rName     = rsR.getString("name")        != null ? rsR.getString("name")        : "";
        rCuisine  = rsR.getString("cuisine")     != null ? rsR.getString("cuisine")     : "";
        rMealType = rsR.getString("meal_type")   != null ? rsR.getString("meal_type")   : "";
        rYt       = rsR.getString("youtube_url") != null ? rsR.getString("youtube_url") : "";
        rsR.close(); psR.close();

        // Ingredients
        PreparedStatement psI = conn.prepareStatement(
            "SELECT ingredient_name, quantity_needed, unit FROM recipe_ingredients WHERE recipe_id=? ORDER BY id");
        psI.setInt(1, recipeId);
        ResultSet rsI = psI.executeQuery();
        while (rsI.next()) {
            ingredients.add(new String[]{
                rsI.getString("ingredient_name") != null ? rsI.getString("ingredient_name") : "",
                rsI.getString("quantity_needed") != null ? rsI.getString("quantity_needed") : "",
                rsI.getString("unit")            != null ? rsI.getString("unit")            : ""
            });
        }
        rsI.close(); psI.close();

        // Steps
        PreparedStatement psS = conn.prepareStatement(
            "SELECT instruction FROM recipe_steps WHERE recipe_id=? ORDER BY step_number");
        psS.setInt(1, recipeId);
        ResultSet rsS = psS.executeQuery();
        while (rsS.next()) {
            steps.add(rsS.getString("instruction") != null ? rsS.getString("instruction") : "");
        }
        rsS.close(); psS.close();

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
        response.sendRedirect("adminRecipes.jsp?error=Failed+to+load+recipe"); return;
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }

    // If no ingredients/steps yet, add one empty slot
    if (ingredients.isEmpty()) ingredients.add(new String[]{"","",""});
    if (steps.isEmpty())       steps.add("");
%>

<nav class="navbar">
    <a href="adminDashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef. <span class="nav-badge">Admin</span></a>
    <div class="nav-links">
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="adminRecipes.jsp" class="active">Recipes</a>
        <a href="adminUsers.jsp">Users</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container">
    <a href="adminRecipes.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Recipes</a>

    <header class="header-group">
        <span class="pg-label">Admin — Edit Recipe</span>
        <h1 class="pg-title">Editing: <%= rName %></h1>
    </header>

    <div class="glass-card">
        <div class="card-body">
            <form action="AdminRecipeServlet" method="post">
                <input type="hidden" name="action"   value="edit">
                <input type="hidden" name="recipeId" value="<%= recipeId %>">

                <div class="form-row-3">
                    <div class="fg">
                        <label>Recipe Name</label>
                        <div class="input-wrap"><i class="fas fa-fire-burner ic"></i>
                            <input type="text" name="name" value="<%= rName %>" required>
                        </div>
                    </div>
                    <div class="fg">
                        <label>Cuisine</label>
                        <div class="input-wrap"><i class="fas fa-earth-americas ic"></i>
                            <select name="cuisine">
                                <% String[] cuisines = {"Western","Asian","Italian","Indian","Mexican","Mediterranean","International","Others"};
                                   for (String c : cuisines) { %>
                                <option <%= c.equals(rCuisine) ? "selected" : "" %>><%= c %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <div class="fg">
                        <label>Meal Type</label>
                        <div class="input-wrap"><i class="fas fa-clock ic"></i>
                            <select name="mealType">
                                <% String[] meals = {"Breakfast","Lunch","Dinner","Snack","Dessert"};
                                   for (String m : meals) { %>
                                <option <%= m.equals(rMealType) ? "selected" : "" %>><%= m %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="fg">
                    <label>YouTube Video Link <span style="opacity:.5;font-size:.7rem;">(optional)</span></label>
                    <div class="input-wrap"><i class="fab fa-youtube ic"></i>
                        <input type="url" name="youtubeUrl" value="<%= rYt %>" placeholder="https://www.youtube.com/watch?v=...">
                    </div>
                </div>

                <span class="sub-label"><i class="fas fa-basket-shopping"></i> &nbsp;Ingredients</span>
                <div id="ingContainer">
                    <% for (String[] ing : ingredients) { %>
                    <div class="ing-row">
                        <input type="text" name="ingName" value="<%= ing[0] %>" placeholder="Ingredient name">
                        <input type="text" name="ingQty"  value="<%= ing[1] %>" placeholder="Qty">
                        <input type="text" name="ingUnit" value="<%= ing[2] %>" placeholder="Unit">
                        <button type="button" class="btn-remove-row" onclick="removeRow(this)"><i class="fas fa-xmark"></i></button>
                    </div>
                    <% } %>
                </div>
                <button type="button" class="btn-add-row" onclick="addIngredient('ingContainer')">
                    <i class="fas fa-plus"></i> Add Ingredient
                </button>

                <span class="sub-label"><i class="fas fa-list-ol"></i> &nbsp;Instructions</span>
                <div id="stepContainer">
                    <% int stepNum = 1; for (String step : steps) { %>
                    <div class="step-row">
                        <div class="step-num-badge"><%= stepNum++ %></div>
                        <textarea name="step"><%= step %></textarea>
                        <button type="button" class="btn-remove-row" onclick="removeRow(this)"><i class="fas fa-xmark"></i></button>
                    </div>
                    <% } %>
                </div>
                <button type="button" class="btn-add-row" onclick="addStep('stepContainer')">
                    <i class="fas fa-plus"></i> Add Step
                </button>

                <div class="btn-row" style="margin-top:2rem;">
                    <button type="submit" class="btn-primary"><i class="fas fa-floppy-disk"></i> Save Changes</button>
                    <a href="adminRecipes.jsp" class="btn-ghost" style="text-decoration:none;">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function addIngredient(cId) {
    const c = document.getElementById(cId);
    const row = document.createElement('div');
    row.className = 'ing-row';
    row.innerHTML = `<input type="text" name="ingName" placeholder="Ingredient name">
        <input type="text" name="ingQty"  placeholder="Qty">
        <input type="text" name="ingUnit" placeholder="Unit">
        <button type="button" class="btn-remove-row" onclick="removeRow(this)"><i class="fas fa-xmark"></i></button>`;
    c.appendChild(row);
}

function addStep(cId) {
    const c = document.getElementById(cId);
    const num = c.querySelectorAll('.step-row').length + 1;
    const row = document.createElement('div');
    row.className = 'step-row';
    row.innerHTML = `<div class="step-num-badge">${num}</div>
        <textarea name="step" placeholder="Describe step ${num}…"></textarea>
        <button type="button" class="btn-remove-row" onclick="removeRow(this)"><i class="fas fa-xmark"></i></button>`;
    c.appendChild(row);
}

function removeRow(btn) {
    const parent = btn.closest('.ing-row, .step-row');
    const container = parent.parentElement;
    parent.remove();
    container.querySelectorAll('.step-num-badge').forEach((b, i) => b.textContent = i + 1);
}
</script>
</body>
</html>
