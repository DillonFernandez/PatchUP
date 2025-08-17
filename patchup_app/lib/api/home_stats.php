<?php
// Set response type to JSON and include database connection
header("Content-Type: application/json");
require_once("../database/db_connection.php");

// Query total number of users
$totalUsers = 0;
$res = $conn->query("SELECT COUNT(*) AS cnt FROM user");
if ($res && $row = $res->fetch_assoc()) {
    $totalUsers = intval($row['cnt']);
}

// Query total reports and calculate average reports per day
$avgReportsPerDay = 0;
$res = $conn->query("SELECT COUNT(*) AS total, MIN(Timestamp) AS first, MAX(Timestamp) AS last FROM potholereport");
if ($res && $row = $res->fetch_assoc()) {
    $totalReports = intval($row['total']);
    $first = $row['first'];
    $last = $row['last'];
    if ($first && $last && $totalReports > 0) {
        $days = max(1, (strtotime($last) - strtotime($first)) / 86400 + 1);
        $avgReportsPerDay = round($totalReports / $days, 2);
    }
}

// Query number of potholes resolved
$potholesResolved = 0;
$res = $conn->query("SELECT COUNT(*) AS cnt FROM potholereport WHERE Status = 'Resolved'");
if ($res && $row = $res->fetch_assoc()) {
    $potholesResolved = intval($row['cnt']);
}

// Output statistics as JSON
echo json_encode([
    "total_users" => $totalUsers,
    "avg_reports_per_day" => $avgReportsPerDay,
    "potholes_resolved" => $potholesResolved
]);

// Close database connection
$conn->close();
