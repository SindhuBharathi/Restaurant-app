DELIMITER $$

USE `restaurant`$$

DROP PROCEDURE IF EXISTS `PR_IS_VALID_INPUT`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PR_IS_VALID_INPUT`(IN in_seat_name VARCHAR(3), IN in_item_name MEDIUMTEXT, IN in_item_qty MEDIUMTEXT, OUT out_msg VARCHAR(70))
BEGIN
	DECLARE name_next TEXT DEFAULT NULL;
	DECLARE name_nextlen INT DEFAULT NULL;
	DECLARE name_value TEXT DEFAULT NULL;
	DECLARE qty_next TEXT DEFAULT NULL;
	DECLARE qty_nextlen INT DEFAULT NULL;
	DECLARE qty_value TEXT DEFAULT NULL;
	DECLARE tab_count INT DEFAULT 0;
	DECLARE i INT;
	DECLARE var_seat_id INT;
	DECLARE var_item_id INT;
	DECLARE var_session_id INT;
	DECLARE var_order_id INT;
	DECLARE var_item_name VARCHAR(20);
	DECLARE var_item_qty INT;
-- to check the service availability at the current time
	IF (FN_IS_VALID_TIME()) THEN
-- to check the inputs are valid
		IF (LENGTH(in_seat_name)=0) OR (LENGTH(in_item_name)=0) OR (LENGTH(in_item_qty)=0) OR (in_seat_name=' ') OR (in_item_name=' ') OR (in_item_qty=' ') THEN
			SET out_msg='Invalid input given';
		ELSE
-- to check the seat given is valid
			IF (FN_IS_VALID_SEAT(in_seat_name)) THEN
-- to check the availability of seat given		
				SET var_seat_id=FN_GET_SEAT_ID(in_seat_name);
				IF (FN_IS_VALID_SEAT_AVAILABLE(var_seat_id)) THEN
-- to check the count of distinct items is 5		
--					start transaction;
						UPDATE SEAT SET STATUS=0 WHERE ID=var_seat_id;
						INSERT INTO ORDER_INFO (SEAT_ID) VALUES (var_seat_id);
--					commit;
					SET var_order_id=FN_GET_ORDER_ID();
					SET out_msg=CONCAT('Your Order id is ',var_order_id);
				/* Seperates the items given in the string and store it in a table */
					DROP TABLE IF EXISTS tab_given_order; 
					CREATE TEMPORARY TABLE IF NOT EXISTS tab_given_order (id INT AUTO_INCREMENT PRIMARY KEY, item_name VARCHAR(20), quantity INT);
					iterator:
					LOOP
						IF LENGTH(TRIM(in_item_name))=0 OR in_item_name IS NULL OR LENGTH(TRIM(in_item_qty))=0 OR in_item_qty IS NULL THEN
							LEAVE iterator;
						END IF;
						SET name_next=SUBSTRING_INDEX(in_item_name,',',1);
						SET name_nextlen=LENGTH(name_next);
						SET name_value=TRIM(name_next);
						SET qty_next=SUBSTRING_INDEX(in_item_qty,',',1);
						SET qty_nextlen=LENGTH(qty_next);
						SET qty_value=TRIM(qty_next);
						INSERT INTO tab_given_order (item_name,quantity) VALUES (name_next,qty_next);
						SET in_item_name=INSERT(in_item_name,1,name_nextlen+1,'');
						SET in_item_qty=INSERT(in_item_qty,1,qty_nextlen+1,'');
					END LOOP;
					SELECT COUNT(item_name) INTO tab_count FROM tab_given_order; 
					IF (tab_count<=5) THEN
--					SELECT 'order processed' AS comments;
						SET i=1;
						WHILE (i<=tab_count) DO
							SELECT item_name INTO var_item_name FROM tab_given_order WHERE id=i;
							SELECT quantity INTO var_item_qty FROM tab_given_order WHERE id=i;
-- to check item given is valid
							IF (FN_IS_VALID_ITEM(var_item_name)) THEN
-- to check quantity given is positive value								
								IF (FN_IS_VALID_NUM(var_item_qty)) THEN
									SET var_item_id=FN_GET_ITEM_ID(var_item_name);
-- to check the item is served in this session
									IF (FN_GET_SESSION_ID(var_item_id)) THEN
										SET var_session_id=FN_GET_SESSION_ID(var_item_id);
-- to check the item is available in the given quantity						
										IF (FN_IS_VALID_QUANTITY(var_item_id,var_session_id,var_item_qty)) THEN
--											do sleep(10);
											CALL PR_ADD_ORDER(var_order_id, var_item_id, var_item_qty);
											SET out_msg='Served';
										ELSE
											SET out_msg='Item with specified quantity is not available';
										END IF;
									ELSE
										SET out_msg='Item specified is unavailable at this session';
									END IF;
								ELSE
									SET out_msg='Invalid quantity is given';
								END IF;
							ELSE 
								SET out_msg='Invalid item given';
							END IF;
							SET i=i+1;
						END WHILE;
					ELSE
						SET out_msg='Only 5 items can be placed in an order';
					END IF;
					IF EXISTS(SELECT 1 FROM ORDERS_TRANSACTION WHERE ORDER_ID=var_order_id) THEN
--						START TRANSACTION;
							UPDATE SEAT SET STATUS=1 WHERE ID=var_seat_id;
							UPDATE ORDER_INFO SET STATUS='Served' WHERE ID=var_order_id;
--						COMMIT;
					ELSE
--						START TRANSACTION;
							UPDATE SEAT SET STATUS=1 WHERE ID=var_seat_id;
							UPDATE ORDER_INFO SET STATUS='Invalid order' WHERE ID=var_order_id;
--						COMMIT;
					END IF;
				ELSE
					SET out_msg='Sorry given seat is unavailable';
				END IF;
			ELSE
				SET out_msg='Invalid seat name given';
			END IF;
		END IF;
	ELSE
			SET out_msg='Sorry service is not available now';
	END IF;
END$$

DELIMITER ;

