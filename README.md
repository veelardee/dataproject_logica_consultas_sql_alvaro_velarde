# DataProject — Lógica. Consultas de SQL

Resolución de 63 consultas sobre la base de datos **Sakila / Pagila**, el modelo de un videoclub con dos tiendas, 1.000 películas y 599 clientes. Todo el trabajo se ha hecho en **PostgreSQL 17** desde **DBeaver**.

---

## Contenido del repositorio

```
├── README.md                              Este archivo
├── consultas_sql.sql                      Las 63 consultas resueltas y comentadas
├── esquema/
│   ├── esquema_bbdd.md                    Diagrama entidad-relación
│   └── diagrama_dbeaver.png               Diagrama generado con DBeaver
└── bbdd/
    └── BBDD_Proyecto_shakila_sinuser.sql  Dump original de la base de datos
```

## Pasos seguidos

**1. Montar el entorno.** Se instaló PostgreSQL 17 y DBeaver Community. El dump que proporciona el bootcamp es un volcado de PostgreSQL, así que no era compatible con otros gestores como SQL Server: la sintaxis de secuencias, tipos y funciones es propia de Postgres.

**2. Crear y cargar la base de datos.** Se creó una base vacía llamada `sakila` y se cargó el dump. El archivo contiene 46.273 sentencias `INSERT`, por lo que se importó desde la línea de comandos con `psql` en lugar de hacerlo desde el editor de DBeaver, que las ejecuta una a una y tarda mucho más:

```bash
psql -U postgres -d sakila -f BBDD_Proyecto_shakila_sinuser.sql
```

**3. Entender el modelo.** Antes de escribir ninguna consulta se revisaron las 15 tablas y sus 22 claves ajenas para tener claro el camino entre ellas. El detalle está en `esquema/esquema_bbdd.md`. El hallazgo más importante para el resto del proyecto: **no hay relación directa entre `film` y `rental`**; para cruzar películas con alquileres siempre hay que pasar por `inventory`, que es la tabla que representa cada copia física.

**4. Resolver las consultas.** Se escribieron las 63 consultas, cada una numerada y con su enunciado como comentario, y se ejecutaron todas comprobando que el resultado tuviera sentido, no solo que no diera error.

## Decisiones de la resolución

**Comparaciones de texto sin distinguir mayúsculas.** Los campos de `actor`, `film` y `customer` están almacenados en mayúsculas (`ACADEMY DINOSAUR`, `PENELOPE GUINESS`), mientras que los enunciados escriben los nombres en formato normal (`Egg Igby`, `Johnny`). Escribir `WHERE title = 'Egg Igby'` devolvería cero filas. Se ha usado `ILIKE`, que compara sin distinguir mayúsculas y hace las consultas robustas frente a cómo se escriba el literal.

**Elección del JOIN.** `INNER JOIN` cuando solo interesan las filas con correspondencia, y `LEFT JOIN` cuando el enunciado pide conservar todos los registros de una tabla aunque no tengan pareja: por ejemplo en la consulta 29 (todas las películas, tengan o no copias en inventario) o en la 46 (actores sin películas). La 33 usa `FULL OUTER JOIN` porque pide explícitamente todas las películas **y** todos los alquileres.

**Desempates en las ordenaciones.** En la consulta 11 se pide el antepenúltimo alquiler por fecha, pero los 182 alquileres más recientes comparten exactamente la misma marca de tiempo (`2006-02-14 15:16:03`). Ordenar solo por fecha daría un resultado distinto en cada ejecución, así que se añadió `rental_id` como criterio de desempate para que el resultado sea reproducible.

**Consultas que devuelven cero filas.** La consulta 4 (películas cuyo idioma coincide con el original) y la 46 (actores sin películas) no devuelven ninguna fila, y es el resultado correcto: `original_language_id` está vacío en las 1.000 películas y los 200 actores tienen al menos una película asignada. Ambos casos quedan documentados con un comentario en el propio archivo `.sql`.

## Conceptos cubiertos

| Requisito | Consultas |
|---|---|
| Consultas sobre una sola tabla | 2, 3, 5, 7, 8, 9, 10, 12, 13, 14, 15, 16, 18, 22, 23, 25, 26, 36, 37, 38, 39, 40, 41 |
| Relaciones entre tablas (JOIN) | 17, 19, 20, 29, 30, 31, 32, 33, 34, 42, 43, 45, 49, 50, 54, 57, 58, 60, 61, 62 |
| CROSS JOIN | 44, 63 |
| Subconsultas | 24, 27, 55, 56, 59 |
| Agrupaciones y HAVING | 20, 28, 52, 60 |
| Vistas | 48 |
| Tablas temporales | 51, 52 |

## Informe del análisis

### El negocio en cifras

La base cubre un histórico de alquileres entre **mayo de 2005 y febrero de 2006**, con 16.044 alquileres y **67.416,51 $ de ingresos** repartidos en 16.049 pagos. El importe medio por pago es de 4,20 $, con una desviación típica de 2,36 $: una dispersión alta para importes tan pequeños, explicada por los tres únicos precios de alquiler del catálogo (0,99, 2,99 y 4,99 $).

La actividad no está repartida de forma uniforme. El grueso se concentra en el verano de 2005, con un pico claro en julio (6.709 alquileres) y agosto (5.686), frente a los 1.156 de mayo. Los 182 alquileres de febrero de 2006 son un bloque aparte, cargado con la misma marca de tiempo, y corresponden a los alquileres aún sin devolver en el momento de generar los datos.

### Catálogo

Las 1.000 películas se reparten de forma bastante equilibrada entre las cinco clasificaciones por edad, con PG-13 a la cabeza (223) y G en la cola (178). La duración media es de 115 minutos, con un rango que va de 46 a 185.

Las 16 categorías también están equilibradas en número de películas, pero no en rendimiento. **Sports (1.179 alquileres), Animation (1.166) y Action (1.112) son las más alquiladas**, mientras que Music (830) y Travel (837) se quedan claramente por detrás: entre la primera y la última hay un 42% de diferencia. Sports es además la categoría con películas más largas (128 minutos de media), lo que sugiere que la duración no penaliza el alquiler.

### Clientes y actores

El cliente que más ha gastado es **Karl Seal, con 221,55 $**, seguido de Eleanor Hunt (216,54 $) y Clara Shaw (195,58 $). No hay clientes dominantes: la diferencia entre el primero y el tercero es de apenas 26 $, y **los 599 clientes han alquilado al menos 7 películas distintas**, lo que indica una base de clientes muy homogénea y sin dependencia de unos pocos.

En el reparto, **Susan Davis encabeza la lista con 54 películas**, por delante de Gina Degeneres (42) y Walter Torn (41). Solo dos actores superan las 40 películas, así que el catálogo no gira alrededor de un reparto reducido.

### Devoluciones

Hay **183 alquileres sin devolver** sobre 16.044, un 1,1%. Es una cifra baja, aunque conviene tener en cuenta que corresponde a la foto del último día de datos y parte de esos alquileres estarían aún en plazo.

## Herramientas

PostgreSQL 17 · DBeaver Community 26
