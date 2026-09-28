# Esquema de la base de datos

Base de datos **Sakila / Pagila**: gestión de un videoclub con dos tiendas. 15 tablas y 22 relaciones.

```mermaid
erDiagram
    COUNTRY  ||--o{ CITY          : "tiene"
    CITY     ||--o{ ADDRESS       : "tiene"
    ADDRESS  ||--o{ CUSTOMER      : "domicilia"
    ADDRESS  ||--o{ STAFF         : "domicilia"
    ADDRESS  ||--o{ STORE         : "ubica"

    STORE    ||--o{ CUSTOMER      : "registra"
    STORE    ||--o{ STAFF         : "emplea"
    STORE    ||--o{ INVENTORY     : "almacena"
    STAFF    ||--o{ STORE         : "gestiona"

    LANGUAGE ||--o{ FILM          : "idioma de"
    FILM     ||--o{ FILM_ACTOR    : "reparto"
    ACTOR    ||--o{ FILM_ACTOR    : "actua en"
    FILM     ||--o{ FILM_CATEGORY : "clasificada"
    CATEGORY ||--o{ FILM_CATEGORY : "agrupa"
    FILM     ||--o{ INVENTORY     : "copias"

    INVENTORY ||--o{ RENTAL       : "se alquila"
    CUSTOMER  ||--o{ RENTAL       : "realiza"
    STAFF     ||--o{ RENTAL       : "gestiona"
    RENTAL    ||--o{ PAYMENT      : "genera"
    CUSTOMER  ||--o{ PAYMENT      : "paga"
    STAFF     ||--o{ PAYMENT      : "cobra"

    ACTOR {
        int actor_id PK
        varchar first_name
        varchar last_name
    }
    FILM {
        int film_id PK
        varchar title
        text description
        year release_year
        int language_id FK
        int original_language_id FK
        smallint rental_duration
        numeric rental_rate
        smallint length
        numeric replacement_cost
        mpaa_rating rating
    }
    CATEGORY {
        int category_id PK
        varchar name
    }
    LANGUAGE {
        int language_id PK
        char name
    }
    FILM_ACTOR {
        int actor_id PK_FK
        int film_id PK_FK
    }
    FILM_CATEGORY {
        int film_id PK_FK
        int category_id PK_FK
    }
    INVENTORY {
        int inventory_id PK
        int film_id FK
        int store_id FK
    }
    RENTAL {
        int rental_id PK
        timestamp rental_date
        int inventory_id FK
        int customer_id FK
        timestamp return_date
        int staff_id FK
    }
    PAYMENT {
        int payment_id PK
        int customer_id FK
        int staff_id FK
        int rental_id FK
        numeric amount
        timestamp payment_date
    }
    CUSTOMER {
        int customer_id PK
        int store_id FK
        varchar first_name
        varchar last_name
        varchar email
        int address_id FK
        boolean activebool
    }
    STAFF {
        int staff_id PK
        varchar first_name
        varchar last_name
        int address_id FK
        int store_id FK
        varchar username
    }
    STORE {
        int store_id PK
        int manager_staff_id FK
        int address_id FK
    }
    ADDRESS {
        int address_id PK
        varchar address
        varchar district
        int city_id FK
        varchar postal_code
        varchar phone
    }
    CITY {
        int city_id PK
        varchar city
        int country_id FK
    }
    COUNTRY {
        int country_id PK
        varchar country
    }
```

## Volumen de datos

| Tabla | Filas | Tabla | Filas |
|---|---:|---|---:|
| payment | 16.049 | film | 1.000 |
| rental | 16.044 | address | 603 |
| film_actor | 5.462 | city | 600 |
| inventory | 4.581 | customer | 599 |
| film_category | 1.000 | actor | 200 |
| country | 109 | category | 16 |
| language | 6 | staff | 2 |
| store | 2 | | |

## Cómo leer el modelo

El núcleo del negocio son tres bloques conectados entre sí:

- **Catálogo** — `film` es la ficha de cada película. Se relaciona con `actor` y con `category` a través de las tablas intermedias `film_actor` y `film_category`, porque ambas son relaciones de muchos a muchos: una película tiene varios actores y un actor sale en varias películas.
- **Existencias** — `inventory` representa cada copia física de una película en una tienda concreta. Una misma película puede tener varias copias repartidas entre las dos tiendas, y es esta tabla la que hace de puente entre el catálogo y los alquileres.
- **Operación** — `rental` registra cada alquiler (qué copia, qué cliente, qué empleado, cuándo se llevó y cuándo se devolvió) y `payment` el cobro asociado. La geografía cuelga de `address` → `city` → `country`, y de ahí salen tanto clientes como empleados y tiendas.

La consecuencia práctica es que **para ir de una película a sus alquileres siempre hay que pasar por `inventory`**: no existe relación directa entre `film` y `rental`.
