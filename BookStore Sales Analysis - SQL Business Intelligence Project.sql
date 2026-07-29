USE book_store;
SELECT * FROM books;
SELECT * FROM customers;
SELECT * FROM orders;

-- Basic Business Analysis
-- =====================================================
-- Business Question 1: Analyze Fiction Book Inventory
-- Objective: Retrieve all books belonging to the Fiction genre.
SELECT row_number() OVER() AS Row_num, Title FROM BOOKS WHERE Genre="Fiction";
-- =====================================================

-- =====================================================
-- Business Question 2: Identify Modern Publications
-- Objective: Retrieve books published after the year 1950.
SELECT row_number() OVER() AS Row_num, Title, Published_Year FROM BOOKS WHERE Published_Year>1950;
-- =====================================================

-- =====================================================
-- Business Question 3: Analyze Customer Distribution by Country
-- Objective: Retrieve all customers located in Canada.
SELECT row_number() OVER() AS Row_num, Customer_ID, Country FROM customers WHERE Country="Canada";
-- =====================================================

-- =====================================================
-- Business Question 4: Analyze November 2023 Sales
-- Objective: Retrieve all orders placed during November 2023.
SELECT row_number() OVER() AS Row_num, Order_ID, MONTH(Order_Date) FROM orders WHERE MONTH(Order_Date)=11;
-- =====================================================

-- =====================================================
-- Business Question 5: Evaluate Current Inventory Levels
-- Objective: Calculate the total stock available across all books.
SELECT SUM(Stock) FROM books;
-- =====================================================

-- =====================================================
-- Business Question 6: Identify Premium-Priced Book
-- Objective: Find the most expensive book in the inventory.
SELECT * FROM BOOKS ORDER BY price DESC Limit 8;
-- =====================================================

-- =====================================================
-- Business Question 7: Identify Bulk Purchase Orders Between quantity range 12-18
-- Objective: Find customers who purchased more than one copy in a single order.
SELECT row_number() OVER() AS Row_num, Customer_ID, book_id, Quantity FROM orders WHERE Quantity BETWEEN 4 AND 8;
-- =====================================================

-- =====================================================
-- Business Question 8: Analyze High-Value Transactions
-- Objective: Retrieve orders exceeding '115.71' in value.
SELECT row_number() OVER() AS Row_num, Order_ID, Total_Amount FROM orders WHERE Total_Amount>115.71;
-- =====================================================

-- =====================================================
-- Business Question 9: Analyze Product Category Mix
-- Objective: List all available book genres.
SELECT Genre, COUNT(book_id) AS Total_books FROM books GROUP BY Genre;
-- =====================================================

-- =====================================================
-- Business Question 10: Detect Low-Stock Inventory
-- Objective: Identify the book with the lowest stock level.
SELECT row_number() OVER() AS Row_num, Book_id, Title, Stock FROM books where stock =(SELECT MIN(Stock) from books);
-- =====================================================

-- =====================================================
-- Business Question 11: Calculate Total Revenue
-- Objective: Compute total revenue generated from all sales.
SELECT SUM(o.Quantity*b.Price) AS total_revenue
FROM orders AS o JOIN books AS b
ON o.book_id=b.book_id;
-- =====================================================

-- Advance Business Analysis
-- =====================================================
-- 12. Business Question 12: Evaluate Genre-wise Sales Performance
-- Objective: Calculate total books sold for each genre.
SELECT row_number() OVER() AS Row_num, b.Genre Genre, COUNT(order_id) Total_orders, SUM(o.quantity) Sold_books 
FROM orders o LEFT JOIN books b
ON b.book_id=o.book_id
GROUP BY Genre;
-- =====================================================

-- =====================================================
-- Business Question 13: Analyze Fantasy Genre Pricing
-- Objective: Calculate the average selling price of Fantasy books.
SELECT AVG(Price) average_price FROM books WHERE genre="Fantasy";
-- =====================================================

-- =====================================================
-- Business Question 14: Identify Repeat Customers
-- Objective: Find customers who have placed at least two orders.
SELECT row_number() OVER() AS Row_num, c.Customer_ID Customer_ID, c.Name Customer_name, COUNT(o.order_id) Total_orders
FROM customers c LEFT JOIN orders o
on c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING  COUNT(o.order_id)>=2
ORDER BY Customer_ID;
-- =====================================================

-- =====================================================
-- Business Question 15: Identify Best-Selling Book
-- Objective: Determine the most frequently ordered book.
SELECT Book_id, COUNT(order_id) most_frequently_ordered_book 
FROM orders 
group by BOOK_ID ORDER BY most_frequently_ordered_book DESC LIMIT 7;
-- =====================================================

