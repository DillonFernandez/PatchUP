-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 17, 2025 at 09:20 AM
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
  `ReportID` int(11) NOT NULL,
  `Title` varchar(120) NOT NULL,
  `Body` varchar(255) NOT NULL,
  `DataJSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`DataJSON`)),
  `IsRead` tinyint(1) NOT NULL DEFAULT 0,
  `CreatedAt` datetime NOT NULL DEFAULT current_timestamp(),
  `ReadAt` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification`
--

INSERT INTO `notification` (`NotificationID`, `UserID`, `ReportID`, `Title`, `Body`, `DataJSON`, `IsRead`, `CreatedAt`, `ReadAt`) VALUES
(1, 2, 5, 'Pothole #5 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-17 12:21:48', NULL),
(2, 2, 2, 'Pothole #2 status updated', 'Status changed from Reported to Resolved.', '{\"old_status\": \"Reported\", \"new_status\": \"Resolved\"}', 0, '2025-08-17 12:21:51', NULL),
(3, 2, 1, 'Pothole #1 status updated', 'Status changed from Reported to In Progress.', '{\"old_status\": \"Reported\", \"new_status\": \"In Progress\"}', 0, '2025-08-17 12:21:53', NULL);

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
(1, 2, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:40:07', 'In Progress', 100, 6.927100, 79.861200),
(2, 2, 'Minor surface-level pothole, requires monitoring.', 'Small', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Resolved', 40000, 9.661500, 80.025500),
(3, 3, 'Medium-depth pothole, may damage vehicles if not repaired soon.', 'Moderate', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 31000, 8.587400, 81.215200),
(4, 3, 'Severe pothole posing a safety hazard, requires immediate attention.', 'Critical', '/patchup_app/uploads/img_688349ef19485_5f36ec4c-ceb2-4a6d-9ab4-f8aa1901e7402753194180329228425.jpg', '2025-07-25 14:50:46', 'Reported', 20000, 7.290600, 80.633700),
(5, 2, 'Offline test 1', 'Critical', '/patchup_app/uploads/img_68970b25931a0_13816123-0893-4deb-8601-79223e9360c57178158823939428142.jpg', '2025-08-09 14:17:33', 'In Progress', 11320, 7.047546, 79.899443);

--
-- Triggers `potholereport`
--
DELIMITER $$
CREATE TRIGGER `trg_pothole_status_notify` AFTER UPDATE ON `potholereport` FOR EACH ROW BEGIN
  IF NEW.`Status` <> OLD.`Status` THEN
    INSERT INTO `notification`
      (`UserID`, `ReportID`, `Title`, `Body`, `DataJSON`)
    VALUES
      (
        NEW.`UserID`,
        NEW.`ReportID`,
        CONCAT('Pothole #', NEW.`ReportID`, ' status updated'),
        CONCAT('Status changed from ', OLD.`Status`, ' to ', NEW.`Status`, '.'),
        JSON_OBJECT(
          'old_status', OLD.`Status`,
          'new_status', NEW.`Status`
        )
      );
  END IF;
END
$$
DELIMITER ;

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
(4, 'Test User', 'test@gmail.com', '$2y$10$7SuV7maSbb5nvB/O.12E4O.O2oOh3Przj7vrUnd2wLqAzdn6M8rHa', 0);

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
  ADD KEY `idx_user_created` (`UserID`,`CreatedAt`),
  ADD KEY `idx_report_created` (`ReportID`,`CreatedAt`);

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
  MODIFY `NotificationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `potholereport`
--
ALTER TABLE `potholereport`
  MODIFY `ReportID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  ADD CONSTRAINT `fk_notification_report` FOREIGN KEY (`ReportID`) REFERENCES `potholereport` (`ReportID`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_notification_user` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`) ON DELETE CASCADE;

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
