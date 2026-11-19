<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
 .qa-grid {
     display: grid;
     grid-template-columns: repeat(3, 1fr);
     gap: 1.5rem;
 }

 .qa-card {
     padding: 2.5rem 2rem;
     text-decoration: none;
     display: block;
 }

 .qa-card:hover {
     background: var(--clay);
     border-color: var(--clay);
 }

 .qa-card:hover * {
     color: var(--white) !important;
 }

 .qa-card i {
     font-size: 1.4rem;
     color: var(--clay);
     margin-bottom: 1.5rem;
     display: block;
 }

 .qa-ttl {
     display: block;
     font-size: 1.1rem;
     font-weight: 600;
     color: var(--charcoal);
     margin-bottom: 0.5rem;
 }

 .qa-sub {
     font-size: 0.8rem;
     color: var(--taupe);
     font-weight: 300;
 }

 @media(max-width:900px) {
     .qa-grid {
         grid-template-columns: 1fr;
     }
 }

 </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    int totalItems = 0, expiringSoon = 0, expiredCount = 0, totalRecipes = 0;
    Connection conn = null;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        java.util.Calendar cal = java.util.Calendar.getInstance();
        java.sql.Date today = new java.sql.Date(cal.getTimeInMillis());
        cal.add(java.util.Calendar.DATE, 3);
        java.sql.Date threeDaysOut = new java.sql.Date(cal.getTimeInMillis());

        PreparedStatement ps1 = conn.prepareStatement(
            "SELECT COUNT(*) FROM ingredients WHERE username=?");
        ps1.setString(1, username);
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) totalItems = rs1.getInt(1); rs1.close(); ps1.close();

        PreparedStatement ps2 = conn.prepareStatement(
            "SELECT COUNT(*) FROM ingredients WHERE username=? " +
            "AND expiry_date IS NOT NULL AND expiry_date >= ? AND expiry_date <= ?");
        ps2.setString(1, username); ps2.setDate(2, today); ps2.setDate(3, threeDaysOut);
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) expiringSoon = rs2.getInt(1); rs2.close(); ps2.close();

        PreparedStatement ps3 = conn.prepareStatement(
            "SELECT COUNT(*) FROM ingredients WHERE username=? " +
            "AND expiry_date IS NOT NULL AND expiry_date < ?");
        ps3.setString(1, username); ps3.setDate(2, today);
        ResultSet rs3 = ps3.executeQuery();
        if (rs3.next()) expiredCount = rs3.getInt(1); rs3.close(); ps3.close();

        PreparedStatement ps4 = conn.prepareStatement("SELECT COUNT(*) FROM recipes");
        ResultSet rs4 = ps4.executeQuery();
        if (rs4.next()) totalRecipes = rs4.getInt(1); rs4.close(); ps4.close();

    } catch (Exception e) { e.printStackTrace(); }
%>

<nav class="navbar">
    <a href="dashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef.</a>
    <div class="nav-links">
        <a href="dashboard.jsp" class="active">Overview</a>
        <a href="viewIngredients.jsp">Inventory</a>
        <a href="recipes.jsp">Recipes</a>
        <a href="favourites.jsp">Saved</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container">
    <header class="header-group">
        <span class="pg-label">Kitchen Status</span>
        <h1 class="pg-title">Hello, <%= username %>.</h1>
        <p class="pg-subtitle">Your pantry is currently holding <strong><%= totalItems %> items</strong>. There are <strong><%= totalRecipes %> recipes</strong> available to explore.</p>
    </header>

    <section class="stats">
        <div class="glass-card stat-card">
            <i class="fas fa-box-archive"></i>
            <span class="stat-num"><%= totalItems %></span>
            <span class="stat-lbl">Total Stock</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-hourglass-start"></i>
            <span class="stat-num" style="<%= expiringSoon > 0 ? " " : "" %>"><%= expiringSoon %></span>
            <span class="stat-lbl">Expiring Soon</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-calendar-xmark"></i>
            <span class="stat-num" style="<%= expiredCount > 0 ? " " : "" %>"><%= expiredCount %></span>
            <span class="stat-lbl">Expired</span>
        </div>
        <div class="glass-card stat-card">
            <i class="fas fa-wand-magic-sparkles"></i>
            <span class="stat-num"><%= totalRecipes %></span>
            <span class="stat-lbl">Recipes Available</span>
        </div>
    </section>

    <h2 class="sec-title">Quick Actions</h2>
    <section class="qa-grid">
        <a href="addIngredient.jsp" class="glass-card qa-card">
            <i class="fas fa-plus"></i>
            <span class="qa-ttl">Add Item</span>
            <span class="qa-sub">Restock your inventory quickly.</span>
        </a>
        <a href="viewIngredients.jsp" class="glass-card qa-card">
            <i class="fas fa-list"></i>
            <span class="qa-ttl">View All</span>
            <span class="qa-sub">Manage your full digital fridge.</span>
        </a>
        <a href="recipes.jsp" class="glass-card qa-card">
            <i class="fas fa-plate-wheat"></i>
            <span class="qa-ttl">Cook Now</span>
            <span class="qa-sub">Recipes using current ingredients.</span>
        </a>
    </section>

    <div class="sec-title">
        Recent Arrivals
        <a href="viewIngredients.jsp" class="btn-text">View Everything &rarr;</a>
    </div>

    <div class="glass-card table-container">
        <table>
            <thead>
                <tr><th>Ingredient</th><th>Category</th><th>Status</th><th>Action</th></tr>
            </thead>
            <tbody>
            <%
                try {
                    java.util.Calendar cal2 = java.util.Calendar.getInstance();
                    java.sql.Date todayR = new java.sql.Date(cal2.getTimeInMillis());
                    cal2.add(java.util.Calendar.DATE, 3);
                    java.sql.Date soonR = new java.sql.Date(cal2.getTimeInMillis());

                    PreparedStatement psR = conn.prepareStatement(
                        "SELECT id, name, category, expiry_date FROM ingredients " +
                        "WHERE username=? ORDER BY added_date DESC FETCH FIRST 5 ROWS ONLY");
                    psR.setString(1, username);
                    ResultSet rsR = psR.executeQuery();
                    boolean anyRows = false;
                    while (rsR.next()) {
                        anyRows = true;
                        int    iId  = rsR.getInt("id");
                        String iName = rsR.getString("name");
                        String cat  = rsR.getString("category");
                        java.sql.Date exp = rsR.getDate("expiry_date");
                        String bClass = "b-fresh", bLab = "Fresh";
                        if (exp != null) {
                            if (exp.before(todayR))      { bClass="b-exp";  bLab="Expired"; }
                            else if (!exp.after(soonR))  { bClass="b-soon"; bLab="Expiring Soon"; }
                        }
            %>
                <tr>
                    <td><strong><%= iName %></strong></td>
                    <td><span class="badge b-cat"><%= cat != null ? cat : "—" %></span></td>
                    <td><span class="badge <%= bClass %>"><%= bLab %></span></td>
                    <td><a href="editIngredient.jsp?id=<%= iId %>" class="btn-text">Edit</a></td>
                </tr>
            <%  }
                if (!anyRows) { %>
                <tr><td colspan="4"><div class="empty-state" style="padding:2rem;">
                    <i class="fas fa-box-open"></i>
                    <p>No items yet. <a href="addIngredient.jsp" style="color:var(--clay); font-weight:600;">Add your first item →</a></p>
                </div></td></tr>
            <%  }
                rsR.close(); psR.close();
                } catch (Exception e) { e.printStackTrace(); }
                finally { if (conn != null) try { conn.close(); } catch (Exception ex) {} }
            %>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>

