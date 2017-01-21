DELIMITER $$

USE `restaurant`$$

DROP PROCEDURE IF EXISTS `PR_ADD_ORDER`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PR_ADD_ORDER`(IN param_order_id INT, IN param_item_id INT, IN param_quantity INT)
BEGIN
	-- do sleep(5);
	START TRANSACTION;
		INSERT INTO ORDERS_TRANSACTION(ORDER_ID, ITEM_ID, QUANTITY, TIME_STAMP,STATUS) 
			VALUES (param_order_id,param_item_id,param_quantity,NOW(),'Served');
	COMMIT;
END$$

DELIMITER ;