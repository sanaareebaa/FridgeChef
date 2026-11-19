<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .btn-act { font-size:0.72rem; text-transform:uppercase; letter-spacing:1px; font-weight:700; text-decoration:none; transition:var(--transition); display:inline-flex; align-items:center; gap:5px; }
        .btn-act-edit   { color:var(--clay); }
        .btn-act-edit:hover { opacity:0.7; }
        .btn-act-delete { color:#c62828; background:none; border:none; cursor:pointer; font-family:'Inter',sans-serif; font-size:0.72rem; text-transform:uppercase; letter-spacing:1px; font-weight:700; padding:0; }
        .btn-act-delete:hover { opacity:0.7; }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username  = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }
    String search     = request.getParameter("search");   if (search    == null) search    = "";
    String catFilter  = request.getParameter("category"); if (catFilter == null) catFilter = "";
    String statFilter = request.getParameter("status");   if (statFilter== null) statFilter= "";
%>

<nav class="navbar">
    <a href="dashboard.jsp" class="nav-brand"><i class="fas fa-utensils"></i> FridgeChef.</a>
    <div class="nav-links">
        <a href="dashboard.jsp">Overview</a>
        <a href="viewIngredients.jsp" class="active">Inventory</a>
        <a href="recipes.jsp">Recipes</a>
        <a href="favourites.jsp">Saved</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container">
    <div class="top-bar">
        <div>
            <span class="pg-label">Inventory</span>
            <h1 class="pg-title">My Fridge.</h1>
        </div>
        <a href="addIngredient.jsp" class="btn-primary"><i class="fas fa-plus"></i> Add Item</a>
    </div>

    <%
        String msg = request.getParameter("msg");
        if ("deleted".equals(msg)) {
    %><div class="alert alert-ok"><i class="fas fa-circle-check"></i> Item removed from your fridge.</div><%
        } else if ("updated".equals(msg)) {
    %><div class="alert alert-ok"><i class="fas fa-circle-check"></i> Item updated successfully.</div><%
        }
    %>

    <!-- Filter Bar -->
    <div class="filter-bar">
        <form action="viewIngredients.jsp" method="get">
            <div class="search-wrap">
                <i class="fas fa-magnifying-glass"></i>
                <input type="text" name="search" placeholder="Search ingredients…" value="<%= search %>">
            </div>
            <select name="category" class="filter-select">
                <option value="">All Categories</option>
                <option <%= "Dairy".equals(catFilter)?"selected":"" %>>Dairy</option>
                <option <%= "Vegetables".equals(catFilter)?"selected":"" %>>Vegetables</option>
                <option <%= "Fruits".equals(catFilter)?"selected":"" %>>Fruits</option>
                <option value="Meat & Seafood" <%= "Meat & Seafood".equals(catFilter)?"selected":"" %>>Meat &amp; Seafood</option>
                <option value="Grains & Bread" <%= "Grains & Bread".equals(catFilter)?"selected":"" %>>Grains &amp; Bread</option>
                <option <%= "Condiments".equals(catFilter)?"selected":"" %>>Condiments</option>
                <option <%= "Beverages".equals(catFilter)?"selected":"" %>>Beverages</option>
                <option <%= "Others".equals(catFilter)?"selected":"" %>>Others</option>
            </select>
            <select name="status" class="filter-select">
                <option value="">All Status</option>
                <option value="fresh"   <%= "fresh".equals(statFilter)?"selected":"" %>>Fresh</option>
                <option value="soon"    <%= "soon".equals(statFilter)?"selected":"" %>>Expiring Soon</option>
                <option value="expired" <%= "expired".equals(statFilter)?"selected":"" %>>Expired</option>
            </select>
            <button type="submit" class="btn-filter"><i class="fas fa-sliders"></i> Filter</button>
            <a href="viewIngredients.jsp" class="btn-clear">Clear</a>
        </form>
    </div>

    <div class="sec-title sec-title-top">
        All Items
        <a href="addIngredient.jsp" class="btn-text">+ Add New &rarr;</a>
    </div>

    <div class="glass-card table-container">
        <table>
            <thead>
                <tr><th>#</th><th>Ingredient</th><th>Category</th><th>Quantity</th><th>Expiry</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
