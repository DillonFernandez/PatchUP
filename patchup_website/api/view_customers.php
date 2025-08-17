<?php
// Start session and set JSON response header
session_start();
header('Content-Type: application/json');

// Verify admin authentication
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

// Connect to database
require_once "../database/db_connection.php";

// Get action parameter from request
$action = $_GET['action'] ?? '';

// Handle listing all customers
if ($action === 'list') {
    $customers = [];
    $result = $conn->query("SELECT UserID, Name, Email, Points FROM user ORDER BY UserID ASC");
    while ($row = $result->fetch_assoc()) {
        $customers[] = $row;
    }
    echo json_encode(['customers' => $customers]);
    exit;
}

// Handle listing reports for a specific customer
if ($action === 'reports' && isset($_GET['userid'])) {
    $userid = intval($_GET['userid']);
    $reports = [];
    $stmt = $conn->prepare("SELECT ReportID, Description, SeverityLevel, ImageURL, Timestamp, Status, ZipCode, Latitude, Longitude FROM potholereport WHERE UserID = ? ORDER BY Timestamp DESC");
    $stmt->bind_param("i", $userid);
    $stmt->execute();
    $result = $stmt->get_result();
    while ($row = $result->fetch_assoc()) {
        $reports[] = $row;
    }
    echo json_encode(['reports' => $reports]);
    exit;
}

// Handle invalid action requests
echo json_encode(['success' => false, 'message' => 'Invalid action']);
