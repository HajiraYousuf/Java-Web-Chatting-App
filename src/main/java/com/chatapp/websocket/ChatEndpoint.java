package com.chatapp.websocket;

import com.chatapp.config.DatabaseConfig;
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chat/{username}")
public class ChatEndpoint {

    private static final Map<String, Session> userSessions =
            new ConcurrentHashMap<>();

    // =========================
    // USER CONNECTS
    // =========================
    @OnOpen
    public void onOpen(
            Session session,
            @PathParam("username") String username) {

        if (username == null || username.trim().isEmpty()) {
            try {
                session.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return;
        }

        username = username.trim();

        userSessions.put(username, session);

        System.out.println("User Connected: " + username);

        // U sheeg dhammaan users-ka in user-kan Online yahay
        broadcastStatus("STATUS:ONLINE:" + username);

        // User-ka cusub u sheeg dadka hore Online u ahaa
        for (String onlineUser : userSessions.keySet()) {

            if (!onlineUser.equals(username)) {

                try {
                    session.getBasicRemote().sendText(
                            "STATUS:ONLINE:" + onlineUser
                    );

                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // =========================
    // MESSAGE RECEIVED
    // =========================
    @OnMessage
    public void onMessage(
            String message,
            Session session,
            @PathParam("username") String senderUsername) {

        if (message == null || message.trim().isEmpty()) {
            return;
        }

        /*
         * Message format:
         *
         * receiver:message
         *
         * Example:
         * Amina:Hello
         */

        if (!message.contains(":")) {
            return;
        }

        String[] parts = message.split(":", 2);

        String receiverUsername = parts[0].trim();
        String msgText = parts[1].trim();

        if (receiverUsername.isEmpty() || msgText.isEmpty()) {
            return;
        }

        // =========================
        // 1. SAVE TO DATABASE
        // =========================

        boolean saved = saveMessageToDB(
                senderUsername,
                receiverUsername,
                msgText
        );

        if (!saved) {
            try {
                session.getBasicRemote().sendText(
                        "ERROR:Message could not be saved."
                );
            } catch (IOException e) {
                e.printStackTrace();
            }

            return;
        }

        // =========================
        // 2. SEND TO RECEIVER
        // =========================

        Session receiverSession =
                userSessions.get(receiverUsername);

        if (receiverSession != null
                && receiverSession.isOpen()) {

            try {

                receiverSession.getBasicRemote().sendText(
                        "MSG:"
                        + senderUsername
                        + ":"
                        + msgText
                );

                System.out.println(
                        "Message sent from "
                        + senderUsername
                        + " to "
                        + receiverUsername
                );

            } catch (IOException e) {
                e.printStackTrace();
            }

        } else {

            System.out.println(
                    receiverUsername
                    + " is Offline. "
                    + "Message is saved in Database."
            );
        }
    }

    // =========================
    // USER DISCONNECTS
    // =========================
    @OnClose
    public void onClose(
            Session session,
            @PathParam("username") String username) {

        if (username == null || username.trim().isEmpty()) {
            return;
        }

        /*
         * Kaliya connection-kan oo keliya.
         *
         * Tani waxay ka hortagaysaa in session cusub
         * si khalad ah loo tirtiro.
         */

        Session currentSession = userSessions.get(username);

        if (currentSession == session) {

            userSessions.remove(username);

            System.out.println(
                    "User Disconnected: " + username
            );

            broadcastStatus(
                    "STATUS:OFFLINE:" + username
            );
        }
    }

    // =========================
    // ERROR
    // =========================
    @OnError
    public void onError(
            Session session,
            Throwable throwable) {

        System.err.println(
                "WebSocket Error: "
                + throwable.getMessage()
        );
    }

    // =========================
    // SAVE MESSAGE TO MYSQL
    // =========================

private boolean saveMessageToDB(String senderUsername, String receiverUsername, String msgText) {
    String findUserSQL = "SELECT id FROM users WHERE username = ?";
    String insertSQL = "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)";

    try (Connection conn = DatabaseConfig.getConnection()) {
        int senderId;
        int receiverId;

        // Find sender ID
        try (PreparedStatement ps = conn.prepareStatement(findUserSQL)) {
            ps.setString(1, senderUsername);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    System.err.println("Sender not found: " + senderUsername);
                    return false;
                }
                senderId = rs.getInt("id");
            }
        }

        // Find receiver ID
        try (PreparedStatement ps = conn.prepareStatement(findUserSQL)) {
            ps.setString(1, receiverUsername);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    System.err.println("Receiver not found: " + receiverUsername);
                    return false;
                }
                receiverId = rs.getInt("id");
            }
        }

        // Save message
        try (PreparedStatement ps = conn.prepareStatement(insertSQL)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.setString(3, msgText);

            int rows = ps.executeUpdate();
            return rows > 0;
        }

    } catch (SQLException e) {
        System.err.println("========== MESSAGE SAVE ERROR ==========");
        e.printStackTrace();
        return false;
    }
}
    // =========================
    // BROADCAST ONLINE/OFFLINE
    // =========================
    private void broadcastStatus(String statusMsg) {

        for (Session session : userSessions.values()) {

            if (session.isOpen()) {

                try {

                    session.getBasicRemote()
                            .sendText(statusMsg);

                } catch (IOException e) {

                    e.printStackTrace();
                }
            }
        }
    }
}