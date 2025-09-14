create database SQL_Task_1;

-- Creating all the required tables
-- Books: PK = isbn
CREATE TABLE books (
  isbn VARCHAR(20) PRIMARY KEY,
  title VARCHAR(255),
  publication_year INT,
  publisher_name VARCHAR(255)
);

CREATE TABLE authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE
);

CREATE TABLE book_authors (
  isbn VARCHAR(20),
  author_id INT,
  author_order SMALLINT DEFAULT 1,
  PRIMARY KEY (isbn, author_id)
);

CREATE TABLE members (
  member_code VARCHAR(50) PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE copies (
  copy_barcode VARCHAR(100) PRIMARY KEY,
  isbn VARCHAR(20),
  copy_no INT,
  status VARCHAR(20) DEFAULT 'available'
);

CREATE TABLE loans (
  loan_id INT AUTO_INCREMENT PRIMARY KEY,
  copy_barcode VARCHAR(100),
  member_code VARCHAR(50),
  borrow_date DATE,
  due_date DATE,
  return_date DATE,
  staff_name VARCHAR(255) 
);

-- Applying Foreign keys

ALTER TABLE copies
  ADD CONSTRAINT fk_copies_books FOREIGN KEY (isbn) REFERENCES books(isbn) ON DELETE CASCADE;

ALTER TABLE book_authors
  ADD CONSTRAINT fk_ba_books FOREIGN KEY (isbn) REFERENCES books(isbn) ON DELETE CASCADE;

ALTER TABLE book_authors
  ADD CONSTRAINT fk_ba_authors FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE;

ALTER TABLE loans
  ADD CONSTRAINT fk_loans_copies FOREIGN KEY (copy_barcode) REFERENCES copies(copy_barcode);

ALTER TABLE loans
  ADD CONSTRAINT fk_loans_members FOREIGN KEY (member_code) REFERENCES members(member_code);


-- Inserting Dummy data to each table(I used ai to generate these data and then inserted in each table)
  INSERT INTO books (isbn, title, publication_year, publisher_name) VALUES
('978-0-111111-0', 'Intro to Databases', 2020, 'Acme Publishing'),
('978-0-222222-0', 'Learning SQL', 2018, 'Beta Books'),
('978-0-333333-0', 'Advanced Database Design', 2021, 'Gamma Press');

INSERT INTO authors (name) VALUES
('John Doe'),
('Jane Smith'),
('Bob Author'),
('Clara White');

-- Intro to Databases has two authors: John Doe, Jane Smith
INSERT INTO book_authors (isbn, author_id, author_order)
SELECT '978-0-111111-0', author_id, 1 FROM authors WHERE name='John Doe';
INSERT INTO book_authors (isbn, author_id, author_order)
SELECT '978-0-111111-0', author_id, 2 FROM authors WHERE name='Jane Smith';

-- Learning SQL has one author: Bob Author
INSERT INTO book_authors (isbn, author_id, author_order)
SELECT '978-0-222222-0', author_id, 1 FROM authors WHERE name='Bob Author';

-- Advanced Database Design has one author: Clara White
INSERT INTO book_authors (isbn, author_id, author_order)
SELECT '978-0-333333-0', author_id, 1 FROM authors WHERE name='Clara White';

INSERT INTO members (member_code, name, email) VALUES
('M001', 'Alice Reader', 'alice@example.com'),
('M002', 'Bob Reader', 'bob@example.com'),
('M003', 'Charlie Student', 'charlie@example.com');

INSERT INTO copies (copy_barcode, isbn, copy_no, status) VALUES
('BCODE-0001', '978-0-111111-0', 1, 'available'),
('BCODE-0002', '978-0-111111-0', 2, 'available'),
('BCODE-0003', '978-0-222222-0', 1, 'available'),
('BCODE-0004', '978-0-333333-0', 1, 'available');

INSERT INTO loans (copy_barcode, member_code, borrow_date, due_date, return_date, staff_name) VALUES
('BCODE-0001', 'M001', '2025-09-01', '2025-09-15', NULL, 'Suman'),
('BCODE-0003', 'M002', '2025-09-05', '2025-09-19', '2025-09-14', 'Rina'),
('BCODE-0002', 'M003', '2025-09-10', '2025-09-24', NULL, 'Suman');


-- Since the above tables donot have any multivalued rows it's already in 1NF

-- Since the above each tables also use single column primary keys so there are no partial dependency left, hence it's also in 2NF

-- Since we have publishers details in books table and also staff details in loans table, 
-- which can cause update anomalies, a non key attributes here may derive other non key attributes
-- showing transitive dependency, Hence not in 3NF


-- Seperating out the required tables

-- Create publishers
CREATE TABLE publishers (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE
);

-- Populate publishers from books
INSERT IGNORE INTO publishers (name)
SELECT DISTINCT publisher_name FROM books WHERE publisher_name IS NOT NULL;

-- Add publisher_id column to books
ALTER TABLE books ADD COLUMN publisher_id INT DEFAULT NULL;

-- Update books.publisher_id by joining on publisher name
UPDATE books b
JOIN publishers p ON b.publisher_name = p.name
SET b.publisher_id = p.publisher_id;

-- Drop the old publisher_name column
ALTER TABLE books DROP COLUMN publisher_name;

-- Add FK
ALTER TABLE books
  ADD CONSTRAINT fk_books_publishers FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL;


-- Create staff table
CREATE TABLE staff (
  staff_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE,
  email VARCHAR(255)
);

-- Populate staff from loans.staff_name
INSERT IGNORE INTO staff (name)
SELECT DISTINCT staff_name FROM loans WHERE staff_name IS NOT NULL;

-- Add staff_id column to loans
ALTER TABLE loans ADD COLUMN staff_id INT DEFAULT NULL;

-- Update loans.staff_id by join
UPDATE loans l
JOIN staff s ON l.staff_name = s.name
SET l.staff_id = s.staff_id
WHERE l.staff_name IS NOT NULL;

-- Drop the old staff_name column
ALTER TABLE loans DROP COLUMN staff_name;

-- Add FK
ALTER TABLE loans
  ADD CONSTRAINT fk_loans_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL;


-- Since we have seperated the table causing transitive dependency, now each table's non key attributes depends only on key attribute, Hence in 3NF





