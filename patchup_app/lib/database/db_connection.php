<?php
// --- Database Connection Configuration ---
$host = "localhost";
$user = "root";
$password = "";
$dbname = "patchup";

// --- Create Database Connection ---
$conn = new mysqli($host, $user, $password, $dbname);

// --- Check for Connection Errors ---
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
