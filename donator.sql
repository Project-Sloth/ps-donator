DROP TABLE IF EXISTS `donator`;
CREATE TABLE `donator` (
    `license` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
    `coins` INT(11) NOT NULL DEFAULT 0,
    UNIQUE INDEX `license` (`license`) USING BTREE
);

DROP TABLE IF EXISTS `donator_pending`;
CREATE TABLE `donator_pending` (
    `transactionId` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
    `package` LONGTEXT NOT NULL COLLATE 'utf8_general_ci',
    `redeemed` INT(11) NOT NULL DEFAULT '0',
    PRIMARY KEY (`transactionId`) USING BTREE
);