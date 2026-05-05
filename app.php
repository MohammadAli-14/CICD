<?php
/**
 * PHP Status Page
 * Demonstrates that PHP is working correctly on the VM
 */

header('Content-Type: text/html; charset=utf-8');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP Status - Kilo CICD</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 900px;
            margin: 30px auto;
            padding: 20px;
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: #333;
            min-height: 100vh;
        }
        .container {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #11998e;
            text-align: center;
            margin-bottom: 30px;
        }
        .section {
            margin: 25px 0;
            padding: 20px;
            background: #f8fafc;
            border-radius: 10px;
            border-left: 4px solid #11998e;
        }
        .section h2 {
            margin-top: 0;
            color: #2d3748;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
        }
        table th {
            background: #e2e8f0;
            padding: 10px;
            text-align: left;
            font-weight: 600;
        }
        table td {
            padding: 10px;
            border-bottom: 1px solid #e2e8f0;
        }
        .success {
            color: #10b981;
            font-weight: bold;
        }
        .info {
            color: #3b82f6;
            font-weight: bold;
        }
        code {
            background: #1e293b;
            color: #e2e8f0;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #64748b;
            font-size: 14px;
        }
        a {
            color: #11998e;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚡ PHP Status Dashboard</h1>

        <div class="section">
            <h2>Server Information</h2>
            <table>
                <tr>
                    <th>PHP Version</th>
                    <td><span class="success"><?php echo phpversion(); ?></span></td>
                </tr>
                <tr>
                    <th>Server Software</th>
                    <td><?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'N/A'; ?></td>
                </tr>
                <tr>
                    <th>Server Name</th>
                    <td><?php echo $_SERVER['SERVER_NAME'] ?? 'N/A'; ?></td>
                </tr>
                <tr>
                    <th>Document Root</th>
                    <td><code><?php echo $_SERVER['DOCUMENT_ROOT'] ?? 'N/A'; ?></code></td>
                </tr>
                <tr>
                    <th>Current Time</th>
                    <td><?php echo date('Y-m-d H:i:s'); ?></td>
                </tr>
            </table>
        </div>

        <div class="section">
            <h2>PHP Configuration</h2>
            <table>
                <tr>
                    <th>Display Errors</th>
                    <td><?php echo ini_get('display_errors') ? 'On' : 'Off'; ?></td>
                </tr>
                <tr>
                    <th>Error Reporting</th>
                    <td><code><?php echo error_reporting(); ?></code></td>
                </tr>
                <tr>
                    <th>Memory Limit</th>
                    <td><?php echo ini_get('memory_limit'); ?></td>
                </tr>
                <tr>
                    <th>Max Execution Time</th>
                    <td><?php echo ini_get('max_execution_time'); ?> seconds</td>
                </tr>
                <tr>
                    <th>Upload Max Size</th>
                    <td><?php echo ini_get('upload_max_filesize'); ?></td>
                </tr>
            </table>
        </div>

        <div class="section">
            <h2>Request Information</h2>
            <table>
                <tr>
                    <th>Request Method</th>
                    <td><span class="info"><?php echo $_SERVER['REQUEST_METHOD']; ?></span></td>
                </tr>
                <tr>
                    <th>Request URI</th>
                    <td><code><?php echo $_SERVER['REQUEST_URI']; ?></code></td>
                </tr>
                <tr>
                    <th>User Agent</th>
                    <td><?php echo substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 80); ?>...</td>
                </tr>
                <tr>
                    <th>Remote Address</th>
                    <td><?php echo $_SERVER['REMOTE_ADDR'] ?? 'N/A'; ?></td>
                </tr>
            </table>
        </div>

        <div class="section">
            <h2>Extensions Loaded</h2>
            <p><strong>Total Extensions:</strong> <?php echo count(get_loaded_extensions()); ?></p>
            <p>Common extensions: <?php
                $exts = ['mysqli', 'pdo', 'curl', 'json', 'mbstring', 'openssl', 'zip'];
                $loaded = array_filter($exts, function($ext) { return extension_loaded($ext); });
                echo implode(', ', array_map(function($e) { return "<span class='success'>$e</span>"; }, $loaded));
            ?></p>
        </div>

        <div class="footer">
            <p>Deployed via <strong>GitHub Actions</strong> | <a href="../">Back to Home</a></p>
            <p>© <?php echo date('Y'); ?> Kilo CICD Pipeline</p>
        </div>
    </div>
</body>
</html>
