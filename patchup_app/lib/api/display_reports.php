<?php
// Database connection
require_once("../database/db_connection.php");

// Set response type to JSON
header('Content-Type: application/json');

// Parse input and extract user email if present
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;

// Build and execute SQL query based on user email presence
if ($userEmail) {
    $stmt = $conn->prepare(
        "SELECT p.*, u.Name AS UserName
         FROM potholereport p
         LEFT JOIN user u ON p.UserID = u.UserID
         WHERE u.Email = ?
         ORDER BY p.ReportID DESC"
    );
    $stmt->bind_param("s", $userEmail);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $sql = "SELECT p.*, u.Name AS UserName
            FROM potholereport p
            LEFT JOIN user u ON p.UserID = u.UserID
            ORDER BY p.ReportID DESC";
    $result = $conn->query($sql);
}

// Collect query results into array
$reports = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

// Output reports as JSON
echo json_encode($reports);

// Close database connection
$conn->close();
