# RadAI Chat - Cloudflare Tunnel Setup

Your RadAI Chat is configured to work seamlessly with Cloudflare tunnel mapping `radiology.haydd.com` → `localhost:5000`.

## 🌩️ How It Works

### Architecture
```
Internet → radiology.haydd.com → Cloudflare Tunnel → localhost:5000 → LM Studio (192.168.2.64:1234)
```

### Smart Configuration
The app automatically detects the access method:

**Local Access (localhost:5000):**
- Configuration: "Local development server" 
- API calls: `/api/*` (relative paths)

**Cloudflare Tunnel (radiology.haydd.com):**
- Configuration: "Cloudflare tunnel to local server"
- API calls: `/api/*` (works through tunnel)

**Other External Access:**
- Configuration: "External access via PHP proxy"
- API calls: `/api.php?path=*` (fallback method)

## ✅ Current Status

Your setup is **ready and working**:
- ✅ Local server running on port 5000
- ✅ API proxy to LM Studio functional
- ✅ 28 AI models available (including lingshu-7b, medgemma-4b-it)
- ✅ Smart configuration detection
- ✅ Cloudflare tunnel support

## 🧪 Testing Your Setup

### 1. Test Local Access
```bash
curl http://localhost:5000
# Should return the RadAI Chat interface
```

### 2. Test Local API
```bash
curl http://localhost:5000/api/v1/models
# Should return JSON with available models
```

### 3. Test Cloudflare Tunnel
```bash
curl https://radiology.haydd.com
# Should return the RadAI Chat interface

curl https://radiology.haydd.com/api/v1/models  
# Should return JSON with available models
```

## 🔧 Troubleshooting

### If radiology.haydd.com shows "Failed to get response from AI model":

1. **Check tunnel status:**
   ```bash
   cloudflared tunnel list
   ```

2. **Verify tunnel configuration:**
   - Ensure tunnel maps `radiology.haydd.com` → `localhost:5000`
   - Check if tunnel is active and healthy

3. **Test API directly:**
   ```bash
   curl https://radiology.haydd.com/api/v1/models
   ```

4. **Check browser console:**
   - Open DevTools (F12)
   - Look for JavaScript errors or network failures
   - Should show: "Cloudflare tunnel to local server"

5. **Verify local server:**
   ```bash
   cd /home/tourniquetrules/radiology
   ./status.sh
   ```

## 🌐 Access Methods

| Method | URL | Use Case |
|--------|-----|----------|
| **Local** | http://localhost:5000 | Development, testing |
| **Network** | http://192.168.2.180:5000 | Hospital LAN access |
| **Internet** | https://radiology.haydd.com | External access via tunnel |

## 🏥 Hospital Usage

Staff can access RadAI Chat from:
- **Hospital computers:** https://radiology.haydd.com
- **Mobile devices:** https://radiology.haydd.com  
- **Internal network:** http://192.168.2.180:5000

All methods provide the same functionality:
- ✅ AI chat with model selection
- ✅ Image upload and analysis
- ✅ Mobile-friendly interface
- ✅ PWA installation support

## 🔒 Security Notes

With Cloudflare tunnel:
- ✅ Automatic HTTPS encryption
- ✅ DDoS protection via Cloudflare
- ✅ No need to expose local ports publicly
- ✅ Access control via Cloudflare Access (if configured)

## 📊 Monitoring

Monitor your setup:
- **Local server status:** `./status.sh`
- **Server logs:** `./logs.sh`
- **API health:** Test endpoints regularly
- **Tunnel status:** Check Cloudflare dashboard

---

**Your RadAI Chat should now work perfectly from radiology.haydd.com!** 🎉

The "Failed to get response from AI model" error should be resolved since the Cloudflare tunnel provides a direct path to your local server with the LM Studio proxy.
