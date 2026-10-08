<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="com.chatapp.config.DatabaseConfig"%>

<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
%>

<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>ChatApp - Private Chat</title>

    <script src="https://cdn.tailwindcss.com"></script>

    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        darkBg: "#090d16",
                        chatBg: "#0b1120",
                        sidebarBg: "#111827",
                        surface: "#1f2937",
                        surfaceHover: "#374151",
                        borderDark: "#1f2937",
                        limeAccent: "#a3e635",
                        limeHover: "#84cc16",
                    }
                }
            }
        }
    </script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #374151; border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: #4b5563; }
    </style>
</head>

<body class="bg-darkBg text-slate-100 h-[100dvh] flex overflow-hidden selection:bg-limeAccent selection:text-slate-950">

    <!-- MAIN APP CONTAINER -->
    <div class="w-full h-full flex overflow-hidden bg-darkBg relative">

        <!-- =========================
             SIDEBAR (Contacts & Profile)
        ========================= -->
        <aside id="sidebar" class="w-full sm:w-[350px] lg:w-[380px] bg-sidebarBg border-r border-borderDark flex flex-col h-full flex-shrink-0 absolute sm:relative z-20 transition-transform duration-300">

            <!-- USER HEADER -->
            <div class="bg-sidebarBg px-5 py-4 border-b border-borderDark flex items-center justify-between flex-shrink-0">
                <div class="flex items-center gap-3">
                    <div class="w-11 h-11 rounded-2xl bg-darkBg border border-borderDark text-limeAccent flex items-center justify-center font-bold text-lg shadow-sm">
                        <%= username.substring(0, 1).toUpperCase() %>
                    </div>
                    <div>
                        <h2 class="font-bold text-sm tracking-wide text-white">
                            <%= username %>
                        </h2>
                        <div class="flex items-center gap-1.5 mt-0.5">
                            <span class="w-2 h-2 rounded-full bg-limeAccent"></span>
                            <span class="text-xs text-slate-400">Online</span>
                        </div>
                    </div>
                </div>

                <button onclick="logout()" class="text-xs font-semibold text-slate-400 hover:text-limeAccent px-3 py-2 rounded-xl hover:bg-surface transition">
                    Logout
                </button>
            </div>

            <!-- SEARCH SECTION -->
            <div class="px-4 py-3 flex-shrink-0">
                <div class="relative">
                    <svg class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m21 21-4.35-4.35m2.35-5.65a8 8 0 1 1-16 0 8 8 0 0 1 16 0z"></path>
                    </svg>
                    <input type="text" id="searchContact" onkeyup="filterContacts()" placeholder="Search conversations..."
                        class="w-full pl-10 pr-4 py-2.5 bg-darkBg border border-borderDark rounded-2xl text-sm text-slate-200 placeholder-slate-500 focus:outline-none focus:border-limeAccent/50 focus:ring-1 focus:ring-limeAccent/20 transition">
                </div>
            </div>

            <!-- CONTACTS LIST -->
            <div id="contactsList" class="flex-1 overflow-y-auto px-3 pb-3 space-y-1">
                <%
                    try {
                        String sql = "SELECT username FROM users WHERE username != ? ORDER BY username ASC";
                        try (
                            Connection conn = DatabaseConfig.getConnection();
                            PreparedStatement pstmt = conn.prepareStatement(sql)
                        ) {
                            pstmt.setString(1, username);
                            try (ResultSet rs = pstmt.executeQuery()) {
                                boolean hasContacts = false;
                                while (rs.next()) {
                                    hasContacts = true;
                                    String contactUser = rs.getString("username");
                                    String firstLetter = contactUser.substring(0, 1).toUpperCase();
                                    String safeContact = contactUser.replace("\\", "\\\\").replace("'", "\\'");
                %>

                <div onclick="selectContact(this, '<%= safeContact %>')"
                    class="contact-item group p-3 rounded-2xl hover:bg-surface cursor-pointer flex items-center gap-3 transition-all duration-200 border-l-4 border-transparent"
                    data-username="<%= contactUser %>">
                    
                    <!-- AVATAR -->
                    <div class="relative flex-shrink-0">
                        <div class="w-12 h-12 rounded-2xl bg-darkBg text-slate-300 flex items-center justify-center font-bold text-base border border-borderDark group-hover:border-limeAccent/40 group-hover:text-limeAccent transition">
                            <%= firstLetter %>
                        </div>
                        <!-- STATUS DOT -->
                        <span id="status-<%= contactUser %>" class="absolute bottom-0 right-0 w-3.5 h-3.5 bg-slate-500 border-[3px] border-sidebarBg rounded-full"></span>
                    </div>

                    <!-- USER INFO -->
                    <div class="flex-1 min-w-0">
                        <div class="flex items-center justify-between">
                            <h3 class="contact-name font-semibold text-slate-200 text-sm truncate group-hover:text-white">
                                <%= contactUser %>
                            </h3>
                        </div>
                        <p id="subtext-<%= contactUser %>" class="text-xs text-slate-400 font-medium mt-0.5">
                            Offline
                        </p>
                    </div>

                    <!-- ARROW -->
                    <svg class="w-4 h-4 text-slate-600 group-hover:text-limeAccent transition" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m9 18 6-6-6-6"></path>
                    </svg>
                </div>

                <%
                                }
                                if (!hasContacts) {
                %>
                <div class="p-8 text-center">
                    <div class="w-14 h-14 mx-auto mb-3 rounded-2xl bg-darkBg border border-borderDark flex items-center justify-center text-slate-500">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2m9-8a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm5-3v6m3-3h-6"></path>
                        </svg>
                    </div>
                    <p class="text-sm font-semibold text-slate-400">No contacts found</p>
                </div>
                <%
                                }
                            }
                        }
                    } catch (Exception e) {
                %>
                <p class="p-4 text-xs text-red-400">Database Error: <%= e.getMessage() %></p>
                <% } %>
            </div>
        </aside>

        <!-- =========================
             CHAT AREA
        ========================= -->
        <main class="flex-1 flex flex-col h-full bg-chatBg min-w-0 relative">

            <!-- CHAT HEADER -->
            <div id="chatHeader" class="bg-sidebarBg px-4 sm:px-6 py-3.5 border-b border-borderDark flex items-center gap-3 shadow-sm hidden z-10 flex-shrink-0">
                <!-- Back Button for Mobile -->
                <button onclick="closeChatMobile()" class="sm:hidden p-2 -ml-2 text-slate-400 hover:text-white">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
                </button>
                <div class="relative flex-shrink-0">
                    <div id="headerAvatar" class="w-11 h-11 rounded-2xl bg-darkBg text-limeAccent border border-borderDark flex items-center justify-center font-bold text-base shadow-sm"></div>
                    <span id="headerStatusDot" class="absolute bottom-0 right-0 w-3.5 h-3.5 bg-slate-500 border-[3px] border-sidebarBg rounded-full"></span>
                </div>
                <div class="min-w-0">
                    <h3 id="headerUsername" class="font-bold text-slate-100 text-sm truncate"></h3>
                    <span id="headerStatusText" class="text-xs text-slate-400 font-medium">Offline</span>
                </div>
            </div>

            <!-- EMPTY CHAT -->
            <div id="noChatSelected" class="flex-1 flex flex-col items-center justify-center text-slate-500 p-6">
                <div class="w-20 h-20 rounded-3xl bg-sidebarBg border border-borderDark shadow-lg flex items-center justify-center mb-5 text-limeAccent">
                    <svg class="w-9 h-9" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.7" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 0 1-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8 3.582 9 8 9z"></path>
                    </svg>
                </div>
                <h2 class="text-lg font-bold text-slate-200 mb-1">Welcome to ChatApp</h2>
                <p class="text-sm text-slate-500 text-center max-w-sm">Select a contact from the sidebar to start a secure private conversation.</p>
            </div>

            <!-- CHAT BOX (Messages) -->
            <div id="chatBox" class="flex-1 p-4 sm:p-6 overflow-y-auto space-y-3 hidden"></div>

            <!-- MESSAGE INPUT -->
            <div id="chatInputArea" class="bg-sidebarBg px-3 sm:px-5 py-3.5 border-t border-borderDark flex gap-2 sm:gap-3 items-center hidden flex-shrink-0">
                <input type="text" id="messageInput" placeholder="Write a message..."
                    class="flex-1 px-4 py-3 bg-darkBg border border-borderDark rounded-2xl text-sm text-slate-200 placeholder-slate-500 focus:outline-none focus:border-limeAccent/50 focus:ring-1 focus:ring-limeAccent/20 transition">
                <button onclick="sendMessage()"
                    class="w-12 h-12 sm:w-auto sm:px-6 bg-limeAccent hover:bg-limeHover active:scale-95 text-slate-950 rounded-2xl font-bold transition shadow-md flex items-center justify-center gap-2 flex-shrink-0">
                    <span class="hidden sm:inline">Send</span>
                    <svg class="w-5 h-5 rotate-90" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m12 19-7-7 7-7m7 7H5"></path>
                    </svg>
                </button>
            </div>

        </main>
    </div>

