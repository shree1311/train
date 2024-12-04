<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.StringWriter, java.io.PrintWriter, com.cs336.pkg.Database" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Stops</title>
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
        }
    </style>
</head>
<body>
    <h1 style="text-align: center;">View Stops</h1>
    <table>
        <thead>
            <tr>
                <th>Stop Number</th>
                <th>Station Name</th>
                <th>Arrival Time</th>
                <th>Departure Time</th>
            </tr>
        </thead>
        <tbody>
            <%
                String assignId = request.getParameter("assignId");
                if (assignId != null && !assignId.isEmpty()) {
                    Database db = new Database();
                    try (Connection conn = db.getConnection()) {
                        String query = """
                            SELECT tls.number_of_stop, s.name AS station_name, tlt.arrival_time, tlt.departure_time
                            FROM transit_line_stops tls
                            JOIN transit_line_timing tlt ON tls.stop_id = tlt.stop_id
                            JOIN Station s ON tls.start_station = s.station_id
                            WHERE tlt.assign_id = ?
                            ORDER BY tls.number_of_stop
                        """;
                        try (PreparedStatement ps = conn.prepareStatement(query)) {
                            ps.setInt(1, Integer.parseInt(assignId));
                            try (ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    int stopNumber = rs.getInt("number_of_stop");
                                    String stationName = rs.getString("station_name");
                                    String arrivalTime = rs.getString("arrival_time");
                                    String departureTime = rs.getString("departure_time");
            %>
                                    <tr>
                                        <td><%= stopNumber %></td>
                                        <td><%= stationName %></td>
                                        <td><%= arrivalTime %></td>
                                        <td><%= departureTime %></td>
                                    </tr>
            <%
                                }
                            }
                        }
                    } catch (SQLException e) {
                        StringWriter sw = new StringWriter();
                        e.printStackTrace(new PrintWriter(sw));
                        out.print("<tr><td colspan='4'>Error: " + sw.toString() + "</td></tr>");
                    }
                } else {
            %>
                <tr>
                    <td colspan="4">No stops to display. Please go back and select a valid train.</td>
                </tr>
            <%
                }
            %>
        </tbody>
    </table>
    <div style="text-align: center; margin: 20px;">
        <a href="searchResults.jsp">Back to Search Results</a>
    </div>
</body>
</html>
