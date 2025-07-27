<?php
// --- Include Database Connection ---
require_once("../database/db_connection.php");

// --- Set JSON Response Header ---
header('Content-Type: application/json');

// --- Decode Input JSON and Extract User Email if Provided ---
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;

// --- Prepare and Execute SQL Query Based on Presence of User Email ---
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

// --- Collect Query Results into an Array ---
$reports = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
}

// --- Output Reports as JSON ---
echo json_encode($reports);

// --- Close Database Connection ---
$conn->close();
