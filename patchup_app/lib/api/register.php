<?php
// --- Set JSON Response Header ---
header("Content-Type: application/json");

// --- Include Database Connection ---
include_once("../database/db_connection.php");

// --- Parse Incoming JSON Request Data ---
$data = json_decode(file_get_contents("php://input"), true);

// --- Extract and Sanitize User Input ---
$name = trim($data["Name"] ?? '');
$email = trim($data["Email"] ?? '');
$password = $data["PasswordHash"] ?? '';

// --- Validate Name Format ---
if (!$name || !preg_match("/^[a-zA-Z][a-zA-Z\s'-]{1,99}$/", $name)) {
    echo json_encode(["success" => false, "message" => "Invalid name format"]);
    exit;
}

// --- Validate Email Format ---
if (!$email || !preg_match("/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/", $email)) {
    echo json_encode(["success" => false, "message" => "Invalid email format"]);
    exit;
}

// --- Check if Email is Already Registered (Case-Insensitive) ---
$stmt = $conn->prepare("SELECT 1 FROM user WHERE LOWER(Email) = LOWER(?)");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Email already registered"]);
    $stmt->close();
    $conn->close();
    exit;
}
$stmt->close();

// --- Validate Password Strength and Format ---
if (
    !$password ||
    strlen($password) < 8 ||
    !preg_match("/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/", $password)
) {
    echo json_encode(["success" => false, "message" => "Password must be at least 8 characters and include uppercase, lowercase, number, and special character"]);
    exit;
}

// --- Check Password Against Denylist of Common Passwords ---
$common_passwords = [
    "password",
    "123456",
    "12345678",
    "qwerty",
    "abc123",
    "111111",
    "123456789",
    "12345",
    "123123",
    "admin"
];
if (in_array(strtolower($password), $common_passwords)) {
    echo json_encode(["success" => false, "message" => "Password is too common"]);
    exit;
}

// --- Hash the Password for Secure Storage ---
$passwordHash = password_hash($password, PASSWORD_DEFAULT);

// --- Insert New User into Database ---
$stmt = $conn->prepare("INSERT INTO user (Name, Email, PasswordHash) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $name, $email, $passwordHash);

// --- Respond with Success or Error Message ---
if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "message" => $conn->error]);
}

// --- Close Statement and Database Connection ---
$stmt->close();
$conn->close();
