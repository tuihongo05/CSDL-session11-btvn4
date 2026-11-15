CREATE DATABASE IF NOT EXISTS session11_btvn4;
USE session11_btvn4;

CREATE TABLE accounts(
	accountID INT PRIMARY KEY,
    customerName VARCHAR(150) NOT NULL,
    balance DECIMAL(10,2)
);

CREATE TABLE transactions(
	transactionID INT AUTO_INCREMENT PRIMARY KEY,
    accountID INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    logMessage VARCHAR(255) NOT NULL,
    transactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(accountID) REFERENCES accounts(accountID)
);

DELIMITER $$
	CREATE PROCEDURE insert_account()
	BEGIN
		DECLARE i INT DEFAULT 1;
        WHILE i <= 10 DO
        INSERT INTO accounts(accountID, customerName, balance)
        VALUES (
			i,
            CONCAT('customer_', i),
            FLOOR(100000 + RAND()*9000000)
		);
        SET i = i + 1;
        END WHILE;
	END $$
DELIMITER ;
CALL insert_account();

UPDATE accounts
SET balance = 2000000
WHERE accountID = 4;

UPDATE accounts
SET balance = 0
WHERE accountID = 5;

DELIMITER $$
	CREATE PROCEDURE transfer_money(p_sender_id INT, p_receiver_id INT, p_amount DECIMAL(10,2))
	BEGIN
		DECLARE balance_sender INT DEFAULT 0;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            RESIGNAL;            
        END;

		START TRANSACTION;
		UPDATE accounts SET balance = balance + p_amount WHERE accountID = p_receiver_id;
        UPDATE accounts SET balance = balance - p_amount WHERE accountID = p_sender_id;
        SELECT balance INTO balance_sender FROM accounts WHERE accountID = p_sender_id;
        IF balance_sender < 0 THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT ='so du khong du';
		END IF;
        COMMIT;

	END $$
DELIMITER ;
CALL transfer_money(4, 5, 300000);
SELECT * FROM accounts
WHERE accountID IN (4,5);