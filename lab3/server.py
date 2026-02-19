import sqlite3
from turtle import title
from typing import cast

from bottle import get, post, request, response, run

HOST = "localhost"
PORT = 7007

DB_PATH = "lab3.sqlite"
db = sqlite3.connect(DB_PATH)
db.row_factory = sqlite3.Row
db.execute("PRAGMA foreign_keys = ON;")


@get("/ping")
def ping():
    response.status = 200
    return "pong"


@post("/reset")
def reset():
    c = db.cursor()
    c.execute("DELETE FROM tickets;")
    c.execute("DELETE FROM performances;")
    c.execute("DELETE FROM movies;")
    c.execute("DELETE FROM customers;")
    c.execute("DELETE FROM theaters;")

    c.executemany(
        "INSERT INTO theaters(name, capacity) VALUES (?, ?);",
        [("Kino", 10), ("Regal", 16), ("Skandia", 100)],
    )
    db.commit()
    response.status = 200
    return ""


@post("/users")
def post_users():
    body = cast(dict, request.json)
    username = body["username"]
    full_name = body["fullName"]
    pwd = body["pwd"]
    hashed_pwd = hash(pwd)

    c = db.cursor()

    exists = c.execute(
        "SELECT 1 FROM customers WHERE username = ?;", [username]
    ).fetchone()

    if exists:
        response.status = 400
        return ""

    c.execute(
        "INSERT INTO customers(username, full_name, hashed_password) VALUES (?, ?, ?);",
        [username, full_name, hashed_pwd],
    )
    db.commit()

    response.status = 201
    return f"/users/{username}"


@post("/movies")
def post_movies():
    body = cast(dict, request.json)
    imdb_key = body["imdbKey"]
    title = body["title"]
    year = body["year"]

    c = db.cursor()

    exists = c.execute(
        "SELECT 1 FROM movies WHERE imdb_key = ?;", [imdb_key]
    ).fetchone()

    if exists:
        response.status = 400
        return ""

    c.execute(
        "INSERT INTO movies(imdb_key, title, year) VALUES (?, ?, ?);",
        [imdb_key, title, year],
    )
    db.commit()

    response.status = 201
    return f"/movies/{imdb_key}"


@post("/performances")
def post_performances():
    body = cast(dict, request.json)
    imdb_key = body["imdbKey"]
    theater = body["theater"]
    date = body["date"]
    time = body["time"]

    c = db.cursor()

    result = c.execute(
        "INSERT INTO performances(imdb_key, theater, date, time) VALUES (?, ?, ?, ?) RETURNING performance_id;",
        [imdb_key, theater, date, time],
    )
    performance_id = result.fetchone()[0]
    db.commit()
    response.status = 201
    return f"/performances/{performance_id}"


@get("/movies")
def get_movies():
    c = db.cursor()
    c.execute(
        """
        SELECT  imdb_key, title, year
        FROM    movies
        """,
    )
    found = [
        {"imdbKey": imdb_key, "title": title, "year": year}
        for imdb_key, title, year in c
    ]
    response.status = 200
    return {"data": found}


@get("/movies/<imdb_key>")
def get_movie(imdb_key):
    c = db.cursor()
    c.execute(
        """
        SELECT  imdb_key, title, year
        FROM    movies
        WHERE   imdb_key = ?
        """,
        [imdb_key],
    )
    found = [
        {"imdbKey": imdb_key, "title": title, "year": year}
        for imdb_key, title, year in c
    ]
    response.status = 200
    return {"data": found}


@get("/performances")
def get_performances():
    c = db.cursor()
    c.execute(
        """
        SELECT  p.performance_id, p.theater, p.imdb_key, p.date, p.time,
                t.capacity - COALESCE(COUNT(tk.ticket_id), 0) as remaining_seats
        FROM    performances p
        JOIN    theaters t ON p.theater = t.name
        LEFT JOIN tickets tk ON p.performance_id = tk.performance_id
        GROUP BY p.performance_id
        """,
    )
    found = [
        {
            "performanceId": performance_id,
            "theater": theater,
            "imdbKey": imdb_key,
            "date": date,
            "startTime": time,
            "remainingSeats": remaining_seats,
        }
        for performance_id, theater, imdb_key, date, time, remaining_seats in c
    ]
    response.status = 200
    return {"data": found}


@post("/tickets")
def post_tickets():
    body = cast(dict, request.json)
    username = body["username"]
    pwd = body["pwd"]
    performance_id = body["performanceId"]

    hashed_pwd = hash(pwd)

    c = db.cursor()

    user = c.execute(
        "SELECT 1 FROM customers WHERE username = ? AND hashed_password = ?;",
        [username, hashed_pwd],
    ).fetchone()

    if not user:
        response.status = 401
        return "Wrong user credentials"

    performance = c.execute(
        """
        SELECT t.capacity - COALESCE(COUNT(tk.ticket_id), 0) as remaining_seats
        FROM performances p
        JOIN theaters t ON p.theater = t.name
        LEFT JOIN tickets tk ON p.performance_id = tk.performance_id
        WHERE p.performance_id = ?
        GROUP BY p.performance_id
        """,
        [performance_id],
    ).fetchone()

    if not performance or performance[0] <= 0:
        response.status = 400
        return "No tickets left"

    try:
        result = c.execute(
            "INSERT INTO tickets(username, performance_id) "
            "VALUES (?, ?) "
            "RETURNING ticket_id;",
            [username, performance_id],
        )
        ticket_id = result.fetchone()[0]
        db.commit()
        response.status = 201
        return f"/tickets/{ticket_id}"
    except:
        response.status = 400
        return "Error"


@get("/users/<username>/tickets")
def get_user_tickets(username):
    c = db.cursor()
    c.execute(
        """
        SELECT p.theater, p.date, p.time, COUNT(t.ticket_id) as nbr
        FROM tickets t
        JOIN performances p ON t.performance_id = p.performance_id
        WHERE t.username = ?
        GROUP BY p.performance_id
        """,
        [username],
    )
    found = [
        {"date": date, "startTime": time, "theater": theater, "nbrOfTickets": nbr}
        for theater, date, time, nbr in c
    ]
    response.status = 200
    return {"data": found}


def hash(msg):
    import hashlib

    return hashlib.sha256(msg.encode("utf-8")).hexdigest()


run(host=HOST, port=PORT, debug=True, reloader=True)
