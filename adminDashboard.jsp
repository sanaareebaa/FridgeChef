<%-- 
    Document   : Admindashboard
    Created on : 27 Mar 2026, 11:35:10 pm
    Author     : acer
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .qa-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; }
        .qa-card { padding: 2.5rem 2rem; text-decoration: none; display: block; }
        .qa-card:hover { background: var(--clay); border-color: var(--clay); }
        .qa-card:hover * { color: var(--white) !important; }
        .qa-card i { font-size: 1.4rem; color: var(--clay); margin-bottom: 1.5rem; display: block; }
        .qa-ttl { display: block; font-size: 1.1rem; font-weight: 600; color: var(--charcoal); margin-bottom: 0.5rem; }
        .qa-sub { font-size: 0.8rem; color: var(--taupe); font-weight: 300; }
        @media(max-width:900px) { .qa-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null || !"admin".equalsIgnoreCase(username)) {
        response.sendRedirect("login.jsp"); return;
    }

    int totalUsers = 0, totalRecipes = 0, totalIngredients = 0, totalFavs = 0;
    String topRecipe = "None yet";
    Connection conn = null;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        ResultSet r;
        r = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE LOWER(username) <> 'admin'").executeQuery();
        if (r.next()) totalUsers = r.getInt(1); r.close();

        r = conn.prepareStatement("SELECT COUNT(*) FROM recipes").executeQuery();
        if (r.next()) totalRecipes = r.getInt(1); r.close();

        r = conn.prepareStatement("SELECT COUNT(*) FROM ingredients").executeQuery();
        if (r.next()) totalIngredients = r.getInt(1); r.close();

        r = conn.prepareStatement("SELECT COUNT(*) FROM favourites").executeQuery();
        if (r.next()) totalFavs = r.getInt(1); r.close();

        try {
            PreparedStatement p5 = conn.prepareStatement(
                "SELECT r.name FROM recipes r JOIN favourites f ON r.id=f.recipe_id " +
                "GROUP BY r.name ORDER BY COUNT(*) DESC FETCH FIRST 1 ROWS ONLY");
            r = p5.executeQuery();
            if (r.next()) topRecipe = r.getString(1);
            r.close(); p5.close();
        } catch (Exception e) {}
    } catch (Exception e) { e.printStackTrace(); }
    finally { if (conn != null) try { conn.close(); } catch (Exception ex) {} }
%>

<nav class="navbar">
    <a href="adminDashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef. <span class="nav-badge">Admin</span></a>
    <div class="nav-links">
        <a href="adminDashboard.jsp" class="active">Dashboard</a>
        <a href="adminRecipes.jsp">Recipes</a>
        <a href="adminUsers.jsp">Users</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container">
    <header class="header-group">
        <span class="pg-label">Admin Panel</span>
        <h1 class="pg-title">Control Centre.</h1>
        <p class="pg-subtitle">Platform overview and quick navigation.</p>
    </header>

    <!-- Stats -->
    <section class="stats">
        <div class="glass-card stat-card">
            <i class="fas fa-users"></i>
            <span class="stat-num"><%= totalUsers %></span>
            <span class="stat-lbl">Registered Users</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-plate-wheat"></i>
            <span class="stat-num"><%= totalRecipes %></span>
            <span class="stat-lbl">Total Recipes</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-box-archive"></i>
            <span class="stat-num"><%= totalIngredients %></span>
            <span class="stat-lbl">Ingredients Tracked</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-heart"></i>
            <span class="stat-num"><%= totalFavs %></span>
            <span class="stat-lbl">Saves / Favourites</span>
        </div>
    </section>

    <!-- Insights -->
    <div class="sec-title sec-title-top">Platform Insights</div>
    <div class="insights-grid" style="margin-bottom:4rem;">
        <div class="glass-card stat-card">
            <i class="fas fa-trophy"></i>
            <span class="stat-num" style="font-size:1.2rem; word-break:break-word;"><%= topRecipe %></span>
            <span class="stat-lbl">Most Saved Recipe</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-chart-simple"></i>
            <span class="stat-num"><%= totalUsers > 0 ? String.format("%.1f", (double)totalIngredients / totalUsers) : "0" %></span>
            <span class="stat-lbl">Avg Ingredients / User</span>
        </div>
    </div>

    <!-- Quick Nav -->
    <div class="sec-title">Quick Navigation</div>
    <div class="qa-grid">
        <a href="adminRecipes.jsp" class="glass-card qa-card">
            <i class="fas fa-plate-wheat"></i>
            <span class="qa-ttl">Manage Recipes</span>
            <span class="qa-sub">Add, edit, delete recipes and pin Recipe of the Week.</span>
        </a>
        <a href="adminUsers.jsp" class="glass-card qa-card">
            <i class="fas fa-users"></i>
            <span class="qa-ttl">Manage Users</span>
            <span class="qa-sub">View all registered users and manage accounts.</span>
        </a>
        <a href="recipes.jsp" class="glass-card qa-card">
            <i class="fas fa-eye"></i>
            <span class="qa-ttl">View as User</span>
            <span class="qa-sub">See the recipe browser exactly as users do.</span>
        </a>
    </div>
</div>
</body>
</html>
