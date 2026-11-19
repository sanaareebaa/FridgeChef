<%-- 
    Document   : logout
    Created on : 11 Mar 2026, 12:13:35?am
    Author     : acer
--%>

<%
session.invalidate();
response.sendRedirect("login.jsp");
%>

