USE sakila;
-- 1) How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory; -- inventory_id
SELECT * FROM film; -- film_id

SELECT 
    COUNT(DISTINCT inventory_id)
FROM
    inventory
WHERE
    film_id = (SELECT 
            film_id
        FROM
            film
        WHERE
            title = 'Hunchback Impossible');

-- 2) List all films whose length is longer than the average of all the films.
SELECT 
    title, length
FROM
    film
WHERE
    length > (SELECT 
            AVG(length) AS average_length
        FROM
            film);

-- 3) Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM actor;

SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));

-- 4) Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as family films.
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;

SELECT 
    film_id, title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id = (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    name = 'Family'));

-- 5) Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary 
-- keys and foreign keys, that will help you get the relevant information.
-- We want to see the 2 different ways to solve the question
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

-- a) Using Subqueries:
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    address_id IN (SELECT 
            address_id
        FROM
            address
        WHERE
            city_id IN (SELECT 
                    city_id
                FROM
                    city
                WHERE
                    country_id = (SELECT 
                            country_id
                        FROM
                            country
                        WHERE
                            country = 'Canada')))
ORDER BY last_name ASC;

-- b) 
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT 
    first_name, last_name, email
FROM
    sakila.customer cu
        JOIN
    sakila.address a USING (address_id)
        JOIN
    sakila.city ci USING (city_id)
        JOIN
    sakila.country co USING (country_id)
WHERE
    country = 'Canada'
ORDER BY last_name ASC;

-- 6) Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the 
-- different films that he/she starred.

SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM actor;

SELECT 
    film_id, title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_actor
        WHERE
            actor_id = (SELECT 
                    actor_id
                FROM
                    actor
                WHERE
                    actor_id = (SELECT 
                            actor_id
                        FROM
                            (SELECT 
                                actor_id, COUNT(DISTINCT film_id) AS count_of_films
                            FROM
                                film_actor
                            GROUP BY actor_id
                            ORDER BY count_of_films DESC
                            LIMIT 1) sub1)));

-- 7) Films rented by most profitable customer. You can use the customer table and payment table 
-- to find the most profitable customer ie the customer that has made the largest sum of payments
-- max sum per customer
SELECT * FROM customer;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film;

SELECT 
    film_id, title
FROM
    film
WHERE
    film_id IN (SELECT -- all the movies, rented by the most prolific customer
            film_id
        FROM
            inventory
        WHERE
            inventory_id IN (SELECT -- all the inventory_ids of the rental_ids by the most prolific customer
                    inventory_id
                FROM
                    rental
                WHERE
                    rental_id IN (SELECT -- all the rental_ids did by the most prolific customer (526)
                            rental_id
                        FROM
                            rental
                        WHERE
                            customer_id IN (SELECT -- most prolific customer (526)
                                    customer_id
                                FROM
                                    (SELECT 
                                        customer_id, SUM(amount)
                                    FROM
                                        payment
                                    GROUP BY customer_id
                                    ORDER BY SUM(amount) DESC
                                    LIMIT 1) sub1))))
ORDER BY film_id;

-- 8) Customers who spent more than the average payments.
SELECT * FROM customer;
SELECT * FROM payment;

-- average payment being the average of the sum of payments per customer.
SELECT 
    customer_id, SUM(amount) AS sum_of_payments
FROM
    payment
GROUP BY customer_id
HAVING sum_of_payments > (SELECT 
        AVG(sum_of_payments)
    FROM
        (SELECT 
            SUM(amount) AS sum_of_payments
        FROM
            payment
        GROUP BY customer_id) sum1)
ORDER BY sum_of_payments ASC;
