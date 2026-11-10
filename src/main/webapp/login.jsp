<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>Sign In | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body>
<div class="auth-shell">
  <div class="auth-card">
    <a class="auth-brand" href="login.jsp" aria-label="Geet Airlines home">
      <svg viewBox="0 0 64 48" aria-hidden="true"><path d="M4 31 55 2 35 42 27 29 4 31Z"/><path d="m27 29 14 5 14-32"/></svg>
      <span>GEET AIRLINES</span>
    </a>
    <h1 class="auth-title">Sign In</h1>
    <% String err = (String) session.getAttribute("error");
       if (err != null && !err.isEmpty()) { session.removeAttribute("error"); %>
    <p class="auth-notice"><%= err %></p>
    <% } %>
    <form action="login" method="post">
      <div class="form-row">
        <div class="form-field">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" required placeholder="you@example.com">
        </div>
        <div class="form-field">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required placeholder="••••••••">
        </div>
      </div>
      <button class="geet-btn" type="submit">Sign In</button>
    </form>
    <p class="auth-link"><a href="register.jsp">Create a new account →</a></p>
  </div>
</div>
</body>
</html>