<script>
const currentUser = "<%= username %>";
let activeContact = null;
const onlineUsers = new Set();

const wsProtocol = window.location.protocol === "https:" ? "wss://" : "ws://";
const wsUrl = wsProtocol + window.location.host + "<%= request.getContextPath() %>" + "/chat/" + encodeURIComponent(currentUser);
const ws = new WebSocket(wsUrl);

ws.onopen = function() { console.log("WebSocket connected:", currentUser); };

ws.onmessage = function(event) {
    const data = event.data;
    if (data.startsWith("ERROR:")) { alert(data.substring(6)); return; }
    if (data.startsWith("STATUS:")) {
        const parts = data.split(":");
        const statusType = parts[1];
        const targetUser = parts.slice(2).join(":");
        const isOnline = statusType === "ONLINE";
        if (isOnline) { onlineUsers.add(targetUser); } else { onlineUsers.delete(targetUser); }
        updateUserStatusUI(targetUser, isOnline);
        return;
    }
    if (data.startsWith("MSG:")) {
        const firstColon = data.indexOf(":");
        const secondColon = data.indexOf(":", firstColon + 1);
        const sender = data.substring(firstColon + 1, secondColon);
        const message = data.substring(secondColon + 1);
        if (sender === activeContact) { appendMessage(sender, message); }
        return;
    }
};

