

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
    ('Filmstaden Lund', 200),
    ('Kino Lund', 100);

INSERT INTO movies(imdb_id, title, length, prod_year) VALUES
    ('tt0133093', 'The Matrix', 136, 1999),
    ('tt0111161', 'The Shawshank Redemption', 142, 1994);

INSERT INTO customers(username, full_name, hashed_password) VALUES
    ('hmautner', 'Hugo Mautner', 'hash1'),
    ('3mil-H', 'Emil Helander', 'hash2');

INSERT INTO screenings(theatre_name, imdb_id, date, start_time) VALUES
    ('Filmstaden Lund', 'tt0133093', '2026-02-15', '19:30'),
    ('Kino Lund',       'tt0111161', '2026-02-15', '20:00');

