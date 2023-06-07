SET sql_mode = '';


USE music;
SHOW TABLES FROM music;

/* WHo is the senior most employee based on job title? */
SELECT * FROM employee
ORDER BY levels DESC;

/* WHich Country has most invoices? */
SELECT * FROM invoice
SELECT COUNT(*), billing_country
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC;

/* WHat are the top 3 values of total invoice? */
SELECT total FROM invoice
ORDER BY total DESC limit 3;

/*Which city has the best customers?
 We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT billing_city,SUM(total) as total
FROM invoice
GROUP BY billing_city
ORDER BY total DESC limit 1;

/* Q5: Who is the best customer? 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT inv.customer_id, cust.first_name, cust.last_name, SUM(total) AS total_spending
FROM invoice inv
JOIN customer cust
ON inv.customer_id = cust.customer_id
GROUP BY inv.customer_id
ORDER BY total_spending DESC limit 1;

/* Q6: Write query to return the email, first name, last name,
 & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email; 

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT art.artist_id, art.name, COUNT(*) as track_count
FROM artist art
JOIN album al ON art.artist_id = al.artist_id
JOIN track tr ON al.album_id = tr.album_id
JOIN genre gen ON tr.genre_id = gen.genre_id
WHERE gen.name LIKE "Rock"
GROUP BY art.name
ORDER BY COUNT(*) DESC; 

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */

SELECT name,milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* Q9: Find how much amount spent by each customer on artists?
 Write a query to return customer name, artist name and total spent */
 
 WITH cte AS (
	SELECT art.artist_id, art.name AS artist_name, 
    SUM(il.unit_price*il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album al ON al.album_id = t.album_id
	JOIN artist art ON art.artist_id = al.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, cte.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN cte ON cte.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



