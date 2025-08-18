# RadAI Chat External Deployment Instructions

This guide explains how to set up RadAI Chat to work from external domains like `radiology.haydd.com` while connecting to your local LM Studio server.

## 🌐 Problem

When accessing RadAI Chat from an external domain (like `radiology.haydd.com`), the browser blocks direct API calls to your local server (`192.168.2.180:5000`) due to CORS (Cross-Origin Resource Sharing) restrictions and network policies.

## ✅ Solution

Use a PHP proxy on your external server to forward API requests to your local LM Studio server.

## 📁 Files to Upload to radiology.haydd.com

Upload these files to your external web server:

```
radiology.haydd.com/
├── index.html
├── styles.css
├── script.js
├── config.js
├── manifest.json
├── sw.js
├── api.php          ← This is the key proxy file
└── paste-test.html  (optional)
```

## 🔧 Setup Steps

### 1. Upload Files to External Server

Upload all the RadAI Chat files to your `radiology.haydd.com` server, including the new `api.php` file.

### 2. Configure the PHP Proxy

The `api.php` file is already configured to connect to your LM Studio server at `192.168.2.64:1234`. 

If you need to change the LM Studio address, edit this line in `api.php`:
```php
$LM_STUDIO_BASE_URL = 'http://192.168.2.64:1234';
```

### 3. Test the Setup

1. **Access locally**: `http://localhost:5000` (should use direct proxy)
2. **Access externally**: `https://radiology.haydd.com` (should use PHP proxy)

## 🔍 How It Works

### Local Access (localhost:5000)
```
Browser → Your Python Server (/api) → LM Studio (192.168.2.64:1234)
```

### External Access (radiology.haydd.com)
```
Browser → External Server (api.php) → LM Studio (192.168.2.64:1234)
```

## 🧪 Testing

### Test External Connectivity

1. **Visit**: `https://radiology.haydd.com/api.php?path=v1/models`
2. **Expected**: JSON response with available models
3. **If it fails**: Check if radiology.haydd.com can reach your network

### Test Chat Functionality

1. **Open**: `https://radiology.haydd.com`
2. **Check console**: Should show "External access via PHP proxy"
3. **Send message**: Should work normally

## ⚠️ Network Requirements

For external access to work, your external server must be able to reach your LM Studio server:

- **Option A**: LM Studio server has public IP access
- **Option B**: External server is on same network/VPN
- **Option C**: Network routing allows external→internal connections

## 🔒 Security Considerations

1. **Firewall**: Ensure LM Studio server allows connections from external server
2. **Authentication**: Consider adding API key authentication to api.php
3. **Rate Limiting**: Consider adding rate limiting to prevent abuse
4. **HTTPS**: Use HTTPS for production deployment

## 🐛 Troubleshooting

### "Failed to get response from AI model"

1. **Check PHP proxy**: Visit `/api.php?path=v1/models` directly
2. **Check network**: Can external server reach `192.168.2.64:1234`?
3. **Check LM Studio**: Is it running and accessible?
4. **Check browser console**: Look for detailed error messages

### CORS Errors

- Should be resolved by the PHP proxy
- If still occurring, check if api.php is properly configured

### Connection Timeouts

- Increase timeout in api.php (currently 60 seconds)
- Check network latency between servers

## 📊 Monitoring

The JavaScript automatically tests connectivity on startup and shows:
- ✅ Success: Normal operation
- ⚠️ Warning: Connectivity issues detected

## 🚀 Production Deployment

For production use:

1. **Use HTTPS** for security
2. **Add authentication** to api.php
3. **Monitor performance** and add caching if needed
4. **Set up proper error logging**
5. **Configure backup LM Studio servers**

---

Your RadAI Chat should now work from both local and external access points!
