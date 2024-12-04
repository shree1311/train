from datetime import datetime, timedelta

def generate_insert_queries():
    queries = []

    # Generate INSERT queries for New York to Trenton
    ny_trenton_start_time = datetime.strptime("06:00:00", "%H:%M:%S")
    for i in range(18):  # Assuming trains run 6 AM to 11:40 PM (every 40 minutes)
        departure = ny_trenton_start_time + timedelta(minutes=40 * i)
        arrival = departure + timedelta(minutes=90)  # Travel time is assumed to be 90 minutes
        queries.append(
            f"INSERT INTO transit_line_timing (assign_id, stop_id, departure_time, arrival_time) "
            f"VALUES (1, {i + 1}, '{departure.time()}', '{arrival.time()}');"
        )

    # Generate INSERT queries for Trenton to New York
    trenton_ny_start_time = datetime.strptime("06:00:00", "%H:%M:%S")
    for i in range(18):
        departure = trenton_ny_start_time + timedelta(minutes=40 * i)
        arrival = departure + timedelta(minutes=90)  # Travel time is assumed to be 90 minutes
        queries.append(
            f"INSERT INTO transit_line_timing (assign_id, stop_id, departure_time, arrival_time) "
            f"VALUES (1, {i + 19}, '{departure.time()}', '{arrival.time()}');"
        )

    # Generate INSERT queries for Atlantic City to Philadelphia
    atlantic_start_time = datetime.strptime("06:30:00", "%H:%M:%S")
    for i in range(18):
        departure = atlantic_start_time + timedelta(minutes=40 * i)
        arrival = departure + timedelta(minutes=120)  # Travel time is assumed to be 120 minutes
        queries.append(
            f"INSERT INTO transit_line_timing (assign_id, stop_id, departure_time, arrival_time) "
            f"VALUES (2, {i + 1}, '{departure.time()}', '{arrival.time()}');"
        )

    # Generate INSERT queries for Philadelphia to Atlantic City
    philly_start_time = datetime.strptime("06:30:00", "%H:%M:%S")
    for i in range(18):
        departure = philly_start_time + timedelta(minutes=40 * i)
        arrival = departure + timedelta(minutes=120)  # Travel time is assumed to be 120 minutes
        queries.append(
            f"INSERT INTO transit_line_timing (assign_id, stop_id, departure_time, arrival_time) "
            f"VALUES (2, {i + 19}, '{departure.time()}', '{arrival.time()}');"
        )

    return queries


def write_to_file(filename, queries):
    with open(filename, "w") as file:
        for query in queries:
            file.write(query + "\n")


# Generate INSERT queries and write to populatedb.txt
insert_queries = generate_insert_queries()
write_to_file("populatedb.txt", insert_queries)

print("populatedb.txt file with INSERT queries has been created successfully.")
