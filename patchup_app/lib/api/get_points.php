<?php
// --- Set JSON Response Header and Include Database Connection ---
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// --- Decode Input JSON and Extract Email ---
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

// --- Check if Email is Provided, Return 0 Points if Not ---
if (!$email) {
    echo json_encode(["points" => 0]);
    exit;
}

// --- Prepare and Execute SQL Query to Fetch User Points by Email ---
$stmt = $conn->prepare("SELECT Points FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($points);

// --- Return Points if User Found, Otherwise Return 0 ---
if ($stmt->fetch()) {
    echo json_encode(["points" => intval($points)]);
} else {
    echo json_encode(["points" => 0]);
}

// --- Close Statement and Database Connection ---
$stmt->close();
$conn->close();
