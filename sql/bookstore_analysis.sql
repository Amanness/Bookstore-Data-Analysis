-- ============================================================
-- BOOKSTORE SALES ANALYSIS
-- SQL PROJECT
-- ============================================================


-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

-- 1.1 Create Books table
CREATE TABLE Books(
	Book_ID SERIAL PRIMARY KEY,
	Title VARCHAR(100),
	Author VARCHAR(100),
	Genre VARCHAR(50),
	Published_Year INT,
	Price NUMERIC(10, 2),
	Stock INT
);


-- 1.2 Create Customers table
CREATE TABLE Customers(
	Customer_ID SERIAL PRIMARY KEY,
	Name VARCHAR(100),
	Email VARCHAR(100),
	Phone VARCHAR(15),
	City VARCHAR(50),
	Country VARCHAR(150)
);


-- 1.3 Create Orders table
CREATE TABLE Orders(
	Order_ID SERIAL PRIMARY KEY,
	Customer_ID INT REFERENCES Customers(Customer_ID),
	Book_ID INT REFERENCES Books(Book_ID),
	Order_Date DATE,
	Quantity INT,
	Total_Amount NUMERIC(10, 2)
);



-- ============================================================
-- 2. DATA IMPORT
-- ============================================================

-- 2.1 Import Books data
COPY Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock)
FROM 'YOUR_PATH\data\Books.csv'
CSV HEADER;


-- 2.2 Import Customers data
COPY Customers(Customer_ID, Name, Email, Phone, City, Country)
FROM 'YOUR_PATH\data\Customers.csv'
CSV HEADER;


-- 2.3 Import Orders data
COPY Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount)
FROM 'YOUR_PATH\data\Orders.csv'
CSV HEADER;



-- ============================================================
-- 3. DATA VALIDATION
-- ============================================================

-- Verify Books data
SELECT * FROM Books;


-- Verify Customers data
SELECT * FROM Customers;


-- Verify Orders data
SELECT * FROM Orders;



-- ============================================================
-- 4. DATA EXPLORATION
-- ============================================================

-- 4.1) Identify all books belonging to the "Fiction" genre.
-- SQL Concept: WHERE 
SELECT * FROM Books
WHERE genre = 'Fiction';


-- 4.2) Identify books published after 1950.
-- SQL Concept: WHERE
SELECT title, author, published_year 
FROM Books
WHERE published_year > 1950;


-- 4.3) Identify customers based in Canada.
-- SQL Concept: WHERE
SELECT * FROM Customers
WHERE country = 'Canada';


-- 4.4) Retrieve all orders placed during November 2023.
-- SQL Concepts: WHERE, BETWEEN, AND
SELECT * FROM Orders
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30';


-- 4.5) Determine the distinct genres represented in the book catalog.
-- SQL Concept: DISTINCT
SELECT DISTINCT genre FROM Books;



-- ============================================================
-- 5. PRODUCT CATALOG ANALYSIS
-- ============================================================

-- 5.1) Identify the most expensive book in the catalog.
-- SQL Concepts: ORDER BY, LIMIT
SELECT * FROM Books
ORDER BY price DESC
LIMIT 1;


-- 5.2) Calculate the average price of books within the Fantasy genre.
-- SQL Concepts: AVG(), WHERE
SELECT AVG(price) AS average_price
FROM Books
WHERE genre = 'Fantasy';



-- ============================================================
-- 6. SALES & REVENUE ANALYSIS
-- ============================================================

-- 6.1) Calculate the total revenue generated from all orders.
-- SQL Concept: SUM()
SELECT SUM(total_amount) AS Revenue 
FROM Orders;


-- 6.2) Analyze the total quantity of books sold across each genre.
-- SQL Concepts: JOIN, SUM(), GROUP BY
SELECT b.genre, SUM(o.quantity) AS Total_book_sold
FROM Books AS b 
JOIN Orders AS o
ON b.book_ID = o.book_ID
GROUP BY b.genre;


-- 6.3) Retrieve orders with a total transaction value exceeding $20.
-- SQL Concepts: JOIN, WHERE
SELECT o.order_ID, o.customer_ID, b.title, o.book_ID, o.order_date, o.quantity, o.total_amount
FROM Orders AS o 
INNER JOIN Books AS b
	ON b.book_ID = o.book_ID
WHERE o.total_amount > 20;


-- 6.4) Identify the most frequently ordered book(s) based on order frequency.
-- SQL Concepts: MAX(), COUNT(), HAVING, GROUP BY, Subquery
SELECT o.book_ID, b.title, b.genre, COUNT(o.order_ID) AS Order_frequency
FROM Books AS b 
INNER JOIN Orders AS o
	ON b.book_ID = o.book_ID
GROUP BY o.book_ID, b.title, b.genre
HAVING COUNT(o.order_ID) = (
	SELECT MAX(order_frequency) 
	FROM(
		SELECT COUNT(order_ID) AS order_frequency
		FROM Orders
		GROUP BY book_ID
	) AS frequencies
);



-- ============================================================
-- 7. CUSTOMER ANALYSIS
-- ============================================================
	