function updateUserStatusUI(username, isOnline) {
    const statusDot = document.getElementById("status-" + username);
    const subtext = document.getElementById("subtext-" + username);

    if (statusDot) {
        statusDot.className = isOnline 
            ? "absolute bottom-0 right-0 w-3.5 h-3.5 bg-limeAccent border-[3px] border-sidebarBg rounded-full shadow-[0_0_8px_#a3e635]" 
            : "absolute bottom-0 right-0 w-3.5 h-3.5 bg-slate-500 border-[3px] border-sidebarBg rounded-full";
    }
    if (subtext) {
        subtext.innerText = isOnline ? "Online" : "Offline";
        subtext.className = isOnline ? "text-xs text-limeAccent font-medium mt-0.5" : "text-xs text-slate-400 font-medium mt-0.5";
    }
    if (activeContact === username) {
        const headerDot = document.getElementById("headerStatusDot");
        const headerText = document.getElementById("headerStatusText");
        if (headerDot) {
            headerDot.className = isOnline 
                ? "absolute bottom-0 right-0 w-3.5 h-3.5 bg-limeAccent border-[3px] border-sidebarBg rounded-full shadow-[0_0_8px_#a3e635]" 
                : "absolute bottom-0 right-0 w-3.5 h-3.5 bg-slate-500 border-[3px] border-sidebarBg rounded-full";
        }
        if (headerText) {
            headerText.innerText = isOnline ? "Online" : "Offline";
            headerText.className = isOnline ? "text-xs text-limeAccent font-medium" : "text-xs text-slate-400 font-medium";
        }
    }
}

