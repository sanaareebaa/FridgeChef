<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Item | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
</head>
<body>
<div class="blob-cont"><div class="blob blob-1"></div><div class="blob blob-2"></div></div>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    String idParam = request.getParameter("id");
    String iName="", iQty="", iUnit="g", iCat="", iExpiry="";
    int iId = 0;

    if (idParam != null) {
        try {
            iId = Integer.parseInt(idParam);
            Class.forName("org.apache.derby.client.ClientAutoloadedDriver");
            Connection c = DriverManager.getConnection("jdbc:derby://localhost:1527/users","app","app");
            PreparedStatement ps = c.prepareStatement("SELECT * FROM ingredients WHERE id=? AND username=?");
            ps.setInt(1, iId); ps.setString(2, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                iName = rs.getString("name");
                iQty  = rs.getString("quantity");
                iUnit = rs.getString("unit") != null ? rs.getString("unit") : "g";
                iCat  = rs.getString("category") != null ? rs.getString("category") : "";
                java.sql.Date exp = rs.getDate("expiry_date");
                if (exp != null) iExpiry = exp.toString();
            }
            rs.close(); ps.close(); c.close();
        } catch (Exception e) { e.printStackTrace(); }
    }
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

<div class="container-sm">
    <a href="viewIngredients.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Inventory</a>
    <span class="pg-label">Inventory</span>
    <h1 class="pg-title-sm">Edit Item.</h1>

    <div class="glass-card">
        <div class="card-body">
            <form action="EditIngredientServlet" method="post">
                <input type="hidden" name="id" value="<%= iId %>">

                <div class="fg">
                    <label>Ingredient Name</label>
                    <div class="input-wrap">
                        <i class="fas fa-carrot ic"></i>
                        <input type="text" name="name" value="<%= iName %>" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="fg">
                        <label>Quantity</label>
                        <div class="input-wrap">
                            <i class="fas fa-scale-balanced ic"></i>
                            <input type="number" name="quantity" value="<%= iQty %>" min="0" step="0.01" required>
                        </div>
                    </div>
                    <div class="fg">
                        <label>Unit</label>
                        <div class="input-wrap">
                            <i class="fas fa-ruler ic"></i>
                            <select name="unit">
                                <% for (String u : new String[]{"g","kg","ml","L","pcs","cups","tbsp","tsp","cloves","slices"}) { %>
                                <option value="<%= u %>" <%= iUnit.equals(u)?"selected":"" %>><%= u %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="fg">
                        <label>Category</label>
                        <div class="input-wrap">
                            <i class="fas fa-tag ic"></i>
                            <select name="category">
                                <% for (String c : new String[]{"Dairy","Vegetables","Fruits","Meat & Seafood","Grains & Bread","Condiments","Beverages","Frozen","Snacks","Others"}) { %>
                                <option value="<%= c %>" <%= iCat.equals(c)?"selected":"" %>><%= c %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                    <div class="fg">
                        <label>Expiry Date</label>
                        <div class="input-wrap">
                            <i class="fas fa-calendar-days ic"></i>
                            <input type="date" name="expiryDate" value="<%= iExpiry %>" style="padding-left:38px;">
                        </div>
                        <p class="hint">Leave blank to clear expiry date.</p>
                    </div>
                </div>
                <div class="btn-row">
                    <button type="submit" class="btn-primary-lg"><i class="fas fa-floppy-disk"></i> &nbsp;Save Changes</button>
                    <a href="viewIngredients.jsp" class="btn-ghost-lg">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
