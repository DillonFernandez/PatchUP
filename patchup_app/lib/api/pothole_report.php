<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connection
require_once("../database/db_connection.php");

// Extract POST data for report fields
$zip = $_POST['ZipCode'] ?? '';
$lat = $_POST['Latitude'] ?? '';
$lng = $_POST['Longitude'] ?? '';
$desc = $_POST['Description'] ?? '';
$severity = $_POST['SeverityLevel'] ?? '';
$userEmail = $_POST['UserEmail'] ?? '';

// Handle image upload and set image URL
$imageUrl = '';
if (isset($_FILES['Image']) && $_FILES['Image']['error'] == UPLOAD_ERR_OK) {
    $uploadDir = '../../uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    $filename = uniqid('img_') . '_' . basename($_FILES['Image']['name']);
    $targetFile = $uploadDir . $filename;
    if (move_uploaded_file($_FILES['Image']['tmp_name'], $targetFile)) {
        $imageUrl = '/patchup_app/uploads/' . $filename;
    }
}

// Log received POST data for debugging
file_put_contents("php://stderr", "Received: ZipCode=$zip, Latitude=$lat, Longitude=$lng, Description=$desc, SeverityLevel=$severity, UserEmail=$userEmail\n");

// Validate required fields and process report
if ($zip !== '' && $lat !== '' && $lng !== '' && $userEmail !== '') {
    // Lookup UserID from email address
    $stmtUser = $conn->prepare("SELECT UserID FROM user WHERE LOWER(Email) = LOWER(?)");
    if ($stmtUser === false) {
        file_put_contents("php://stderr", "User lookup prepare failed: " . $conn->error . "\n");
        die("User lookup prepare failed: " . $conn->error);
    }
    $stmtUser->bind_param("s", $userEmail);
    $stmtUser->execute();
    $stmtUser->bind_result($userId);
    if (!$stmtUser->fetch()) {
        $stmtUser->close();
        $conn->close();
        die("User not found");
    }
    $stmtUser->close();

    // Insert new pothole report into database
    $stmt = $conn->prepare("INSERT INTO potholereport (UserID, ZipCode, Latitude, Longitude, Description, SeverityLevel, ImageURL) VALUES (?, ?, ?, ?, ?, ?, ?)");
    if ($stmt === false) {
        file_put_contents("php://stderr", "Prepare failed: " . $conn->error . "\n");
        die("Prepare failed: " . $conn->error);
    }
    $stmt->bind_param("iiddsss", $userId, $zip, $lat, $lng, $desc, $severity, $imageUrl);
    if (!$stmt->execute()) {
        file_put_contents("php://stderr", "Execute failed: " . $stmt->error . "\n");
        die("Execute failed: " . $stmt->error);
    }
    $stmt->close();
}

// Close database connection
$conn->close();
