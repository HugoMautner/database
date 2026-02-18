import sqlite3
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
    c.execute("DELETE FROM screenings;")
    c.execute("DELETE FROM movies;")
    c.execute("DELETE FROM customers;")
    c.execute("DELETE FROM theatres;")

    c.executemany(
        "INSERT INTO theatres(name, capacity) VALUES (?, ?);",
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

    c = db.cursor()

    exists = c.execute(
        "SELECT 1 FROM customers WHERE username = ?;", [username]
    ).fetchone()

    if exists:
        response.status = 400
        return ""

    # TODO add pwd hashing
    c.execute(
        "INSERT INTO customers(username, full_name, hashed_password) VALUES (?, ?, ?);",
        [username, full_name, pwd],
    )
    db.commit()

    response.status = 201
    return f"/users/{username}"


run(host=HOST, port=PORT, debug=True, reloader=True)
