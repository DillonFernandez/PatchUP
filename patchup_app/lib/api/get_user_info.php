<?php
// Set response type to JSON and include database connection
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse input and extract email
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

// Validate email input, return empty values if missing
if (!$email) {
    echo json_encode(["name" => "", "email" => ""]);
    exit;
}

// Query to fetch user name and email by email
$stmt = $conn->prepare("SELECT Name, Email FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($name, $emailResult);

// Output user info if found, otherwise return empty values
if ($stmt->fetch()) {
    echo json_encode(["name" => $name, "email" => $emailResult]);
} else {
    echo json_encode(["name" => "", "email" => ""]);
}

// Close statement and database connection
$stmt->close();
$conn->close();
