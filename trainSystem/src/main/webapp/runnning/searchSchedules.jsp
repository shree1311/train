<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.cs336.pkg.Database" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Train Schedules</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid black;
            padding: 10px;
            text-align: center;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        .form-container {
            margin-bottom: 20px;
        }
        .inline-button {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
        }
        .inline-button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <h1>Search Train Schedules</h1>
    <div class="form-container">
        <form method="get" action="searchResults.jsp">
            <label for="origin">Select Origin:</label>
            <select name="origin" id="origin" required>
                <option value="" disabled selected>--Select Origin--</option>
                <%
                    Database db = new Database();
                    try (Connection con = db.getConnection();
                         PreparedStatement stmt = con.prepareStatement("SELECT DISTINCT name FROM station ORDER BY name");
                         ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                %>
                            <option value="<%= rs.getString("name") %>"><%= rs.getString("name") %></option>
                <% 
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </select>
            
            <label for="destination">Select Destination:</label>
            <select name="destination" id="destination" required>
                <option value="" disabled selected>--Select Destination--</option>
                <%
                    try (Connection con = db.getConnection();
                         PreparedStatement stmt = con.prepareStatement("SELECT DISTINCT name FROM station ORDER BY name");
                         ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                %>
                            <option value="<%= rs.getString("name") %>"><%= rs.getString("name") %></option>
                <% 
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </select>

            <label for="sortBy">Sort By:</label>
            <select name="sortBy">
                <option value="departure_time">Departure Time</option>
                <option value="arrival_time">Arrival Time</option>
                <option value="fare">Fare</option>
            </select>

            <button type="submit">Search</button>
        </form>
    </div>
</body>
</html>
