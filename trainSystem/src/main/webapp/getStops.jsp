<%@ page language="java" import="java.sql.*, com.cs336.pkg.Database" %>
<%
    Database db = new Database();
    Connection conn = db.getConnection();
    int trainId = Integer.parseInt(request.getParameter("trainId"));
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");

    try {
        String query = "SELECT s.name AS stop_name, tt.departure_time, tt.arrival_time "
                     + "FROM transit_line_stops tls "
                     + "JOIN station s ON tls.start_station = s.station_id "
                     + "JOIN transit_line_timing tt ON tls.stop_id = tt.stop_id "
                     + "WHERE tls.t1_nick = (SELECT tl.tl_nick FROM transit_line_assign WHERE train_id = ?) "
                     + "AND s.name BETWEEN ? AND ? "
                     + "ORDER BY tt.departure_time";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setInt(1, trainId);
        ps.setString(2, origin);
        ps.setString(3, destination);
        ResultSet rs = ps.executeQuery();
%>
<table>
    <thead>
        <tr>
            <th>Stop Name</th>
            <th>Departure Time</th>
            <th>Arrival Time</th>
        </tr>
    </thead>
    <tbody>
        <%
            while (rs.next()) {
                String stopName = rs.getString("stop_name");
                String departureTime = rs.getString("departure_time");
                String arrivalTime = rs.getString("arrival_time");
        %>
        <tr>
            <td><%= stopName %></td>
            <td><%= departureTime %></td>
            <td><%= arrivalTime %></td>
        </tr>
        <%
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.closeConnection(conn);
        }
        %>
    </tbody>
</table>
