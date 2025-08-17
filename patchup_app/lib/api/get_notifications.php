<?php
// Set response type to JSON and include database connection
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse input and extract email
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

// Validate email input
if (!$email) {
    echo json_encode(["success" => false, "notifications" => [], "message" => "Missing email"]);
    exit;
}

// Retrieve UserID using email
$stmt = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($userID);
if (!$stmt->fetch()) {
    echo json_encode(["success" => false, "notifications" => [], "message" => "User not found"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Fetch notifications for the user
$stmt = $conn->prepare("SELECT NotificationID, Title, Body, DataJSON, IsRead, CreatedAt, ReadAt FROM notification WHERE UserID = ? ORDER BY CreatedAt DESC");
$stmt->bind_param("i", $userID);
$stmt->execute();
$result = $stmt->get_result();

// Collect notifications into array and decode DataJSON
$notifications = [];
while ($row = $result->fetch_assoc()) {
    $row['DataJSON'] = $row['DataJSON'] ? json_decode($row['DataJSON'], true) : null;
    $notifications[] = $row;
}

// Output notifications as JSON
echo json_encode(["success" => true, "notifications" => $notifications]);

// Close statement and database connection
$stmt->close();
$conn->close();
