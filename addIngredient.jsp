<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Item | FridgeChef</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/fridgechef.css">
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
        <a href="viewIngredients.jsp" class="active">Inventory</a>
        <a href="recipes.jsp">Recipes</a>
        <a href="favourites.jsp">Saved</a>
        <a href="logout.jsp" class="btn-logout">Sign Out</a>
    </div>
</nav>

<div class="container-sm">
    <a href="viewIngredients.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Inventory</a>

    <span class="pg-label">Inventory</span>
    <h1 class="pg-title-sm">Add New Item.</h1>

    <% String msg = request.getParameter("msg"); %>
    <% if ("added".equals(msg)) { %><div class="alert alert-ok"><i class="fas fa-circle-check"></i> Ingredient added successfully!</div><% } %>
    <% String err = request.getParameter("error"); %>
    <% if (err != null) { %><div class="alert alert-err"><i class="fas fa-circle-exclamation"></i> <%= err %></div><% } %>

    <div class="glass-card">
        <div class="card-body">
            <form action="AddIngredientServlet" method="post">
                <div class="fg">
                    <label>Ingredient Name</label>
                    <div class="input-wrap">
                        <i class="fas fa-carrot ic"></i>
                        <input type="text" name="name" placeholder="e.g. Tomato, Chicken, Milk…" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="fg">
                        <label>Quantity</label>
                        <div class="input-wrap">
                            <i class="fas fa-scale-balanced ic"></i>
                            <input type="number" name="quantity" placeholder="e.g. 500" min="0" step="0.01" required>
                        </div>
                    </div>
                    <div class="fg">
                        <label>Unit</label>
                        <div class="input-wrap">
                            <i class="fas fa-ruler ic"></i>
                            <select name="unit">
                                <option value="g">g — grams</option>
                                <option value="kg">kg</option>
                                <option value="ml">ml</option>
                                <option value="L">L — litres</option>
                                <option value="pcs">pcs — pieces</option>
                                <option value="cups">cups</option>
                                <option value="tbsp">tbsp</option>
                                <option value="tsp">tsp</option>
                                <option value="cloves">cloves</option>
                                <option value="slices">slices</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="fg">
                        <label>Category</label>
                        <div class="input-wrap">
                            <i class="fas fa-tag ic"></i>
                            <select name="category" required>
                                <option value="">— Select —</option>
                                <option>Dairy</option>
                                <option>Vegetables</option>
                                <option>Fruits</option>
                                <option>Meat &amp; Seafood</option>
                                <option>Grains &amp; Bread</option>
                                <option>Condiments</option>
                                <option>Beverages</option>
                                <option>Frozen</option>
                                <option>Snacks</option>
                                <option>Others</option>
                            </select>
                        </div>
                    </div>
                    <div class="fg">
                        <label>Expiry Date</label>
                        <div class="input-wrap">
                            <i class="fas fa-calendar-days ic"></i>
                            <input type="date" name="expiryDate" style="padding-left:38px;">
                        </div>
                        <p class="hint">Leave blank if no expiry date.</p>
                    </div>
                </div>
                <div class="btn-row">
                    <button type="submit" class="btn-primary-lg"><i class="fas fa-plus"></i> &nbsp;Add to Fridge</button>
                    <a href="viewIngredients.jsp" class="btn-ghost-lg">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
