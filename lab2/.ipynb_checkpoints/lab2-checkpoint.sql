

-- Disable FK quickly so we can drop tables in any order.
PRAGMA foreign_keys = OFF;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS screenings;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS theatres;
DROP TABLE IF EXISTS customers;
PRAGMA foreign_keys = ON;


CREATE TABLE theatres (
    name        TEXT,
    capacity    INTEGER NOT NULL CHECK (capacity > 0),
    PRIMARY KEY (name)
);

CREATE TABLE movies (
    imdb_id    TEXT,
    title      TEXT NOT NULL,
    length     INTEGER NOT NULL CHECK (length > 0),
    prod_year  INTEGER NOT NULL,
    PRIMARY KEY (imdb_id)
);

CREATE TABLE customers (
    username        TEXT,
    full_name       TEXT NOT NULL,
    hashed_password TEXT NOT NULL,
    PRIMARY KEY (username)
);

CREATE TABLE screenings (
    screening_id    INTEGER PRIMARY KEY,
    theatre_name    TEXT NOT NULL,
    imdb_id         TEXT NOT NULL,
    date            DATE NOT NULL,
    start_time      TIME NOT NULL,

    FOREIGN KEY (theatre_name) REFERENCES theatres(name),
    FOREIGN KEY (imdb_id) REFERENCES movies(imdb_id),

    -- Make sure no 2 movies start at the same time at the same theatre
    UNIQUE (theatre_name, date, start_time)
);

CREATE TABLE tickets (
    ticket_uuid     TEXT DEFAULT (lower(hex(randomblob(16)))),
    screening_id    INTEGER NOT NULL,
    username        TEXT NOT NULL,

    PRIMARY KEY (ticket_uuid),

    FOREIGN KEY (screening_id) REFERENCES screenings(screening_id),
    FOREIGN KEY (username) REFERENCES customers(username)
);


-- Insert data into tables
INSERT INTO theatres(name, capacity) VALUES
    ('SF Malmö', 250),
    ('Bio Helsingborg', 150),
    ('Capitol Stockholm', 180);

INSERT INTO movies(imdb_id, title, length, prod_year) VALUES
    ('tt0468569', 'The Dark Knight', 152, 2008),
    ('tt0109830', 'Forrest Gump', 142, 1994),
    ('tt1375666', 'Inception', 148, 2010),
    ('tt0120737', 'The Lord of the Rings: The Fellowship of the Ring', 178, 2001);

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

