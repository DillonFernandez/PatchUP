<?php
// --- Set JSON Response Header ---
header("Content-Type: application/json");

// --- Include Database Connection ---
include_once("../database/db_connection.php");

// --- Parse Incoming JSON Request Data ---
$data = json_decode(file_get_contents("php://input"), true);

// --- Extract Email and Password from Request ---
$email = $data["Email"] ?? '';
$password = $data["PasswordHash"] ?? '';

// --- Validate Required Fields ---
if (!$email || !$password) {
    echo json_encode(["success" => false, "message" => "Missing fields"]);
    exit;
}

// --- Prepare SQL Statement to Fetch Password Hash for Given Email ---
$stmt = $conn->prepare("SELECT PasswordHash FROM user WHERE Email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

// --- Check if User Exists ---
if ($stmt->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Invalid email or password"]);
    $stmt->close();
    $conn->close();
    exit;
}

// --- Retrieve Password Hash from Database ---
$stmt->bind_result($hash);
$stmt->fetch();

// --- Verify Password and Respond Accordingly ---
if (password_verify($password, $hash)) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => "Invalid email or password"]);
}

// --- Close Statement and Database Connection ---
$stmt->close();
$conn->close();
