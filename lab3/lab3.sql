

-- Disable FK quickly so we can drop tables in any order.
PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS screenings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS theatres;
DROP TABLE IF EXISTS customers;
PRAGMA foreign_keys = ON;


CREATE TABLE theatres (
    name        TEXT PRIMARY KEY,
    capacity    INTEGER NOT NULL CHECK (capacity > 0)
);

CREATE TABLE movies (
    imdb_id    TEXT PRIMARY KEY,
    title      TEXT NOT NULL,
    prod_year  INTEGER NOT NULL
);

CREATE TABLE customers (
    username        TEXT PRIMARY KEY,
    full_name       TEXT NOT NULL,
    hashed_password TEXT NOT NULL
);

CREATE TABLE screenings (
    screening_id    TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    theatre_name    TEXT NOT NULL REFERENCES theatres(name),
    imdb_id         TEXT NOT NULL REFERENCES movies(imdb_id),
    date            DATE NOT NULL,
    start_time      TIME NOT NULL
);

CREATE TABLE tickets (
    ticket_uuid     TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    screening_id    TEXT NOT NULL REFERENCES screenings(screening_id),
    username        TEXT NOT NULL REFERENCES customers(username)
);


-- Insert data into tables
INSERT INTO theatres(name, capacity) VALUES
    ('SF Malmö', 250),
    ('Bio Helsingborg', 150),
    ('Capitol Stockholm', 180);

INSERT INTO movies(imdb_id, title, prod_year) VALUES
    ('tt0468569', 'The Dark Knight', 2008),
    ('tt0109830', 'Forrest Gump', 1994),
    ('tt1375666', 'Inception', 2010),
    ('tt0120737', 'The Lord of the Rings: The Fellowship of the Ring', 2001);

INSERT INTO customers(username, full_name, hashed_password) VALUES
    ('anna92', 'Anna Svensson', 'hash3'),
    ('jsmith', 'John Smith', 'hash4'),
    ('lisa_k', 'Lisa Karlsson', 'hash5'),
    ('omar_a', 'Omar Ali', 'hash6');

INSERT INTO screenings(theatre_name, imdb_id, date, start_time) VALUES
    ('SF Malmö',        'tt0109830', '2026-02-16', '15:00'),
    ('SF Malmö',        'tt0468569', '2026-02-16', '18:00'),
    ('Bio Helsingborg', 'tt1375666', '2026-02-16', '21:00'),
    ('SF Malmö',        'tt0109830', '2026-02-17', '19:00'),
    ('Bio Helsingborg', 'tt0120737', '2026-02-17', '18:30'),
    ('Capitol Stockholm','tt0468569', '2026-02-19', '20:00'),
    ('Capitol Stockholm','tt1375666', '2026-02-20', '17:45');

