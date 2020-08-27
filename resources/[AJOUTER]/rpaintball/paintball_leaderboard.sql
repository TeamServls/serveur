-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le :  Dim 19 jan. 2020 à 17:05
-- Version du serveur :  10.4.10-MariaDB
-- Version de PHP :  7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `fxserveur`
--

-- --------------------------------------------------------

--
-- Structure de la table `paintball_leaderboard`
--

DROP TABLE IF EXISTS `paintball_leaderboard`;
CREATE TABLE IF NOT EXISTS `paintball_leaderboard` (
  `id` varchar(30) CHARACTER SET utf8 NOT NULL,
  `kill` int(11) NOT NULL DEFAULT 0,
  `mort` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Déchargement des données de la table `paintball_leaderboard`
--

INSERT INTO `paintball_leaderboard` (`id`, `kill`, `mort`) VALUES
('steam:11000010dbee8b6', 45, 23),
('steam:110000132bd968a', 6, 7),
('steam:11000013cae2393', 7, 6);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
