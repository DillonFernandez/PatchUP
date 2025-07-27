<?php
// --- Include Database Connection ---
require_once("../database/db_connection.php");

// --- Decode Input JSON and Extract User Email if Provided ---
$input = json_decode(file_get_contents('php://input'), true);
$userEmail = isset($input['UserEmail']) ? $input['UserEmail'] : null;

// --- Prepare and Execute SQL Query Based on Presence of User Email ---
if ($userEmail) {
    $stmt = $conn->prepare(
        "SELECT p.Latitude, p.Longitude, p.SeverityLevel
         FROM potholereport p
         LEFT JOIN user u ON p.UserID = u.UserID
         WHERE u.Email = ? AND p.Latitude IS NOT NULL AND p.Longitude IS NOT NULL"
    );
    $stmt->bind_param("s", $userEmail);
    $stmt->execute();
    $result = $stmt->get_result();
} else {
    $result = $conn->query("SELECT Latitude, Longitude, SeverityLevel FROM potholereport WHERE Latitude IS NOT NULL AND Longitude IS NOT NULL");
}

// --- Collect Query Results into an Array for Heatmap ---
$reports = [];
while ($row = $result->fetch_assoc()) {
    $reports[] = [
        'latitude' => floatval($row['Latitude']),
        'longitude' => floatval($row['Longitude']),
        'severity' => $row['SeverityLevel'],
    ];
}

// --- Close Database Connection ---
$conn->close();

// --- Set Response Header and Output Heatmap Points as JSON ---
header('Content-Type: application/json');
echo json_encode($reports);
