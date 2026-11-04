<?php
require_once __DIR__ . '/includes/auth.php';
header('Location: ' . app_url(current_user() ? 'pages/dashboard.php' : 'auth/login.php'));
exit;
