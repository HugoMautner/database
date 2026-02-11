# EDAF75 - Lab 2 answers

Hugo Mautner, Emil Helander

## Relational Model
```
theatres(_name_, capacity)
movies(_imdb_id_, title, length, prod_year)
customers(_username_, full_name, hashed_password)
screenings(_screening_id_, /theatre_name/, /imdb_id/, date, start_time)
tickets(_ticket_uuid_, /screening_id/, /username/)
```

## Questions
### 4. Identify keys, both primary keys and foreign keys

1. Which relations have natural keys?
   
- theatres: name
- movies: imdb_id
- customers: username

2. Is there a risk that any of the natural keys will ever change?
   
- theatres: possible, but unlikely
- movies: low risk that its id changes
- customers: high risk that username is changed

3. Are there any weak entity sets?

- There shouldn't be any. Screening could have been, assuming no use of invented key. However with screening_id (invented), it's not weak.

4. In which relations do you want to use an invented key. Why?

- tickets use uuid (invented) key as per lab instructions
- screening_id is invented to simplify FK in tickets


### 7. There are at least two ways of keeping track of the number of seats available for each performance – describe them both, with their upsides and downsides

We can keep track of available seats by either:

1. Deriving the remaining available seats from the screening's theatre's max capacity, and subtracting the nr of tickets:
COUNT(tickets sold for screening) from that, or
2. Keeping another field, a counter, like "seats_left" or "tickets_sold" in the screening entity set, and using that. But that introduces another field which needs to be updated continuously which is less optimal. We'll use method 1.
