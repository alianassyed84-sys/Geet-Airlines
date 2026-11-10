<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>Register | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body>
<div class="auth-shell">
  <div class="auth-card">
    <a class="auth-brand" href="login.jsp" aria-label="Geet Airlines home">
      <svg viewBox="0 0 64 48" aria-hidden="true"><path d="M4 31 55 2 35 42 27 29 4 31Z"/><path d="m27 29 14 5 14-32"/></svg>
      <span>GEET AIRLINES</span>
    </a>
    <h1 class="auth-title">Create Account</h1>
    <% String err = (String) session.getAttribute("error");
       if (err != null && !err.isEmpty()) { session.removeAttribute("error"); %>
    <p class="auth-notice"><%= err %></p>
    <% } %>
    <form action="register" method="post">
      <div class="form-row">
        <div class="form-field">
          <label for="firstname">Full name</label>
          <input type="text" id="firstname" name="firstname" required placeholder="Gursangeet Singh">
        </div>
        <div class="form-field">
          <label for="email">Email</label>
          <input type="email" id="email" name="email" required placeholder="you@example.com">
        </div>
        <div class="form-field">
          <label for="address">Address</label>
          <textarea id="address" name="address" placeholder="Your address (optional)"></textarea>
        </div>
        <div class="form-field">
          <label for="password">Password</label>
          <input type="password" id="password" name="password" required minlength="8" placeholder="At least 8 characters">
        </div>
        <div class="form-field">
          <label for="retype">Retype password</label>
          <input type="password" id="retype" required placeholder="Repeat password">
        </div>
        <div class="form-field">
          <label for="phone">Phone</label>
          <input type="text" id="phone" name="phone" required placeholder="+91 00000 00000">
        </div>
        <div class="form-field">
          <label>Gender</label>
          <div class="radio-group">
            <label><input type="radio" name="gender" value="M" required> Male</label>
            <label><input type="radio" name="gender" value="F"> Female</label>
            <label><input type="radio" name="gender" value="O"> Other</label>
          </div>
        </div>
      </div>
      <button class="geet-btn" type="submit">Create Account</button>
    </form>
    <p class="auth-link"><a href="login.jsp">Already have an account? Sign in →</a></p>
  </div>
</div>
</body>
</html>
