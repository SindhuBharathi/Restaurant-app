/* Function to get the item id using item name */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_GET_ITEM_ID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_ITEM_ID`(param_item_name VARCHAR(20)) RETURNS INT(11)
BEGIN
	DECLARE var_item_id INT;
	SELECT ID INTO var_item_id FROM ITEM WHERE NAME=param_item_name;
	RETURN var_item_id;
END$$
DELIMITER ;


/* Function to get the last inserted order id */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_GET_ORDER_ID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_ORDER_ID`() RETURNS INT(11)
BEGIN
	RETURN (SELECT LAST_INSERT_ID());
END$$
DELIMITER ;


/* Function to get the seat id of an order id */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_GET_ORDERED_SEAT_ID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_ORDERED_SEAT_ID`(param_order_id INT) RETURNS INT(11)
BEGIN
	DECLARE var_seat_id INT;
	SELECT SEAT_ID INTO var_seat_id FROM ORDER_INFO WHERE ID=param_order_id;
	RETURN var_seat_id;
END$$
DELIMITER ;


/* Function to get the seat id from the seat name */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_GET_SEAT_ID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_SEAT_ID`(param_seat_name VARCHAR(3)) RETURNS INT(11)
BEGIN
	DECLARE var_seat_id INT;
	SELECT ID INTO var_seat_id FROM SEAT WHERE NAME=param_seat_name;
	RETURN var_seat_id;
END$$
DELIMITER ;

/* Function to get the session id from item id */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_GET_SESSION_ID`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_SESSION_ID`(param_item_id INT) RETURNS INT(11)
BEGIN
	DECLARE var_session_id INT;
	SELECT SCHEDULE_ID INTO var_session_id FROM ITEMS_AVAILABLE IA 
		WHERE IA.`SCHEDULE_ID` 
		IN (SELECT ID FROM SCHEDULE WHERE NOW() BETWEEN FROM_TIME AND TO_TIME) 
		AND IA.`ITEM_ID`=param_item_id;
	RETURN var_session_id;
END$$
DELIMITER ;


/* Function to check the order is entered in the transaction table (ORDERS_TRANSACTION) */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_DELIVERED`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_DELIVERED`(param_order_id INT) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM ORDERS_TRANSACTION WHERE ID=param_order_id AND STATUS='Served');
END$$
DELIMITER ;


/* Function to check the order is requested */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_REQUESTED`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_REQUESTED`(param_order_id INT) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM ORDER_INFO WHERE ID=param_order_id AND STATUS='Requested');
END$$
DELIMITER ;


/* Function to check the order is served */
DELIMITER $$
USE `restaurant`$$
DROP FUNCTION IF EXISTS `FN_IS_SERVED`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_IS_SERVED`(param_order_id INT) RETURNS TINYINT(1)
BEGIN
	RETURN EXISTS (SELECT 1 FROM ORDER_INFO WHERE ID=param_order_id AND STATUS='Served');
END$$
DELIMITER ;