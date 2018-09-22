-- 1a. Display the first and last names of all actors fromt the table 'actor'
SELECT a.first_name AS ActorFirstName, a.last_name AS ActorLastName
FROM sakila.actor AS a;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column 'Actor Name'.
SELECT UPPER(CONCAT(a.first_name, ' ' , a.last_name)) AS `Actor Name`
FROM sakila.actor AS a;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT a.actor_id AS ActorID,
	a.first_name AS ActorFirstName,
    a.last_name AS ActorLastName
FROM sakila.actor AS a
WHERE a.first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT a.actor_id AS ActorID,
	a.first_name AS  ActorFirstName,
    a.last_name AS ActorLastName
FROM sakila.actor AS a
WHERE a.last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT a.actor_id AS ActorID,
	a.first_name AS ActorFirstName,
    a.last_name AS ActorLastName
FROM sakila.actor AS a
WHERE a.last_name LIKE '%LI%'
ORDER BY a.last_name, a.first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country_id AS CountryID,
	c.country AS CountryName
FROM sakila.country AS c
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE sakila.actor
ADD COLUMN Description BLOB AFTER last_name;

SELECT * 
FROM information_schema.COLUMNS AS col
WHERE col.TABLE_SCHEMA = 'sakila'
AND col.TABLE_NAME = 'actor'
AND col.COLUMN_NAME = 'description';

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE sakila.actor DROP COLUMN description;

SELECT *
FROM information_schema.COLUMNS AS col
WHERE col.TABLE_SCHEMA = 'sakila'
AND col.TABLE_NAME = 'actor'
AND col.COLUMN_NAME =  'description';

--  4a. List the last names of actors, as well as how many actors have that last name.
SELECT a.last_name AS ActorLastName,
COUNT(1) AS RecordCount
FROM sakila.actor AS a
GROUP BY a.last_name
ORDER BY 2 DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT a.last_name AS ActorLastName,
COUNT(1) AS RecordCount
FROM sakila.actor AS a
GROUP BY a.last_name
HAVING COUNT(1) >=2
ORDER BY 2 DESC;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE sakila.actor AS a
SET a.first_name = 'HARPO'
WHERE a.first_name = 'GROUCHO'
AND a.last_name = 'WILLIAMS';

SELECT *
FROM sakila.actor AS a
WHERE a.first_name = 'HARPO'
AND a.last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE sakila.actor AS a
SET a.first_name = 'GROUCHO'
WHERE a.first_name = 'HARPO'
AND a.last_name = 'WILLIAMS';

SELECT * 
FROM sakila.actor AS A
WHERE a.first_name = 'GROUCHO'
AND a.last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name AS StaffFirstName, 
	s.last_name AS StaffLastName,
    a.address AS StaffAddressLine1,
    a.address2 AS StaffAddressLine2,
    a.district AS StaffDistrict,
    c.city AS StaffCity
FROM sakila.staff as s
JOIN sakila.address AS a ON s.address_id = a.address_id
LEFT JOIN sakila.city AS c ON a.city_id = c.city_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT CONCAT(s.first_name, ' ', s.last_name)  AS StaffFullName,
     SUM(p.amount) AS TotalRungUp_August2015
FROM sakila.staff AS s
LEFT JOIN sakila.payment AS p ON s.staff_id = p.staff_id
AND YEAR(p.payment_date) = 2005
AND MONTH(p.payment_date) = 8;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.film_id AS FilmID,
	f.title AS FilmTitle,
    COUNT(1) AS CountOfActors
FROM sakila.film AS f
JOIN sakila.film_actor AS fa ON f.film_id = fa.film_id
GROUP BY f.film_id, f.title
ORDER BY 3 DESC;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(1) AS CopiesOfHunchbackImpossible
FROM sakila.inventory AS i
JOIN sakila.film AS f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.customer_id AS CustomerID,
	c.first_name AS CustomerFirstName,
    c.last_name AS CustomerLastName,
    c.email AS CustomerEmail,
    SUM(p.amount) AS TotalPaidByCustomer
FROM sakila.customer AS c
JOIN sakila.payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id,
	c.first_name,
    c.last_name,
    c.email
ORDER BY c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT f.title  AS FilmTitle
FROM sakila.film AS f
WHERE (f.title LIKE 'K%'
OR f.title LIKE 'Q%')
AND f.language_id IN (SELECT l.language_id
FROM sakila.language AS l
WHERE l.name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT CONCAT(a.first_name, ' ', a.last_name) AS AloneTrip_ActorName
FROM sakila.actor AS a
WHERE a.actor_id IN (SELECT fa.actor_id
FROM sakila.film_actor AS fa
WHERE fa.film_id IN (SELECT f.film_id
FROM sakila.film AS f
WHERE f.title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cu.first_name  AS CustomerFirstName
     , cu.last_name   AS CustomerLastName
     , cu.email       AS CustomerEmail
     , co.country     AS CustomerCountry
  FROM sakila.customer AS cu
  JOIN sakila.address AS a ON cu.address_id = a.address_id
  JOIN sakila.city AS ci ON a.city_id = ci.city_id
  JOIN sakila.country AS co ON ci.country_id = co.country_id
 WHERE co.country_id = 20;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title AS FilmTitle,
     c.name AS FilmCategory
FROM sakila.category AS c
JOIN sakila.film_category AS fc ON c.category_id = fc.category_id
JOIN sakila.film AS f ON fc.film_id = f.film_id

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.film_id AS FilmID, f.title AS FilmTitle,
     COUNT(r.rental_id) AS RentalCounts
FROM sakila.film AS f
LEFT JOIN sakila.inventory AS i on f.film_id = i.film_id
LEFT JOIN sakila.rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY 3 DESC;

-- 7f. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id,
	 SUM(p.amount)  AS StoreRentalRevenue
FROM sakila.store AS s
LEFT JOIN sakila.inventory AS i ON s.store_id = i.store_id
LEFT JOIN sakila.rental AS r ON i.inventory_id = r.inventory_id
LEFT JOIN sakila.payment AS p ON r.rental_id = p.rental_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS StoreID
     , ci.city AS StoreCity
     , co.country AS StoreCountry
FROM sakila.store AS s
JOIN sakila.address AS a ON s.address_id = a.address_id
JOIN sakila.city AS ci ON a.city_id = ci.city_id
JOIN sakila.country AS co ON co.country_id = ci.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name          AS FilmCategory
     , SUM(p.amount)   AS GrossRevenue
FROM sakila.payment AS p
LEFT JOIN sakila.rental AS r ON p.rental_id = r.rental_id
LEFT JOIN sakila.inventory AS i ON r.inventory_id = i.inventory_id
LEFT JOIN sakila.film_category AS fc ON i.film_id = fc.film_id
LEFT JOIN sakila.category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY 2 DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS sakila.vTop5GrossingFilmGenres;
CREATE VIEW sakila.vTop5GrossingFilmGenres AS

SELECT c.name AS FilmCategory,
     SUM(p.amount) AS GrossRevenue
FROM sakila.payment AS p
LEFT JOIN sakila.rental AS r ON p.rental_id = r.rental_id
LEFT JOIN sakila.inventory AS i ON r.inventory_id = i.inventory_id
LEFT JOIN sakila.film_category AS fc ON i.film_id = fc.film_id
LEFT JOIN sakila.category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY 2 DESC
LIMIT 5;

SELECT *
FROM sakila.vTop5GrossingFilmGenres;

-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW sakila.vTop5GrossingFilmGenres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW IF EXISTS sakila.vTop5GrossingFilmGenres;

