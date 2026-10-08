<%@page contentType="application/json" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%@page import="com.chatapp.config.DatabaseConfig" %>
<%
    out.clear();

    String currentUser = (String) session.getAttribute("username");
    String contact = request.getParameter("contact");

    if (currentUser == null || contact == null || contact.trim().isEmpty()) {
        out.print("[]");
        return;
    }

    StringBuilder jsonResult = new StringBuilder("[");
    
    
String findUserSQL = "SELECT id FROM users WHERE username = ?";
String sql = "SELECT sender_id, message FROM messages " +
             "WHERE (sender_id = ? AND receiver_id = ?) " +
             "OR (sender_id = ? AND receiver_id = ?) " +
             "ORDER BY id ASC";

try (Connection conn = DatabaseConfig.getConnection()) {
    int currentUserId;
    int contactId;

    try (PreparedStatement ps = conn.prepareStatement(findUserSQL)) {
        ps.setString(1, currentUser);
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                out.print("[]");
                return;
            }
            currentUserId = rs.getInt("id");
        }
    }

    try (PreparedStatement ps = conn.prepareStatement(findUserSQL)) {
        ps.setString(1, contact);
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                out.print("[]");
                return;
            }
            contactId = rs.getInt("id");
        }
    }

    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setInt(1, currentUserId);
        pstmt.setInt(2, contactId);
        pstmt.setInt(3, contactId);
        pstmt.setInt(4, currentUserId);

        try (ResultSet rs = pstmt.executeQuery()) {
            boolean first = true;

            while (rs.next()) {
                if (!first) jsonResult.append(",");

                int senderId = rs.getInt("sender_id");
                String sender = senderId == currentUserId
                    ? currentUser : contact;

                String msg = rs.getString("message")
                    .replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "");

                jsonResult.append("{\"sender\":\"")
                    .append(sender)
                    .append("\",\"message\":\"")
                    .append(msg)
                    .append("\"}");

                first = false;
            }
        }
    }
} catch (Exception e) {
    e.printStackTrace();
}
jsonResult.append("]");
out.print(jsonResult.toString());
%>