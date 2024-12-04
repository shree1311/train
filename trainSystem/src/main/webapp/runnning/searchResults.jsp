<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.Database" %>
<!DOCTYPE html>
<html>
<head>
    <title>Train Search Results</title>
    <style>
        table {
            width: 80%;
            margin: auto;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
            cursor: pointer;
        }
        .stops-row {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <h1 style="text-align: center;">Train Search Results</h1>
    <table>
        <thead>
            <tr>
                <th>Train ID</th>
                <th>Origin</th>
                <th>Destination</th>
                <th>
                    <a href="searchResults.jsp?origin=<%= request.getParameter("origin") %>&destination=<%= request.getParameter("destination") %>&sortBy=departure_time">Departure Time</a>
                </th>
                <th>
                    <a href="searchResults.jsp?origin=<%= request.getParameter("origin") %>&destination=<%= request.getParameter("destination") %>&sortBy=arrival_time">Arrival Time</a>
                </th>
                <th>
                    <a href="searchResults.jsp?origin=<%= request.getParameter("origin") %>&destination=<%= request.getParameter("destination") %>&sortBy=fare">Fare</a>
                </th>
                <th>Stops</th>
            </tr>
        </thead>
        <tbody>
            <%
                String origin = request.getParameter("origin");
                String destination = request.getParameter("destination");
                String sortBy = request.getParameter("sortBy");
                String showStopsFor = request.getParameter("showStopsFor");

                String sortColumn = "departure_time";
                if ("arrival_time".equals(sortBy)) sortColumn = "arrival_time";
                else if ("fare".equals(sortBy)) sortColumn = "fare";

                if (origin != null && destination != null && !origin.isEmpty() && !destination.isEmpty()) {
                    Database db = new Database();
                    try (Connection conn = db.getConnection()) {
                        String query = """
                            SELECT DISTINCT tla.assign_id, t.train_id, s1.name AS origin, s2.name AS destination,
                                            tlt1.departure_time, tlt2.arrival_time, tl.fare
                            FROM transit_line_assign tla
                            JOIN transit_line tl ON tla.tl_nick = tl.tl_nick
                            JOIN Train t ON tla.train_id = t.train_id
                            JOIN Station s1 ON tl.origin_station_id = s1.station_id
                            JOIN Station s2 ON tl.destination_station_id = s2.station_id
                            JOIN transit_line_stops tls1 ON tls1.t1_nick = tl.tl_nick
                            JOIN transit_line_stops tls2 ON tls2.t1_nick = tl.tl_nick
                            JOIN transit_line_timing tlt1 ON tlt1.stop_id = tls1.stop_id AND tlt1.assign_id = tla.assign_id
                            JOIN transit_line_timing tlt2 ON tlt2.stop_id = tls2.stop_id AND tlt2.assign_id = tla.assign_id
                            WHERE tls1.start_station = (SELECT station_id FROM Station WHERE name = ?)
                              AND tls2.end_station = (SELECT station_id FROM Station WHERE name = ?)
                              AND tls1.number_of_stop <= tls2.number_of_stop
                            ORDER BY %s
                        """.formatted(sortColumn);

                        try (PreparedStatement ps = conn.prepareStatement(query)) {
                            ps.setString(1, origin);
                            ps.setString(2, destination);
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    int trainId = rs.getInt("train_id");
                                    String depTime = rs.getString("departure_time");
                                    String arrTime = rs.getString("arrival_time");
                                    double fare = rs.getDouble("fare");
                                    int assignId = rs.getInt("assign_id");

                                    boolean showStops = String.valueOf(assignId).equals(showStopsFor);
            %>
                                    <tr>
                                        <td><%= trainId %></td>
                                        <td><%= origin %></td>
                                        <td><%= destination %></td>
                                        <td><%= depTime %></td>
                                        <td><%= arrTime %></td>
                                        <td>$<%= fare %></td>
                                        <td>
                                            <a href="searchResults.jsp?origin=<%= origin %>&destination=<%= destination %>&sortBy=<%= sortBy %>&showStopsFor=<%= assignId %>">
                                                <%= showStops ? "Hide Stops" : "View Stops" %>
                                            </a>
                                        </td>
                                    </tr>
                                    <%
                                        if (showStops) {
                                            String stopsQuery = """
                                                SELECT tls.number_of_stop, s.name AS station_name,
                                                       tlt.arrival_time, tlt.departure_time
                                                FROM transit_line_stops tls
                                                JOIN Station s ON tls.start_station = s.station_id
                                                JOIN transit_line_timing tlt ON tls.stop_id = tlt.stop_id
                                                WHERE tlt.assign_id = ? AND tls.number_of_stop BETWEEN
                                                      (SELECT MIN(tls1.number_of_stop)
                                                       FROM transit_line_stops tls1
                                                       WHERE tls1.start_station = (SELECT station_id FROM Station WHERE name = ?))
                                                      AND
                                                      (SELECT MAX(tls2.number_of_stop)
                                                       FROM transit_line_stops tls2
                                                       WHERE tls2.end_station = (SELECT station_id FROM Station WHERE name = ?))
                                                ORDER BY tls.number_of_stop
                                            """;
                                            try (PreparedStatement stopsPs = conn.prepareStatement(stopsQuery)) {
                                                stopsPs.setInt(1, assignId);
                                                stopsPs.setString(2, origin);
                                                stopsPs.setString(3, destination);
                                                try (ResultSet stopsRs = stopsPs.executeQuery()) {
                                                    while (stopsRs.next()) {
                                                        int stopNumber = stopsRs.getInt("number_of_stop");
                                                        String stationName = stopsRs.getString("station_name");
                                                        String arrivalTime = stopsRs.getString("arrival_time");
                                                        String departureTime = stopsRs.getString("departure_time");
                                    %>
                                                        <tr class="stops-row">
                                                            <td colspan="2"></td>
                                                            <td><%= stopNumber %></td>
                                                            <td><%= stationName %></td>
                                                            <td><%= arrivalTime %></td>
                                                            <td><%= departureTime %></td>
                                                            <td></td>
                                                        </tr>
                                    <%
                                                    }
                                                }
                                            }
                                        }
                                    %>
            <%
                                }
                            }
                        }
                    } catch (SQLException e) {
                        out.print("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
                    }
                } else {
            %>
                <tr>
                    <td colspan="7">Please select an origin and destination.</td>
                </tr>
            <%
                }
            %>
        </tbody>
    </table>
</body>
</html>
