<?php
// --- Start Session and Redirect if Already Logged In ---
session_start();
if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header("Location: index.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Head Section: Meta, Styles, and Scripts -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>PatchUp | Admin Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://unpkg.com/@fortawesome/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
</head>

<body>
    <!-- Login Container Section -->
    <div class="min-h-screen flex items-center justify-center px-4 py-8">
        <div class="w-full max-w-md">
            <!-- Login Card Section -->
            <div class="login-card bg-white rounded-2xl login-shadow p-8 flex flex-col items-center">
                <!-- Logo and Heading Section -->
                <div class="mb-4 flex flex-col items-center">
                    <img src="images/Logo 1.webp" alt="PatchUp Logo"
                        class="w-24 h-24 object-contain mb-2 rounded-full border-4 border-gray-100 shadow-md">
                    <h2 class="text-2xl font-bold text-gray-800 mt-2 mb-1 tracking-tight">Admin Login</h2>
                    <p class="text-gray-500 text-sm">Sign in to your PatchUp admin account</p>
                </div>
                <!-- Login Form Section -->
                <form id="loginForm" class="w-full mt-4 space-y-5">
                    <!-- Name Input Section -->
                    <div>
                        <label for="name" class="block text-gray-700 font-medium mb-1">Name</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                <i class="fas fa-user"></i>
                            </span>
                            <input type="text" id="name" name="name" required
                                class="login-input pl-10 pr-4 py-2 w-full rounded-lg border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition outline-none bg-gray-50 text-gray-800 font-medium shadow-sm">
                        </div>
                    </div>
                    <!-- Email Input Section -->
                    <div>
                        <label for="email" class="block text-gray-700 font-medium mb-1">Email</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                <i class="fas fa-envelope"></i>
                            </span>
                            <input type="email" id="email" name="email" required
                                class="login-input pl-10 pr-4 py-2 w-full rounded-lg border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition outline-none bg-gray-50 text-gray-800 font-medium shadow-sm">
                        </div>
                    </div>
                    <!-- Password Input Section -->
                    <div>
                        <label for="password" class="block text-gray-700 font-medium mb-1">Password</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                                <i class="fas fa-lock"></i>
                            </span>
                            <input type="password" id="password" name="password" required
                                class="login-input pl-10 pr-4 py-2 w-full rounded-lg border border-gray-300 focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition outline-none bg-gray-50 text-gray-800 font-medium shadow-sm">
                        </div>
                    </div>
                    <!-- Submit Button Section -->
                    <button type="submit"
                        class="w-full py-2 px-4 rounded-lg bg-[#04274B] hover:bg-[#063366] text-white font-semibold text-lg shadow-md transition-all duration-200 login-btn">
                        <i class="fas fa-sign-in-alt mr-2"></i>Login
                    </button>
                    <!-- Login Message Section -->
                    <div id="loginMessage" class="text-center text-red-500 text-sm mt-2"></div>
                </form>
            </div>
            <!-- Footer Section -->
            <div class="text-center text-gray-400 text-xs mt-6">
                &copy; <?php echo date('Y'); ?> PatchUp. All rights reserved.
            </div>
        </div>
    </div>
    <!-- Custom Scripts Section -->
    <script src="javascript/script.js"></script>
</body>

</html>