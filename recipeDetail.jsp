<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recipe | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .recipe-header { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:3rem; gap:1.5rem; flex-wrap:wrap; }
        .meta-row  { display:flex; gap:8px; flex-wrap:wrap; margin-top:0.8rem; }
        .meta-chip { font-size:0.68rem; font-weight:500; background:rgba(0,0,0,0.04); padding:4px 12px; border-radius:30px; display:inline-flex; align-items:center; gap:5px; }
        .meta-chip.ready { background:#e8f5e9; color:#2e7d32; }
        .fav-btn-lg { display:inline-flex; align-items:center; gap:8px; padding:10px 22px; border-radius:30px; border:1px solid var(--clay); background:transparent; font-family:'Inter',sans-serif; font-size:0.78rem; font-weight:600; color:var(--clay); cursor:pointer; transition:var(--transition); flex-shrink:0; margin-top:1rem; }
        .fav-btn-lg:hover  { background:var(--clay); color:#fff; }
        .fav-btn-lg.active { background:var(--clay); color:#fff; }
        .sec-title-sm { font-family:'DM Serif Display',serif; font-size:1.4rem; color:var(--charcoal); margin-bottom:1.5rem; }
        .ing-row { display:flex; align-items:center; gap:1rem; padding:1rem 0; border-bottom:1px solid var(--border); font-size:0.88rem; }
        .ing-row:last-child { border-bottom:none; }
        .chk-icon { width:26px; height:26px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.72rem; flex-shrink:0; }
        .chk-have { background:#e8f5e9; color:#2e7d32; }
        .chk-miss { background:#ffebee; color:#c62828; }
        .ing-name  { flex:1; color:var(--charcoal); font-weight:500; }
        .ing-name.missing { color:#c62828; }
        .ing-qty   { font-size:0.78rem; opacity:0.5; }
        .b-have { background:#e8f5e9; color:#2e7d32; }
        .b-miss { background:#ffebee; color:#c62828; }
        .step-row { display:flex; gap:1.2rem; padding:1.2rem 0; border-bottom:1px solid var(--border); }
        .step-row:last-child { border-bottom:none; }
        .step-num { width:30px; height:30px; border-radius:50%; background:var(--bone); border:1px solid var(--border); display:flex; align-items:center; justify-content:center; font-size:0.72rem; font-weight:700; color:var(--clay); flex-shrink:0; margin-top:2px; }
        .step-txt  { font-size:0.88rem; color:var(--charcoal); line-height:1.7; font-weight:300; }
        .yt-btn { display:inline-flex; align-items:center; gap:8px; padding:10px 20px; background:#ffebee; border:1px solid #ffcdd2; border-radius:30px; color:#c62828; font-size:0.82rem; font-weight:700; text-decoration:none; transition:var(--transition); margin-top:1rem; }
        .yt-btn:hover { background:#fcc; }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    int recipeId = 0;
    try { recipeId = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}

    List<String> fridgeItems = new ArrayList<>();
    String rName="", rCuis="", rMeal="", rYt=""; int rSteps=0;
    List<String[]> rIngs = new ArrayList<>();
    List<String[]> rStepsList = new ArrayList<>();
    boolean isFav = false;
    Connection conn = null;

    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        PreparedStatement pf = conn.prepareStatement("SELECT LOWER(name) FROM ingredients WHERE username=?");
        pf.setString(1, username); ResultSet rf = pf.executeQuery();
        while (rf.next()) fridgeItems.add(rf.getString(1)); rf.close(); pf.close();

        PreparedStatement pr = conn.prepareStatement("SELECT * FROM recipes WHERE id=?");
        pr.setInt(1, recipeId); ResultSet rr = pr.executeQuery();
        if (rr.next()) {
            rName  = rr.getString("name");
            rCuis  = rr.getString("cuisine")    != null ? rr.getString("cuisine")    : "";
            rMeal  = rr.getString("meal_type")  != null ? rr.getString("meal_type")  : "";
            rYt    = rr.getString("youtube_url")!= null ? rr.getString("youtube_url"): "";
            rSteps = rr.getInt("total_steps");
        }
        rr.close(); pr.close();

        PreparedStatement pi = conn.prepareStatement(
            "SELECT ingredient_name,quantity_needed,unit FROM recipe_ingredients WHERE recipe_id=? ORDER BY id");
        pi.setInt(1, recipeId); ResultSet ri = pi.executeQuery();
        while (ri.next()) rIngs.add(new String[]{ri.getString(1), ri.getString(2)!=null?ri.getString(2):"", ri.getString(3)!=null?ri.getString(3):""});
        ri.close(); pi.close();

        PreparedStatement ps = conn.prepareStatement(
            "SELECT step_number,instruction FROM recipe_steps WHERE recipe_id=? ORDER BY step_number");
        ps.setInt(1, recipeId); ResultSet rs = ps.executeQuery();
        while (rs.next()) rStepsList.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2)});
        rs.close(); ps.close();

        PreparedStatement pfav = conn.prepareStatement(
            "SELECT id FROM favourites WHERE username=? AND recipe_id=?");
        pfav.setString(1, username); pfav.setInt(2, recipeId);
        ResultSet rfav = pfav.executeQuery(); if (rfav.next()) isFav=true;
        rfav.close(); pfav.close();

    } catch (Exception e) { e.printStackTrace(); }
    finally { if(conn!=null) try{conn.close();}catch(Exception ex){} }

    int missingCount = 0;
    for (String[] ri : rIngs) {
        boolean f=false;
        for (String fi:fridgeItems){ if(fi.contains(ri[0].toLowerCase())||ri[0].toLowerCase().contains(fi)){f=true;break;} }
        if (!f) missingCount++;
    }
%>

<nav class="navbar">
    <a href="dashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef.</a>
    <div class="nav-links">
        <a href="dashboard.jsp">Overview</a>
        <a href="viewIngredients.jsp">Inventory</a>
        <a href="recipes.jsp" class="active">Recipes</a>
        <a href="favourites.jsp">Saved</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container-md">
    <a href="recipes.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Recipes</a>

    <% if (rName.isEmpty()) { %>
    <div class="empty-state"><i class="fas fa-plate-wheat"></i><p>Recipe not found.</p></div>
    <% } else { %>

    <div class="recipe-header">
        <div>
            <span class="pg-label">Recipe</span>
            <h1 class="pg-title"><%= rName %></h1>
            <div class="meta-row">
                <% if (!rCuis.isEmpty()) { %><span class="meta-chip"><i class="fas fa-earth-americas"></i> <%= rCuis %></span><% } %>
                <% if (!rMeal.isEmpty()) { %><span class="meta-chip"><i class="fas fa-clock"></i> <%= rMeal %></span><% } %>
                <span class="meta-chip"><i class="fas fa-list-ol"></i> <%= rSteps %> steps</span>
                <% if (missingCount==0) { %><span class="meta-chip ready"><i class="fas fa-circle-check"></i> Ready to cook!</span><% } %>
            </div>
            <% if (!rYt.isEmpty()) { %>
            <a href="<%= rYt %>" target="_blank" class="yt-btn">
                <i class="fab fa-youtube"></i> Watch on YouTube
            </a>
            <% } %>
        </div>
        <form action="FavouriteServlet" method="post">
            <input type="hidden" name="recipeId" value="<%= recipeId %>">
            <input type="hidden" name="action"   value="<%= isFav?"remove":"add" %>">
            <input type="hidden" name="from"     value="detail">
            <button type="submit" class="fav-btn-lg <%= isFav?"active":"" %>">
                <i class="<%= isFav?"fas":"far" %> fa-heart"></i>
                <%= isFav ? "Saved" : "Save Recipe" %>
            </button>
        </form>
    </div>

    <!-- Ingredients -->
    <div class="glass-card" style="margin-bottom:1.5rem;">
        <div class="card-body">
            <div class="sec-title-sm"><i class="fas fa-basket-shopping" style="color:var(--clay); margin-right:10px;"></i>Ingredients</div>
            <% for (String[] ri : rIngs) {
                boolean have=false;
                for (String f:fridgeItems){if(f.contains(ri[0].toLowerCase())||ri[0].toLowerCase().contains(f)){have=true;break;}}
            %>
            <div class="ing-row">
                <div class="chk-icon <%= have?"chk-have":"chk-miss" %>"><i class="fas fa-<%= have?"check":"xmark" %>"></i></div>
                <span class="ing-name <%= have?"":"missing" %>"><%= ri[0] %></span>
                <span class="ing-qty"><%= ri[1] %> <%= ri[2] %></span>
                <span class="badge <%= have?"b-have":"b-miss" %>"><%= have?"In Fridge":"Missing" %></span>
            </div>
            <% } %>
        </div>
    </div>

    <!-- Steps -->
    <div class="glass-card">
        <div class="card-body">
            <div class="sec-title-sm"><i class="fas fa-clipboard-list" style="color:var(--clay); margin-right:10px;"></i>Instructions</div>
            <% if (rStepsList.isEmpty()) { %>
                <p style="opacity:.4; font-size:.87rem;">No instructions available.</p>
            <% } else { for (String[] st : rStepsList) { %>
            <div class="step-row">
                <div class="step-num"><%= st[0] %></div>
                <div class="step-txt"><%= st[1] %></div>
            </div>
            <% }} %>
        </div>
    </div>

    <% } %>
</div>
</body>
</html>