function appendMessage(sender, text) {
    const chatBox = document.getElementById("chatBox");
    const messageDiv = document.createElement("div");

    if (sender === currentUser) {
        messageDiv.className = "flex justify-end";
        messageDiv.innerHTML = '<div class="bg-limeAccent text-slate-950 px-4 py-2.5 rounded-2xl rounded-tr-sm max-w-[85%] sm:max-w-md text-sm shadow-md font-medium break-words">' + escapeHTML(text) + '</div>';
    } else {
        messageDiv.className = "flex justify-start";
        messageDiv.innerHTML = '<div class="bg-surface text-slate-100 border border-borderDark px-4 py-2.5 rounded-2xl rounded-tl-sm max-w-[85%] sm:max-w-md text-sm shadow-md break-words">' + escapeHTML(text) + '</div>';
    }
    chatBox.appendChild(messageDiv);
    chatBox.scrollTop = chatBox.scrollHeight;
}

function selectContact(element, contactName) {
    activeContact = contactName;
    document.getElementById("noChatSelected").classList.add("hidden");
    document.getElementById("chatHeader").classList.remove("hidden");
    document.getElementById("chatBox").classList.remove("hidden");
    document.getElementById("chatInputArea").classList.remove("hidden");

    document.getElementById("headerUsername").innerText = contactName;
    document.getElementById("headerAvatar").innerText = contactName.charAt(0).toUpperCase();

    document.querySelectorAll(".contact-item").forEach(function(item) {
        item.classList.remove("bg-surface", "border-limeAccent");
        item.classList.add("border-transparent");
    });
    element.classList.remove("border-transparent");
    element.classList.add("bg-surface", "border-limeAccent");

    updateUserStatusUI(contactName, onlineUsers.has(contactName));
    loadMessages(contactName);

    if (window.innerWidth < 640) {
        document.getElementById("sidebar").classList.add("-translate-x-full");
    }
}

function closeChatMobile() {
    document.getElementById("sidebar").classList.remove("-translate-x-full");
}

function loadMessages(contactName) {
    const chatBox = document.getElementById("chatBox");
    chatBox.innerHTML = "<p class='text-xs text-center text-slate-500'>Loading history...</p>";

    fetch("getMessages.jsp?contact=" + encodeURIComponent(contactName) + "&_=" + new Date().getTime())
    .then(response => { if (!response.ok) throw new Error("HTTP Error: " + response.status); return response.text(); })
    .then(text => {
        let messages;
        try { messages = JSON.parse(text); } catch (error) { throw new Error("Invalid JSON: " + text); }
        chatBox.innerHTML = "";
        if (!Array.isArray(messages) || messages.length === 0) {
            chatBox.innerHTML = "<p class='text-xs text-center text-slate-500'>No messages yet.</p>";
            return;
        }
        messages.forEach(msg => appendMessage(msg.sender, msg.message));
        chatBox.scrollTop = chatBox.scrollHeight;
    })
    .catch(error => {
        console.error("History Error:", error);
        chatBox.innerHTML = "<p class='text-xs text-center text-red-400'>Cilad ayaa dhacday marka messages-ka la soo saarayo.</p>";
    });
}

function sendMessage() {
    const input = document.getElementById("messageInput");
    const message = input.value.trim();
    if (message === "" || !activeContact) return;
    if (ws.readyState !== WebSocket.OPEN) { alert("WebSocket ma xirmo. Fadlan dib u fur page-ka."); return; }

    ws.send(activeContact + ":" + message);
    appendMessage(currentUser, message);
    input.value = "";
    input.focus();
}

document.getElementById("messageInput").addEventListener("keypress", function(event) {
    if (event.key === "Enter") { event.preventDefault(); sendMessage(); }
});

function filterContacts() {
    const query = document.getElementById("searchContact").value.toLowerCase();
    document.querySelectorAll(".contact-item").forEach(function(item) {
        const name = item.querySelector(".contact-name").innerText.toLowerCase();
        item.style.display = name.includes(query) ? "flex" : "none";
    });
}

function escapeHTML(str) {
    return String(str).replace(/[&<>'"]/g, function(tag) {
        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag];
    });
}

function logout() {
    if (ws && ws.readyState === WebSocket.OPEN) ws.close();
    window.location.href = "logout.jsp";
}
</script>
</body>
</html>