<?php
// --- Start Session and Redirect if Not Authenticated ---
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Head Section: Meta, Styles, and Scripts -->
    <meta charset="UTF-8">
    <title>Patch | Manage Reports</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
</head>

<body class="bg-gray-100 min-h-screen flex relative">

    <!-- Sidebar Navigation Section -->
    <aside id="sidebar" class="w-64 bg-white shadow-md h-full md:h-screen fixed flex flex-col justify-between transform -translate-x-full md:translate-x-0 transition-transform duration-300 z-40 overflow-y-auto">
        <div>
            <div class="px-6 py-5 border-b border-gray-200">
                <h2 class="text-xl font-bold text-[#04274B]">PatchUp Admin</h2>
            </div>
            <nav class="mt-6 px-6 space-y-2">
                <a href="index.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">Dashboard</a>
                <a href="manage_admins.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">Manage Admins</a>
                <a href="manage_reports.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white text-[#04274B] font-medium bg-[#04274B] bg-opacity-10">Manage Reports</a>
                <a href="view_customers.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">View Customers</a>
            </nav>
        </div>
        <!-- Logout Button Section -->
        <form action="logout.php" method="post" class="px-6 mb-6">
            <hr class="border-t border-gray-200 mb-4 px-6">
            <button type="submit" class="w-full py-2 px-4 rounded-md bg-red-500 text-white hover:bg-red-600 transition">Logout</button>
        </form>
    </aside>

    <!-- Mobile Sidebar Overlay Section -->
    <div id="overlay" class="fixed inset-0 bg-black bg-opacity-50 hidden z-30 md:hidden"></div>

    <!-- Main Content Section -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- Header Bar Section -->
        <header class="bg-white px-6 py-4 flex items-center justify-between border-b shadow-sm">
            <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none z-10">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                </svg>
            </button>
            <h1 class="text-xl md:text-2xl font-bold text-[#04274B] mx-auto md:mx-0 md:mb-1">Manage Reports</h1>
        </header>

        <!-- Reports Management Section -->
        <section class="w-full mx-auto px-[30px] py-[30px] sm:px-4 md:px-10 md:py-10">
            <div class="max-w-7xl mx-auto">
                <!-- Filter Form Section -->
                <form id="filterForm" class="manage-re-filter-form flex flex-col sm:flex-row sm:items-end gap-4 sm:gap-6">
                    <div class="flex flex-row gap-2 w-full sm:w-auto">
                        <div class="w-1/2 sm:w-auto">
                            <label class="manage-re-filter-label">Status</label>
                            <select name="status" id="statusFilter" class="manage-re-filter-select w-full sm:w-auto">
                                <option value="All">All</option>
                                <option value="Reported">Reported</option>
                                <option value="In Progress">In Progress</option>
                                <option value="Resolved">Resolved</option>
                            </select>
                        </div>
                        <div class="w-1/2 sm:w-auto">
                            <label class="manage-re-filter-label">Severity</label>
                            <select name="severity" id="severityFilter" class="manage-re-filter-select w-full sm:w-auto">
                                <option value="All">All</option>
                                <option value="Small">Small</option>
                                <option value="Moderate">Moderate</option>
                                <option value="Critical">Critical</option>
                            </select>
                        </div>
                    </div>
                    <div class="flex flex-row gap-2 w-full sm:w-auto">
                        <button type="submit" class="manage-re-filter-btn w-1/2 sm:w-auto">Filter</button>
                        <button type="button" id="resetBtn" class="manage-re-filter-btn w-1/2 sm:w-auto bg-gray-300 text-white hover:bg-gray-400 border-none">Reset</button>
                    </div>
                </form>
                <div id="reportsGrid" class="manage-re-grid">
                    <!-- Reports will be loaded here via JS -->
                </div>
            </div>
        </section>
    </main>

    <!-- Sidebar Toggle Script Section -->
    <script src="javascript/script.js"></script>
    <script>
        // --- Fetch and Render Reports ---
        function fetchReports() {
            const status = document.getElementById('statusFilter').value;
            const severity = document.getElementById('severityFilter').value;
            fetch(`api/manage_reports.php?status=${encodeURIComponent(status)}&severity=${encodeURIComponent(severity)}`)
                .then(res => res.json())
                .then(data => {
                    const grid = document.getElementById('reportsGrid');
                    grid.innerHTML = '';
                    if (!data.length) {
                        grid.innerHTML = '<div class="col-span-full text-center text-gray-500 py-12 bg-white rounded-xl shadow-sm border border-gray-100">No reports found.</div>';
                        return;
                    }
                    data.forEach(report => {
                        const sevClass = report.SeverityLevel === 'Critical' ? 'bg-red-100 text-red-700' :
                            report.SeverityLevel === 'Moderate' ? 'bg-yellow-100 text-yellow-700' :
                            'bg-green-100 text-green-700';
                        const img = report.ImageURL ?
                            `<img src="${report.ImageURL}" alt="Pothole Image" class="object-cover w-full h-full">` :
                            `<span class="manage-re-no-img">No Image</span>`;
                        grid.innerHTML += `
                <div class="manage-re-card">
                    <div class="manage-re-card-inner">
                        <div class="manage-re-card-header">
                            <span class="text-xs text-gray-400 font-mono">#${report.ReportID}</span>
                            <span class="manage-re-status-badge ${sevClass}">
                                ${report.SeverityLevel}
                            </span>
                        </div>
                        <div class="manage-re-card-section">
                            <span class="manage-re-label">Reported By:</span>
                            <span class="manage-re-value">${report.ReporterName}</span>
                        </div>
                        <div class="manage-re-img-wrap">
                            ${img}
                        </div>
                        <div class="manage-re-card-section">
                            <span class="manage-re-label">Status:</span>
                            <span class="manage-re-value">${report.Status}</span>
                        </div>
                        <form class="statusForm manage-re-form-row" data-id="${report.ReportID}">
                            <select name="new_status" class="manage-re-form-select">
                                <option value="Reported" ${report.Status === 'Reported' ? 'selected' : ''}>Reported</option>
                                <option value="In Progress" ${report.Status === 'In Progress' ? 'selected' : ''}>In Progress</option>
                                <option value="Resolved" ${report.Status === 'Resolved' ? 'selected' : ''}>Resolved</option>
                            </select>
                            <button type="submit" class="manage-re-form-btn">Update</button>
                        </form>
                        <div class="manage-re-card-section">
                            <span class="manage-re-label">Description:</span>
                            <span class="manage-re-value">${report.Description}</span>
                        </div>
                        <div class="manage-re-card-section">
                            <span class="manage-re-label">Zip Code:</span>
                            <span class="manage-re-value">${report.ZipCode}</span>
                        </div>
                        <div class="manage-re-card-section">
                            <span class="manage-re-label">Location:</span>
                            <span class="manage-re-value">Lat: ${report.Latitude}, Lng: ${report.Longitude}</span>
                        </div>
                        <div class="manage-re-timestamp">
                            ${report.Timestamp}
                        </div>
                    </div>
                </div>
                `;
                    });
                    // Attach status update handlers
                    document.querySelectorAll('.statusForm').forEach(form => {
                        form.onsubmit = function(e) {
                            e.preventDefault();
                            const report_id = form.getAttribute('data-id');
                            const new_status = form.querySelector('select').value;
                            fetch('api/manage_reports.php', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded'
                                },
                                body: `report_id=${encodeURIComponent(report_id)}&new_status=${encodeURIComponent(new_status)}`
                            }).then(() => fetchReports());
                        };
                    });
                });
        }
        document.getElementById('filterForm').onsubmit = function(e) {
            e.preventDefault();
            fetchReports();
        };
        document.getElementById('resetBtn').onclick = function(e) {
            e.preventDefault();
            document.getElementById('statusFilter').value = 'All';
            document.getElementById('severityFilter').value = 'All';
            fetchReports();
        };
        // Initial load
        fetchReports();
    </script>
</body>

</html>