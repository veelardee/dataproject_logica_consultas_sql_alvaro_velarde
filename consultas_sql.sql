-- =============================================================================
-- DATAPROJECT: LÓGICA. CONSULTAS DE SQL
-- Base de datos: Sakila / Pagila (videoclub) · PostgreSQL
-- Autor: Álvaro Velarde
-- =============================================================================
-- NOTA SOBRE LOS DATOS:
-- Los campos de texto de actor, film y customer están almacenados en MAYÚSCULAS
-- ('ACADEMY DINOSAUR', 'PENELOPE GUINESS'). Por eso las búsquedas por nombre
-- usan ILIKE, que compara sin distinguir mayúsculas de minúsculas y hace la
-- consulta robusta frente a cómo se escriba el literal.
-- =============================================================================


-- =============================================================================
-- 1. Crea el esquema de la BBDD.
-- =============================================================================
-- El diagrama entidad-relación de las 15 tablas está en el repositorio
-- (carpeta /esquema). Se ha generado con DBeaver: botón derecho sobre la base
-- de datos -> Ver diagrama.
--
-- Consulta de apoyo: lista las relaciones (claves ajenas) entre tablas.
SELECT
    tc.table_name        AS tabla_origen,
    kcu.column_name      AS columna_origen,
    ccu.table_name       AS tabla_referenciada,
    ccu.column_name      AS columna_referenciada
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tabla_origen, columna_origen;


-- =============================================================================
-- 2. Muestra los nombres de todas las películas con una clasificación por
--    edades de 'R'.
-- =============================================================================
SELECT title AS pelicula
FROM film
WHERE rating = 'R'
ORDER BY title;


-- =============================================================================
-- 3. Encuentra los nombres de los actores que tengan un "actor_id" entre 30 y 40.
-- =============================================================================
SELECT
    actor_id,
    first_name AS nombre,
    last_name  AS apellido
FROM actor
WHERE actor_id BETWEEN 30 AND 40
ORDER BY actor_id;


-- =============================================================================
-- 4. Obtén las películas cuyo idioma coincide con el idioma original.
-- =============================================================================
-- En esta base de datos original_language_id está vacío en las 1.000 películas,
-- por lo que la consulta no devuelve filas. El resultado es correcto: no hay
-- ninguna película con idioma original informado.
SELECT
    f.title       AS pelicula,
    l.name        AS idioma
FROM film AS f
INNER JOIN language AS l
    ON f.language_id = l.language_id
WHERE f.language_id = f.original_language_id
ORDER BY f.title;


-- =============================================================================
-- 5. Ordena las películas por duración de forma ascendente.
-- =============================================================================
SELECT
    title  AS pelicula,
    length AS duracion_minutos
FROM film
ORDER BY length ASC;


-- =============================================================================
-- 6. Encuentra el nombre y apellido de los actores que tengan 'Allen' en su
--    apellido.
-- =============================================================================
SELECT
    first_name AS nombre,
    last_name  AS apellido
FROM actor
WHERE last_name ILIKE '%Allen%'
ORDER BY last_name, first_name;


-- =============================================================================
-- 7. Encuentra la cantidad total de películas en cada clasificación de la tabla
--    "film" y muestra la clasificación junto con el recuento.
-- =============================================================================
SELECT
    rating    AS clasificacion,
    COUNT(*)  AS total_peliculas
FROM film
GROUP BY rating
ORDER BY total_peliculas DESC;


-- =============================================================================
-- 8. Encuentra el título de todas las películas que son 'PG-13' o tienen una
--    duración mayor a 3 horas en la tabla film.
-- =============================================================================
SELECT
    title   AS pelicula,
    rating  AS clasificacion,
    length  AS duracion_minutos
FROM film
WHERE rating = 'PG-13'
   OR length > 180          -- 3 horas = 180 minutos
ORDER BY title;


-- =============================================================================
-- 9. Encuentra la variabilidad de lo que costaría reemplazar las películas.
-- =============================================================================
-- La variabilidad se mide con la varianza y la desviación estándar del coste
-- de reemplazo.
SELECT
    ROUND(VARIANCE(replacement_cost), 2) AS varianza_coste_reemplazo,
    ROUND(STDDEV(replacement_cost), 2)   AS desviacion_tipica_coste_reemplazo
FROM film;


-- =============================================================================
-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD.
-- =============================================================================
SELECT
    MIN(length) AS duracion_minima,
    MAX(length) AS duracion_maxima
FROM film;


