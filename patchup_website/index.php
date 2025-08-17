<?php
include 'api/home_status.php';
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Section: Meta, Styles, and Scripts -->
    <meta charset="UTF-8">
    <title>Patch | Admin Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/styles.css">
    <script src="https://unpkg.com/feather-icons"></script>
</head>

<body class="bg-gray-100 min-h-screen flex relative">

    <!-- Section: Sidebar Navigation -->
    <aside id="sidebar"
        class="w-64 bg-white shadow-md h-full md:h-screen fixed flex flex-col justify-between transform -translate-x-full md:translate-x-0 transition-transform duration-300 z-40 overflow-y-auto">
        <div>
            <div class="px-6 py-5 border-b border-gray-200">
                <h2 class="text-xl font-bold text-[#04274B]">PatchUp Admin</h2>
            </div>
            <nav class="mt-6 px-6 space-y-2">
                <a href="index.php"
                    class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white text-[#04274B] font-medium bg-[#04274B] bg-opacity-10">
                    Dashboard
                </a>
                <a href="manage_admins.php"
                    class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">
                    Manage Admins
                </a>
                <a href="manage_reports.php"
                    class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">
                    Manage Reports
                </a>
                <a href="view_customers.php"
                    class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">
                    View Customers
                </a>
            </nav>
        </div>
        <form action="logout.php" method="post" class="px-6 mb-6">
            <hr class="border-t border-gray-200 mb-4 px-6">
            <button type="submit"
                class="w-full py-2 px-4 rounded-md bg-red-500 text-white hover:bg-red-600 transition">
                Logout
            </button>
        </form>
    </aside>

    <!-- Section: Mobile Sidebar Overlay -->
    <div id="overlay" class="fixed inset-0 bg-black bg-opacity-50 hidden z-30 md:hidden"></div>

    <!-- Section: Main Content -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- Section: Header Bar -->
        <header class="bg-white px-6 py-4 flex items-center justify-between border-b shadow-sm">
            <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none z-10">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                </svg>
            </button>
            <h1 class="text-xl md:text-2xl font-bold text-[#04274B] mx-auto md:mx-0 md:mb-1">Admin Dashboard</h1>
        </header>

        <!-- Section: Dashboard Content -->
        <section class="px-[30px] py-[30px] md:p-10 space-y-[20px] md:space-y-10 max-w-7xl mx-auto">

            <!-- Section: Welcome Card -->
            <div class="home-card home-shadow p-8 flex flex-col items-start justify-center text-left mb-2 bg-white border border-gray-100 relative overflow-hidden rounded-[20px]">
                <h2 class="text-2xl md:text-3xl font-extrabold text-[#04274B] flex items-center gap-2 tracking-tight drop-shadow-sm rounded-[15px]">
                    Welcome Back, <?= htmlspecialchars($_SESSION['admin_name']) ?>
                    <span class="text-3xl rounded-[10px]">👋</span>
                </h2>
                <p class="text-gray-600 text-base mt-2 font-medium rounded-[15px]">
                    Here’s what’s happening with PatchUp today.
                </p>
            </div>

            <!-- Section: Statistics Row -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-[20px] sm:gap-8">
                <!-- Card: Total Reports -->
                <div class="home-card home-shadow p-8 flex flex-col items-center justify-center text-center relative overflow-hidden bg-white rounded-[20px]">
                    <div class="absolute right-4 top-4 opacity-10 text-6xl pointer-events-none select-none rounded-[15px]">
                        <span data-feather="alert-triangle" class="text-[#facc15] rounded-[10px]"></span>
                    </div>
                    <div class="flex items-center gap-3 mb-2 z-10 rounded-[15px]">
                        <span data-feather="alert-triangle" class="text-[#facc15] rounded-[10px]"></span>
                        <h2 class="text-lg md:text-xl font-bold text-gray-700 home-section-title tracking-wide rounded-[10px]">
                            Total Pothole Reports
                        </h2>
                    </div>
                    <p class="text-5xl md:text-6xl font-extrabold text-[#04274B] mt-2 tracking-tight drop-shadow-sm z-10 rounded-[15px]">
                        <?= $totalReports ?>
                    </p>
                </div>
                <!-- Card: Status Breakdown Chart -->
                <div class="home-card home-shadow p-8 flex flex-col items-center justify-center text-center bg-white rounded-[20px]">
                    <div class="flex items-center gap-2 mb-4 rounded-[15px]">
                        <span data-feather="pie-chart" class="text-[#3b82f6] rounded-[10px]"></span>
                        <h3 class="text-lg font-semibold home-section-title tracking-wide rounded-[10px]">Status Breakdown</h3>
                    </div>
                    <div class="w-full flex justify-center rounded-[15px]">
                        <canvas id="statusChart" class="mx-auto max-w-[220px] rounded-[10px]"></canvas>
                    </div>
                </div>
                <!-- Card: Severity Breakdown Chart -->
                <div class="home-card home-shadow p-8 flex flex-col items-center justify-center text-center bg-white rounded-[20px]">
                    <div class="flex items-center gap-2 mb-4 rounded-[15px]">
                        <span data-feather="bar-chart-2" class="text-[#f87171] rounded-[10px]"></span>
                        <h3 class="text-lg font-semibold home-section-title tracking-wide rounded-[10px]">Severity Breakdown</h3>
                    </div>
                    <div class="w-full flex justify-center rounded-[15px]">
                        <canvas id="severityChart" class="mx-auto max-w-[220px] rounded-[10px]"></canvas>
                    </div>
                </div>
            </div>

            <!-- Section: Top Users and Latest Reports -->
            <div class="grid md:grid-cols-2 gap-[20px] md:gap-8">
                <!-- Card: Top 5 Reporters -->
                <div class="home-card home-shadow p-6 bg-white flex flex-col rounded-[20px]">
                    <div class="flex items-center gap-2 mb-4 rounded-[15px]">
                        <span data-feather="award" class="text-[#10b981] rounded-[10px]"></span>
                        <h3 class="text-lg font-semibold home-section-title tracking-wide rounded-[10px]">Top 5 Reporters</h3>
                    </div>
                    <ul class="space-y-3 rounded-[15px]">
                        <?php while ($row = $topUsers->fetch_assoc()) { ?>
                            <li class="flex justify-between items-center px-4 py-3 bg-gray-100 rounded-[10px]">
                                <span class="font-medium text-gray-700 text-base rounded-[10px]"><?= htmlspecialchars($row['Name']) ?></span>
                                <span class="home-badge rounded-[10px]"><?= $row['totalReports'] ?> reports</span>
                            </li>
                        <?php } ?>
                    </ul>
                </div>

                <!-- Card: Latest Reports -->
                <div class="home-card home-shadow p-6 bg-white flex flex-col rounded-[20px]">
                    <div class="flex items-center gap-2 mb-4 rounded-[15px]">
                        <span data-feather="clock" class="text-[#60a5fa] rounded-[10px]"></span>
                        <h3 class="text-lg font-semibold home-section-title tracking-wide rounded-[10px]">Latest Reports</h3>
                    </div>
                    <ul class="space-y-4 rounded-[15px]">
                        <?php while ($row = $latestReports->fetch_assoc()) { ?>
                            <li class="flex items-center space-x-4 px-3 py-3 bg-gray-100 rounded-[10px]">
                                <img src="<?= htmlspecialchars($row['ImageURL']) ?>"
                                    class="w-14 h-14 object-cover home-avatar shadow rounded-[10px]">
                                <div class="rounded-[10px]">
                                    <p class="text-base font-semibold text-gray-800 leading-tight rounded-[10px]"><?= htmlspecialchars($row['Description']) ?>
                                    </p>
                                    <p class="text-xs text-gray-500 mt-1 rounded-[10px]"><?= htmlspecialchars($row['Name']) ?> •
                                        <span class="font-medium rounded-[10px]"><?= $row['Status'] ?></span>
                                    </p>
                                </div>
                            </li>
                        <?php } ?>
                    </ul>
                </div>
            </div>

        </section>
    </main>

    <!-- Section: Sidebar Toggle Script -->
    <script src="javascript/script.js"></script>
    <script>
        feather.replace();
    </script>

    <!-- Section: Chart.js Scripts -->
    <script>
        // Section: Prepare Data for Status Chart
        const statusData = <?= json_encode(array_values($statusData)) ?>;
        const statusLabels = <?= json_encode(array_keys($statusData)) ?>;

        // Section: Prepare Data for Severity Chart
        const severityData = <?= json_encode(array_values($severityData)) ?>;
        const severityLabels = <?= json_encode(array_keys($severityData)) ?>;

        // Section: Render Status Pie Chart
        new Chart(document.getElementById('statusChart'), {
            type: 'pie',
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusData,
                    backgroundColor: ['#facc15', '#3b82f6', '#10b981']
                }]
            },
            options: {
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 14,
                                family: 'Inter, sans-serif'
                            }
                        }
                    }
                }
            }
        });

        // Section: Render Severity Doughnut Chart
        new Chart(document.getElementById('severityChart'), {
            type: 'doughnut',
            data: {
                labels: severityLabels,
                datasets: [{
                    data: severityData,
                    backgroundColor: [
                        '#f87171',
                        '#fbbf24',
                        '#10b981'
                    ]
                }]
            },
            options: {
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 14,
                                family: 'Inter, sans-serif'
                            }
                        }
                    }
                }
            }
        });
    </script>
</body>

</html>