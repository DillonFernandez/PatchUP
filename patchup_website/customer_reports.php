<?php
// Section: Session Handling and Authentication Redirect
session_start();
if (!isset($_SESSION['admin_logged_in']) || $_SESSION['admin_logged_in'] !== true) {
    header("Location: login.php");
    exit;
}
$userid = isset($_GET['userid']) ? intval($_GET['userid']) : 0;
$name = isset($_GET['name']) ? htmlspecialchars($_GET['name']) : '';
if (!$userid) {
    header("Location: view_customers.php");
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- Section: Meta, Styles, and Scripts -->
    <meta charset="UTF-8">
    <title>Patch | <?php echo $name ? $name : 'Customer'; ?>'s Reports</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
    <script src="https://unpkg.com/leaflet.heat/dist/leaflet-heat.js"></script>
</head>

<body class="bg-gray-100 min-h-screen flex flex-col">
    <!-- Section: Header (No Sidebar) -->
    <header class="bg-white px-6 py-4 flex items-center justify-between border-b shadow-sm w-full">
        <a href="view_customers.php">
            <button type="button" class="flex items-center justify-center px-2 py-1.5 rounded bg-[#04274B] text-white hover:bg-[#06477B] transition" title="Back to Customers">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                </svg>
            </button>
        </a>
        <h1 class="text-xl md:text-2xl font-bold text-[#04274B] text-center flex-1">
            <?php echo $name ? $name : 'Customer'; ?>'s Reports
        </h1>
        <div class="w-10"></div>
    </header>
    <main class="flex-1 bg-gray-50 min-h-screen overflow-x-hidden">
        <section class="w-full mx-auto px-[30px] py-[30px] sm:px-4 md:px-10 md:py-10 rounded-[20px]">
            <div class="max-w-7xl mx-auto rounded-[15px]">
                <!-- Section: Filter Form -->
                <form id="filterForm" class="manage-re-filter-form flex flex-col sm:flex-row sm:items-end gap-4 sm:gap-6 rounded-[15px]">
                    <div class="flex flex-row gap-2 w-full sm:w-auto rounded-[15px]">
                        <div class="w-1/2 sm:w-auto rounded-[10px]">
                            <label class="manage-re-filter-label rounded-[10px]">Status</label>
                            <select name="status" id="statusFilter" class="manage-re-filter-select w-full sm:w-auto rounded-[10px]">
                                <option value="All">All</option>
                                <option value="Reported">Reported</option>
                                <option value="In Progress">In Progress</option>
                                <option value="Resolved">Resolved</option>
                            </select>
                        </div>
                        <div class="w-1/2 sm:w-auto rounded-[10px]">
                            <label class="manage-re-filter-label rounded-[10px]">Severity</label>
                            <select name="severity" id="severityFilter" class="manage-re-filter-select w-full sm:w-auto rounded-[10px]">
                                <option value="All">All</option>
                                <option value="Small">Small</option>
                                <option value="Moderate">Moderate</option>
                                <option value="Critical">Critical</option>
                            </select>
                        </div>
                    </div>
                    <div class="flex flex-row gap-2 w-full sm:w-auto rounded-[15px]">
                        <button type="submit" class="manage-re-filter-btn w-1/2 sm:w-auto rounded-[10px]">Filter</button>
                        <button type="button" id="resetBtn" class="manage-re-filter-btn w-1/2 sm:w-auto bg-gray-300 text-white hover:bg-gray-400 border-none rounded-[10px]">Reset</button>
                    </div>
                </form>
                <!-- Section: Heatmap -->
                <div class="mt-6 mb-8 rounded-[15px]">
                    <div id="heatmap" style="height: 400px; width: 100%; border-radius: 20px; overflow: hidden; box-shadow: 0 2px 8px #0001;"></div>
                </div>
                <div id="reportsGrid" class="manage-re-grid rounded-[15px]">
                    <!-- Reports will be loaded here via JS -->
                </div>
            </div>
        </section>
    </main>
    <script src="javascript/script.js"></script>
    <script>
        // Section: Leaflet Heatmap Setup
        let map, heatCritical, heatModerate, heatSmall;

        function initMap() {
            if (map) return;
            const sriLankaBounds = L.latLngBounds([5.719, 79.521], [9.850, 81.881]);
            map = L.map('heatmap', {
                maxBounds: sriLankaBounds,
                maxBoundsViscosity: 1.0,
                minZoom: 7,
                maxZoom: 12,
                zoomControl: true
            }).setView([7.8731, 80.7718], 7);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap contributors'
            }).addTo(map);
            heatCritical = L.heatLayer([], {
                radius: 25,
                blur: 18,
                maxZoom: 12,
                gradient: {
                    0.4: 'red',
                    0.7: 'red',
                    1.0: 'darkred'
                }
            }).addTo(map);
            heatModerate = L.heatLayer([], {
                radius: 25,
                blur: 18,
                maxZoom: 12,
                gradient: {
                    0.4: 'yellow',
                    0.7: 'orange',
                    1.0: 'gold'
                }
            }).addTo(map);
            heatSmall = L.heatLayer([], {
                radius: 25,
                blur: 18,
                maxZoom: 12,
                gradient: {
                    0.4: 'green',
                    0.7: 'lime',
                    1.0: 'darkgreen'
                }
            }).addTo(map);
            map.setMaxBounds(sriLankaBounds);
        }

        function updateHeatmap(data) {
            if (!map) initMap();
            const critical = [],
                moderate = [],
                small = [];
            data.forEach(r => {
                if (r.Latitude && r.Longitude) {
                    const lat = parseFloat(r.Latitude);
                    const lng = parseFloat(r.Longitude);
                    if (r.SeverityLevel === 'Critical') critical.push([lat, lng, 1]);
                    else if (r.SeverityLevel === 'Moderate') moderate.push([lat, lng, 1]);
                    else if (r.SeverityLevel === 'Small') small.push([lat, lng, 1]);
                }
            });
            heatCritical.setLatLngs(critical);
            heatModerate.setLatLngs(moderate);
            heatSmall.setLatLngs(small);
        }
        // Section: Fetch and Render Reports + Heatmap
        function fetchReports() {
            const status = document.getElementById('statusFilter').value;
            const severity = document.getElementById('severityFilter').value;
            const userid = <?php echo json_encode($userid); ?>;
            fetch(`api/view_customers.php?action=reports&userid=${encodeURIComponent(userid)}&status=${encodeURIComponent(status)}&severity=${encodeURIComponent(severity)}`)
                .then(res => res.json())
                .then(data => {
                    updateHeatmap(data.reports || []);
                    const grid = document.getElementById('reportsGrid');
                    grid.innerHTML = '';
                    if (!data.reports || !data.reports.length) {
                        grid.innerHTML = '<div class="col-span-full text-center text-gray-500 py-12 bg-white rounded-[20px] shadow-sm border border-gray-100">No reports found.</div>';
                        return;
                    }
                    data.reports.forEach(report => {
                        const sevClass = report.SeverityLevel === 'Critical' ? 'bg-red-100 text-red-700' :
                            report.SeverityLevel === 'Moderate' ? 'bg-yellow-100 text-yellow-700' :
                            'bg-green-100 text-green-700';
                        const img = report.ImageURL ?
                            `<img src="${report.ImageURL}" alt="Pothole Image" class="object-cover w-full h-full rounded-[10px]">` :
                            `<span class="manage-re-no-img rounded-[10px]">No Image</span>`;
                        grid.innerHTML += `
<div class="manage-re-card rounded-[20px]">
    <div class="manage-re-card-inner rounded-[15px]">
        <div class="manage-re-card-header rounded-[15px]">
            <span class="text-xs text-gray-400 font-mono rounded-[10px]">#${report.ReportID}</span>
            <span class="manage-re-status-badge ${sevClass} rounded-[10px]">
                ${report.SeverityLevel}
            </span>
        </div>
        <div class="manage-re-img-wrap rounded-[15px]">
            ${img}
        </div>
        <div class="manage-re-card-section rounded-[15px]">
            <span class="manage-re-label rounded-[10px]">Status:</span>
            <span class="manage-re-value rounded-[10px]">${report.Status}</span>
        </div>
        <div class="manage-re-card-section rounded-[15px]">
            <span class="manage-re-label rounded-[10px]">Description:</span>
            <span class="manage-re-value rounded-[10px]">${report.Description || '<span class="italic text-gray-400">(No description)</span>'}</span>
        </div>
        <div class="manage-re-card-section rounded-[15px]">
            <span class="manage-re-label rounded-[10px]">Zip Code:</span>
            <span class="manage-re-value rounded-[10px]">${report.ZipCode}</span>
        </div>
        <div class="manage-re-card-section rounded-[15px]">
            <span class="manage-re-label rounded-[10px]">Location:</span>
            <span class="manage-re-value rounded-[10px]">Lat: ${report.Latitude}, Lng: ${report.Longitude}</span>
        </div>
        <div class="flex justify-between items-center mt-2 rounded-[15px]">
            <div class="manage-re-timestamp rounded-[10px]">
                ${report.Timestamp}
            </div>
            <a href="https://www.google.com/maps?q=${report.Latitude},${report.Longitude}" target="_blank"
               class="text-blue-600 text-sm underline hover:text-blue-800 rounded-[10px]">
                View on Google Maps
            </a>
        </div>
    </div>
</div>
`;
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
        // Section: Initial load
        initMap();
        fetchReports();
    </script>
</body>

</html>