-- =============================================================================
-- 11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.
-- =============================================================================
-- Se ordenan los alquileres del más reciente al más antiguo y se saltan los dos
-- últimos (OFFSET 2) para quedarse con el antepenúltimo.
-- Los 182 alquileres más recientes comparten exactamente la misma fecha y hora
-- (2006-02-14 15:16:03), así que se añade rental_id como criterio de desempate
-- para que el resultado sea siempre el mismo y no dependa del orden interno.
SELECT
    r.rental_id    AS id_alquiler,
    r.rental_date  AS fecha_alquiler,
    p.amount       AS importe
FROM rental AS r
LEFT JOIN payment AS p
    ON r.rental_id = p.rental_id
ORDER BY r.rental_date DESC, r.rental_id DESC
LIMIT 1 OFFSET 2;


-- =============================================================================
-- 12. Encuentra el título de las películas en la tabla "film" que no sean ni
--     'NC17' ni 'G' en cuanto a su clasificación.
-- =============================================================================
SELECT
    title  AS pelicula,
    rating AS clasificacion
FROM film
WHERE rating NOT IN ('NC-17', 'G')
ORDER BY title;


-- =============================================================================
-- 13. Encuentra el promedio de duración de las películas para cada clasificación
--     de la tabla film y muestra la clasificación junto con el promedio.
-- =============================================================================
SELECT
    rating                  AS clasificacion,
    ROUND(AVG(length), 2)   AS duracion_media_minutos
FROM film
GROUP BY rating
ORDER BY duracion_media_minutos DESC;


-- =============================================================================
-- 14. Encuentra el título de todas las películas que tengan una duración mayor
--     a 180 minutos.
-- =============================================================================
SELECT
    title  AS pelicula,
    length AS duracion_minutos
FROM film
WHERE length > 180
ORDER BY length DESC;


-- =============================================================================
-- 15. ¿Cuánto dinero ha generado en total la empresa?
-- =============================================================================
SELECT SUM(amount) AS ingresos_totales
FROM payment;


-- =============================================================================
-- 16. Muestra los 10 clientes con mayor valor de id.
-- =============================================================================
SELECT
    customer_id AS id_cliente,
    first_name  AS nombre,
    last_name   AS apellido
FROM customer
ORDER BY customer_id DESC
LIMIT 10;


-- =============================================================================
-- 17. Encuentra el nombre y apellido de los actores que aparecen en la película
--     con título 'Egg Igby'.
-- =============================================================================
SELECT
    a.first_name AS nombre,
    a.last_name  AS apellido
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
INNER JOIN film AS f
    ON fa.film_id = f.film_id
WHERE f.title ILIKE 'Egg Igby'
ORDER BY a.last_name;


-- =============================================================================
-- 18. Selecciona todos los nombres de las películas únicos.
-- =============================================================================
SELECT DISTINCT title AS pelicula
FROM film
ORDER BY title;


-- =============================================================================
-- 19. Encuentra el título de las películas que son comedias y tienen una
--     duración mayor a 180 minutos en la tabla "film".
-- =============================================================================
SELECT
    f.title  AS pelicula,
    f.length AS duracion_minutos
FROM film AS f
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
WHERE c.name = 'Comedy'
  AND f.length > 180
ORDER BY f.length DESC;


-- =============================================================================
-- 20. Encuentra las categorías de películas que tienen un promedio de duración
--     superior a 110 minutos y muestra el nombre junto con el promedio.
-- =============================================================================
SELECT
    c.name                  AS categoria,
    ROUND(AVG(f.length), 2) AS duracion_media_minutos
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN film AS f
    ON fc.film_id = f.film_id
GROUP BY c.name
HAVING AVG(f.length) > 110
ORDER BY duracion_media_minutos DESC;


-- =============================================================================
-- 21. ¿Cuál es la media de duración del alquiler de las películas?
-- =============================================================================
-- Se calcula sobre rental_duration, el número de días que dura el alquiler
-- según las condiciones de cada película.
SELECT ROUND(AVG(rental_duration), 2) AS duracion_media_alquiler_dias
FROM film;


-- =============================================================================
-- 22. Crea una columna con el nombre y apellidos de todos los actores y actrices.
-- =============================================================================
SELECT
    actor_id,
    CONCAT(first_name, ' ', last_name) AS nombre_completo
FROM actor
ORDER BY nombre_completo;


-- =============================================================================
-- 23. Números de alquiler por día, ordenados por cantidad de alquiler de forma
--     descendente.
-- =============================================================================
SELECT
    CAST(rental_date AS DATE) AS dia,
    COUNT(*)                  AS total_alquileres
