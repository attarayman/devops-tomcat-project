<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevOps Tomcat Application</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 50px;
            max-width: 800px;
            width: 100%;
        }
        
        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
        }
        
        .tech-stack {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin: 30px 0;
        }
        
        .tech-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            font-size: 0.9em;
        }
        
        .endpoints {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin: 20px 0;
        }
        
        .endpoint {
            margin: 15px 0;
            padding: 15px;
            background: white;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .endpoint-title {
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .endpoint-url {
            color: #667eea;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        
        .status {
            display: inline-block;
            background: #28a745;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            margin: 20px 0;
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 1em;
            margin: 10px 5px;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DevOps Application</h1>
        <p class="subtitle">CI/CD Pipeline Demonstration with GitHub, Maven, Tomcat, Docker & Jenkins</p>
        
        <div class="status">✓ Application Running</div>
        
        <div class="tech-stack">
            <span class="tech-badge">GitHub</span>
            <span class="tech-badge">Maven</span>
            <span class="tech-badge">Tomcat</span>
            <span class="tech-badge">Docker</span>
            <span class="tech-badge">Jenkins</span>
            <span class="tech-badge">Java 11</span>
        </div>
        
        <div class="endpoints">
            <h3 style="margin-bottom: 15px; color: #333;">📡 Available Endpoints</h3>
            
            <div class="endpoint">
                <div class="endpoint-title">Home Page</div>
                <div class="endpoint-url"><%= request.getContextPath() %>/</div>
            </div>
            
            <div class="endpoint">
                <div class="endpoint-title">Hello API</div>
                <div class="endpoint-url"><%= request.getContextPath() %>/hello</div>
            </div>
            
            <div class="endpoint">
                <div class="endpoint-title">Health Check</div>
                <div class="endpoint-url"><%= request.getContextPath() %>/health</div>
            </div>
        </div>
        
        <div style="text-align: center;">
            <button class="btn" onclick="testAPI()">Test Hello API</button>
            <button class="btn" onclick="checkHealth()">Check Health</button>
        </div>
        
        <div class="footer">
            <p><strong>Version:</strong> 1.0.0</p>
            <p><strong>Build Date:</strong> <%= new java.util.Date() %></p>
            <p><strong>Server:</strong> <%= application.getServerInfo() %></p>
        </div>
    </div>
    
    <script>
        function testAPI() {
            window.open('<%= request.getContextPath() %>/hello?name=DevOps', '_blank');
        }
        
        function checkHealth() {
            window.open('<%= request.getContextPath() %>/health', '_blank');
        }
    </script>
</body>
</html>
