-- 1 task
SELECT
    a.aircraft_code,
    s.fare_conditions AS class_service,
    COUNT(s.seat_no) AS seats_count
FROM
    bookings.aircrafts_data a
        JOIN
    bookings.seats s
    ON
        a.aircraft_code = s.aircraft_code
GROUP BY
    a.aircraft_code, s.fare_conditions
ORDER BY
    a.aircraft_code, s.fare_conditions;

-- 2 task

SELECT
    a.model ->> 'en' AS aircraft_model,
    COUNT(s.seat_no) AS total_seats
FROM
    bookings.aircrafts_data a
        JOIN
    bookings.seats s
    ON
        a.aircraft_code = s.aircraft_code
GROUP BY
    a.model
ORDER BY
    total_seats DESC
LIMIT 3;

-- 3 task
SELECT
    f.flight_id,
    f.flight_no,
    f.scheduled_departure,
    f.scheduled_arrival,
    f.actual_departure,
    f.actual_arrival,
    (f.actual_arrival - f.scheduled_arrival) AS delay_duration
FROM
    bookings.flights f
WHERE
    f.actual_arrival IS NOT NULL
  AND (f.actual_arrival - f.scheduled_arrival) > INTERVAL '2 hours';

-- 4 task

SELECT
    t.ticket_no,
    t.passenger_name,
    t.contact_data,
    tf.fare_conditions
FROM
    bookings.tickets t
        JOIN
    bookings.ticket_flights tf
    ON
        t.ticket_no = tf.ticket_no
WHERE
    tf.fare_conditions = 'Business'
ORDER BY
    (SELECT book_date FROM bookings.bookings b WHERE b.book_ref = t.book_ref) DESC
LIMIT 10;

-- 5 task
SELECT
    f.flight_id,
    f.flight_no,
    f.scheduled_departure,
    f.scheduled_arrival
FROM
    bookings.flights f
WHERE
    NOT EXISTS (
        SELECT 1
        FROM bookings.ticket_flights tf
        WHERE tf.flight_id = f.flight_id
          AND tf.fare_conditions = 'Business'
    );

-- 6 task
SELECT DISTINCT
    a.airport_name ->> 'en' AS airport_name,
    a.city ->> 'en' AS city
FROM
    bookings.flights f
        JOIN
    bookings.airports a ON f.departure_airport = a.airport_code
WHERE
    f.actual_departure IS NOT NULL
  AND (f.actual_departure - f.scheduled_departure) > INTERVAL '0 seconds';

-- 7 task

SELECT
    a.airport_name ->> 'en' AS airport_name,
    COUNT(f.flight_id) AS flight_count
FROM
    bookings.airports a
        JOIN
    bookings.flights f ON a.airport_code = f.departure_airport
GROUP BY
    a.airport_name
ORDER BY
    flight_count DESC;

-- 8 task

SELECT
    flight_id,
    flight_no,
    scheduled_arrival,
    actual_arrival
FROM
    bookings.flights
WHERE
    actual_arrival IS NOT NULL
  AND actual_arrival <> scheduled_arrival;

-- 9 task

SELECT
    ad.aircraft_code,
    ad.model,
    s.seat_no
FROM
    bookings.aircrafts_data ad
        JOIN
    bookings.seats s ON ad.aircraft_code = s.aircraft_code
WHERE
    ad.model ->> 'en' = 'Аэробус A321-200'
  AND s.fare_conditions <> 'Economy'
ORDER BY
    s.seat_no;

-- 10 task

SELECT
    a.airport_code,
    a.airport_name ->> 'en' AS airport_name,
    a.city ->> 'en' AS city
FROM
    bookings.airports a
WHERE
    a.city IN (
        SELECT
            city ->> 'en'
        FROM
            bookings.airports
        GROUP BY
            city ->> 'en'
        HAVING
            COUNT(airport_code) > 1
    );

-- 11 task
WITH average_booking AS (
    SELECT
        AVG(total_amount) AS avg_amount
    FROM
        bookings.bookings
),
     passenger_totals AS (
         SELECT
             t.passenger_id,
             t.passenger_name,
             SUM(b.total_amount) AS total_amount
         FROM
             bookings.tickets t
                 JOIN
             bookings.bookings b ON t.book_ref = b.book_ref
         GROUP BY
             t.passenger_id, t.passenger_name
     )
SELECT
    pt.passenger_id,
    pt.passenger_name,
    pt.total_amount
FROM
    passenger_totals pt
        JOIN
    average_booking ab ON pt.total_amount > ab.avg_amount;

-- 12 task
SELECT
    flight_id,
    flight_no,
    scheduled_departure,
    departure_airport,
    arrival_airport,
    status
FROM
    bookings.flights
WHERE
    departure_airport = 'SVX' -- Код аэропорта Екатеринбурга
  AND arrival_airport = 'SVO' -- Код аэропорта Москвы
  AND scheduled_departure > NOW() + INTERVAL '30 minutes' -- Время вылета больше текущего времени + 30 минут
ORDER BY
    scheduled_departure
LIMIT 1; -- Берем только ближайший рейс

-- 13 task
SELECT
    'Самый дешевый' AS ticket_type,
    ticket_no,
    amount AS ticket_price
FROM
    bookings.ticket_flights
ORDER BY
    amount ASC
LIMIT 1

    UNION ALL

SELECT
    'Самый дорогой' AS ticket_type,
    ticket_no,
    amount AS ticket_price
FROM
    bookings.ticket_flights
ORDER BY
    amount DESC
LIMIT 1;

-- 14 task
CREATE TABLE Customers (
                           id SERIAL PRIMARY KEY,
                           firstName VARCHAR(50) NOT NULL,
                           lastName VARCHAR(50) NOT NULL,
                           email VARCHAR(100) UNIQUE NOT NULL,
                           phone VARCHAR(15)
);

-- 15 task
CREATE TABLE Orders (
                        id SERIAL PRIMARY KEY,
                        customerId INT NOT NULL,
                        quantity INT NOT NULL CHECK (quantity > 0),
                        FOREIGN KEY (customerId) REFERENCES Customers(id)
                            ON DELETE CASCADE
);

-- 16 task
INSERT INTO Customers (firstName, lastName, email, phone) VALUES
                                                              ('Иван', 'Иванов', 'ivan.ivanov@example.com', '1234567890'),
                                                              ('Мария', 'Петрова', 'maria.petrova@example.com', '0987654321'),
                                                              ('Сергей', 'Сергеев', 'sergey.sergeev@example.com', '1122334455'),
                                                              ('Анна', 'Антонова', 'anna.antonova@example.com', '2233445566'),
                                                              ('Олег', 'Олегов', 'oleg.olegov@example.com', '3344556677');

INSERT INTO Orders (customerId, quantity) VALUES
                                              (1, 5),
                                              (2, 3),
                                              (1, 10),
                                              (3, 2),
                                              (4, 1);

-- 17 task
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