FROM rental
GROUP BY dia
ORDER BY total_alquileres DESC;


-- =============================================================================
-- 24. Encuentra las películas con una duración superior al promedio.
-- =============================================================================
SELECT
    title  AS pelicula,
    length AS duracion_minutos
FROM film
WHERE length > (SELECT AVG(length) FROM film)   -- subconsulta escalar
ORDER BY length DESC;


-- =============================================================================
-- 25. Averigua el número de alquileres registrados por mes.
-- =============================================================================
SELECT
    TO_CHAR(rental_date, 'YYYY-MM') AS mes,
    COUNT(*)                        AS total_alquileres
FROM rental
GROUP BY mes
ORDER BY mes;


-- =============================================================================
-- 26. Encuentra el promedio, la desviación estándar y varianza del total pagado.
-- =============================================================================
SELECT
    ROUND(AVG(amount), 2)      AS importe_medio,
    ROUND(STDDEV(amount), 2)   AS desviacion_tipica,
    ROUND(VARIANCE(amount), 2) AS varianza
FROM payment;


-- =============================================================================
-- 27. ¿Qué películas se alquilan por encima del precio medio?
-- =============================================================================
SELECT
    title       AS pelicula,
    rental_rate AS precio_alquiler
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY rental_rate DESC, title;


-- =============================================================================
-- 28. Muestra el id de los actores que hayan participado en más de 40 películas.
-- =============================================================================
SELECT
    actor_id AS id_actor,
    COUNT(*) AS total_peliculas
FROM film_actor
GROUP BY actor_id
HAVING COUNT(*) > 40
ORDER BY total_peliculas DESC;


-- =============================================================================
-- 29. Obtener todas las películas y, si están disponibles en el inventario,
--     mostrar la cantidad disponible.
-- =============================================================================
-- LEFT JOIN para no perder las películas que no tienen copias en inventario.
SELECT
    f.title                AS pelicula,
    COUNT(i.inventory_id)  AS copias_en_inventario
FROM film AS f
LEFT JOIN inventory AS i
    ON f.film_id = i.film_id
GROUP BY f.film_id, f.title
ORDER BY copias_en_inventario DESC, f.title;


-- =============================================================================
-- 30. Obtener los actores y el número de películas en las que ha actuado.
-- =============================================================================
SELECT
    a.first_name        AS nombre,
    a.last_name         AS apellido,
    COUNT(fa.film_id)   AS total_peliculas
FROM actor AS a
LEFT JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY total_peliculas DESC;


-- =============================================================================
-- 31. Obtener todas las películas y mostrar los actores que han actuado en ellas,
--     incluso si algunas películas no tienen actores asociados.
-- =============================================================================
SELECT
    f.title      AS pelicula,
    a.first_name AS nombre_actor,
    a.last_name  AS apellido_actor
FROM film AS f
LEFT JOIN film_actor AS fa
    ON f.film_id = fa.film_id
LEFT JOIN actor AS a
    ON fa.actor_id = a.actor_id
ORDER BY f.title, a.last_name;


-- =============================================================================
-- 32. Obtener todos los actores y mostrar las películas en las que han actuado,
--     incluso si algunos actores no han actuado en ninguna película.
-- =============================================================================
SELECT
    a.first_name AS nombre,
    a.last_name  AS apellido,
    f.title      AS pelicula
FROM actor AS a
LEFT JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
LEFT JOIN film AS f
    ON fa.film_id = f.film_id
ORDER BY a.last_name, a.first_name, f.title;


-- =============================================================================
-- 33. Obtener todas las películas que tenemos y todos los registros de alquiler.
-- =============================================================================
-- FULL OUTER JOIN: conserva tanto las películas sin alquileres como cualquier
-- alquiler que no pudiera enlazarse con una película.
SELECT
    f.title       AS pelicula,
    r.rental_id   AS id_alquiler,
    r.rental_date AS fecha_alquiler
FROM film AS f
FULL OUTER JOIN inventory AS i
    ON f.film_id = i.film_id
FULL OUTER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
ORDER BY f.title, r.rental_date;


-- =============================================================================
-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.
-- =============================================================================
SELECT
    c.customer_id  AS id_cliente,
    c.first_name   AS nombre,
    c.last_name    AS apellido,
    SUM(p.amount)  AS total_gastado
FROM customer AS c
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_gastado DESC
LIMIT 5;


