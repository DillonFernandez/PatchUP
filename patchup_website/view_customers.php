<?php
// --- Session Handling and Authentication Redirect ---
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- --- Head: Meta, Styles, and Scripts --- -->
    <meta charset="UTF-8">
    <title>Patch | View Customers</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
</head>

<body class="bg-gray-100 min-h-screen flex relative">

    <!-- --- Sidebar Navigation --- -->
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
        <!-- --- Logout Button --- -->
        <form action="logout.php" method="post" class="px-6 mb-6">
            <hr class="border-t border-gray-200 mb-4 px-6">
            <button type="submit" class="w-full py-2 px-4 rounded-md bg-red-500 text-white hover:bg-red-600 transition">Logout</button>
        </form>
    </aside>

    <!-- --- Mobile Sidebar Overlay --- -->
    <div id="overlay" class="fixed inset-0 bg-black bg-opacity-50 hidden z-30 md:hidden"></div>

    <!-- --- Main Content Area --- -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- --- Header Bar --- -->
        <header class="bg-white px-6 py-4 flex items-center justify-between border-b shadow-sm">
            <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none z-10">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                </svg>
            </button>
            <h1 class="text-xl md:text-2xl font-bold text-[#04274B] mx-auto md:mx-0 md:mb-1">View Customers</h1>
        </header>

        <!-- --- Customers Grid --- -->
        <section class="w-full mx-auto px-[30px] py-[30px] sm:px-4 md:px-10 md:py-10">
            <div id="customersCardGrid" class="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
                <!-- Customer cards will be inserted here by JS -->
            </div>
        </section>

        <!-- --- Reports Modal --- -->
        <div id="reportsModal" class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 hidden">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl p-0 relative manage-ad-shadow-modal max-h-[90vh] overflow-y-auto
                        sm:max-w-lg
                        xs:max-w-[95vw]
                        md:w-[30%]"
                style="max-width:95vw;">
                <!-- --- Modal Header --- -->
                <div class="flex items-center justify-between px-6 py-5 border-b border-gray-200 rounded-t-3xl bg-[#F7FAFC]">
                    <div class="flex items-center gap-3">
                        <div id="modalUserAvatar" class="w-10 h-10 rounded-full bg-[#04274B] flex items-center justify-center text-white font-bold text-lg"></div>
                        <div>
                            <div id="modalUserName" class="font-bold text-[#04274B] text-lg"></div>
                            <div id="modalUserId" class="text-xs text-gray-400"></div>
                        </div>
                    </div>
                    <button id="closeReportsModal" class="text-gray-400 hover:text-gray-700 text-3xl font-bold focus:outline-none">&times;</button>
                </div>
                <!-- --- Modal Content --- -->
                <div class="px-6 py-5">
                    <h2 class="text-xl font-bold mb-4 text-[#04274B]">
                        User Reports
                    </h2>
                    <div id="reportsList" class="overflow-y-auto max-h-[60vh] flex flex-col gap-4 items-center">
                        <!-- Reports will be loaded here -->
                    </div>
                </div>
            </div>
        </div>
    </main>

    <script>
        // --- Load Customers and Render Cards ---
        function loadCustomers() {
            fetch('api/view_customers.php?action=list')
                .then(res => res.json())
                .then(data => {
                    const grid = document.getElementById('customersCardGrid');
                    grid.innerHTML = '';
                    if (data.customers && data.customers.length > 0) {
                        data.customers.forEach(customer => {
                            grid.innerHTML += `
                                <div class="manage-cus-shadow-card bg-white rounded-xl p-5 flex flex-col gap-2">
                                    <div class="flex items-center justify-between mb-2">
                                        <span class="text-xs text-gray-400 font-semibold">ID: ${customer.UserID}</span>
                                        <span class="text-xs text-gray-500 font-semibold">Points: ${customer.Points}</span>
                                    </div>
                                    <div class="mb-1">
                                        <div class="text-base font-bold text-[#04274B]">${customer.Name}</div>
                                        <div class="text-sm text-gray-600">${customer.Email}</div>
                                    </div>
                                    <button class="mt-3 bg-[#04274B] text-white px-4 py-2 rounded-lg shadow manage-ad-shadow-btn font-semibold hover:bg-[#06477B] transition"
                                        onclick="showReportsModal(${customer.UserID}, '${encodeURIComponent(customer.Name)}')">
                                        View Reports
                                    </button>
                                </div>
                            `;
                        });
                    } else {
                        grid.innerHTML = '<div class="col-span-full text-gray-500 text-center">No customers found.</div>';
                    }
                });
        }

        // --- Show Reports Modal for Selected User ---
        function showReportsModal(userid, name) {
            const modal = document.getElementById('reportsModal');
            const reportsList = document.getElementById('reportsList');
            const modalUserName = document.getElementById('modalUserName');
            const modalUserId = document.getElementById('modalUserId');
            const modalUserAvatar = document.getElementById('modalUserAvatar');
            const decodedName = decodeURIComponent(name);

            // Set user info in modal header
            modalUserName.textContent = decodedName;
            modalUserId.textContent = 'User ID: ' + userid;
            // Avatar: use initials
            const initials = decodedName.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
            modalUserAvatar.textContent = initials;

            modal.classList.remove('hidden');
            reportsList.innerHTML = '<div class="text-gray-500">Loading...</div>';
            fetch('api/view_customers.php?action=reports&userid=' + encodeURIComponent(userid))
                .then(res => res.json())
                .then(data => {
                    if (data.reports && data.reports.length > 0) {
                        let html = '';
                        data.reports.forEach(report => {
                            // --- Severity Badge Color ---
                            let sevClass = '';
                            if (report.SeverityLevel === 'Small') {
                                sevClass = 'text-green-700 bg-green-100';
                            } else if (report.SeverityLevel === 'Moderate') {
                                sevClass = 'text-yellow-700 bg-yellow-100';
                            } else if (report.SeverityLevel === 'Critical') {
                                sevClass = 'text-red-700 bg-red-100';
                            } else {
                                sevClass = 'text-gray-700 bg-gray-100';
                            }
                            // --- Status Badge Color ---
                            let statusClass = '';
                            if (report.Status === 'Resolved') {
                                statusClass = 'text-green-700 bg-green-100';
                            } else if (report.Status === 'In Progress') {
                                statusClass = 'text-yellow-700 bg-yellow-100';
                            } else if (report.Status === 'Reported') {
                                statusClass = 'text-blue-700 bg-blue-100';
                            } else {
                                statusClass = 'text-gray-700 bg-gray-100';
                            }
                            html += `
                                <div class="border rounded-xl p-3 bg-white shadow-sm w-full max-w-md flex flex-row gap-4 items-stretch">
                                    ${
                                        report.ImageURL
                                            ? `<div class="flex-shrink-0 flex items-center justify-center mr-2">
                                                <img src="${report.ImageURL}" alt="Report Image" class="max-w-[96px] rounded-lg border shadow-sm object-cover">
                                            </div>`
                                            : ''
                                    }
                                    <div class="flex-1 flex flex-col gap-1 justify-between">
                                        <div>
                                            <div class="flex items-center gap-2 mb-1">
                                                <span class="text-xs font-semibold text-gray-400">#${report.ReportID}</span>
                                                <span class="text-xs font-semibold rounded px-2 py-0.5 ${statusClass}">${report.Status}</span>
                                                <span class="text-xs font-semibold rounded px-2 py-0.5 ${sevClass}">${report.SeverityLevel}</span>
                                            </div>
                                            <div class="text-gray-800 text-sm mb-1">${report.Description || '<span class="italic text-gray-400">(No description)</span>'}</div>
                                        </div>
                                        <div class="flex flex-wrap gap-2 text-xs text-gray-600 mb-1">
                                            <span class="bg-gray-100 rounded px-2 py-0.5">Zip: ${report.ZipCode}</span>
                                            <span class="bg-gray-100 rounded px-2 py-0.5">Lat: ${report.Latitude}</span>
                                            <span class="bg-gray-100 rounded px-2 py-0.5">Lng: ${report.Longitude}</span>
                                        </div>
                                        <div class="text-xs text-gray-400">${report.Timestamp}</div>
                                    </div>
                                </div>
                            `;
                        });
                        reportsList.innerHTML = html;
                    } else {
                        reportsList.innerHTML = '<div class="text-gray-500 text-center py-10">No reports found for this user.</div>';
                    }
                });
        }

        // --- Modal Close Handlers ---
        document.getElementById('closeReportsModal').onclick = function() {
            document.getElementById('reportsModal').classList.add('hidden');
        };
        window.addEventListener('click', function(event) {
            const modal = document.getElementById('reportsModal');
            if (event.target === modal) {
                modal.classList.add('hidden');
            }
        });

        // --- Initial Customers Load on Page Ready ---
        loadCustomers();
    </script>

    <!-- --- Sidebar Toggle Script --- -->
    <script src="javascript/script.js"></script>
</body>

</html>