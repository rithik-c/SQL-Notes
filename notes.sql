-- Selecting from table

select * from sales;
select SaleDate, Amount, Customers from sales;
select Amount, Customers, GeoID from sales;


-- Using WHERE and OR Clause in SQL

select * from sales where amount > 10000;
select * from people where team = 'Delish' or team = 'Jucies';


-- Showing sales data where amount is greater than 10,000 by descending order
select * from sales where amount > 10000 order by amount desc;
select * from sales where geoid='g1' order by PID, Amount desc;


-- Casting

SELECT SaleDate, Amount, Boxes,
       CAST(Amount AS DECIMAL(10,2)) / Boxes AS PricePerBox -- Decimal(10,2) means 10 digits, 2 of which are decimal places
FROM sales; 
SELECT CONVERT(VARCHAR, hire_date, 101) FROM employees;

-- SQL Math, and field aliases

Select SaleDate, Amount, Boxes, Amount / boxes as 'Amount per box'  from sales; -- int/int=rounded int, decimal/int_or_decimal=decimal
SELECT CONVERT(VARCHAR, hire_date, 101) FROM employees; -- 101 = the U.S. date format MM/DD/YYYY
SELECT amount / NULLIF(boxes, 0) FROM sales; -- returns null if both nullif args are the same, useful to avoid divide-by-zero errors

-- Working with dates in SQL

Select * from sales
where amount > 10000 and SaleDate >= '2022-01-01';


-- Using year() function to select all data in a specific year

select SaleDate, Amount from sales
where amount > 10000 and year(SaleDate) = 2022
order by amount desc;


-- Using datepart() function in SQL

select SaleDate, Amount, Boxes, weekday(SaleDate) as 'Day of week'
from sales
where weekday(SaleDate) = 4; --weekday() is mysql-specific, 0 is monday, 6 is sunday, 4 is friday

SET DATEFIRST 1;  -- Monday = 1, Tuesday = 2, ..., Sunday = 7
SELECT * FROM sales
WHERE DATEPART(WEEKDAY, SaleDate) = 5;  -- safe for ssms || 5 = Friday when DATEFIRST is set to 1
-- default datetime type format = YYYY-MM-DD hh:mm:ss[.fff] or YYYY-MM-DD for only date type

WHERE DATEPART(WEEKDAY, CONVERT(DATE, SaleDate)) = 6; -- conversion if date stored as a varchar
WHERE DATEPART(WEEKDAY, TRY_CONVERT(DATE, SaleDate)) = 6; -- if some values may be malformed returns null for those values, prefer this so other valid data still gets processed


-- BETWEEN condition in SQL

WHERE boxes >0 AND boxes <=50;
WHERE price BETWEEN 100 AND 200 -- inclusive both ends
WHERE date BETWEEN '2023-01-01' AND '2023-12-31' -- inclusive both ends
-- for string between strings, lexicographical comparison is used ('l' < 'lacy' < 'mango' < 'o' < 'oliver' < 'peter' < 'rick'), so oliver wouldn't be included for between 'l' and 'o'


-- IN operator in SQL

WHERE status IN ('active', 'pending')
WHERE id NOT IN (1, 2, 3)


-- LIKE operator in SQL

WHERE name = 'John'
WHERE name != 'John'
WHERE name LIKE 'Jo%'        -- starts with Jo
WHERE name LIKE '%hn'        -- ends with hn
WHERE name LIKE '%oh%'       -- contains oh
WHERE name LIKE '_a%'        -- second letter is a
WHERE name LIKE '__a%'       -- third letter is a
WHERE LOWER(name) LIKE '%abc%'  -- case-insensitive match


-- NULL Handling

WHERE team IS NULL
WHERE email IS NOT NULL

SELECT ISNULL(nickname, 'No Nickname') FROM users; -- Returns 'No Nickname' if nickname is NULL

SELECT COALESCE(nickname, username, 'No Name') FROM users; -- Returns the first non-NULL from left to right (supports multiple fallbacks)


-- Exists/Not Exists

WHERE EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customers.id)
WHERE NOT EXISTS (SELECT 1 FROM blacklist WHERE user_id = users.id)
-- note: use select 1 for exists subqueries for performance since you'd likely only care about presence and not quantity


-- Subqueries

WHERE salary > (SELECT AVG(salary) FROM employees)
WHERE department_id IN (SELECT id FROM departments WHERE name = 'Sales')


-- Unions (combining rows, not a join)
-- table A: Alice || table B: Alice, Bob
SELECT * FROM A UNION SELECT * FROM B; -- Results: Alice, Bob (removes duplicates)
SELECT * FROM A UNION ALL SELECT * FROM B; -- Results: Alice, Alice, Bob (keeps everything)


-- Except/Intersect

-- EXCEPT: returns rows in A not in B
-- INTERSECT: returns rows in both A and B
-- table A: Alice, Bob || table B: Alice, Carol
SELECT name FROM A EXCEPT SELECT name FROM B; -- Result: Bob

SELECT name FROM A INTERSECT SELECT name FROM B; -- Result: Alice


-- Regex (Email)

WHERE email REGEXP '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'
-- | Part           | Meaning                                                                                                                |
-- | -------------- | ---------------------------------------------------------------------------------------------------------------------- |
-- | `^`            | Start of string                                                                                                        |
-- | `[\w.-]+`      | 1+ characters that are letters, digits, underscores (`_`), dots (`.`), or dashes (`-`) — this is the **username** part |
-- | `@`            | Literal "@" symbol                                                                                                     |
-- | `[\w.-]+`      | 1+ of the same allowed characters — this is the **domain** part                                                        |
-- | `\.`           | A literal dot (.) before the domain extension                                                                          |
-- | `[a-zA-Z]{2,}` | 2 or more letters (uppercase/lowercase) — this is the **TLD** like `.com`, `.org`                                      |
-- | `$`            | End of string                                                                                                          |


-- GROUP BY in SQL

select team, count(*) from people
group by team
-- for group by, you can only select grouped columns or aggregates since multiple rows are joined together so ssms wouldnt know which squashed row's value to show for the other columns


-- Using CASE to create branching logic in SQL

select 	SaleDate, Amount,
		case 	when amount < 1000 then 'Under 1k'
				when amount < 5000 then 'Under 5k'
                when amount < 10000 then 'Under 10k'
			else '10k or more'
		end as 'Amount category'
from sales;


-- Variable Subqueries

with febProds as (
    select pr.Product, s.Amount, s.Date
    from products pr
    left join shipments s on s.Product_ID = pr.Product_ID and s.Date = '2022-2-1'
)
select product, sum(amount) as "Sales",
    "Sales Status" = 
    case when sum(amount) > 0 then 'Shipped'
    else 'Not Shipped' end
from febProds
group by product


-- Transactions/Commits/Rollbacks

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO employees (name, salary) VALUES ('John', 50000);
    INSERT INTO employees (name, salary) VALUES ('Jane', 60000);

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT ERROR_MESSAGE();
END CATCH


-- Delete and Truncate

-- Inside a transaction, safe to rollback
BEGIN TRANSACTION;
DELETE FROM employees WHERE name = 'John'; -- can filter deleted rows
TRUNCATE TABLE employees; -- deletes whole table so no row filters, doesn't log deletions, is faster because minimal logging, fails if foreign keys exist unless disabled
ROLLBACK;

