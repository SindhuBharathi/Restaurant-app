DELIMITER $$

USE `restaurant`$$

DROP PROCEDURE IF EXISTS `PR_CANCEL_ORDER`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PR_CANCEL_ORDER`(IN param_order_id INT, OUT param_msg VARCHAR(70))
BEGIN
	IF (FN_IS_VALID_ORDER_ID(param_order_id)) THEN
		IF (FN_IS_SERVED(param_order_id)) THEN
			SET param_msg='Cannot cancel an order which is served';
		ELSE
			IF (FN_IS_REQUESTED(param_order_id)) THEN
				IF (FN_IS_DELIVERED(param_order_id)) THEN
					SET param_msg='An item in the order is served cannot cancel the order';
				ELSE
--					START TRANSACTION;
--						UPDATE ORDERS_TRANSACTION SET STATUS='Cancelled', MODIFIED_TIME_STAMP=NOW() WHERE ORDER_ID=param_order_id;
						UPDATE SEAT SET STATUS=1 WHERE ID=FN_GET_ORDERED_SEAT_ID(param_order_id);
						UPDATE ORDER_INFO SET STATUS='Cancelled' WHERE ID=param_order_id;
--					COMMIT;	
					SET param_msg=CONCAT('All items in order id ',param_order_id,' is cancelled');
				END IF;
			ELSE
				SET param_msg='Cancelled already';
			END IF;
		END IF;
	ELSE
		SET param_msg='Invalid order id';
	END IF;
END$$

DELIMITER ;

CALL PR_CANCEL_ORDER(12,@op);
SELECT @op;