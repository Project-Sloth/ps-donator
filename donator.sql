CREATE TABLE `donator` (
	`license` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
	`coins` INT(11) NOT NULL DEFAULT 0,
	UNIQUE INDEX `license` (`license`) USING BTREE
)