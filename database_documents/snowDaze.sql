-- MySQL Workbench Forward Engineering

SET
@OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET
@OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET
@OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema snowDaze
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `snowDaze`;

-- -----------------------------------------------------
-- Schema snowDaze
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `snowDaze` DEFAULT CHARACTER SET utf8;
USE
`snowDaze` ;

-- -----------------------------------------------------
-- Table `Location`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Location`
(
    `location_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `city`
    VARCHAR
(
    45
) NOT NULL,
    `state` VARCHAR
(
    45
) NOT NULL,
    `street_name` VARCHAR
(
    45
) NOT NULL,
    `street_number` VARCHAR
(
    45
) NOT NULL,
    `zip_code` VARCHAR
(
    45
) NOT NULL,
    PRIMARY KEY
(
    `location_id`
))
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Weather_Sources`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Weather_Sources`
(
    `weather_source_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `weather_source_url`
    TEXT
    NOT
    NULL,

    PRIMARY
    KEY
(
    `weather_source_id`
))
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Traffic_Sources`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Traffic_Sources`
(
    `traffic_source_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `traffic_source_url`
    TEXT
    NOT
    NULL,

    PRIMARY
    KEY
(
    `traffic_source_id`
))
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Resorts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Resorts`
(
    `resort_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `resort_name`
    VARCHAR
(
    100
) NOT NULL,
    `resort_location` INT NOT NULL,
    `resort_phone` VARCHAR
(
    45
) NOT NULL,
    `resort_website` TEXT NOT NULL,
    `resort_traffic_source` INT NOT NULL,
    `resort_weather_source` INT NOT NULL,
    PRIMARY KEY
(
    `resort_id`
),
    CONSTRAINT `fk_Resorts_Location`
    FOREIGN KEY
(
    `resort_location`
)
    REFERENCES `Location`
