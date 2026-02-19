

-- Disable FK quickly so we can drop tables in any order.
PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS performances;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS theaters;
DROP TABLE IF EXISTS customers;
PRAGMA foreign_keys = ON;


CREATE TABLE theaters (
    name        TEXT PRIMARY KEY,
    capacity    INTEGER NOT NULL CHECK (capacity > 0)
);

CREATE TABLE movies (
    imdb_key    TEXT PRIMARY KEY,
    title       TEXT NOT NULL,
    year        INTEGER NOT NULL
);

CREATE TABLE customers (
    username        TEXT PRIMARY KEY,
    full_name       TEXT NOT NULL,
    hashed_password TEXT NOT NULL
);

CREATE TABLE performances (
    performance_id      TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    theater             TEXT NOT NULL REFERENCES theaters(name),
    imdb_key            TEXT NOT NULL REFERENCES movies(imdb_key),
    date                DATE NOT NULL,
    time                TIME NOT NULL
);

CREATE TABLE tickets (
    ticket_id         TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    performance_id      TEXT NOT NULL REFERENCES performances(performance_id),
    username            TEXT NOT NULL REFERENCES customers(username)
);


-- Insert data into tables
INSERT INTO theaters(name, capacity) VALUES
    ('SF Malmö', 250),
    ('Bio Helsingborg', 150),
    ('Capitol Stockholm', 180);

INSERT INTO movies(imdb_key, title, year) VALUES
    ('tt0468569', 'The Dark Knight', 2008),
    ('tt0109830', 'Forrest Gump', 1994),
    ('tt1375666', 'Inception', 2010),
    ('tt0120737', 'The Lord of the Rings: The Fellowship of the Ring', 2001);

INSERT INTO customers(username, full_name, hashed_password) VALUES
    ('anna92', 'Anna Svensson', 'hash3'),
    ('jsmith', 'John Smith', 'hash4'),
    ('lisa_k', 'Lisa Karlsson', 'hash5'),
    ('omar_a', 'Omar Ali', 'hash6');

INSERT INTO performances(theater, imdb_key, date, time) VALUES
    ('SF Malmö',        'tt0109830', '2026-02-16', '15:00'),
    ('SF Malmö',        'tt0468569', '2026-02-16', '18:00'),
    ('Bio Helsingborg', 'tt1375666', '2026-02-16', '21:00'),
    ('SF Malmö',        'tt0109830', '2026-02-17', '19:00'),
    ('Bio Helsingborg', 'tt0120737', '2026-02-17', '18:30'),
    ('Capitol Stockholm','tt0468569', '2026-02-19', '20:00'),
    ('Capitol Stockholm','tt1375666', '2026-02-20', '17:45');

