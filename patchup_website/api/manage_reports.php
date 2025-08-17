<?php
// Start session and verify admin authentication
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    http_response_code(403);
    exit;
}

// Connect to database
require_once("../database/db_connection.php");

// Handle report status update via POST
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['report_id'], $_POST['new_status'])) {
    $report_id = intval($_POST['report_id']);
    $new_status = $conn->real_escape_string($_POST['new_status']);
    $conn->query("UPDATE potholereport SET Status='$new_status' WHERE ReportID=$report_id");
    echo json_encode(['success' => true]);
    exit;
}

// Fetch reports with optional status and severity filters via GET
$status_filter = isset($_GET['status']) ? $conn->real_escape_string($_GET['status']) : '';
$severity_filter = isset($_GET['severity']) ? $conn->real_escape_string($_GET['severity']) : '';
$where = [];
if ($status_filter !== '' && $status_filter !== 'All') {
    $where[] = "p.Status = '$status_filter'";
}
if ($severity_filter !== '' && $severity_filter !== 'All') {
    $where[] = "p.SeverityLevel = '$severity_filter'";
}
$where_sql = count($where) ? 'WHERE ' . implode(' AND ', $where) : '';
$sql = "SELECT p.*, u.Name AS ReporterName FROM potholereport p JOIN user u ON p.UserID = u.UserID $where_sql ORDER BY p.Timestamp DESC";
$result = $conn->query($sql);
$reports = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Format timestamp for display
        $row['Timestamp'] = date('Y-m-d H:i', strtotime($row['Timestamp']));
        $reports[] = $row;
    }
}

// Output reports as JSON response
header('Content-Type: application/json');
echo json_encode($reports);
