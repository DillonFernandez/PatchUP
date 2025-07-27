<?php
// --- Start Session and Set JSON Header ---
session_start();
header('Content-Type: application/json');

// --- Admin Authentication Check ---
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

// --- Database Connection ---
require_once "../database/db_connection.php";

// --- Get Action Parameter ---
$action = $_GET['action'] ?? '';

// --- List All Customers ---
if ($action === 'list') {
    $customers = [];
    $result = $conn->query("SELECT UserID, Name, Email, Points FROM user ORDER BY UserID ASC");
    while ($row = $result->fetch_assoc()) {
        $customers[] = $row;
    }
    echo json_encode(['customers' => $customers]);
    exit;
}

// --- List Reports for a Specific Customer ---
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

// --- Handle Invalid Action ---
echo json_encode(['success' => false, 'message' => 'Invalid action']);
