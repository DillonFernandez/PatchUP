-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 27, 2025 at 10:51 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `patchup`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `AdminID` int(11) NOT NULL,
  `Name` varchar(100) NOT NULL,
  `Email` varchar(150) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`AdminID`, `Name`, `Email`, `PasswordHash`) VALUES
(1, 'Dillon Fernandez', 'dillon@gmail.com', 'Dillon@1'),
(2, 'Hiranya Nirmal', 'hiranya@gmail.com', 'Hiranya@1'),
(3, 'Sanura Devjan', 'sanura@gmail.com', 'Sanura@1'),
(4, 'Akshith Rithushan', 'akshith@gmail.com', 'Akshith@1');

-- --------------------------------------------------------

--
-- Table structure for table `badge`
--

CREATE TABLE `badge` (
  `BadgeID` int(11) NOT NULL,
  `BadgeName` varchar(100) NOT NULL,
  `Description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leaderboardentry`
--

CREATE TABLE `leaderboardentry` (
  `EntryID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Month` int(11) NOT NULL,
  `Year` int(11) NOT NULL,
  `Points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `NotificationID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Message` text NOT NULL,
  `CreatedAt` datetime NOT NULL DEFAULT current_timestamp(),
  `SeenStatus` varchar(10) NOT NULL DEFAULT 'Unseen'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `potholereport`
--

CREATE TABLE `potholereport` (
  `ReportID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Description` text DEFAULT NULL,
  `SeverityLevel` varchar(10) NOT NULL,
  `ImageURL` varchar(255) DEFAULT NULL,
  `Timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  `Status` varchar(20) NOT NULL DEFAULT 'Reported',
  `ZipCode` int(11) NOT NULL,
  `Latitude` decimal(9,6) NOT NULL,
  `Longitude` decimal(9,6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `potholereport`
--

INSERT INTO `potholereport` (`ReportID`, `UserID`, `Description`, `SeverityLevel`, `ImageURL`, `Timestamp`, `Status`, `ZipCode`, `Latitude`, `Longitude`) VALUES
(1, 2, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:40:07', 'Reported', 100, 6.927100, 79.861200),
(2, 2, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 20000, 7.290600, 80.633700),
(3, 2, 'Medium-depth pothole, may damage vehicles if not repaired soon.', 'Moderate', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 80000, 6.053500, 80.220000),
(4, 2, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 22200, 6.949700, 80.789100),
(5, 2, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'In Progress', 21120, 7.957000, 80.760300),
(6, 3, 'Medium-depth pothole, may damage vehicles if not repaired soon.', 'Moderate', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'In Progress', 50000, 8.311400, 80.403700),
(7, 3, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 51000, 7.939400, 81.000300),
(8, 3, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 21100, 7.856000, 80.651100),
(9, 3, 'Medium-depth pothole, may damage vehicles if not repaired soon.', 'Moderate', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'In Progress', 31000, 8.587400, 81.215200),
(10, 3, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Resolved', 40000, 9.661500, 80.025500),
(11, 4, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 15:42:43', 'Reported', 32500, 6.839300, 81.836300),
(12, 4, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_68836807c770e_55259496-0e93-4ce4-bff6-2f4d4b9b53035630922262713800944.jpg', '2025-07-25 16:48:31', 'Reported', 90090, 6.875300, 81.046900),
(13, 4, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_6883da7881f4d_adf36596-dbe1-45ce-8c25-882357e9ce708997312964316498072.jpg', '2025-07-26 00:56:48', 'Reported', 82600, 6.366600, 81.499000),
(14, 4, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_6883dbd69dcf6_8a40c3ec-939a-41ff-abda-3fa657a2ff145815127699207144132.jpg', '2025-07-26 01:02:38', 'Reported', 22216, 6.800000, 80.800000),
(15, 4, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_6883dc2413f12_cb19a838-5c25-446a-9f93-7b1f2e5cb7ca6547428922718307582.jpg', '2025-07-26 01:03:56', 'Reported', 41000, 8.971200, 79.913300),
(16, 4, 'Medium-depth pothole, may damage vehicles if not repaired soon.', 'Moderate', '/patchup_app/uploads/img_6883dcaa32ba3_d9abe61b-b3f7-477f-a7cc-49851e967a703733471441431390199.jpg', '2025-07-26 01:06:10', 'Reported', 61360, 8.236000, 79.759400),
(17, 5, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_688524f333972_b949ed5e-b341-4dc0-947a-8b6222a16f791822590115738653714.jpg', '2025-07-27 00:26:51', 'Reported', 11320, 7.047503, 79.899384),
(18, 3, 'Medium-depth pothole, may damage vehicles if not repaired soon.', 'Moderate', '/patchup_app/uploads/img_6885e7388f174_6fc2b840-86f1-4a56-92e0-dbb351c2d92e4342135641658813191.jpg', '2025-07-27 14:15:44', 'Reported', 11320, 7.047515, 79.899357);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `UserID` int(11) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL,
  `Points` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`UserID`, `Name`, `Email`, `PasswordHash`, `Points`) VALUES
(2, 'Dillon Fernandez', 'dillon@gmail.com', '$2y$10$mTKlAcwGyGHDtdVXah.PUuWNKLBDUDz41BmfWEvLc35rwazG91ehm', 0),
(3, 'Hiranya Nirmal', 'hiranya@gmail.com', '$2y$10$40YtgoJc76aZTXx58FaJs.uEO1.3sozFt/V4RL3mH.FiSKFbOJJPC', 0),
(4, 'Sanura Devjan', 'sanura@gmail.com', '$2y$10$YKs7uPXFuIhw/.Ci8KqLAutAqymkIASnbhzQ9Q.5AlC1i24011/0y', 0),
(5, 'Akshith Rithushan', 'akshith@gmail.com', '$2y$10$vqRhavwO7MZfQ5wCrZV1YuSETTKaXAyRxj2bUlzwi2rPZzuP7BZ/i', 0);

-- --------------------------------------------------------

--
-- Table structure for table `userbadge`
--

CREATE TABLE `userbadge` (
  `UserBadgeID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `BadgeID` int(11) NOT NULL,
  `EarnedAt` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`AdminID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `badge`
--
ALTER TABLE `badge`
  ADD PRIMARY KEY (`BadgeID`),
  ADD UNIQUE KEY `BadgeName` (`BadgeName`);

--
-- Indexes for table `leaderboardentry`
--
ALTER TABLE `leaderboardentry`
  ADD PRIMARY KEY (`EntryID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`NotificationID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `potholereport`
--
ALTER TABLE `potholereport`
  ADD PRIMARY KEY (`ReportID`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Indexes for table `userbadge`
--
ALTER TABLE `userbadge`
  ADD PRIMARY KEY (`UserBadgeID`),
  ADD KEY `UserID` (`UserID`),
  ADD KEY `BadgeID` (`BadgeID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `AdminID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `badge`
--
ALTER TABLE `badge`
  MODIFY `BadgeID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leaderboardentry`
--
ALTER TABLE `leaderboardentry`
  MODIFY `EntryID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `NotificationID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `potholereport`
--
ALTER TABLE `potholereport`
  MODIFY `ReportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `userbadge`
--
ALTER TABLE `userbadge`
  MODIFY `UserBadgeID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `leaderboardentry`
--
ALTER TABLE `leaderboardentry`
  ADD CONSTRAINT `leaderboardentry_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`);

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`);

--
-- Constraints for table `potholereport`
--
ALTER TABLE `potholereport`
  ADD CONSTRAINT `potholereport_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`);

--
-- Constraints for table `userbadge`
--
ALTER TABLE `userbadge`
  ADD CONSTRAINT `userbadge_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`),
  ADD CONSTRAINT `userbadge_ibfk_2` FOREIGN KEY (`BadgeID`) REFERENCES `badge` (`BadgeID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
