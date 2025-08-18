# RadAI Chat - Project Overview

## 🏗️ Architecture

**Backend:** Python HTTP Server (`server.py`)
- **Port:** 5000
- **Features:** Static file serving + LM Studio API proxy
- **API Proxy:** `/api/*` → `http://192.168.2.64:1234/*`

**Frontend:** Browser JavaScript
- `script.js` - Main chat application
- `config.js` - Smart environment detection
- `sw.js` - Progressive Web App features

**LM Studio Integration:**
- **Server:** 192.168.2.64:1234
- **Models:** 28 available (including lingshu-7b, medgemma-4b-it)
- **API:** OpenAI-compatible endpoints

## 🌐 Access Methods

| Method | URL | Status |
|--------|-----|--------|
| Local | `http://localhost:5000` | ✅ Working |
| Network | `http://192.168.2.180:5000` | ✅ Ready |
| Internet | `https://radiology.haydd.com` | 🔧 Debugging |

## 🐛 Current Issue

**Mixed Content Error:** Browser blocks HTTP requests from HTTPS page
- **Problem:** `https://radiology.haydd.com` → trying to access `http://192.168.2.64:1234`
- **Solution:** All requests should go through HTTPS proxy: `/api/*`

## 📁 File Structure

```
/home/tourniquetrules/radiology/
├── server.py              # ✅ Python server (active)
├── index.html            # Main interface
├── styles.css            # Styling
├── script.js             # Chat logic
├── config.js             # Environment detection
├── sw.js                 # Service worker
├── manifest.json         # PWA manifest
├── start-background.sh   # Server management
├── stop-server.sh        # Server management
├── status.sh             # Server status
├── logs.sh               # Server logs
└── diagnose.sh           # Troubleshooting
```

## 🔧 Management Commands

```bash
# Start server
./start-background.sh

# Check status
./status.sh

# View logs
./logs.sh

# Diagnose issues
./diagnose.sh

# Stop server
./stop-server.sh
```

## 🎯 Next Steps

1. Test `https://radiology.haydd.com` with browser console open
2. Check configuration detection logs
3. Verify API proxy routing through `/api/*` endpoints
4. Ensure no direct calls to `192.168.2.64:1234`
