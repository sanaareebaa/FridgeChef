<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Recipes | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .action-cell { display:flex; gap:0.4rem; align-items:center; flex-wrap:nowrap; }
        .saves-cell  { white-space:nowrap; font-size:.84rem; color:var(--charcoal); display:flex; align-items:center; gap:4px; }
        .saves-cell i { color:#c62828; }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null || !"admin".equalsIgnoreCase(username)) {
        response.sendRedirect("login.jsp"); return;
    }

    int totalRecipes = 0;

    Connection conn = null;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        ResultSet r;
        r = conn.prepareStatement("SELECT COUNT(*) FROM recipes").executeQuery();
        if (r.next()) totalRecipes = r.getInt(1); r.close();

    } catch (Exception e) { e.printStackTrace(); }

    String msg       = request.getParameter("msg");
    String errMsg    = request.getParameter("error");
    String activeTab = request.getParameter("tab") != null ? request.getParameter("tab") : "recipes";
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
    <header class="header-group">
        <span class="pg-label">Admin — Recipes</span>
        <h1 class="pg-title">Recipe Manager.</h1>
        <p class="pg-subtitle">Add, edit, delete recipes and manage Recipe of the Week.</p>
    </header>

    <% if (msg    != null) { %><div class="alert alert-ok" ><i class="fas fa-circle-check"></i> <%= msg %></div><% } %>
    <% if (errMsg != null) { %><div class="alert alert-err"><i class="fas fa-circle-exclamation"></i> <%= errMsg %></div><% } %>

    <div class="nav-tabs">
        <button class="nav-tab <%= "recipes".equals(activeTab)?"active":"" %>" onclick="switchTab('recipes',this)"><i class="fas fa-plate-wheat"></i> &nbsp;All Recipes</button>
        <button class="nav-tab <%= "add".equals(activeTab)?"active":"" %>"     onclick="switchTab('add',this)"><i class="fas fa-plus"></i> &nbsp;Add Recipe</button>
    </div>

    <!-- ═══ TAB 1: ALL RECIPES ═══ -->
    <div id="tab-recipes" class="tab-content <%= "recipes".equals(activeTab)?"active":"" %>">
        <div class="sec-title sec-title-top">All Recipes (<%= totalRecipes %>)</div>
        <div class="glass-card table-container">
            <table>
                <thead>
                    <tr>
                        <th>#</th><th>Recipe</th><th>Cuisine</th><th>Meal</th>
                        <th style="text-align:center;">Steps</th><th>YouTube</th><th>Saves</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody>
