/* Function to check the item name is available in the menu list */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_ITEM`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_ITEM`(param_item_name VARCHAR(20)) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM ITEM WHERE NAME=param_item_name);
END$$
DELIMITER ;


/* Function to check the integer is non negative */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_NUM`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_NUM`(param_number INT) RETURNS TINYINT(1)
BEGIN
	DECLARE flag BOOLEAN;
	IF (param_number>0) THEN
		SET flag=TRUE;	
	ELSE
		SET flag=FALSE;	
	END IF;
	RETURN flag;
END$$
DELIMITER ;


/* Function to check the order is requested or not */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_ORDER_ID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_ORDER_ID`(param_order_id INT) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM ORDER_INFO WHERE ID=param_order_id);
END$$
DELIMITER ;


/* Function to check the item is available with the given quantity */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_QUANTITY`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_QUANTITY`(param_item_id INT, param_schedule_id INT, param_quantity INT) RETURNS TINYINT(1)
BEGIN
	DECLARE flag INT;
	DECLARE var_qty INT;
	DECLARE var_consumed_qty INT;
	SELECT QUANTITY INTO var_qty FROM ITEMS_AVAILABLE WHERE ITEM_ID=param_item_id AND SCHEDULE_ID=param_schedule_id;
	SELECT IFNULL(SUM(QUANTITY),0) INTO var_consumed_qty FROM ORDERS_TRANSACTION WHERE ITEM_ID=param_item_id AND STATUS='Served';
	IF (var_qty-var_consumed_qty)>=param_quantity THEN
		SET flag=1;
	ELSE
		SET flag=0;
	END IF;
	RETURN flag;
END$$
DELIMITER ;


/* Function to check the seat is vaild or not */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_SEAT`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_SEAT`(param_seat VARCHAR(3)) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM SEAT WHERE NAME=param_seat);
END$$
DELIMITER ;


/* Function to check whether the seat is available or not */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_SEAT_AVAILABLE`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_SEAT_AVAILABLE`(param_seat INT) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM SEAT WHERE ID=param_seat AND STATUS=1);
END$$
DELIMITER ;


/* Function to check the service is available */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_VALID_TIME`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_VALID_TIME`() RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM SCHEDULE WHERE CURTIME() BETWEEN FROM_TIME AND TO_TIME);
END$$
DELIMITER ;