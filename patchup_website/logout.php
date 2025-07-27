<?php
// --- Start Session and Clear All Session Data ---
session_start();
$_SESSION = [];
session_unset();
session_destroy();

// --- Redirect to Login Page After Logout ---
header("Location: login.php");
exit;