<%
    try {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT r.id, r.name, r.cuisine, r.meal_type, r.total_steps, r.youtube_url, " +
            "COUNT(f.id) AS save_count " +
            "FROM recipes r LEFT JOIN favourites f ON r.id = f.recipe_id " +
            "GROUP BY r.id, r.name, r.cuisine, r.meal_type, r.total_steps, r.youtube_url " +
            "ORDER BY r.id DESC");
        ResultSet rs = ps.executeQuery();
        boolean anyR = false; int cnt = 1;
        while (rs.next()) {
            anyR    = true;
            int    rId    = rs.getInt("id");
            String rName  = rs.getString("name");
            String rCuis  = rs.getString("cuisine")    != null ? rs.getString("cuisine")    : "—";
            String rMeal  = rs.getString("meal_type")  != null ? rs.getString("meal_type")  : "—";
            int    rSteps = rs.getInt("total_steps");
            String rYt    = rs.getString("youtube_url")!= null ? rs.getString("youtube_url"): "";
            int    rSaves = rs.getInt("save_count");
%>
                <tr>
                    <td style="opacity:.35;font-size:.78rem;"><%= String.format("%02d",cnt++) %></td>
                    <td>
                        <strong><%= rName %></strong>
                    </td>
                    <td><span class="badge b-cat"><%= rCuis %></span></td>
                    <td><span class="badge b-cat"><%= rMeal %></span></td>
                    <td style="text-align:center;"><%= rSteps %></td>
                    <td>
                        <% if (!rYt.isEmpty()) { %>
                        <a href="<%= rYt %>" target="_blank" style="color:#c62828;font-size:.82rem;font-weight:600;text-decoration:none;white-space:nowrap;">
                            <i class="fab fa-youtube"></i> Watch
                        </a>
                        <% } else { %><span style="opacity:.3;font-size:.78rem;">—</span><% } %>
                    </td>
                    <td>
                        <span class="saves-cell"><i class="fas fa-heart"></i> <%= rSaves %></span>
                    </td>
                    <td>
                        <div class="action-cell">
                            <a href="editRecipe.jsp?id=<%= rId %>" class="btn-edit">
                                <i class="fas fa-pen"></i> Edit
                            </a>
                            <form action="AdminRecipeServlet" method="post" style="margin:0;"
                                  onsubmit="return confirm('Delete this recipe? This cannot be undone.')">
                                <input type="hidden" name="action"   value="delete">
                                <input type="hidden" name="recipeId" value="<%= rId %>">
                                <button type="submit" class="btn-del"><i class="fas fa-trash-can"></i> Delete</button>
                            </form>
                        </div>
                    </td>
                </tr>
<%      }
        rs.close(); ps.close();
        if (!anyR) {
%>
            <tr><td colspan="8"><div class="empty-state"><i class="fas fa-plate-wheat"></i><p>No recipes yet. Use the Add Recipe tab!</p></div></td></tr>
<%      }
    } catch (Exception e) {
        out.print("<tr><td colspan='8' style='color:red;padding:1rem;'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ═══ TAB 2: ADD RECIPE ═══ -->
    <div id="tab-add" class="tab-content <%= "add".equals(activeTab)?"active":"" %>">
        <div class="sec-title sec-title-top">Add New Recipe</div>
        <div class="glass-card">
            <div class="card-body">
                <form action="AdminRecipeServlet" method="post">
                    <input type="hidden" name="action" value="add">
                    <div class="form-row-3">
                        <div class="fg">
                            <label>Recipe Name</label>
                            <div class="input-wrap"><i class="fas fa-fire-burner ic"></i>
                                <input type="text" name="name" placeholder="e.g. Chicken Curry" required>
                            </div>
                        </div>
                        <div class="fg">
                            <label>Cuisine</label>
                            <div class="input-wrap"><i class="fas fa-earth-americas ic"></i>
                                <select name="cuisine">
                                    <option>Western</option>
                                    <option>Asian</option>
                                    <option>Italian</option>
                                    <option>Indian</option>
                                    <option>Mexican</option>
                                    <option>Mediterranean</option>
                                    <option>International</option>
                                    <option>Others</option>
                                </select>
                            </div>
                        </div>
                        <div class="fg">
                            <label>Meal Type</label>
                            <div class="input-wrap"><i class="fas fa-clock ic"></i>
                                <select name="mealType">
                                    <option>Breakfast</option>
                                    <option>Lunch</option>
                                    <option>Dinner</option>
                                    <option>Snack</option>
                                    <option>Dessert</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="fg">
                        <label>YouTube Video Link <span style="opacity:.5;font-size:.7rem;">(optional)</span></label>
                        <div class="input-wrap"><i class="fab fa-youtube ic"></i>
                            <input type="url" name="youtubeUrl" placeholder="https://www.youtube.com/watch?v=...">
                        </div>
                    </div>
                    <span class="sub-label"><i class="fas fa-basket-shopping"></i> &nbsp;Ingredients</span>
                    <div id="addIngContainer">
                        <div class="ing-row">
                            <input type="text" name="ingName" placeholder="Ingredient name" required>
                            <input type="text" name="ingQty"  placeholder="Qty">
                            <input type="text" name="ingUnit" placeholder="Unit">
                            <button type="button" class="btn-remove-row" onclick="removeRow(this)"><i class="fas fa-xmark"></i></button>
                        </div>
                    </div>
                    <button type="button" class="btn-add-row" onclick="addIngredient('addIngContainer')"><i class="fas fa-plus"></i> Add Ingredient</button>
                    <span class="sub-label"><i class="fas fa-list-ol"></i> &nbsp;Instructions</span>
                    <div id="addStepContainer">
                        <div class="step-row">
                            <div class="step-num-badge">1</div>
                            <textarea name="step" placeholder="Describe step 1…" required></textarea>
                            <button type="button" class="btn-remove-row" onclick="removeRow(this)"><i class="fas fa-xmark"></i></button>
                        </div>
                    </div>
                    <button type="button" class="btn-add-row" onclick="addStep('addStepContainer')"><i class="fas fa-plus"></i> Add Step</button>
                    <div class="btn-row">
                        <button type="submit" class="btn-primary"><i class="fas fa-floppy-disk"></i> Save Recipe</button>
                        <button type="reset"  class="btn-ghost">Clear</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>

<% if (conn != null) try { conn.close(); } catch (Exception ex) {} %>


<script>
function switchTab(name, btn) {
    document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    btn.classList.add('active');
}

function addIngredient(cId) {
    const c = document.getElementById(cId);
    const row = document.createElement('div');
    row.className = 'ing-row';
    row.innerHTML = `<input type="text" name="ingName" placeholder="Ingredient name">
        <input type="text" name="ingQty" placeholder="Qty">
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
    container.querySelectorAll('.step-num-badge').forEach((b,i) => b.textContent = i+1);
}
</script>
</body>
</html>

