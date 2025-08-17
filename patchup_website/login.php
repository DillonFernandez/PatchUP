<?php
// Section: Session Start and Redirect if Already Logged In
session_start();
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header("Location: index.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Section: Meta, Styles, and Scripts -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PatchUp | Admin Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/@fortawesome/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>

<body class="bg-gray-100">
    <!-- Section: Login Container -->
    <div class="min-h-screen flex items-center justify-center px-4 py-8">
        <div class="w-full max-w-md rounded-[20px]">
            <!-- Section: Login Card -->
            <div class="login-card bg-white rounded-[20px] login-shadow p-8 flex flex-col items-center">
                <!-- Section: Logo and Heading -->
                <div class="mb-4 flex flex-col items-center rounded-[15px]">
                    <img src="images/Logo 1.webp" alt="PatchUp Logo"
                        class="w-24 h-24 object-contain mb-2 rounded-full border-4 border-gray-100 shadow-md rounded-[10px]">
                    <h2 class="text-2xl font-bold text-gray-800 mt-2 mb-1 tracking-tight rounded-[10px]">Admin Login</h2>
                    <p class="text-gray-500 text-sm rounded-[10px]">Sign in to your PatchUp admin account</p>
                </div>
                <!-- Section: Login Form -->
                <form id="loginForm" class="w-full mt-4 space-y-5 rounded-[15px]">
                    <!-- Section: Name Input -->
                    <div class="rounded-[15px]">
                        <label for="name" class="block text-gray-700 font-medium mb-1 rounded-[10px]">Name</label>
                        <div class="relative rounded-[10px]">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400 rounded-[10px]">
                                <i class="fas fa-user rounded-[10px]"></i>
                            </span>
                            <input type="text" id="name" name="name" required
                                class="login-input pl-10 pr-4 py-2 w-full rounded-[10px] border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition outline-none bg-gray-50 text-gray-800 font-medium shadow-sm">
                        </div>
                    </div>
                    <!-- Section: Email Input -->
                    <div class="rounded-[15px]">
                        <label for="email" class="block text-gray-700 font-medium mb-1 rounded-[10px]">Email</label>
                        <div class="relative rounded-[10px]">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400 rounded-[10px]">
                                <i class="fas fa-envelope rounded-[10px]"></i>
                            </span>
                            <input type="email" id="email" name="email" required
                                class="login-input pl-10 pr-4 py-2 w-full rounded-[10px] border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition outline-none bg-gray-50 text-gray-800 font-medium shadow-sm">
                        </div>
                    </div>
                    <!-- Section: Password Input -->
                    <div class="rounded-[15px]">
                        <label for="password" class="block text-gray-700 font-medium mb-1 rounded-[10px]">Password</label>
                        <div class="relative rounded-[10px]">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400 rounded-[10px]">
                                <i class="fas fa-lock rounded-[10px]"></i>
                            </span>
                            <input type="password" id="password" name="password" required
                                class="login-input pl-10 pr-4 py-2 w-full rounded-[10px] border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition outline-none bg-gray-50 text-gray-800 font-medium shadow-sm">
                        </div>
                    </div>
                    <!-- Section: Submit Button -->
                    <button type="submit"
                        class="w-full py-2 px-4 rounded-[10px] bg-[#04274B] hover:bg-[#063366] text-white font-semibold text-lg shadow-md transition-all duration-200 login-btn">
                        <i class="fas fa-sign-in-alt mr-2 rounded-[10px]"></i>Login
                    </button>
                    <!-- Section: Login Message -->
                    <div id="loginMessage" class="text-center text-red-500 text-sm mt-2 rounded-[10px]"></div>
                </form>
            </div>
            <!-- Section: Footer -->
            <div class="text-center text-gray-400 text-xs mt-6 rounded-[15px]">
                &copy; <?php echo date('Y'); ?> PatchUp. All rights reserved.
            </div>
        </div>
    </div>
    <!-- Section: Custom Scripts -->
    <script src="javascript/script.js"></script>
</body>

</html>