-- =============================================================================
-- 35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.
-- =============================================================================
SELECT
    actor_id,
    first_name AS nombre,
    last_name  AS apellido
FROM actor
WHERE first_name ILIKE 'Johnny'
ORDER BY last_name;


-- =============================================================================
-- 36. Renombra la columna "first_name" como Nombre y "last_name" como Apellido.
-- =============================================================================
SELECT
    first_name AS "Nombre",
    last_name  AS "Apellido"
FROM actor
ORDER BY "Apellido";


-- =============================================================================
-- 37. Encuentra el ID del actor más bajo y más alto en la tabla actor.
-- =============================================================================
SELECT
    MIN(actor_id) AS id_mas_bajo,
    MAX(actor_id) AS id_mas_alto
FROM actor;


-- =============================================================================
-- 38. Cuenta cuántos actores hay en la tabla "actor".
-- =============================================================================
SELECT COUNT(*) AS total_actores
FROM actor;


-- =============================================================================
-- 39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.
-- =============================================================================
SELECT
    actor_id,
    first_name AS nombre,
    last_name  AS apellido
FROM actor
ORDER BY last_name ASC;


-- =============================================================================
-- 40. Selecciona las primeras 5 películas de la tabla "film".
-- =============================================================================
SELECT
    film_id,
    title AS pelicula
FROM film
ORDER BY film_id
LIMIT 5;


-- =============================================================================
-- 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo
--     nombre. ¿Cuál es el nombre más repetido?
-- =============================================================================
SELECT
    first_name AS nombre,
    COUNT(*)   AS total_actores
FROM actor
GROUP BY first_name
ORDER BY total_actores DESC, nombre;
-- RESPUESTA: hay un triple empate en el primer puesto. JULIA, KENNETH y
-- PENELOPE son los nombres más repetidos, con 4 actores cada uno. Por detrás
-- quedan varios nombres con 3 apariciones (BURT, CAMERON, CHRISTIAN...).


-- =============================================================================
-- 42. Encuentra todos los alquileres y los nombres de los clientes que los
--     realizaron.
-- =============================================================================
SELECT
    r.rental_id   AS id_alquiler,
    r.rental_date AS fecha_alquiler,
    c.first_name  AS nombre_cliente,
    c.last_name   AS apellido_cliente
FROM rental AS r
INNER JOIN customer AS c
    ON r.customer_id = c.customer_id
ORDER BY r.rental_date;


-- =============================================================================
-- 43. Muestra todos los clientes y sus alquileres si existen, incluyendo
--     aquellos que no tienen alquileres.
-- =============================================================================
SELECT
    c.customer_id AS id_cliente,
    c.first_name  AS nombre,
    c.last_name   AS apellido,
    r.rental_id   AS id_alquiler,
    r.rental_date AS fecha_alquiler
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
ORDER BY c.customer_id, r.rental_date;


-- =============================================================================
-- 44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor esta
--     consulta? ¿Por qué?
-- =============================================================================
SELECT
    f.title AS pelicula,
    c.name  AS categoria
FROM film AS f
CROSS JOIN category AS c
ORDER BY f.title, c.name;
-- RESPUESTA: no aporta valor analítico. El CROSS JOIN cruza cada una de las
-- 1.000 películas con las 16 categorías y devuelve 16.000 filas con todas las
-- combinaciones posibles, sin tener en cuenta la categoría real de cada
-- película. La relación verdadera está en la tabla intermedia film_category, y
-- solo usando esa tabla (con un INNER JOIN) se obtiene la categoría correcta de
-- cada película. El CROSS JOIN sí sería útil cuando se busca justamente el
-- producto cartesiano, como en la consulta 63 (todos los trabajadores con todas
-- las tiendas).


-- =============================================================================
-- 45. Encuentra los actores que han participado en películas de la categoría
--     'Action'.
-- =============================================================================
SELECT DISTINCT
    a.first_name AS nombre,
    a.last_name  AS apellido
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
INNER JOIN film_category AS fc
    ON fa.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
WHERE c.name = 'Action'
ORDER BY a.last_name, a.first_name;


-- =============================================================================
-- 46. Encuentra todos los actores que no han participado en películas.
-- =============================================================================
-- Se usa LEFT JOIN y se filtran las filas sin correspondencia en film_actor.
-- En esta base de datos no hay ninguno: los 200 actores tienen películas.
SELECT
    a.actor_id,
    a.first_name AS nombre,
    a.last_name  AS apellido
FROM actor AS a
LEFT JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
WHERE fa.actor_id IS NULL
ORDER BY a.last_name;


