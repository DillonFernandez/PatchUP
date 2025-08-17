<?php
session_start();

// Check admin authentication
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}

// Connect to database
include 'database/db_connection.php';

// Fetch total pothole report count
$totalReports = $conn->query("SELECT COUNT(*) as total FROM potholereport")->fetch_assoc()['total'];

// Fetch report count grouped by status
$statusData = [];
$statusResult = $conn->query("SELECT Status, COUNT(*) as count FROM potholereport GROUP BY Status");
while ($row = $statusResult->fetch_assoc()) {
    $statusData[$row['Status']] = $row['count'];
}

// Fetch report count grouped by severity level
$severityData = [];
$severityResult = $conn->query("SELECT SeverityLevel, COUNT(*) as count FROM potholereport GROUP BY SeverityLevel");
while ($row = $severityResult->fetch_assoc()) {
    $severityData[$row['SeverityLevel']] = $row['count'];
}

// Fetch top 5 users by report submissions
$topUsers = $conn->query("SELECT u.Name, COUNT(p.ReportID) as totalReports 
    FROM user u 
    JOIN potholereport p ON u.UserID = p.UserID 
    GROUP BY u.UserID 
    ORDER BY totalReports DESC LIMIT 5");

// Fetch 5 most recent pothole reports
$latestReports = $conn->query("SELECT p.ReportID, p.Description, p.Status, p.ImageURL, u.Name 
    FROM potholereport p 
    JOIN user u ON p.UserID = u.UserID 
    ORDER BY p.Timestamp DESC LIMIT 5");
