<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Search Train Schedules</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        h1 {
            text-align: center;
            margin-bottom: 30px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        select, button {
            padding: 10px;
            margin-bottom: 20px;
            width: 100%;
            font-size: 16px;
        }
    </style>
    <script>
        $(document).ready(function () {
            $("#origin").change(function () {
                var selectedOrigin = $(this).val();
                if (selectedOrigin !== "") {
                    $.ajax({
                        url: "getDestinations.jsp",
                        type: "GET",
                        data: { origin: selectedOrigin },
                        success: function (data) {
                            $("#destination").html(data);
                        },
                        error: function (xhr, status, error) {
                            console.error("Error: " + error);
                        }
                    });
                } else {
                    $("#destination").html("<option value=''>--Select Destination--</option>");
                }
            });
        });
    </script>
</head>
<body>
    <div class="container">
        <h1>Search Train Schedules</h1>

        <!-- Search Form -->
        <form method="get" action="searchSchedules.jsp">
            <label for="origin">Select Origin:</label>
            <select name="origin" id="origin" required>
                <option value="">--Select Origin--</option>
                <%
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/trainsystem", "root", "admin");
                         Statement stmt = con.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT DISTINCT name FROM station")) {

                        while (rs.next()) {
                            String stationName = rs.getString("name");
                %>
                            <option value="<%= stationName %>"><%= stationName %></option>
                <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </select>

            <label for="destination">Select Destination:</label>
            <select name="destination" id="destination" required>
                <option value="">--Select Destination--</option>
            </select>

            <button type="submit">Search</button>
        </form>

        <!-- Display Results -->
        <h2>Results</h2>
        <table>
            <tr>
                <th>Transit Line</th>
                <th>Origin</th>
                <th>Destination</th>
                <th>Departure Time</th>
                <th>Arrival Time</th>
                <th>Fare</th>
            </tr>
            <%
                String origin = request.getParameter("origin");
                String destination = request.getParameter("destination");
                if (origin != null && destination != null) {
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/trainsystem", "root", "admin");
                         PreparedStatement ps = con.prepareStatement(
                                 "SELECT tl.tl_nick, s1.name AS origin, s2.name AS destination, " +
                                         "tlt.departure_time, tlt.arrival_time, tl.fare " +
                                         "FROM transit_line_timing tlt " +
                                         "JOIN transit_line_assign tla ON tlt.assign_id = tla.assign_id " +
                                         "JOIN transit_line tl ON tla.tl_nick = tl.tl_nick " +
                                         "JOIN station s1 ON tl.origin_station_id = s1.station_id " +
                                         "JOIN station s2 ON tl.destination_station_id = s2.station_id " +
                                         "WHERE s1.name = ? AND s2.name = ?")) {
                        ps.setString(1, origin);
                        ps.setString(2, destination);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
            %>
                                <tr>
                                    <td><%= rs.getString("tl_nick") %></td>
                                    <td><%= rs.getString("origin") %></td>
                                    <td><%= rs.getString("destination") %></td>
                                    <td><%= rs.getTime("departure_time") %></td>
                                    <td><%= rs.getTime("arrival_time") %></td>
                                    <td>$<%= rs.getFloat("fare") %></td>
                                </tr>
            <%
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </table>

        <!-- Display All Transit Lines -->
        <h2>All Transit Lines (For Testing)</h2>
        <table>
            <tr>
                <th>Transit Line</th>
                <th>Origin</th>
                <th>Destination</th>
                <th>Stop</th>
                <th>Departure Time</th>
                <th>Arrival Time</th>
            </tr>
            <%
                try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/trainsystem", "root", "admin");
                     Statement stmt = con.createStatement();
                     ResultSet rs = stmt.executeQuery(
                             "SELECT tl.tl_nick, s1.name AS origin, s2.name AS destination, " +
                                     "tls.number_of_stop, tlt.departure_time, tlt.arrival_time " +
                                     "FROM transit_line_timing tlt " +
                                     "JOIN transit_line_assign tla ON tlt.assign_id = tla.assign_id " +
                                     "JOIN transit_line tl ON tla.tl_nick = tl.tl_nick " +
                                     "JOIN transit_line_stops tls ON tlt.stop_id = tls.stop_id " +
                                     "JOIN station s1 ON tls.start_station = s1.station_id " +
                                     "JOIN station s2 ON tls.end_station = s2.station_id")) {

                    while (rs.next()) {
            %>
                        <tr>
                            <td><%= rs.getString("tl_nick") %></td>
                            <td><%= rs.getString("origin") %></td>
                            <td><%= rs.getString("destination") %></td>
                            <td><%= rs.getInt("number_of_stop") %></td>
                            <td><%= rs.getTime("departure_time") %></td>
                            <td><%= rs.getTime("arrival_time") %></td>
                        </tr>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            %>
        </table>
    </div>
</body>
</html>
