<?php
// Set response type to JSON and include database connection
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// Parse input and extract email and notification ID
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';
$notificationID = $data["NotificationID"] ?? null;

// Validate email input
if (!$email) {
    echo json_encode(["success" => false, "message" => "Missing email"]);
    exit;
}

// Retrieve UserID using email
$stmt = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($userID);
if (!$stmt->fetch()) {
    echo json_encode(["success" => false, "message" => "User not found"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// Mark notification(s) as read based on presence of notification ID
if ($notificationID) {
    $stmt = $conn->prepare("UPDATE notification SET IsRead = 1, ReadAt = NOW() WHERE NotificationID = ? AND UserID = ?");
    $stmt->bind_param("ii", $notificationID, $userID);
} else {
    $stmt = $conn->prepare("UPDATE notification SET IsRead = 1, ReadAt = NOW() WHERE UserID = ? AND IsRead = 0");
    $stmt->bind_param("i", $userID);
}

// Execute update and respond with result
if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}

// Close statement and database connection
$stmt->close();
$conn->close();
