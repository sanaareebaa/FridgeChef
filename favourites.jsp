<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Favourites | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .fav-card { padding:1.6rem 2rem; margin-bottom:1rem; display:flex; align-items:center; justify-content:space-between; gap:1.5rem; }
        .fav-card:hover { transform:translateX(4px); border-color:var(--clay); background:white; }
        .fav-left { display:flex; align-items:center; gap:1.2rem; flex:1; }
        .fav-icon { width:44px; height:44px; background:var(--bone); border:1px solid var(--border); border-radius:10px; display:flex; align-items:center; justify-content:center; font-size:1rem; color:var(--clay); flex-shrink:0; }
        .fav-info h4 { font-family:'DM Serif Display',serif; font-size:1.05rem; color:var(--charcoal); margin-bottom:3px; }
        .fav-info p  { font-size:0.75rem; font-weight:300; }
        .fav-actions { display:flex; gap:0.8rem; flex-shrink:0; }
        .btn-view { padding:8px 18px; border:1px solid var(--border); border-radius:30px; font-family:'Inter',sans-serif; font-size:0.75rem; font-weight:600; text-transform:uppercase; letter-spacing:1px; color:var(--clay); text-decoration:none; transition:var(--transition); }
        .btn-view:hover { background:var(--clay); color:#fff; border-color:var(--clay); }
        .btn-remove { padding:8px 14px; background:none; border:1px solid var(--border); border-radius:30px; font-family:'Inter',sans-serif; font-size:0.75rem; font-weight:600; text-transform:uppercase; letter-spacing:1px; color:#c62828; cursor:pointer; transition:var(--transition); }
        .btn-remove:hover { background:#ffebee; border-color:#c62828; }
        .btn-browse { display:inline-block; padding:11px 24px; background:var(--clay); color:#fff; border-radius:30px; font-family:'Inter',sans-serif; font-size:0.78rem; font-weight:600; text-transform:uppercase; letter-spacing:1px; text-decoration:none; transition:var(--transition); }
        .btn-browse:hover { background:#8a3e1e; transform:translateY(-1px); }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }
%>

<nav class="navbar">
    <a href="dashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef.</a>
    <div class="nav-links">
        <a href="dashboard.jsp">Overview</a>
        <a href="viewIngredients.jsp">Inventory</a>
        <a href="recipes.jsp">Recipes</a>
        <a href="favourites.jsp" class="active">Saved</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container-md">
    <span class="pg-label">Saved</span>
    <h1 class="pg-title" style="margin-bottom:3rem;">Your Favourites.</h1>

<%
    Connection conn = null;
    boolean any = false;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");
        PreparedStatement ps = conn.prepareStatement(
            "SELECT r.id,r.name,r.cuisine,r.meal_type,r.total_steps FROM recipes r " +
            "JOIN favourites f ON r.id=f.recipe_id WHERE f.username=? ORDER BY f.saved_at DESC");
        ps.setString(1, username); ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            any = true;
            int    rId    = rs.getInt("id");
            String rName  = rs.getString("name");
            String rCuis  = rs.getString("cuisine")   != null ? rs.getString("cuisine")   : "";
            String rMeal  = rs.getString("meal_type") != null ? rs.getString("meal_type") : "";
            int    rSteps = rs.getInt("total_steps");
%>
    <div class="glass-card fav-card">
        <div class="fav-left">
            <div class="fav-icon"><i class="fas fa-fire-burner"></i></div>
            <div class="fav-info">
                <h4><%= rName %></h4>
                <p>
                    <% if(!rCuis.isEmpty()){%><i class="fas fa-earth-americas"></i> <%= rCuis %> &nbsp;&middot;&nbsp;<% } %>
                    <% if(!rMeal.isEmpty()){%><i class="fas fa-clock"></i> <%= rMeal %> &nbsp;&middot;&nbsp;<% } %>
                    <i class="fas fa-list-ol"></i> <%= rSteps %> steps
                </p>
            </div>
        </div>
        <div class="fav-actions">
            <a href="recipeDetail.jsp?id=<%= rId %>" class="btn-view">View</a>
            <form action="FavouriteServlet" method="post" style="margin:0;">
                <input type="hidden" name="recipeId" value="<%= rId %>">
                <input type="hidden" name="action"   value="remove">
                <input type="hidden" name="from"     value="favourites">
                <button type="submit" class="btn-remove" onclick="return confirm('Remove from favourites?')">
                    <i class="fas fa-trash-can"></i>
                </button>
            </form>
        </div>
    </div>
<%  }
    rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); }
    finally { if(conn!=null) try{conn.close();}catch(Exception ex){} }

    if (!any) { %>
    <div class="empty-state" style="opacity:0.5; padding:5rem;">
        <i class="fas fa-heart-crack" style="font-size:2.5rem;"></i>
        <p style="margin-bottom:2rem;">You haven't saved any recipes yet.</p>
        <a href="recipes.jsp" class="btn-browse">Browse Recipes</a>
    </div>
<% } else { %>
    <div style="text-align:center; margin-top:2.5rem;">
        <a href="recipes.jsp" style="font-size:0.78rem; text-transform:uppercase; letter-spacing:1px; font-weight:700; color:var(--clay); text-decoration:none;">
            Explore More Recipes <i class="fas fa-arrow-right"></i>
        </a>
    </div>
<% } %>
</div>
</body>
</html>
