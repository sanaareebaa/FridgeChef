<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recipes | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
    <style>
        .recipe-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:1.5rem; }
        .r-card { padding:2rem; display:flex; flex-direction:column; }
        .r-card:hover { transform:translateY(-5px); border-color:var(--clay); background:white; }
        .r-card.rotw-highlight { border-color:#f9a825; border-width:2px; }
        .r-top  { display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:1rem; }
        .r-name { font-family:'DM Serif Display',serif; font-size:1.2rem; color:var(--charcoal); line-height:1.3; }
        .miss-pill { font-size:0.6rem; font-weight:700; text-transform:uppercase; letter-spacing:1px; padding:4px 10px; border-radius:30px; white-space:nowrap; margin-left:8px; flex-shrink:0; }
        .pill-zero { background:#e8f5e9; color:#2e7d32; }
        .pill-few  { background:#fff3e0; color:#ef6c00; }
        .pill-many { background:#ffebee; color:#c62828; }
        .r-meta { display:flex; gap:6px; margin-bottom:1.2rem; flex-wrap:wrap; }
        .meta-chip { font-size:0.68rem; font-weight:500; color:var(--taupe); background:rgba(0,0,0,0.04); padding:3px 10px; border-radius:30px; }
        .needs-lbl { font-size:0.6rem; text-transform:uppercase; letter-spacing:2px; font-weight:600; color:var(--taupe); opacity:0.5; margin-bottom:0.6rem; }
        .ing-tags  { display:flex; flex-wrap:wrap; gap:5px; margin-bottom:0.8rem; }
        .ing-tag   { font-size:0.68rem; font-weight:600; padding:3px 10px; border-radius:30px; }
        .tag-have    { background:#e8f5e9; color:#2e7d32; }
        .tag-missing { background:#f5f5f5; color:#999; }
        .miss-text { font-size:0.78rem; color:var(--taupe); font-weight:300; flex:1; margin-bottom:1.2rem; }
        .miss-text strong { color:var(--charcoal); font-weight:600; }
        .r-footer { display:flex; justify-content:space-between; align-items:center; border-top:1px solid var(--border); padding-top:1rem; margin-top:auto; }
        .steps-lbl { font-size:0.68rem; text-transform:uppercase; letter-spacing:1px; opacity:0.45; }
        .view-link { font-size:0.75rem; text-transform:uppercase; letter-spacing:1px; font-weight:700; color:var(--clay); text-decoration:none; display:inline-flex; align-items:center; gap:6px; }
        .view-link:hover { opacity:0.7; }
        .fav-btn { background:none; border:none; cursor:pointer; color:var(--clay); font-size:0.88rem; padding:0; transition:var(--transition); }
        .fav-btn:hover { transform:scale(1.2); }
        .yt-mini { font-size:0.7rem; color:#c62828; font-weight:700; text-decoration:none; display:inline-flex; align-items:center; gap:4px; margin-top:4px; }
        .yt-mini:hover { opacity:0.75; }
        @media(max-width:900px) { .recipe-grid { grid-template-columns:1fr 1fr; } }
        @media(max-width:600px) { .recipe-grid { grid-template-columns:1fr; } }
    </style>
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    String filterCuisine  = request.getParameter("cuisine");
    String filterMealType = request.getParameter("mealType");
    if (filterCuisine  == null) filterCuisine  = "";
    if (filterMealType == null) filterMealType = "";

    List<String> fridgeItems = new ArrayList<>();
    Connection conn = null;
    String dbError = null;

    // ROTW info
    int    rotwId   = -1;
    String rotwName = null, rotwCuis = "", rotwMeal = "", rotwYt = "";

    try {
        Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
        conn = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");

        PreparedStatement pf = conn.prepareStatement("SELECT LOWER(name) FROM ingredients WHERE username=?");
        pf.setString(1, username); ResultSet rf = pf.executeQuery();
        while (rf.next()) fridgeItems.add(rf.getString(1)); rf.close(); pf.close();

        // Load ROTW
        try {
            PreparedStatement p6 = conn.prepareStatement(
                "SELECT r.id, r.name, r.cuisine, r.meal_type, r.youtube_url " +
                "FROM recipes r, admin_settings s " +
                "WHERE s.setting_key='rotw' AND CAST(r.id AS VARCHAR(20))=s.val");
            ResultSet r6 = p6.executeQuery();
            if (r6.next()) {
                rotwId   = r6.getInt("id");
                rotwName = r6.getString("name");
                rotwCuis = r6.getString("cuisine")    != null ? r6.getString("cuisine")    : "";
                rotwMeal = r6.getString("meal_type")  != null ? r6.getString("meal_type")  : "";
                rotwYt   = r6.getString("youtube_url")!= null ? r6.getString("youtube_url"): "";
            }
            r6.close(); p6.close();
        } catch (Exception e) {}

    } catch (Exception e) { dbError = e.getMessage(); e.printStackTrace(); }
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

<div class="container">
    <span class="pg-label">Recipe Assistant</span>
    <h1 class="pg-title" style="margin-bottom:2rem;">What Can You Cook?</h1>

    <% if (dbError != null) { %>
    <div class="alert alert-err"><i class="fas fa-circle-exclamation"></i> DB Error: <%= dbError %></div>
    <% } %>

  

    <!-- Filters -->
    <div class="filter-row">
        <form action="recipes.jsp" method="get">
            <select name="cuisine" class="filter-select">
                <option value="">All Cuisines</option>
                <%
                    if (conn != null) {
                        try {
                            PreparedStatement pc = conn.prepareStatement(
                                "SELECT DISTINCT cuisine FROM recipes WHERE cuisine IS NOT NULL ORDER BY cuisine");
                            ResultSet rc = pc.executeQuery();
                            while (rc.next()) {
                                String c = rc.getString(1);
                                out.print("<option value=\"" + c + "\" " + (c.equals(filterCuisine)?"selected":"") + ">" + c + "</option>");
                            }
                            rc.close(); pc.close();
                        } catch (Exception e) {}
                    }
                %>
            </select>
            <select name="mealType" class="filter-select">
                <option value="">All Meal Types</option>
                <%
                    if (conn != null) {
                        try {
                            PreparedStatement pm = conn.prepareStatement(
                                "SELECT DISTINCT meal_type FROM recipes WHERE meal_type IS NOT NULL ORDER BY meal_type");
                            ResultSet rm = pm.executeQuery();
                            while (rm.next()) {
                                String m = rm.getString(1);
                                out.print("<option value=\"" + m + "\" " + (m.equals(filterMealType)?"selected":"") + ">" + m + "</option>");
                            }
                            rm.close(); pm.close();
                        } catch (Exception e) {}
                    }
                %>
            </select>
            <button type="submit" class="btn-filter"><i class="fas fa-sliders"></i> Filter</button>
            <a href="recipes.jsp" class="btn-clear">Clear</a>
        </form>
    </div>

    <!-- Recipe Grid -->
    <div class="recipe-grid">
    <%
        if (conn == null) {
    %>
        <div class="empty-state" style="grid-column:1/-1;">
            <i class="fas fa-plug-circle-xmark"></i>
            <p>Could not connect to database. Make sure Derby is running.</p>
        </div>
    <%
        } else {
            try {
                StringBuilder sql = new StringBuilder(
                    "SELECT id,name,cuisine,meal_type,total_steps,youtube_url FROM recipes WHERE 1=1");
                if (!filterCuisine.isEmpty())  sql.append(" AND cuisine=?");
                if (!filterMealType.isEmpty()) sql.append(" AND meal_type=?");
                // Put ROTW first
                sql.append(" ORDER BY CASE WHEN id=").append(rotwId > 0 ? rotwId : -1).append(" THEN 0 ELSE 1 END, name");

                PreparedStatement pr = conn.prepareStatement(sql.toString());
                int idx = 1;
                if (!filterCuisine.isEmpty())  pr.setString(idx++, filterCuisine);
                if (!filterMealType.isEmpty()) pr.setString(idx,   filterMealType);

                ResultSet rr = pr.executeQuery();
                boolean any = false;

                while (rr.next()) {
                    any = true;
                    int    rId    = rr.getInt("id");
                    String rName  = rr.getString("name");
                    String rCuis  = rr.getString("cuisine")    != null ? rr.getString("cuisine")    : "";
                    String rMeal  = rr.getString("meal_type")  != null ? rr.getString("meal_type")  : "";
                    int    rSteps = rr.getInt("total_steps");
                    String rYt    = rr.getString("youtube_url")!= null ? rr.getString("youtube_url"): "";
                    boolean isRotwCard = (rId == rotwId);

                    PreparedStatement pi = conn.prepareStatement(
                        "SELECT ingredient_name FROM recipe_ingredients WHERE recipe_id=?");
                    pi.setInt(1, rId); ResultSet ri = pi.executeQuery();
                    List<String> have = new ArrayList<>(), miss = new ArrayList<>();
                    while (ri.next()) {
                        String ing = ri.getString(1); boolean found = false;
                        for (String f : fridgeItems) {
                            if (f.contains(ing.toLowerCase()) || ing.toLowerCase().contains(f)) { found=true; break; }
                        }
                        if (found) have.add(ing); else miss.add(ing);
                    }
                    ri.close(); pi.close();

                    boolean isFav = false;
                    PreparedStatement pf2 = conn.prepareStatement(
                        "SELECT id FROM favourites WHERE username=? AND recipe_id=?");
                    pf2.setString(1, username); pf2.setInt(2, rId);
                    ResultSet rf2 = pf2.executeQuery(); if (rf2.next()) isFav=true;
                    rf2.close(); pf2.close();

                    int mc = miss.size();
                    String pillClass = mc==0 ? "pill-zero" : (mc<=2 ? "pill-few" : "pill-many");
                    String pillLabel = mc==0 ? "Ready!" : mc + " missing";
    %>
        <div class="glass-card r-card <%= isRotwCard ? "rotw-highlight" : "" %>">
            <% if (isRotwCard) { %>
            <div style="margin-bottom:0.8rem;">
                <span class="badge b-gold"><i class="fas fa-star"></i> Week's Pick</span>
            </div>
            <% } %>
            <div class="r-top">
                <div class="r-name"><%= rName %></div>
                <span class="miss-pill <%= pillClass %>"><%= pillLabel %></span>
            </div>
            <div class="r-meta">
                <% if (!rCuis.isEmpty()) { %><span class="meta-chip"><i class="fas fa-earth-americas"></i> <%= rCuis %></span><% } %>
                <% if (!rMeal.isEmpty()) { %><span class="meta-chip"><i class="fas fa-clock"></i> <%= rMeal %></span><% } %>
            </div>
            <div class="needs-lbl">Needs</div>
            <div class="ing-tags">
                <% for (String h : have) { %><span class="ing-tag tag-have"><%= h %></span><% } %>
                <% for (String m : miss) { %><span class="ing-tag tag-missing"><%= m %></span><% } %>
            </div>
            <% if (mc == 0) { %>
                <p class="miss-text" style="color:#2e7d32;"><i class="fas fa-circle-check"></i> You have everything!</p>
            <% } else { %>
                <p class="miss-text">Missing: <strong><%
                    for (int mi=0; mi<miss.size(); mi++) {
                        out.print(miss.get(mi)); if (mi<miss.size()-1) out.print(", ");
                    }
                %></strong></p>
            <% } %>
            <% if (!rYt.isEmpty()) { %>
            <a href="<%= rYt %>" target="_blank" class="yt-mini" style="margin-bottom:0.8rem;">
                <i class="fab fa-youtube"></i> Watch on YouTube
            </a>
            <% } %>
            <div class="r-footer">
                <span class="steps-lbl"><i class="fas fa-list-ol"></i> <%= rSteps %> steps</span>
                <div style="display:flex;align-items:center;gap:1rem;">
                    <form action="FavouriteServlet" method="post" style="margin:0;">
                        <input type="hidden" name="recipeId" value="<%= rId %>">
                        <input type="hidden" name="action"   value="<%= isFav?"remove":"add" %>">
                        <input type="hidden" name="from"     value="recipes">
                        <button type="submit" class="fav-btn">
                            <i class="<%= isFav?"fas":"far" %> fa-heart"></i>
                        </button>
                    </form>
                    <a href="recipeDetail.jsp?id=<%= rId %>" class="view-link">View <i class="fas fa-arrow-right"></i></a>
                </div>
            </div>
        </div>
    <%
                }
                if (!any) {
    %>
        <div class="empty-state" style="grid-column:1/-1;">
            <i class="fas fa-plate-wheat"></i>
            <p>No recipes found. Try adjusting your filters.</p>
        </div>
    <%
                }
                rr.close(); pr.close();
            } catch (Exception e) {
                e.printStackTrace();
                out.print("<div class='alert alert-err' style='grid-column:1/-1;'>Recipe load error: " + e.getMessage() + "</div>");
            } finally {
                try { conn.close(); } catch (Exception ex) {}
            }
        }
    %>
    </div>
</div>
</body>
</html>
