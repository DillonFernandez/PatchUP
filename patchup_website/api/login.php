<?php
// Set response type to JSON
header('Content-Type: application/json');

// Include database connection
require_once("../database/db_connection.php");

// Get and sanitize POST input
$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

// Check for missing required fields
if (!$name || !$email || !$password) {
    echo json_encode(['success' => false, 'message' => 'All fields are required.']);
    exit;
}

// Query admin table for matching user
$stmt = $conn->prepare("SELECT * FROM admin WHERE Name=? AND Email=?");
$stmt->bind_param("ss", $name, $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

// Validate credentials and start session if successful
if ($user && $user['PasswordHash'] === $password) {
    session_start();
    session_regenerate_id(true);
    $_SESSION['admin_logged_in'] = true;
    $_SESSION['admin_name'] = $user['Name'];
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid credentials.']);
}

// Clean up statement and database connection
$stmt->close();
$conn->close();
