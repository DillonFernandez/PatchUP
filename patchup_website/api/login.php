<?php
// --- Set JSON Response Header ---
header('Content-Type: application/json');

// --- Database Connection ---
require_once("../database/db_connection.php");

// --- Retrieve and Sanitize Input ---
$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$password = $_POST['password'] ?? '';

// --- Validate Required Fields ---
if (!$name || !$email || !$password) {
    echo json_encode(['success' => false, 'message' => 'All fields are required.']);
    exit;
}

// --- Prepare and Execute SQL to Fetch Admin User ---
$stmt = $conn->prepare("SELECT * FROM admin WHERE Name=? AND Email=?");
$stmt->bind_param("ss", $name, $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

// --- Verify Credentials and Handle Login ---
if ($user && $user['PasswordHash'] === $password) {
    session_start();
    session_regenerate_id(true);
    $_SESSION['admin_logged_in'] = true;
    $_SESSION['admin_name'] = $user['Name'];
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid credentials.']);
}

// --- Close Statement and Database Connection ---
$stmt->close();
$conn->close();
