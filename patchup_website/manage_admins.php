<?php
// Section: Session Start and Redirect if Not Authenticated
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
    <title>Patch | Manage Admins</title>
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
                <a href="manage_admins.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white text-[#04274B] font-medium bg-[#04274B] bg-opacity-10">Manage Admins</a>
                <a href="manage_reports.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">Manage Reports</a>
                <a href="view_customers.php" class="block py-2 px-4 rounded-md hover:bg-[#04274B] hover:text-white">View Customers</a>
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

    <!-- Section: Main Content -->
    <main class="flex-1 md:ml-64 bg-gray-50 min-h-screen overflow-x-hidden">

        <!-- Section: Header Bar -->
        <header class="bg-white px-6 py-4 flex items-center justify-between border-b shadow-sm">
            <button id="menuToggle" class="md:hidden text-[#04274B] focus:outline-none z-10">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7" />
                </svg>
            </button>
            <h1 class="text-xl md:text-2xl font-bold text-[#04274B] mx-auto md:mx-0 md:mb-1">Manage Admins</h1>
        </header>

        <!-- Section: Admin Management -->
        <section class="w-full mx-auto px-[30px] py-[30px] sm:px-4 md:px-10 md:py-10 rounded-[20px]">
            <div id="message" class="rounded-[15px]"></div>
            <div id="adminsCardGrid" class="grid gap-6 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 rounded-[15px]">
                <!-- Admin cards will be inserted here by JS -->
            </div>
            <button id="showAddAdminBtn" class="mt-6 bg-[#04274B] text-white px-6 py-2 rounded-[15px] shadow manage-ad-shadow-btn font-semibold flex items-center gap-2 hover:bg-[#06477B] transition">
                Add Admin
            </button>
            <!-- Section: Add Admin Modal -->
            <div id="addAdminModal" class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 hidden">
                <div class="bg-white rounded-[20px] shadow-2xl w-full max-w-md p-8 relative manage-ad-shadow-modal">
                    <button id="closeAddAdminModal" class="absolute top-3 right-3 text-gray-400 hover:text-gray-700 text-2xl font-bold rounded-[10px]">&times;</button>
                    <h2 class="text-xl font-bold mb-4 text-[#04274B] flex items-center gap-2 rounded-[15px]">
                        Add New Admin
                    </h2>
                    <form id="addAdminForm" class="space-y-5 rounded-[15px]">
                        <div id="addAdminFormMsg" class="rounded-[10px]"></div>
                        <div class="rounded-[10px]">
                            <label class="block mb-1 font-medium text-gray-700 rounded-[10px]">Name</label>
                            <input type="text" name="name" class="w-full border border-gray-200 px-3 py-2 rounded-[10px] focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition manage-ad-shadow-input" required>
                        </div>
                        <div class="rounded-[10px]">
                            <label class="block mb-1 font-medium text-gray-700 rounded-[10px]">Email</label>
                            <input type="email" name="email" class="w-full border border-gray-200 px-3 py-2 rounded-[10px] focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition manage-ad-shadow-input" required>
                        </div>
                        <div class="rounded-[10px]">
                            <label class="block mb-1 font-medium text-gray-700 rounded-[10px]">Password</label>
                            <input type="text" name="password" class="w-full border border-gray-200 px-3 py-2 rounded-[10px] focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition manage-ad-shadow-input" required>
                        </div>
                        <button type="submit" class="w-full bg-[#04274B] text-white px-4 py-2 rounded-[10px] shadow manage-ad-shadow-btn font-semibold hover:bg-[#06477B] transition">Add Admin</button>
                    </form>
                </div>
            </div>
            <!-- Section: Edit Admin Modal -->
            <div id="editAdminModal" class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 hidden">
                <div class="bg-white rounded-[20px] shadow-2xl w-full max-w-md p-8 relative manage-ad-shadow-modal">
                    <button id="closeEditAdminModal" class="absolute top-3 right-3 text-gray-400 hover:text-gray-700 text-2xl font-bold rounded-[10px]">&times;</button>
                    <h2 class="text-xl font-bold mb-4 text-[#04274B] flex items-center gap-2 rounded-[15px]">
                        Edit Admin
                    </h2>
                    <form id="editAdminForm" class="space-y-5 rounded-[15px]">
                        <div id="editAdminFormMsg" class="rounded-[10px]"></div>
                        <input type="hidden" name="id" id="editAdminId">
                        <div class="rounded-[10px]">
                            <label class="block mb-1 font-medium text-gray-700 rounded-[10px]">Name</label>
                            <input type="text" name="name" id="editAdminName" class="w-full border border-gray-200 px-3 py-2 rounded-[10px] focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition manage-ad-shadow-input" required>
                        </div>
                        <div class="rounded-[10px]">
                            <label class="block mb-1 font-medium text-gray-700 rounded-[10px]">Email</label>
                            <input type="email" name="email" id="editAdminEmail" class="w-full border border-gray-200 px-3 py-2 rounded-[10px] focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition manage-ad-shadow-input" required>
                        </div>
                        <div class="rounded-[10px]">
                            <label class="block mb-1 font-medium text-gray-700 rounded-[10px]">Password <span class="text-gray-400 text-xs rounded-[10px]">(leave blank to keep unchanged)</span></label>
                            <input type="text" name="password" id="editAdminPassword" class="w-full border border-gray-200 px-3 py-2 rounded-[10px] focus:ring-2 focus:ring-[#04274B] focus:border-[#04274B] transition manage-ad-shadow-input">
                        </div>
                        <button type="submit" class="w-full bg-[#04274B] text-white px-4 py-2 rounded-[10px] shadow manage-ad-shadow-btn font-semibold hover:bg-[#06477B] transition">Save Changes</button>
                    </form>
                </div>
            </div>

            <!-- Section: Delete Confirmation Modal -->
            <div id="deleteConfirmModal" class="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 hidden">
                <div class="bg-white rounded-[20px] shadow-2xl w-full max-w-sm p-6 relative manage-ad-shadow-modal">
                    <button id="closeDeleteConfirmModal" class="absolute top-3 right-3 text-gray-400 hover:text-gray-700 text-2xl font-bold rounded-[10px]">&times;</button>
                    <h2 class="text-lg font-bold mb-4 text-[#04274B] rounded-[15px]">Delete Admin</h2>
                    <p class="mb-6 text-gray-700 rounded-[15px]">Are you sure you want to delete this admin?</p>
                    <div class="flex justify-end gap-3 rounded-[15px]">
                        <button id="cancelDeleteBtn" class="px-4 py-2 rounded-[10px] bg-gray-200 text-gray-700 font-semibold hover:bg-gray-300 transition">Cancel</button>
                        <button id="confirmDeleteBtn" class="px-4 py-2 rounded-[10px] bg-red-500 text-white font-semibold hover:bg-red-600 transition">Delete</button>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <script>
        // Section: Fetch and Display Admins as Cards
        function loadAdmins() {
            fetch('api/manage_admins.php?action=list')
                .then(res => res.json())
                .then(data => {
                    const grid = document.getElementById('adminsCardGrid');
                    grid.innerHTML = '';
                    data.admins.forEach(admin => {
                        let actions = '';
                        if (admin.is_current) {
                            actions = '<span class="text-gray-400 font-semibold rounded-[10px]">Current</span>';
                        } else {
                            actions = `
    <div class="flex items-center gap-2 bg-gray-100 rounded-[15px] px-2 py-1">
        <a href="#" class="text-blue-600 hover:underline font-semibold px-2 py-1 rounded-[10px] hover:bg-blue-50 transition" onclick="showEditAdminModal(${admin.AdminID}, '${encodeURIComponent(admin.Name)}', '${encodeURIComponent(admin.Email)}');return false;">
            Edit
        </a>
        <span class="text-gray-400 select-none rounded-[10px]">|</span>
        <a href="#" class="text-red-600 hover:underline font-semibold px-2 py-1 rounded-[10px] hover:bg-red-50 transition" onclick="deleteAdmin(${admin.AdminID});return false;">
            Delete
        </a>
    </div>
                            `;
                        }
                        grid.innerHTML += `
                        <div class="manage-ad-shadow-card bg-white rounded-[20px] p-5 flex flex-col gap-2">
                            <div class="flex items-center justify-between mb-2 rounded-[15px]">
                                <span class="text-xs text-gray-400 font-semibold rounded-[10px]">ID: ${admin.AdminID}</span>
                                ${actions}
                            </div>
                            <div class="mb-1 rounded-[15px]">
                                <div class="text-base font-bold text-[#04274B] rounded-[10px]">${admin.Name}</div>
                                <div class="text-sm text-gray-600 rounded-[10px]">${admin.Email}</div>
                            </div>
                        </div>
                        `;
                    });
                });
        }

        // Section: Show Message Helper
        function showMessage(msg, type) {
            const div = document.getElementById('message');
            div.innerHTML = `<div class="px-4 py-2 rounded mb-4 ${type === 'error' ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'}">${msg}</div>`;
            setTimeout(() => {
                div.innerHTML = '';
            }, 3000);
        }

        // Section: Modal Logic for Add Admin
        const modal = document.getElementById('addAdminModal');
        document.getElementById('showAddAdminBtn').onclick = () => {
            modal.classList.remove('hidden');
        };
        document.getElementById('closeAddAdminModal').onclick = () => {
            modal.classList.add('hidden');
        };
        window.onclick = function(event) {
            if (event.target === modal) modal.classList.add('hidden');
            if (event.target === editModal) editModal.classList.add('hidden');
        };

        document.getElementById('addAdminForm').onsubmit = function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const msgDiv = document.getElementById('addAdminFormMsg');
            msgDiv.innerHTML = '';
            fetch('api/manage_admins.php?action=add', {
                    method: 'POST',
                    body: formData
                }).then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        this.reset();
                        modal.classList.add('hidden');
                        msgDiv.innerHTML = '';
                        loadAdmins();
                    } else {
                        msgDiv.innerHTML = `<div class="bg-red-100 text-red-700 px-4 py-2 rounded mb-2">${data.message}</div>`;
                    }
                });
        };

        // Section: Modal Logic for Edit Admin
        const editModal = document.getElementById('editAdminModal');
        document.getElementById('closeEditAdminModal').onclick = () => {
            editModal.classList.add('hidden');
        };

        function showEditAdminModal(id, name, email) {
            document.getElementById('editAdminId').value = id;
            document.getElementById('editAdminName').value = decodeURIComponent(name);
            document.getElementById('editAdminEmail').value = decodeURIComponent(email);
            document.getElementById('editAdminPassword').value = '';
            document.getElementById('editAdminFormMsg').innerHTML = '';
            editModal.classList.remove('hidden');
        }
        document.getElementById('editAdminForm').onsubmit = function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const msgDiv = document.getElementById('editAdminFormMsg');
            msgDiv.innerHTML = '';
            fetch('api/manage_admins.php?action=edit', {
                    method: 'POST',
                    body: formData
                }).then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        this.reset();
                        editModal.classList.add('hidden');
                        msgDiv.innerHTML = '';
                        loadAdmins();
                    } else {
                        msgDiv.innerHTML = `<div class="bg-red-100 text-red-700 px-4 py-2 rounded mb-2">${data.message}</div>`;
                    }
                });
        };

        // Section: Modal Logic for Delete Confirmation
        let deleteAdminId = null;
        const deleteModal = document.getElementById('deleteConfirmModal');
        const closeDeleteBtn = document.getElementById('closeDeleteConfirmModal');
        const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
        const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');

        function deleteAdmin(id) {
            deleteAdminId = id;
            deleteModal.classList.remove('hidden');
        }

        closeDeleteBtn.onclick = () => {
            deleteModal.classList.add('hidden');
            deleteAdminId = null;
        };
        cancelDeleteBtn.onclick = () => {
            deleteModal.classList.add('hidden');
            deleteAdminId = null;
        };
        confirmDeleteBtn.onclick = () => {
            if (!deleteAdminId) return;
            fetch('api/manage_admins.php?action=delete', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'id=' + encodeURIComponent(deleteAdminId)
                }).then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showMessage(data.message, 'success');
                        loadAdmins();
                    } else {
                        showMessage(data.message, 'error');
                    }
                    deleteModal.classList.add('hidden');
                    deleteAdminId = null;
                });
        };

        // Section: Close Modal When Clicking Outside
        window.addEventListener('click', function(event) {
            if (event.target === deleteModal) {
                deleteModal.classList.add('hidden');
                deleteAdminId = null;
            }
            if (event.target === modal) modal.classList.add('hidden');
            if (event.target === editModal) editModal.classList.add('hidden');
        });

        // Section: Initial Load of Admins
        loadAdmins();
    </script>

    <!-- Section: Sidebar Toggle Script -->
    <script src="javascript/script.js"></script>
</body>

</html>