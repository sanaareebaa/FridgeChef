<%-- 
    Document   : Register
    Created on : 6 Mar 2026, 1:39:51 am
    Author     : acer
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register — FridgeChef</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        :root { --clay:#a64d26; --bone:#faf7f2; --charcoal:#1c1917; --taupe:#717171; --border:#e0dbd5; }
        * { margin:0; padding:0; box-sizing:border-box; -webkit-font-smoothing:antialiased; }
        body {
            font-family:'Inter',sans-serif; background:var(--bone);
            min-height:100vh; display:flex; align-items:center; justify-content:center;
            overflow:auto;
        }
        .wrapper { width:100%; max-width:460px; padding:2rem; text-align:center; }
        .brand { font-family:'DM Serif Display',serif; font-size:2.4rem; color:var(--clay); margin-bottom:4px; }
        .brand-sub { font-size:0.85rem; color:var(--taupe); margin-bottom:1.8rem; }
        .card { background:#fff; border-radius:16px; padding:2.4rem; box-shadow:0 4px 24px rgba(0,0,0,0.07); }
        .card h2 { font-family:'DM Serif Display',serif; font-size:1.5rem; color:var(--charcoal); margin-bottom:4px; text-align:left; }
        .card .sub { font-size:0.82rem; color:var(--taupe); margin-bottom:1.8rem; text-align:left; }
        .fg { margin-bottom:1.1rem; text-align:left; }
        .fg label { display:block; font-size:0.72rem; font-weight:600; text-transform:uppercase; letter-spacing:1px; color:var(--taupe); margin-bottom:0.5rem; }
        .fg input {
            width:100%; padding:11px 14px; border:1.5px solid var(--border); border-radius:8px;
            font-size:0.9rem; background:#faf9f7; outline:none; transition:border 0.2s;
            font-family:'Inter',sans-serif; color:var(--charcoal);
        }
        .fg input:focus { border-color:var(--clay); }
        .btn-submit {
            width:100%; padding:13px; background:var(--clay); color:#fff; border:none;
            border-radius:10px; font-size:0.9rem; font-weight:700; cursor:pointer;
            margin-top:0.5rem; transition:background 0.2s; font-family:'Inter',sans-serif;
            letter-spacing:0.5px;
        }
        .btn-submit:hover { background:#8a3e1e; }
        .link-row { margin-top:1.2rem; font-size:0.82rem; color:var(--taupe); }
        .link-row a { color:var(--clay); font-weight:600; text-decoration:none; }
        .link-row a:hover { text-decoration:underline; }
        .alert { padding:10px 14px; border-radius:8px; font-size:0.82rem; margin-bottom:1.2rem; display:flex; align-items:center; gap:8px; text-align:left; }
        .alert-err { background:#ffebee; border:1px solid #ffcdd2; color:#c62828; }
        .fridge-img { margin-top:1.6rem; border-radius:14px; overflow:hidden; box-shadow:0 4px 16px rgba(0,0,0,0.07); }
        .fridge-img img { width:100%; display:block; }
        .pw-hint { font-size:0.72rem; color:var(--taupe); margin-top:0.3rem; opacity:0.7; }
    </style>
</head>
<body>
<div class="wrapper">
    <div class="brand">FridgeChef.</div>
    <p class="brand-sub">Manage your fridge. Discover recipes. Reduce waste.</p>

    <div class="card">
        <h2>Create an account</h2>
        <p class="sub">Join FridgeChef to track your ingredients and discover new recipes.</p>

        <% String err = request.getParameter("error"); %>
        <% if (err != null) { %>
        <div class="alert alert-err"><i style="flex-shrink:0;" class="fas fa-circle-exclamation"></i> <%= err %></div>
        <% } %>

        <form action="RegisterServlet" method="post">
            <div class="fg">
                <label>Username</label>
                <input type="text" name="username" placeholder="Choose a username" required
                       minlength="3" maxlength="30" autocomplete="username">
            </div>
            <div class="fg">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="you@example.com" required
                       autocomplete="email">
            </div>
            <div class="fg">
                <label>Password</label>
                <input type="password" name="password" placeholder="Create a password" required
                       minlength="6" autocomplete="new-password">
                <p class="pw-hint">At least 6 characters.</p>
            </div>
            <button type="submit" class="btn-submit">Create Account</button>
        </form>

        <p class="link-row">Already have an account? <a href="login.jsp">Sign in</a></p>

        <div class="fridge-img">
            <img src="loginpagefridge.png" alt="FridgeChef Kitchen">
        </div>
    </div>
</div>
</body>
</html>
