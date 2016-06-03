/*
Navicat MySQL Data Transfer

Source Server         : 虚拟机
Source Server Version : 50547
Source Host           : 192.168.1.75:3306
Source Database       : game

Target Server Type    : MYSQL
Target Server Version : 50547
File Encoding         : 65001

Date: 2016-06-03 17:02:42
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `nickname` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `mobilephone` varchar(255) DEFAULT NULL,
  `gold` bigint(20) NOT NULL,
  `gem` bigint(20) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('8', '18065367676', '', 'a0cc1916862af87ca2019c36c9329280', null, '0', '0', '2016-06-02 15:02:54', null, null);

-- ----------------------------
-- Table structure for version
-- ----------------------------
DROP TABLE IF EXISTS `version`;
CREATE TABLE `version` (
  `base` varchar(255) NOT NULL,
  `version` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ----------------------------
-- Records of version
-- ----------------------------
INSERT INTO `version` VALUES ('1', '100000');

-- ----------------------------
-- Procedure structure for sp_Register
-- ----------------------------
DROP PROCEDURE IF EXISTS `sp_Register`;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `sp_Register`(IN `_username` varchar(255),IN `_password` varchar(255))
BEGIN
	#Routine body goes here...
	declare _hasRecord int ;
	DECLARE _now datetime;
	
  set _now = NOW();
	SELECT count(*) from user where username = _username into _hasRecord;
	
	if not _hasRecord then
		insert into user (username,password,created_at) value(_username,_password,_now);
	end if;
	select * from user where username = _username and password = _password and created_at = _now;

END
;;
DELIMITER ;
