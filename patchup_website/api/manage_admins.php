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

// --- List All Admins ---
if ($action === 'list') {
    $admins = [];
    $current_email = $_SESSION['admin_email'] ?? '';
    $result = $conn->query("SELECT AdminID, Name, Email FROM admin ORDER BY AdminID ASC");
    while ($row = $result->fetch_assoc()) {
        $row['is_current'] = ($row['Email'] === $current_email);
        $admins[] = $row;
    }
    echo json_encode(['admins' => $admins]);
    exit;
}

// --- Add New Admin ---
if ($action === 'add') {
    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

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

    // --- Check for Existing Email (Case-Insensitive) ---
    $stmt = $conn->prepare("SELECT 1 FROM admin WHERE LOWER(Email) = LOWER(?)");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Email already exists.']);
        $stmt->close();
        exit;
    }
    $stmt->close();

    // --- Validate Password Strength and Format ---
    if (
        !$password ||
        strlen($password) < 8 ||
        !preg_match("/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/", $password)
    ) {
        echo json_encode([
            "success" => false,
            "message" => "Password must be at least 8 characters and include uppercase, lowercase, number, and special character"
        ]);
        exit;
    }

    // --- Check Password Against Common Passwords Denylist ---
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

    // --- Insert New Admin Record ---
    $stmt = $conn->prepare("INSERT INTO admin (Name, Email, PasswordHash) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $name, $email, $password);
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Admin added successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add admin.']);
    }
    $stmt->close();
    exit;
}

// --- Delete Admin ---
if ($action === 'delete') {
    $id = intval($_POST['id'] ?? 0);
    if (!$id) {
        echo json_encode(['success' => false, 'message' => 'Invalid admin ID.']);
        exit;
    }
    // --- Prevent Deleting Self ---
    $stmt = $conn->prepare("SELECT Email FROM admin WHERE AdminID=?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $stmt->bind_result($del_email);
    $stmt->fetch();
    $stmt->close();
    if (!$del_email) {
        echo json_encode(['success' => false, 'message' => 'Admin not found.']);
        exit;
    }
    if (($del_email === ($_SESSION['admin_email'] ?? ''))) {
        echo json_encode(['success' => false, 'message' => 'You cannot delete yourself.']);
        exit;
    }
    // --- Delete Admin Record ---
    $stmt = $conn->prepare("DELETE FROM admin WHERE AdminID=?");
    $stmt->bind_param("i", $id);
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Admin deleted successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete admin.']);
    }
    $stmt->close();
    exit;
}

// --- Edit Admin ---
if ($action === 'edit') {
    $id = intval($_POST['id'] ?? 0);
    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    if (!$id) {
        echo json_encode(["success" => false, "message" => "Invalid admin ID."]);
        exit;
    }

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

    // --- Check for Existing Email (Case-Insensitive, Excluding Self) ---
    $stmt = $conn->prepare("SELECT 1 FROM admin WHERE LOWER(Email) = LOWER(?) AND AdminID != ?");
    $stmt->bind_param("si", $email, $id);
    $stmt->execute();
    $stmt->store_result();
    if ($stmt->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Email already exists.']);
        $stmt->close();
        exit;
    }
    $stmt->close();

    // --- If Password Provided, Validate and Update ---
    if ($password) {
        if (
            strlen($password) < 8 ||
            !preg_match("/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/", $password)
        ) {
            echo json_encode([
                "success" => false,
                "message" => "Password must be at least 8 characters and include uppercase, lowercase, number, and special character"
            ]);
            exit;
        }
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
        // --- Update Admin With Password ---
        $stmt = $conn->prepare("UPDATE admin SET Name=?, Email=?, PasswordHash=? WHERE AdminID=?");
        $stmt->bind_param("sssi", $name, $email, $password, $id);
    } else {
        // --- Update Admin Without Password ---
        $stmt = $conn->prepare("UPDATE admin SET Name=?, Email=? WHERE AdminID=?");
        $stmt->bind_param("ssi", $name, $email, $id);
    }
    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Admin updated successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update admin.']);
    }
    $stmt->close();
    exit;
}
