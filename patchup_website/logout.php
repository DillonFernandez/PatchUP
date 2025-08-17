<?php
// Section: Session Start and Clear Session Data
session_start();
$_SESSION = [];
session_unset();
session_destroy();

// Section: Redirect to Login Page
header("Location: login.php");
exit;
