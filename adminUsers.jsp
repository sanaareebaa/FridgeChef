<%-- 
    Document   : adminUsers
    Created on : 27 Mar 2026, 11:36:56 pm
    Author     : acer
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Users | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .user-avatar {
            width:36px; height:36px; border-radius:50%;
            background:var(--bone); border:1px solid var(--border);
            display:flex; align-items:center; justify-content:center;
            font-size:0.82rem; font-weight:700; color:var(--clay); flex-shrink:0;
        }
        .user-cell { display:flex; align-items:center; gap:0.8rem; }
        .count-cell { white-space:nowrap; font-size:.84rem; color:var(--charcoal); display:flex; align-items:center; gap:4px; }
        .count-cell i { color:var(--clay); opacity:.6; }
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

    int totalUsers = 0, totalAllIngredients = 0, totalAllFavs = 0, totalRecipes = 0;
    String topRecipe = "None yet";
    String msg    = request.getParameter("msg");
    String errMsg = request.getParameter("error");

    Connection conn = null;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        ResultSet r;
        r = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE LOWER(username)<>'admin'").executeQuery();
        if (r.next()) totalUsers = r.getInt(1); r.close();

        r = conn.prepareStatement("SELECT COUNT(*) FROM ingredients").executeQuery();
        if (r.next()) totalAllIngredients = r.getInt(1); r.close();

        r = conn.prepareStatement("SELECT COUNT(*) FROM favourites").executeQuery();
        if (r.next()) totalAllFavs = r.getInt(1); r.close();

        r = conn.prepareStatement("SELECT COUNT(*) FROM recipes").executeQuery();
        if (r.next()) totalRecipes = r.getInt(1); r.close();

        try {
            PreparedStatement p = conn.prepareStatement(
                "SELECT r.name FROM recipes r JOIN favourites f ON r.id=f.recipe_id " +
                "GROUP BY r.name ORDER BY COUNT(*) DESC FETCH FIRST 1 ROWS ONLY");
            r = p.executeQuery();
            if (r.next()) topRecipe = r.getString(1);
            r.close(); p.close();
        } catch (Exception e) {}

    } catch (Exception e) { e.printStackTrace(); }
%>

<nav class="navbar">
    <a href="adminDashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef. <span class="nav-badge">Admin</span></a>
    <div class="nav-links">
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="adminRecipes.jsp">Recipes</a>
        <a href="adminUsers.jsp" class="active">Users</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container">
    <header class="header-group">
        <span class="pg-label">Admin — Users</span>
        <h1 class="pg-title">User Manager.</h1>
        <p class="pg-subtitle">View and manage registered user accounts.</p>
    </header>

    <% if (msg    != null) { %><div class="alert alert-ok" ><i class="fas fa-circle-check"></i> <%= msg %></div><% } %>
    <% if (errMsg != null) { %><div class="alert alert-err"><i class="fas fa-circle-exclamation"></i> <%= errMsg %></div><% } %>

    <!-- Summary stats -->
    <section class="stats" style="grid-template-columns:repeat(4,1fr); max-width:1000px; margin-bottom:4rem;">
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
            <span class="stat-num"><%= totalAllIngredients %></span>
            <span class="stat-lbl">Ingredients Tracked</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-heart"></i>
            <span class="stat-num"><%= totalAllFavs %></span>
            <span class="stat-lbl">Total Saves</span>
        </div>
    </section>

    <div class="sec-title sec-title-top">All Registered Users (<%= totalUsers %>)</div>
    <div class="glass-card table-container">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>User</th>
                    <th>Email</th>
                    <th>Ingredients</th>
                    <th>Saved Recipes</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
<%
    try {
        // Subquery per user — guarantees correct counts with no cross-join inflation
        PreparedStatement pu = conn.prepareStatement(
            "SELECT u.username, u.email, " +
            "(SELECT COUNT(*) FROM ingredients i WHERE i.username = u.username) AS ing_count, " +
            "(SELECT COUNT(*) FROM favourites  f WHERE f.username = u.username) AS fav_count " +
            "FROM users u " +
            "WHERE LOWER(u.username) <> 'admin' " +
            "ORDER BY u.username");
        ResultSet ru = pu.executeQuery();
        boolean anyU = false; int ucnt = 1;
        while (ru.next()) {
            anyU = true;
            String uName = ru.getString("username");
            String uMail = ru.getString("email");
            int    uIngs = ru.getInt("ing_count");
            int    uFavs = ru.getInt("fav_count");
            String init  = uName.substring(0,1).toUpperCase();
%>
                <tr>
                    <td style="opacity:.35;font-size:.78rem;"><%= String.format("%02d",ucnt++) %></td>
                    <td>
                        <div class="user-cell">
                            <div class="user-avatar"><%= init %></div>
                            <strong><%= uName %></strong>
                        </div>
                    </td>
                    <td style="font-size:.82rem;">
                        <% if (uMail != null && !uMail.isEmpty()) { %>
                            <a href="mailto:<%= uMail %>" style="color:var(--clay);text-decoration:none;"><%= uMail %></a>
                        <% } else { %>
                            <span style="opacity:.35;">—</span>
                        <% } %>
                    </td>
                    <td>
                        <span class="count-cell">
                            <i class="fas fa-box-archive"></i> <%= uIngs %> item<%= uIngs != 1 ? "s" : "" %>
                        </span>
                    </td>
                    <td>
                        <span class="count-cell saves-cell">
                            <i class="fas fa-heart"></i> <%= uFavs %> saved
                        </span>
                    </td>
                    <td>
                        <form action="AdminRecipeServlet" method="post" style="margin:0;"
                              onsubmit="return confirm('Delete user <%= uName %>? This removes ALL their data permanently.')">
                            <input type="hidden" name="action"   value="deleteUser">
                            <input type="hidden" name="userName" value="<%= uName %>">
                            <button type="submit" class="btn-del"><i class="fas fa-user-minus"></i> Remove</button>
                        </form>
                    </td>
                </tr>
<%
        }
        ru.close(); pu.close();
        if (!anyU) {
%>
            <tr><td colspan="6">
                <div class="empty-state">
                    <i class="fas fa-users"></i>
                    <p>No users registered yet.</p>
                </div>
            </td></tr>
<%      }
    } catch (Exception e) {
        out.print("<tr><td colspan='6' style='color:red;padding:1rem;'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
            </tbody>
        </table>
    </div>

    <!-- Insights -->
    <div class="sec-title">Platform Insights</div>
    <div class="insights-grid">
        <div class="glass-card stat-card">
            <i class="fas fa-trophy"></i>
            <span class="stat-num" style="font-size:1.1rem;word-break:break-word;"><%= topRecipe %></span>
            <span class="stat-lbl">Most Saved Recipe</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-chart-simple"></i>
            <span class="stat-num">
                <%= totalUsers > 0 ? String.format("%.1f", (double)totalAllIngredients / totalUsers) : "0" %>
            </span>
            <span class="stat-lbl">Avg Ingredients / User</span>
        </div>
    </div>
</div>

<% if (conn != null) try { conn.close(); } catch (Exception ex) {} %>
</body>
</html>