-- =============================================================================
-- 47. Selecciona el nombre de los actores y la cantidad de películas en las que
--     han participado.
-- =============================================================================
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS actor,
    COUNT(fa.film_id)                      AS total_peliculas
FROM actor AS a
LEFT JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY total_peliculas DESC, actor;


-- =============================================================================
-- 48. Crea una vista llamada "actor_num_peliculas" que muestre los nombres de
--     los actores y el número de películas en las que han participado.
-- =============================================================================
CREATE OR REPLACE VIEW actor_num_peliculas AS
SELECT
    a.actor_id,
    a.first_name      AS nombre,
    a.last_name       AS apellido,
    COUNT(fa.film_id) AS num_peliculas
FROM actor AS a
LEFT JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- Comprobación del contenido de la vista:
SELECT *
FROM actor_num_peliculas
ORDER BY num_peliculas DESC;


-- =============================================================================
-- 49. Calcula el número total de alquileres realizados por cada cliente.
-- =============================================================================
SELECT
    c.customer_id     AS id_cliente,
    c.first_name      AS nombre,
    c.last_name       AS apellido,
    COUNT(r.rental_id) AS total_alquileres
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_alquileres DESC;


-- =============================================================================
-- 50. Calcula la duración total de las películas en la categoría 'Action'.
-- =============================================================================
SELECT
    c.name        AS categoria,
    SUM(f.length) AS duracion_total_minutos
FROM film AS f
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
WHERE c.name = 'Action'
GROUP BY c.name;


-- =============================================================================
-- 51. Crea una tabla temporal llamada "cliente_rentas_temporal" para almacenar
--     el total de alquileres por cliente.
-- =============================================================================
-- Las tablas temporales solo existen durante la sesión activa: al cerrar la
-- conexión desaparecen automáticamente.
DROP TABLE IF EXISTS cliente_rentas_temporal;

CREATE TEMP TABLE cliente_rentas_temporal AS
SELECT
    c.customer_id      AS id_cliente,
    c.first_name       AS nombre,
    c.last_name        AS apellido,
    COUNT(r.rental_id) AS total_alquileres
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

SELECT *
FROM cliente_rentas_temporal
ORDER BY total_alquileres DESC;


-- =============================================================================
-- 52. Crea una tabla temporal llamada "peliculas_alquiladas" que almacene las
--     películas que han sido alquiladas al menos 10 veces.
-- =============================================================================
DROP TABLE IF EXISTS peliculas_alquiladas;

CREATE TEMP TABLE peliculas_alquiladas AS
SELECT
    f.film_id,
    f.title            AS pelicula,
    COUNT(r.rental_id) AS veces_alquilada
FROM film AS f
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) >= 10;

SELECT *
FROM peliculas_alquiladas
ORDER BY veces_alquilada DESC;


-- =============================================================================
-- 53. Encuentra el título de las películas que han sido alquiladas por el
--     cliente 'Tammy Sanders' y que aún no se han devuelto. Ordena los
--     resultados alfabéticamente por título.
-- =============================================================================
-- Una película sin devolver es la que tiene return_date a NULL.
SELECT f.title AS pelicula
FROM rental AS r
INNER JOIN customer AS c
    ON r.customer_id = c.customer_id
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
    ON i.film_id = f.film_id
WHERE c.first_name ILIKE 'Tammy'
  AND c.last_name  ILIKE 'Sanders'
  AND r.return_date IS NULL
ORDER BY f.title;


-- =============================================================================
-- 54. Encuentra los nombres de los actores que han actuado en al menos una
--     película de la categoría 'Sci-Fi'. Ordena por apellido.
-- =============================================================================
SELECT DISTINCT
    a.first_name AS nombre,
    a.last_name  AS apellido
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
INNER JOIN film_category AS fc
    ON fa.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
WHERE c.name = 'Sci-Fi'
ORDER BY a.last_name, a.first_name;


-- =============================================================================
-- 55. Encuentra el nombre y apellido de los actores que han actuado en películas
--     que se alquilaron después de que la película 'Spartacus Cheaper' se
--     alquilara por primera vez. Ordena por apellido.
-- =============================================================================
SELECT DISTINCT
    a.first_name AS nombre,
    a.last_name  AS apellido
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
INNER JOIN inventory AS i
    ON fa.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
WHERE r.rental_date > (
        -- Fecha del primer alquiler de 'Spartacus Cheaper'
        SELECT MIN(r2.rental_date)
        FROM rental AS r2
        INNER JOIN inventory AS i2
            ON r2.inventory_id = i2.inventory_id
        INNER JOIN film AS f2
            ON i2.film_id = f2.film_id
        WHERE f2.title ILIKE 'Spartacus Cheaper'
      )