(
    `location_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Resorts_Weather_Sources1`
    FOREIGN KEY
(
    `resort_weather_source`
)
    REFERENCES `Weather_Sources`
(
    `weather_source_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Resorts_Traffic_Sources1`
    FOREIGN KEY
(
    `resort_traffic_source`
)
    REFERENCES `Traffic_Sources`
(
    `traffic_source_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;

CREATE INDEX `fk_Resorts_Location_idx` ON `Resorts` (`resort_location`
                                                     ASC) VISIBLE;
CREATE INDEX `fk_Resorts_Weather_Sources1_idx` ON `Resorts` (`resort_weather_source`
                                                             ASC) VISIBLE;
CREATE INDEX `fk_Resorts_Traffic_Sources1_idx` ON `Resorts` (`resort_traffic_source`
                                                             ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Slope_Difficulty_Categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Slope_Difficulty_Categories`
(
    `slope_difficulty_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `slope_difficulty_level`
    VARCHAR
(
    45
) NOT NULL,
    PRIMARY KEY
(
    `slope_difficulty_id`
))
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Slopes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Slopes`
(
    `slope_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `slope_name`
    VARCHAR
(
    100
) NOT NULL,
    `slope_difficulty` INT NOT NULL,
    `slope_difficulty_id` INT NOT NULL,
    PRIMARY KEY
(
    `slope_id`
),
    CONSTRAINT `fk_Slopes_Slope_Difficulties1`
    FOREIGN KEY
(
    `slope_difficulty_id`
)
    REFERENCES `Slope_Difficulty_Categories`
(
    `slope_difficulty_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;

CREATE INDEX `fk_Slopes_Slope_Difficulties1_idx` ON `Slopes` (`slope_difficulty_id`
                                                              ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Resort_Slopes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Resort_Slopes`
(
    `slope_id`
    INT
    NOT
    NULL,
    `resort_id`
    INT
    NOT
    NULL,

    PRIMARY
    KEY
(
    `slope_id`,
    `resort_id`
),
    CONSTRAINT `fk_Slopes_has_Resorts_Slopes1`
    FOREIGN KEY
(
    `slope_id`
)
    REFERENCES `Slopes`
(
    `slope_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Slopes_has_Resorts_Resorts1`
    FOREIGN KEY
(
    `resort_id`
)
    REFERENCES `Resorts`
(
    `resort_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;

CREATE INDEX `fk_Slopes_has_Resorts_Resorts1_idx` ON `Resort_Slopes` (`resort_id`
                                                                      ASC) VISIBLE;
CREATE INDEX `fk_Slopes_has_Resorts_Slopes1_idx` ON `Resort_Slopes` (`slope_id`
                                                                     ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Chain_Control_Category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Chain_Control_Category`
(
    `chain_control_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `chain_control_level_description`
    VARCHAR
(
    45
) NOT NULL,
    `chain_control_level` VARCHAR
(
    45
) NOT NULL,
    PRIMARY KEY
(
    `chain_control_id`
))
    ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Road_Status_Category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Road_Status_Category`
(
    `road_status_category_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `road_status`
    VARCHAR
(
    45
) NOT NULL,
    PRIMARY KEY
(
    `road_status_category_id`
))
    ENGINE = InnoDB
    COMMENT = 'road_status categories include: open no restrictions, closed, open with restrictions';


-- -----------------------------------------------------
-- Table `Road_Status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Road_Status`
(
    `road_status_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `chain_control`
    INT
    NOT
    NULL,
    `road_status`
    INT
    NOT
    NULL,

    PRIMARY
    KEY
(
    `road_status_id`
),
    CONSTRAINT `fk_Roads_Status_Categories_Chain_Control_Category1`
    FOREIGN KEY
(
    `chain_control`
)
    REFERENCES `Chain_Control_Category`
(
    `chain_control_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Road_Status_Road_Status_Category1`
    FOREIGN KEY
(
    `road_status`
)
    REFERENCES `Road_Status_Category`
(
    `road_status_category_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB
    COMMENT = 'road_status collects the information about the status of the road and the status of the roads chain control';

CREATE INDEX `fk_Roads_Status_Categories_Chain_Control_Category1_idx` ON `Road_Status` (`chain_control`
                                                                                        ASC) VISIBLE;
CREATE INDEX `fk_Road_Status_Road_Status_Category1_idx` ON `Road_Status` (`road_status`
                                                                          ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Access_Roads`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Access_Roads`
(
    `road_id`
    INT
    NOT
    NULL
    AUTO_INCREMENT,
    `road_name`
    VARCHAR
(
    245
) NOT NULL,
    `road_direction` VARCHAR
(
    45
) NOT NULL,
    `road_status` INT NOT NULL,
    PRIMARY KEY
(
    `road_id`
),
    CONSTRAINT `fk_Access_Roads_Roads_Statuses1`
    FOREIGN KEY
(
    `road_status`
)
    REFERENCES `Road_Status`
(
    `road_status_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;

CREATE INDEX `fk_Access_Roads_Roads_Statuses1_idx` ON `Access_Roads` (`road_status`
                                                                      ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `Resort_Access_Roads`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Resort_Access_Roads`
(
    `resort_id`
    INT
    NOT
    NULL,
    `access_road_id`
    INT
    NOT
    NULL,
    `is_to_resort`
    TINYINT
    NOT
    NULL,
    `is_from_resort`
    TINYINT
    NOT
    NULL,

    PRIMARY
    KEY
(
    `resort_id`,
    `access_road_id`
),
    CONSTRAINT `fk_Resorts_has_Access_Roads_Resorts1`
    FOREIGN KEY
(
    `resort_id`
)
    REFERENCES `Resorts`
(
    `resort_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT `fk_Resorts_has_Access_Roads_Access_Roads1`
    FOREIGN KEY
(
    `access_road_id`
)
    REFERENCES `Access_Roads`
(
    `road_id`
)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
    ENGINE = InnoDB;

CREATE INDEX `fk_Resorts_has_Access_Roads_Access_Roads1_idx` ON `Resort_Access_Roads` (`access_road_id`
                                                                                       ASC) VISIBLE;
CREATE INDEX `fk_Resorts_has_Access_Roads_Resorts1_idx` ON `Resort_Access_Roads` (`resort_id`
                                                                                  ASC) VISIBLE;


SET
SQL_MODE=@OLD_SQL_MODE;
SET
FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET
UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