-- =====================================================
-- Business Question 16: Analyze Premium Fantasy Books
-- Objective: Retrieve the top three most expensive Fantasy books.
SELECT Title, Genre, Price FROM books WHERE genre="Fantasy" ORDER BY price DESC LIMIT 3;
-- =====================================================

-- =====================================================
-- Business Question 17: Evaluate Author-wise Sales Performance
-- Objective: Calculate total quantity sold for each author.
SELECT row_number() OVER() AS Row_num, b.author, COUNT(o.Order_ID) Total_orders, SUM(o.Quantity) quantity_of_books_sold_by_each_author 
FROM books b LEFT JOIN orders o
ON b.book_id=o.book_id
GROUP BY author ;
-- =====================================================

-- =====================================================
-- Business Question 18: Identify High-Spending Customer Locations
-- Objective: Find cities where customers spent more than $30.
SELECT row_number() OVER() AS Row_num, c.Name Name, c.City  cities_where_customers_who_spent_over_30, SUM(o.Total_Amount) Amount
FROM customers c JOIN orders o
on c.Customer_ID=o.Customer_ID
GROUP BY Name, cities_where_customers_who_spent_over_30
HAVING Amount>30;
-- =====================================================

-- =====================================================
-- Business Question 19: Identify Highest-Value Customer
-- Objective: Determine the customer with the highest total spending.
SELECT c.Name Name, COUNT(O.ORDER_ID) Total_orders, ROUND(SUM(Total_Amount)) spending
FROM customers c JOIN orders o
on c.Customer_ID=o.Customer_ID
GROUP BY Name
ORDER BY spending DESC LIMIT 1;
-- =====================================================

-- =====================================================
-- Business Question 20: Calculate Remaining Inventory
-- Objective: Calculate stock remaining after fulfilling all customer orders.
SELECT b.book_id Book_id, b.title Title, b.stock Total_stock, 
COALESCE(SUM(o.Quantity), 0) Total_orders, (b.stock-COALESCE(SUM(o.Quantity), 0)) remaining_stock
FROM books b LEFT JOIN orders o
ON b.book_id=o.book_id
GROUP BY b.book_id, b.title, b.stock 
ORDER BY b.book_id;
-- =====================================================

-- =====================================================
-- Business Question 21: Identify Above-Average Customers
-- Objective: Find customers whose spending exceeds the average customer spending.
WITH CustomerSpending AS (
    SELECT Customer_ID,
        SUM(Total_Amount) AS Total_Spending
    FROM Orders
    GROUP BY Customer_ID)
SELECT *,
       AVG(Total_Spending) OVER() AS Avg_Spending
FROM CustomerSpending
WHERE Total_Spending >
(SELECT AVG(Total_Spending)
FROM CustomerSpending);
-- =====================================================

-- =====================================================
-- Business Question 22: Detect Unsold Inventory
-- Objective: Identify books that have never been purchased.
SELECT row_number() OVER() AS Row_num, b.Book_ID Book_ID, b.Title Name_of_Book, COUNT(o.Order_ID) Total_orders
FROM orders o Right JOIN books b
ON b.book_id=o.book_id
GROUP BY Book_ID, Name_of_Book
HAVING Total_orders=0;
-- =====================================================

-- =====================================================
-- Business Question 23: Identify Inactive Customers
-- Objective: Find customers who have never placed an order.
SELECT row_number() OVER() AS Sr_No, c.Name Name, c.Customer_ID Customer_ID, COUNT(o.Order_ID) Total_orders
FROM customers c LEFT JOIN orders o
on c.Customer_ID=o.Customer_ID
GROUP BY Customer_ID, Name
HAVING Total_orders=0;
-- =====================================================

-- =====================================================
-- Business Question 24: Analyze Monthly Revenue Trend
-- Objective: Calculate cumulative monthly revenue generated by the bookstore.
WITH MonthlyRevenue AS (
    SELECT 
        MONTH(Order_Date) AS Month,
        SUM(Total_Amount) AS Monthly_Revenue
    FROM Orders
    GROUP BY MONTH(Order_Date))
SELECT Month, Monthly_Revenue,
    SUM(Monthly_Revenue) OVER(ORDER BY Month) AS Cumulative_monthly_Revenue
FROM MonthlyRevenue
ORDER BY Month;
-- =====================================================

