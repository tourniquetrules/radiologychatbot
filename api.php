<?php
/**
 * RadAI Chat API Proxy for External Hosting
 * 
 * This file should be placed on your external server (radiology.haydd.com)
 * to proxy requests to your local LM Studio server.
 * 
 * Usage: Upload this file to radiology.haydd.com/api.php
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuration
$LM_STUDIO_BASE_URL = 'http://192.168.2.64:1234';  // Direct to LM Studio

// Get the API path from the request
$path = $_GET['path'] ?? '';
if (empty($path)) {
    http_response_code(400);
    echo json_encode(['error' => 'No API path specified']);
    exit();
}

// Construct the full LM Studio URL
$lm_studio_url = $LM_STUDIO_BASE_URL . '/' . $path;

// Prepare request data
$request_data = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $request_data = file_get_contents('php://input');
}

// Initialize cURL
$ch = curl_init();

curl_setopt_array($ch, [
    CURLOPT_URL => $lm_studio_url,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_FOLLOWLOCATION => true,
    CURLOPT_TIMEOUT => 60,
    CURLOPT_CONNECTTIMEOUT => 10,
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'User-Agent: RadAI-Chat-Proxy/1.0'
    ]
]);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($request_data)) {
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $request_data);
}

// Execute request
$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

// Handle errors
if ($response === false || !empty($error)) {
    http_response_code(502);
    echo json_encode([
        'error' => [
            'message' => 'Failed to connect to AI service: ' . $error,
            'type' => 'connection_error'
        ]
    ]);
    exit();
}

// Return response
http_response_code($http_code);
echo $response;
?>
