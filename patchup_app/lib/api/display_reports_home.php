<?php
// --- Include Database Connection ---
require_once("../database/db_connection.php");

// --- Set JSON Response Header ---
header('Content-Type: application/json');

// --- Prepare SQL Query to Fetch Latest 5 Pothole Reports with User Names ---
$sql = "SELECT p.*, u.Name AS UserName
        FROM potholereport p
        LEFT JOIN user u ON p.UserID = u.UserID
        ORDER BY p.ReportID DESC
        LIMIT 5";
$result = $conn->query($sql);

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
