<?php
session_start();

// --- Admin Session Authentication ---
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

// --- Database Connection ---
include 'database/db_connection.php';

// --- Get Total Number of Pothole Reports ---
$totalReports = $conn->query("SELECT COUNT(*) as total FROM potholereport")->fetch_assoc()['total'];

// --- Get Report Count Grouped by Status ---
$statusData = [];
$statusResult = $conn->query("SELECT Status, COUNT(*) as count FROM potholereport GROUP BY Status");
while ($row = $statusResult->fetch_assoc()) {
    $statusData[$row['Status']] = $row['count'];
}

// --- Get Report Count Grouped by Severity Level ---
$severityData = [];
$severityResult = $conn->query("SELECT SeverityLevel, COUNT(*) as count FROM potholereport GROUP BY SeverityLevel");
while ($row = $severityResult->fetch_assoc()) {
    $severityData[$row['SeverityLevel']] = $row['count'];
}

// --- Get Top 5 Users by Number of Reports Submitted ---
$topUsers = $conn->query("SELECT u.Name, COUNT(p.ReportID) as totalReports 
    FROM user u 
    JOIN potholereport p ON u.UserID = p.UserID 
    GROUP BY u.UserID 
    ORDER BY totalReports DESC LIMIT 5");

// --- Get 5 Most Recent Pothole Reports ---
$latestReports = $conn->query("SELECT p.ReportID, p.Description, p.Status, p.ImageURL, u.Name 
    FROM potholereport p 
    JOIN user u ON p.UserID = u.UserID 
    ORDER BY p.Timestamp DESC LIMIT 5");
