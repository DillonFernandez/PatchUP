<?php
// --- Set JSON Response Header and Include Database Connection ---
header("Content-Type: application/json");
include_once("../database/db_connection.php");

// --- Decode Input JSON and Extract Email ---
$data = json_decode(file_get_contents("php://input"), true);
$email = $data["Email"] ?? '';

// --- Check if Email is Provided, Return Empty Values if Not ---
if (!$email) {
    echo json_encode(["name" => "", "email" => ""]);
    exit;
}

// --- Prepare and Execute SQL Query to Fetch User Name and Email by Email ---
$stmt = $conn->prepare("SELECT Name, Email FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($name, $emailResult);

// --- Return User Info if Found, Otherwise Return Empty Values ---
if ($stmt->fetch()) {
    echo json_encode(["name" => $name, "email" => $emailResult]);
} else {
    echo json_encode(["name" => "", "email" => ""]);
}

// --- Close Statement and Database Connection ---
$stmt->close();
$conn->close();
