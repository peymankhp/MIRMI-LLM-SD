#!/usr/bin/env python3
"""
Flask Web App for Ollama API
Run: python3 web_app.py
Then open: http://localhost:5000
"""

from flask import Flask, render_template_string, request, jsonify, Response
import requests
import json
import time

app = Flask(__name__)

OLLAMA_BASE_URL = "http://localhost:11434"

# HTML Template
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ollama API Web Interface (Flask)</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { font-size: 1.1em; opacity: 0.9; }
        .content { padding: 30px; }
        .section { margin-bottom: 30px; }
        .section h2 { color: #667eea; margin-bottom: 15px; font-size: 1.5em; }
        .model-selector {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .model-card {
            background: #f8f9fa;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 15px;
            cursor: pointer;
            transition: all 0.3s;
            text-align: center;
        }
        .model-card:hover {
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }
        .model-card.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        .model-name { font-weight: bold; font-size: 1.1em; margin-bottom: 5px; }
        .model-size { font-size: 0.9em; opacity: 0.7; }
        .input-group { margin-bottom: 20px; }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        textarea, input, select {
            width: 100%;
            padding: 12px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 1em;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        textarea:focus, input:focus, select:focus {
            outline: none;
            border-color: #667eea;
        }
        textarea { min-height: 120px; resize: vertical; }
        .button-group { display: flex; gap: 10px; margin-bottom: 20px; }
        button {
            flex: 1;
            padding: 15px 30px;
            font-size: 1.1em;
            font-weight: 600;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; }
        .btn-primary:disabled, .btn-secondary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        .response-box {
            background: #f8f9fa;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            padding: 20px;
            min-height: 200px;
            white-space: pre-wrap;
            word-wrap: break-word;
            font-family: 'Courier New', monospace;
            line-height: 1.6;
        }
        .loading { display: none; text-align: center; padding: 20px; }
        .loading.active { display: block; }
        .spinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto 10px;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .api-info {
            background: #e7f3ff;
            border-left: 4px solid #667eea;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .api-info code {
            background: #fff;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .stat-card {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-value {
            font-size: 1.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            font-size: 0.9em;
            color: #6c757d;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 Ollama API Web Interface</h1>
            <p>Flask-powered web interface for your local AI models</p>
        </div>
        
        <div class="content">
            <div class="api-info">
                <strong>🔗 Backend:</strong> <code>Flask + Ollama API</code><br>
                <strong>📡 Status:</strong> <span id="apiStatus">Connected ✅</span>
            </div>
            
            <div class="section">
                <h2>📦 Select Model</h2>
                <div id="modelSelector" class="model-selector">
                    <div class="loading active">
                        <div class="spinner"></div>
                        <p>Loading models...</p>
                    </div>
                </div>
            </div>
            
            <div class="section">
                <h2>💬 Chat</h2>
                
                <div class="input-group">
                    <label for="prompt">Your Message:</label>
                    <textarea id="prompt" placeholder="Type your message here...">Hello! Can you introduce yourself?</textarea>
                </div>
                
                <div class="input-group">
                    <label for="temperature">Temperature (0.0 - 2.0):</label>
                    <input type="number" id="temperature" value="0.7" min="0" max="2" step="0.1">
                </div>
                
                <div class="button-group">
                    <button class="btn-primary" onclick="sendMessage()" id="sendBtn">
                        🚀 Send Message
                    </button>
                    <button class="btn-secondary" onclick="clearResponse()">
                        🗑️ Clear
                    </button>
                </div>
                
                <div class="loading" id="loading">
                    <div class="spinner"></div>
                    <p>Generating response...</p>
                </div>
                
                <div class="input-group">
                    <label>Response:</label>
                    <div id="response" class="response-box">Response will appear here...</div>
                </div>
                
                <div class="stats" id="stats" style="display: none;">
                    <div class="stat-card">
                        <div class="stat-value" id="tokenCount">-</div>
                        <div class="stat-label">Tokens</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="responseTime">-</div>
                        <div class="stat-label">Response Time</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="modelUsed">-</div>
                        <div class="stat-label">Model</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        let selectedModel = null;
        
        window.addEventListener('DOMContentLoaded', async () => {
            await loadModels();
        });
        
        async function loadModels() {
            try {
                const response = await fetch('/api/models');
                const data = await response.json();
                
                const modelSelector = document.getElementById('modelSelector');
                modelSelector.innerHTML = '';
                
                if (data.models && data.models.length > 0) {
                    data.models.forEach((model, index) => {
                        const card = document.createElement('div');
                        card.className = 'model-card';
                        if (index === 0) {
                            card.classList.add('active');
                            selectedModel = model.name;
                        }
                        
                        card.innerHTML = `
                            <div class="model-name">${model.name}</div>
                            <div class="model-size">${model.size}</div>
                        `;
                        
                        card.onclick = () => selectModel(model.name, card);
                        modelSelector.appendChild(card);
                    });
                } else {
                    modelSelector.innerHTML = '<p>No models found</p>';
                }
            } catch (error) {
                console.error('Error loading models:', error);
            }
        }
        
        function selectModel(modelName, cardElement) {
            document.querySelectorAll('.model-card').forEach(card => {
                card.classList.remove('active');
            });
            cardElement.classList.add('active');
            selectedModel = modelName;
        }
        
        async function sendMessage() {
            if (!selectedModel) {
                alert('Please select a model first');
                return;
            }
            
            const prompt = document.getElementById('prompt').value;
            if (!prompt.trim()) {
                alert('Please enter a message');
                return;
            }
            
            const responseBox = document.getElementById('response');
            const loading = document.getElementById('loading');
            const sendBtn = document.getElementById('sendBtn');
            const stats = document.getElementById('stats');
            const temperature = parseFloat(document.getElementById('temperature').value);
            
            loading.classList.add('active');
            sendBtn.disabled = true;
            responseBox.textContent = '';
            stats.style.display = 'none';
            
            const startTime = Date.now();
            
            try {
                const response = await fetch('/api/generate', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        model: selectedModel,
                        prompt: prompt,
                        temperature: temperature
                    })
                });
                
                const data = await response.json();
                const endTime = Date.now();
                
                responseBox.textContent = data.response;
                
                const tokenCount = data.response.split(/\s+/).length;
                const timeSec = ((endTime - startTime) / 1000).toFixed(2);
                
                document.getElementById('tokenCount').textContent = tokenCount;
                document.getElementById('responseTime').textContent = timeSec + 's';
                document.getElementById('modelUsed').textContent = selectedModel.split(':')[0];
                stats.style.display = 'grid';
                
            } catch (error) {
                console.error('Error:', error);
                responseBox.textContent = 'Error: ' + error.message;
            } finally {
                loading.classList.remove('active');
                sendBtn.disabled = false;
            }
        }
        
        function clearResponse() {
            document.getElementById('response').textContent = 'Response will appear here...';
            document.getElementById('stats').style.display = 'none';
        }
        
        document.getElementById('prompt').addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.ctrlKey && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/models')
def get_models():
    try:
        response = requests.get(f"{OLLAMA_BASE_URL}/api/tags")
        data = response.json()
        
        models = []
        for model in data.get('models', []):
            models.append({
                'name': model['name'],
                'size': f"{model['size'] / 1e9:.1f} GB"
            })
        
        return jsonify({'models': models})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/generate', methods=['POST'])
def generate():
    try:
        data = request.json
        model = data.get('model')
        prompt = data.get('prompt')
        temperature = data.get('temperature', 0.7)
        
        response = requests.post(
            f"{OLLAMA_BASE_URL}/api/generate",
            json={
                'model': model,
                'prompt': prompt,
                'stream': False,
                'options': {
                    'temperature': temperature
                }
            }
        )
        
        result = response.json()
        return jsonify({'response': result['response']})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    print("=" * 70)
    print("🚀 Starting Ollama Web Interface")
    print("=" * 70)
    print()
    print("📡 Ollama API:", OLLAMA_BASE_URL)
    print("🌐 Web Interface: http://localhost:5000")
    print()
    print("Press Ctrl+C to stop the server")
    print("=" * 70)
    print()
    
    app.run(host='0.0.0.0', port=5000, debug=True)
