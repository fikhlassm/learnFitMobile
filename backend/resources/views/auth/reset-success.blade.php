<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Successful</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen p-4 font-sans">

    <div class="max-w-sm w-full bg-white rounded-2xl shadow-lg p-8 text-center">
        
        <div class="mx-auto flex items-center justify-center h-20 w-20 rounded-full bg-green-100 mb-6">
            <svg class="h-10 w-10 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
            </svg>
        </div>

        <h2 class="text-2xl font-bold text-gray-900 mb-2">Password Updated!</h2>
        <p class="text-gray-500 mb-8 text-sm leading-relaxed">
            Your password has been changed successfully. You can now securely log in to your account.
        </p>

        <a href="myapp://login" 
           class="inline-flex justify-center items-center w-full py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors">
            Return to App
        </a>
        
        <p class="mt-6 text-xs text-gray-400">
            If you are not automatically redirected, please close this window and open the app manually.
        </p>
    </div>

</body>
</html>