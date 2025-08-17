<?php
// Set response type to JSON and include database connection
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse input and extract email
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

// Validate email input, return 0 points if missing
if (!$email) {
    echo json_encode(["points" => 0]);
    exit;
}

// Query to fetch user points by email
$stmt = $conn->prepare("SELECT Points FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($points);

// Output points if user found, otherwise return 0
if ($stmt->fetch()) {
    echo json_encode(["points" => intval($points)]);
} else {
    echo json_encode(["points" => 0]);
}

// Close statement and database connection
$stmt->close();
$conn->close();