-- =====================================================
-- Business Question 25: Identify Peak Revenue Month
-- Objective: Determine the month with the highest revenue using a CTE.
WITH month_with_the_highest_revenue AS(
SELECT month(Order_Date) MONTH, SUM(Total_Amount) AS Monthly_Revenue
FROM Orders GROUP BY MONTH(Order_Date)
) SELECT MONTH, Monthly_Revenue
FROM month_with_the_highest_revenue
ORDER BY Monthly_Revenue DESC LIMIT 1;
-- =====================================================

-- Advanced Analytics with Window Functions
-- =====================================================
-- Business Question 26: Rank Books Within Each Genre
-- Objective: Rank books based on price within each genre.
SELECT DENSE_RANK() OVER(PARTITION BY Genre ORDER BY Price) Ranking, Title, Genre, Price FROM books;
-- =====================================================

-- =====================================================
-- Business Question 27: Assign Sequential Book Numbers
-- Objective: Assign a unique row number to books within each genre.
SELECT row_number() OVER(Partition by Genre) AS Row_num, Title, Genre FROM books;
-- =====================================================

-- =====================================================
-- Business Question 28: Identify Second Highest-Priced Book
-- Objective: Find the second most expensive book in every genre.
WITH A AS (SELECT 
              DENSE_RANK() OVER(
                      PARTITION BY Genre 
                      ORDER BY Price DESC) RANKING,
			  Title, Genre, Price 
              FROM books)
SELECT * FROM A  WHERE RANKING =2;
-- =====================================================

-- =====================================================
-- Business Question 29: Compare Current and Previous Customer Purchases
-- Objective: Display each order amount alongside the customer's previous order.
SELECT Customer_ID, TOTAL_AMOUNT, Order_Date,
      LAG(TOTAL_AMOUNT) OVER(PARTITION BY Customer_id ORDER BY ORDER_DATE) amount_along_with_their_previous_order
FROM orders 
order by customer_id, order_date;
-- =====================================================

-- =====================================================
-- Business Question 30: Compare Current and Next Customer Purchases
-- Objective: Display each order amount alongside the customer's next order.
SELECT Customer_ID, Order_Date, TOTAL_AMOUNT,
      LEAD(TOTAL_AMOUNT) OVER(PARTITION BY Customer_id ORDER BY ORDER_DATE) amount_along_with_their_next_order
FROM orders
order by customer_id, order_date;
-- =====================================================

-- =====================================================
-- Business Question 31: Track Cumulative Revenue Growth
-- Objective: Calculate the running total of bookstore revenue.
SELECT *, SUM(TOTAL_AMOUNT) OVER(ORDER BY ORDER_DATE) running_total_of_bookstore_revenue FROM orders;
-- =====================================================

-- =====================================================
-- Business Question 32: Compare Book Price with Genre Average
-- Objective: Display each book price along with the average price of its genre.
SELECT Book_ID, Title, Genre, Price, 
       AVG(Price) OVER(PARTITION BY GENRE) average_price_of_books_in_the_same_genre 
FROM BOOKS;
-- =====================================================

-- =====================================================
-- Business Question 33: Measure Revenue Contribution by Book
-- Objective: Calculate each book's percentage contribution to total bookstore revenue.
WITH Book_Revenue AS (
    SELECT
        b.Book_ID, b.Title, b.Genre,
        SUM(o.Quantity * b.Price) AS Book_Revenue
    FROM Books b
    JOIN Orders o
        ON b.Book_ID = o.Book_ID
    GROUP BY b.Book_ID, b.Title, b.Genre)
SELECT
    Book_ID, Title, Genre, Book_Revenue,
    ROUND(Book_Revenue * 100.0 / SUM(Book_Revenue) OVER(), 2) AS Percentage_Contribution
FROM Book_Revenue;
-- =====================================================

-- =====================================================
-- Business Question 34: Analyze Month-over-Month Revenue Growth
-- Objective: Calculate the monthly revenue growth percentage using window functions.
WITH Monthly_Revenue AS (
    SELECT
        MONTH(Order_Date) AS Month,
        SUM(Total_Amount) AS Revenue
    FROM Orders
    GROUP BY MONTH(Order_Date))
SELECT
    Month, Revenue,
    LAG(Revenue) OVER(ORDER BY Month) AS Previous_Month_Revenue,
    ROUND((Revenue - LAG(Revenue) OVER(ORDER BY Month)) * 100.0 / LAG(Revenue) OVER(ORDER BY Month),2) 
    AS Month_over_Month_Growth_Percentage
FROM Monthly_Revenue
ORDER BY Month;
-- =====================================================