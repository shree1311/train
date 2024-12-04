<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.sql.*" %>
<%@ page import="com.cs336.pkg.Database" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Train Stops</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
    </style>
</head>
<body>
    <h1>Train Stops</h1>
    <%
        int assignId = Integer.parseInt(request.getParameter("assignId"));
        Database db = new Database();
        Connection con = null;
        PreparedStatement pst = null;
        ResultSet rs = null;

        try {
            con = db.getConnection();
            pst = con.prepareStatement(
                "SELECT s.name AS station_name, tlt.departure_time, tlt.arrival_time " +
                "FROM transit_line_timing tlt " +
                "JOIN transit_line_stops tls ON tlt.stop_id = tls.stop_id " +
                "JOIN station s ON tls.start_station = s.station_id " +
                "WHERE tlt.assign_id = ? ORDER BY tlt.departure_time"
            );
            pst.setInt(1, assignId);
            rs = pst.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
                <p>No stops found for this train.</p>
    <%
            } else {
    %>
                <table>
                    <tr>
                        <th>Station</th>
                        <th>Departure Time</th>
                        <th>Arrival Time</th>
                    </tr>
                    <%
                        while (rs.next()) {
                    %>
                        <tr>
                            <td><%= rs.getString("station_name") %></td>
                            <td><%= rs.getTime("departure_time") %></td>
                            <td><%= rs.getTime("arrival_time") %></td>
                        </tr>
                    <%
                        }
                    %>
                </table>
    <%
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>An error occurred while fetching stops.</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (con != null) db.closeConnection(con);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</body>
</html>
