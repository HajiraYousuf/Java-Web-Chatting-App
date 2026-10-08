<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - ChatApp</title>

    <script src="https://cdn.tailwindcss.com"></script>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
        }
    </style>
</head>

<body class="min-h-screen bg-[#090d16] text-white flex items-center justify-center px-5 py-8">

    <div class="w-full max-w-md">

        <!-- Logo -->
        <div class="text-center mb-8">
            <a href="index.html" class="text-2xl font-extrabold">
                Chat<span class="text-lime-400">App</span>
            </a>

            <p class="text-sm text-slate-500 mt-2">
                Sign in to continue your conversations
            </p>
        </div>


        <!-- Login Card -->
        <div class="bg-[#111827] border border-slate-800 rounded-3xl p-6 sm:p-8 shadow-2xl">

            <h1 class="text-2xl font-bold text-center">
                Welcome Back
            </h1>

            <p class="text-center text-sm text-slate-400 mt-2 mb-7">
                Login to your account
            </p>


            <form action="login" method="POST" class="space-y-5">

                <!-- Email -->
                <div>
                    <label class="block text-sm font-medium text-slate-300 mb-2">
                        Email
                    </label>

                    <input type="email"
                           name="email"
                           required
                           placeholder="you@example.com"
                           class="w-full px-4 py-3 bg-[#090d16]
                                  border border-slate-700 rounded-xl
                                  text-white placeholder-slate-600
                                  outline-none
                                  focus:border-lime-400
                                  focus:ring-2 focus:ring-lime-400/20
                                  transition">
                </div>


                <!-- Password -->
                <div>
                    <label class="block text-sm font-medium text-slate-300 mb-2">
                        Password
                    </label>

                    <input type="password"
                           name="password"
                           required
                           placeholder="Enter your password"
                           class="w-full px-4 py-3 bg-[#090d16]
                                  border border-slate-700 rounded-xl
                                  text-white placeholder-slate-600
                                  outline-none
                                  focus:border-lime-400
                                  focus:ring-2 focus:ring-lime-400/20
                                  transition">
                </div>


                <!-- Button -->
                <button type="submit"
                        class="w-full py-3.5 bg-lime-400
                               hover:bg-lime-500
                               active:scale-[0.98]
                               text-slate-950
                               font-bold rounded-xl
                               transition shadow-lg shadow-lime-400/10">
                    Login
                </button>

            </form>


            <!-- Register -->
            <p class="text-center text-sm text-slate-400 mt-6">
                Don't have an account?
                <a href="register.jsp"
                   class="text-lime-400 font-semibold hover:text-lime-300">
                    Register
                </a>
            </p>

        </div>


        <!-- Back -->
        <div class="text-center mt-6">
            <a href="index.html"
               class="text-sm text-slate-500 hover:text-slate-300 transition">
                ← Back to ChatApp
            </a>
        </div>

    </div>

</body>
</html>