-- 7.1) Identify customers who have placed at least two orders.
-- SQL Concepts: JOIN, COUNT(), GROUP BY, HAVING
SELECT o.customer_ID, c.Name, COUNT(o.order_ID) AS Order_count
FROM Customers AS c 
INNER JOIN Orders AS o
	ON c.customer_ID = o.customer_ID
GROUP BY o.customer_ID, c.Name
HAVING COUNT(o.order_ID) >= 2;


-- 7.2) Identify customers who ordered more than one copy of a book.
-- SQL Concepts: JOIN, WHERE
SELECT c.customer_ID, c.Name, o.quantity
FROM Customers AS c 
INNER JOIN Orders AS o
	ON c.customer_ID = o.customer_ID
WHERE o.quantity > 1;


-- 7.3) Identify the customer with the highest total spending.
-- SQL Concepts: JOIN, SUM(), GROUP BY, ORDER BY, LIMIT
SELECT c.customer_ID, c.Name, SUM(o.total_amount) AS total_spent
FROM Customers AS c
JOIN Orders AS o
ON c.customer_ID = o.customer_ID
GROUP BY c.customer_ID, c.Name
ORDER BY total_spent DESC
LIMIT 1;


-- 7.4) Identify cities associated with customers who placed an order exceeding $30.
-- SQL Concepts: JOIN, WHERE
SELECT c.name, c.city, o.total_amount
FROM Customers AS c
JOIN Orders AS o
ON c.customer_ID = o.customer_ID
WHERE total_amount > 30;



-- ============================================================
-- 8. AUTHOR ANALYSIS
-- ============================================================

-- 8.1) Analyze the total quantity of books sold by each author.
-- SQL Concepts: JOIN, SUM(), GROUP BY
SELECT b.author, SUM(o.quantity) AS Total_quantity
FROM Books AS b
JOIN Orders AS o
ON b.book_ID = o.book_ID
GROUP BY b.author
ORDER BY Total_quantity DESC;



-- ============================================================
-- 9. INVENTORY ANALYSIS
-- ============================================================

-- 9.1) Determine the total number of books currently in stock.
-- SQL Concept: SUM()
SELECT SUM(stock) AS TOTAL_STOCK 
FROM Books;


-- 9.2) Identify all books with the minimum stock level.
-- SQL Concepts: MIN(), Subquery
SELECT * FROM Books
WHERE stock = (
	SELECT MIN(stock) 
	FROM Books);

	
-- 9.3) Calculate the remaining inventory for each book after fulfilling all recorded orders.
-- SQL Concepts: LEFT JOIN, SUM(), COALESCE(), GROUP BY, ORDER BY
SELECT b.book_ID, b.title, b.stock, COALESCE(SUM(o.quantity),0) AS books_sold,
		b.stock - COALESCE(SUM(o.quantity),0) AS remaining_stock
FROM books AS b
LEFT JOIN orders AS o
ON b.book_ID = o.book_ID
GROUP BY b.book_ID, b.title, b.stock
ORDER BY b.book_ID;



-- ============================================================
-- 10. ADVANCED SQL ANALYSIS
-- ============================================================

-- 10.1) Rank the top three most expensive books within the Fantasy genre.
-- SQL Concepts: Window Function, RANK(), Subquery
SELECT * FROM
	(SELECT title, author, genre, price, 
		RANK() OVER(PARTITION BY genre ORDER BY price DESC) 
			AS ranking
	FROM Books) AS ranked_books
WHERE genre = 'Fantasy' AND ranking <= 3;



-- ============================================================
-- 11. BUSINESS INSIGHTS
-- ============================================================

-- 11.1)Product Pricing Insight
-- The highest-priced book in the catalog is "Proactive system-worthy
-- orchestration" priced at $49.98, highlighting the upper range of 
-- products in the bookstore catalog.
 


-- 11.2)Revenue Insight
-- The bookstore generated total recorded revenue of $75,628.66,
-- providing a baseline measure of overall sales performance.
 


-- 11.3) Genre Sales Insight
-- Mystery is the best-performing genre with 504 books sold,
-- followed by Science Fiction and Fantasy. Fiction has the lowest
-- recorded sales volume at 225 books.



-- 11.4) Popularity Insight
-- Seven books share the highest order frequency, with each appearing
-- in four orders. This indicates that demand is distributed across
-- multiple books rather than being concentrated in a single title.



-- 11.5) Customer Spending Insight
-- Kim Turner is the highest-spending customer, with total recorded
-- spending of $1,398.90, making this customer the highest-value
-- customer identified in the dataset.



-- 11.6) Repeat Customer Insight
-- 139 customers have placed more than one order, indicating the
-- presence of a substantial group of repeat customers in the dataset.



-- 11.7) Inventory Insight
-- Five books currently have zero stock, indicating products that
-- may require immediate inventory replenishment if they continue
-- to receive customer demand.



-- 11.8) Author Sales Insight
-- Patrick Contreras has the highest recorded book sales at 28 units,
-- followed by Melissa Taylor at 27 units. These authors could be
-- considered for greater promotional focus based on observed sales.


-- 11.9) Inventory Insight
-- Inventory levels vary considerably across the catalog. Some books
-- have relatively low remaining stock, while others have substantial
-- inventory despite limited recorded sales. This suggests that
-- inventory decisions should consider both remaining stock and
-- historical sales demand rather than stock levels alone.