ORDER BY a.last_name, a.first_name;


-- =============================================================================
-- 56. Encuentra el nombre y apellido de los actores que no han actuado en
--     ninguna película de la categoría 'Music'.
-- =============================================================================
SELECT
    a.first_name AS nombre,
    a.last_name  AS apellido
FROM actor AS a
WHERE a.actor_id NOT IN (
        -- Actores que SÍ han participado en películas de categoría 'Music'
        SELECT fa.actor_id
        FROM film_actor AS fa
        INNER JOIN film_category AS fc
            ON fa.film_id = fc.film_id
        INNER JOIN category AS c
            ON fc.category_id = c.category_id
        WHERE c.name = 'Music'
      )
ORDER BY a.last_name, a.first_name;


-- =============================================================================
-- 57. Encuentra el título de todas las películas que fueron alquiladas por más
--     de 8 días.
-- =============================================================================
SELECT DISTINCT f.title AS pelicula
FROM film AS f
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
WHERE r.return_date - r.rental_date > INTERVAL '8 days'
ORDER BY f.title;


-- =============================================================================
-- 58. Encuentra el título de todas las películas que son de la misma categoría
--     que 'Animation'.
-- =============================================================================
SELECT f.title AS pelicula
FROM film AS f
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
WHERE c.name = 'Animation'
ORDER BY f.title;


-- =============================================================================
-- 59. Encuentra los nombres de las películas que tienen la misma duración que la
--     película 'Dancing Fever'. Ordena alfabéticamente por título.
-- =============================================================================
-- Se excluye la propia 'Dancing Fever' porque se buscan las películas que
-- coinciden con ella, no ella misma.
SELECT
    title  AS pelicula,
    length AS duracion_minutos
FROM film
WHERE length = (
        SELECT length
        FROM film
        WHERE title ILIKE 'Dancing Fever'
      )
  AND title NOT ILIKE 'Dancing Fever'
ORDER BY title;


-- =============================================================================
-- 60. Encuentra los nombres de los clientes que han alquilado al menos 7
--     películas distintas. Ordena alfabéticamente por apellido.
-- =============================================================================
SELECT
    c.first_name              AS nombre,
    c.last_name               AS apellido,
    COUNT(DISTINCT i.film_id) AS peliculas_distintas
FROM customer AS c
INNER JOIN rental AS r
    ON c.customer_id = r.customer_id
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT i.film_id) >= 7
ORDER BY c.last_name, c.first_name;


-- =============================================================================
-- 61. Encuentra la cantidad total de películas alquiladas por categoría y
--     muestra el nombre de la categoría junto con el recuento de alquileres.
-- =============================================================================
SELECT
    c.name             AS categoria,
    COUNT(r.rental_id) AS total_alquileres
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN inventory AS i
    ON fc.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY c.name
ORDER BY total_alquileres DESC;


-- =============================================================================
-- 62. Encuentra el número de películas por categoría estrenadas en 2006.
-- =============================================================================
-- Todas las películas de esta base de datos son del año 2006.
SELECT
    c.name   AS categoria,
    COUNT(*) AS total_peliculas
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN film AS f
    ON fc.film_id = f.film_id
WHERE f.release_year = 2006
GROUP BY c.name
ORDER BY total_peliculas DESC;


-- =============================================================================
-- 63. Obtén todas las combinaciones posibles de trabajadores con las tiendas
--     que tenemos.
-- =============================================================================
-- Aquí el CROSS JOIN sí es la herramienta correcta: se busca justamente el
-- producto cartesiano, todas las parejas trabajador-tienda posibles.
SELECT
    s.staff_id    AS id_trabajador,
    s.first_name  AS nombre,
    s.last_name   AS apellido,
    st.store_id   AS id_tienda
FROM staff AS s
CROSS JOIN store AS st
ORDER BY s.staff_id, st.store_id;


-- =============================================================================
-- 64. Encuentra la cantidad total de películas alquiladas por cada cliente y
--     muestra el ID del cliente, su nombre y apellido junto con la cantidad.
-- =============================================================================
SELECT
    c.customer_id      AS id_cliente,
    c.first_name       AS nombre,
    c.last_name        AS apellido,
    COUNT(r.rental_id) AS peliculas_alquiladas
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY peliculas_alquiladas DESC, c.last_name;
