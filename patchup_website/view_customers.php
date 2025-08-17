<?php
// Section: Session Handling and Authentication Redirect
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Section: Meta, Styles, and Scripts -->
    <meta charset="UTF-8">
    <title>Patch | View Customers</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
</head>

<body class="bg-gray-100 min-h-screen flex relative">

    <!-- Section: Sidebar Navigation -->
    <aside id="sidebar" class="w-64 bg-white shadow-md h-full md:h-screen fixed flex flex-col justify-between transform -translate-x-full md:translate-x-0 transition-transform duration-300 z-40 overflow-y-auto">
        <div>
            <div class="px-6 py-5 border-b border-gray-200">
                <h2 class="text-xl font-bold text-[#04274B]">PatchUp Admin</h2>
            </div>
            <nav class="mt-6 px-6 space-y-2">
                <a href="index.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">Dashboard</a>
                <a href="manage_admins.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">Manage Admins</a>
                <a href="manage_reports.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">Manage Reports</a>
                <a href="view_customers.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white text-[#04274B] font-medium bg-[#04274B] bg-opacity-10">View Customers</a>
            </nav>
        </div>
        <!-- Section: Logout Button -->
        <form action="logout.php" method="post" class="px-6 mb-6">
            <hr class="border-t border-gray-200 mb-4 px-6">
            <button type="submit" class="w-full py-2 px-4 rounded-md bg-red-500 text-white hover:bg-red-600 transition">Logout</button>
        </form>
    </aside>

    <!-- Section: Mobile Sidebar Overlay -->
    <div id="overlay" class="fixed inset-0 bg-black bg-opacity-50 hidden z-30 md:hidden"></div>

    <!-- Section: Main Content Area -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- Section: Header Bar -->
        <header class="bg-white px-6 py-4 flex items-center justify-between border-b shadow-sm">
            <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none z-10">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                </svg>
            </button>
            <h1 class="text-xl md:text-2xl font-bold text-[#04274B] mx-auto md:mx-0 md:mb-1">View Customers</h1>
        </header>

        <!-- Section: Customers Grid -->
        <section class="w-full mx-auto px-[30px] py-[30px] sm:px-4 md:px-10 md:py-10 rounded-[20px]">
            <div id="customersCardGrid" class="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 rounded-[15px]">
                <!-- Customer cards will be inserted here by JS -->
            </div>
        </section>
    </main>

    <script>
        // Section: Load Customers and Render Cards
        function loadCustomers() {
            fetch('api/view_customers.php?action=list')
                .then(res => res.json())
                .then(data => {
                    const grid = document.getElementById('customersCardGrid');
                    grid.innerHTML = '';
                    if (data.customers && data.customers.length > 0) {
                        data.customers.forEach(customer => {
                            grid.innerHTML += `
                                <div class="manage-cus-shadow-card bg-white rounded-[20px] p-5 flex flex-col gap-2">
                                    <div class="flex items-center justify-between mb-2 rounded-[15px]">
                                        <span class="text-xs text-gray-400 font-semibold rounded-[10px]">ID: ${customer.UserID}</span>
                                        <span class="text-xs text-gray-500 font-semibold rounded-[10px]">Points: ${customer.Points}</span>
                                    </div>
                                    <div class="mb-1 rounded-[15px]">
                                        <div class="text-base font-bold text-[#04274B] rounded-[10px]">${customer.Name}</div>
                                        <div class="text-sm text-gray-600 rounded-[10px]">${customer.Email}</div>
                                    </div>
                                    <a class="mt-3 bg-[#04274B] text-white px-4 py-2 rounded-[10px] shadow manage-ad-shadow-btn font-semibold hover:bg-[#06477B] transition text-center"
                                        href="customer_reports.php?userid=${customer.UserID}&name=${encodeURIComponent(customer.Name)}">
                                        View Reports
                                    </a>
                                </div>
                            `;
                        });
                    } else {
                        grid.innerHTML = '<div class="col-span-full text-gray-500 text-center rounded-[20px]">No customers found.</div>';
                    }
                });
        }

        // Section: Initial Customers Load on Page Ready
        loadCustomers();
    </script>

    <!-- Section: Sidebar Toggle Script -->
    <script src="javascript/script.js"></script>
</body>

</html>