<%
    Connection conn = null;
    int rowCount = 0;
    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        java.util.Calendar cal = java.util.Calendar.getInstance();
        java.sql.Date today    = new java.sql.Date(cal.getTimeInMillis());
        cal.add(java.util.Calendar.DAY_OF_MONTH, 3);
        java.sql.Date threeDaysLater = new java.sql.Date(cal.getTimeInMillis());

        StringBuilder sql = new StringBuilder(
            "SELECT id,name,quantity,unit,category,expiry_date FROM ingredients WHERE username=?");
        if (!search.isEmpty())    sql.append(" AND LOWER(name) LIKE LOWER(?)");
        if (!catFilter.isEmpty()) sql.append(" AND category=?");
        if ("fresh".equals(statFilter))   sql.append(" AND expiry_date > ?");
        else if ("soon".equals(statFilter))    sql.append(" AND expiry_date >= ? AND expiry_date <= ?");
        else if ("expired".equals(statFilter)) sql.append(" AND expiry_date < ?");
        sql.append(" ORDER BY name");

        PreparedStatement ps = conn.prepareStatement(sql.toString());
        int idx = 1;
        ps.setString(idx++, username);
        if (!search.isEmpty())    ps.setString(idx++, "%" + search + "%");
        if (!catFilter.isEmpty()) ps.setString(idx++, catFilter);
        if ("fresh".equals(statFilter))        ps.setDate(idx++, threeDaysLater);
        else if ("soon".equals(statFilter))  { ps.setDate(idx++, today); ps.setDate(idx++, threeDaysLater); }
        else if ("expired".equals(statFilter)) ps.setDate(idx++, today);

        ResultSet rs = ps.executeQuery();
        int counter = 1;
        while (rs.next()) {
            rowCount++;
            int    iId   = rs.getInt("id");
            String iName = rs.getString("name");
            String iQty  = rs.getString("quantity");
            String iUnit = rs.getString("unit");
            String iCat  = rs.getString("category");
            java.sql.Date iExp = rs.getDate("expiry_date");

            String bClass = "b-nodate", bLabel = "No Date";
            if (iExp != null) {
                long diff = iExp.getTime() - System.currentTimeMillis();
                long threeDays = 3L*24*60*60*1000;
                if (diff < 0)            { bClass="b-exp";   bLabel="Expired"; }
                else if(diff<=threeDays) { bClass="b-soon";  bLabel="Expiring Soon"; }
                else                     { bClass="b-fresh"; bLabel="Fresh"; }
            }
%>
                <tr>
                    <td style="opacity:.35; font-size:.78rem;"><%= String.format("%02d", counter++) %></td>
                    <td><strong><%= iName %></strong></td>
                    <td><span class="badge b-cat"><%= iCat != null ? iCat : "—" %></span></td>
                    <td><%= iQty %> <%= iUnit != null ? iUnit : "" %></td>
                    <td style="font-size:.82rem;"><%= iExp != null ? iExp.toString() : "—" %></td>
                    <td><span class="badge <%= bClass %>"><%= bLabel %></span></td>
                    <td>
                        <div class="action-cell">
                            <a href="editIngredient.jsp?id=<%= iId %>" class="btn-act btn-act-edit">
                                <i class="fas fa-pen-to-square"></i> Edit
                            </a>
                            <a href="DeleteIngredientServlet?id=<%= iId %>"
                               class="btn-act btn-act-delete"
                               onclick="return confirm('Remove <%= iName %> from your fridge?')">
                               <i class="fas fa-trash-can"></i> Delete
                            </a>
                        </div>
                    </td>
                </tr>
<%      }
        rs.close(); ps.close();
        if (rowCount == 0) { %>
                <tr><td colspan="7">
                    <div class="empty-state">
                        <i class="fas fa-box-open"></i>
                        <p>No items found. <a href="addIngredient.jsp" style="color:var(--clay); font-weight:600;">Add your first item →</a></p>
                    </div>
                </td></tr>
<%      }
    } catch (Exception e) { e.printStackTrace(); }
    finally { if (conn!=null) try { conn.close(); } catch (Exception ex) {} }
%>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>
