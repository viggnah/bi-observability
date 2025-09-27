-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS banking_demo;
USE banking_demo;

-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type ENUM('SAVINGS','CHECKING') NOT NULL,
    balance DECIMAL(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    txn_type ENUM('DEPOSIT','WITHDRAWAL','TRANSFER') NOT NULL,
    txn_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Insert sample customers (aligned with CSV data IDs 1001-1010)
INSERT INTO customers (customer_id, name, email, phone) VALUES
(1001, 'John Doe', 'john.doe@email.com', '555-0001'),
(1002, 'Jane Smith', 'jane.smith@email.com', '555-0002'),
(1003, 'Carlos Rodriguez', 'carlos.rodriguez@email.com', '555-0003'),
(1004, 'Yuki Tanaka', 'yuki.tanaka@email.com', '555-0004'),
(1005, 'Emma Wilson', 'emma.wilson@email.com', '555-0005'),
(1006, 'Pierre Dubois', 'pierre.dubois@email.com', '555-0006'),
(1007, 'Maria Silva', 'maria.silva@email.com', '555-0007'),
(1008, 'Ahmed Hassan', 'ahmed.hassan@email.com', '555-0008'),
(1009, 'Anna Kowalski', 'anna.kowalski@email.com', '555-0009'),
(1010, 'Liu Wei', 'liu.wei@email.com', '555-0010');

-- Insert accounts (using customer IDs 1001-1010)
INSERT INTO accounts (customer_id, account_type, balance) VALUES
(1001, 'SAVINGS', 5000.00),
(1001, 'CHECKING', 1500.00),
(1002, 'SAVINGS', 3000.00),
(1002, 'CHECKING', 750.00),
(1003, 'SAVINGS', 8200.00),
(1004, 'CHECKING', 1200.00),
(1005, 'SAVINGS', 2800.00),
(1006, 'CHECKING', 950.00),
(1007, 'SAVINGS', 12000.00),
(1008, 'CHECKING', 3200.00),
(1009, 'SAVINGS', 2100.00),
(1010, 'CHECKING', 6500.00);

-- Insert transactions (using account IDs that correspond to the accounts above)
INSERT INTO transactions (account_id, amount, txn_type) VALUES
-- Account 1 (1001 SAVINGS)
(1, 1000.00, 'DEPOSIT'),
(1, -200.00, 'WITHDRAWAL'),
-- Account 2 (1001 CHECKING) 
(2, 500.00, 'DEPOSIT'),
-- Account 3 (1002 SAVINGS)
(3, 1500.00, 'DEPOSIT'),
(3, -250.00, 'WITHDRAWAL'),
-- Account 4 (1002 CHECKING)
(4, 300.00, 'DEPOSIT'),
-- Account 5 (1003 SAVINGS)
(5, 2000.00, 'DEPOSIT'),
-- Account 6 (1004 CHECKING)
(6, 400.00, 'DEPOSIT'),
(6, -100.00, 'WITHDRAWAL'),
-- Account 7 (1005 SAVINGS)
(7, 800.00, 'DEPOSIT'),
-- Account 8 (1006 CHECKING)
(8, 200.00, 'DEPOSIT'),
-- Account 9 (1007 SAVINGS)
(9, 5000.00, 'DEPOSIT'),
-- Account 10 (1008 CHECKING)
(10, 1000.00, 'DEPOSIT'),
-- Account 11 (1009 SAVINGS)
(11, 600.00, 'DEPOSIT'),
-- Account 12 (1010 CHECKING)
(12, 2500.00, 'DEPOSIT');
