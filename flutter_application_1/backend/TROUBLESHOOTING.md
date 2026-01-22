# Quick Start - Stripe Backend

## Problem: "Cannot connect to payment service"

This error means the Python backend isn't running. Follow these steps:

## Solution: Start the Backend

### Option 1: Using the start script (Recommended)
```bash
cd backend
start.bat
```

### Option 2: Manual start
```bash
cd backend
python stripe_backend.py
```

## What You Should See

When the backend starts successfully, you'll see:
```
==================================================
Starting Stripe Payment Backend...
==================================================
Stripe API Key: Configured
Running on: http://localhost:5000
Health Check: http://localhost:5000/health
==================================================

 * Running on http://127.0.0.1:5000
```

## ✅ Backend is Running!

Once you see this, the backend is ready! Now you can:
1. Keep this terminal window open (don't close it!)
2. Run your Flutter app in a separate terminal
3. Try making payments - they should work now!

## Test Backend is Working

Open a browser and go to: http://localhost:5000/health

You should see:
```json
{"status":"healthy","message":"Stripe backend is running"}
```

## Troubleshooting

❌ **Port 5000 already in use?**
- Close any other programs using port 5000
- Or change the port in `stripe_backend.py` (last line)

❌ **STRIPE_SECRET_KEY not found?**
- Make sure `.env` file exists in the backend folder
- Check that it contains: `STRIPE_SECRET_KEY=sk_test_...`

❌ **Module not found errors?**
- Run: `python -m pip install -r requirements.txt`

## Important Notes

⚠️ **Keep the backend running** - The terminal must stay open while testing payments
⚠️ **Run on every restart** - You need to start the backend each time  you restart your computer
⚠️ **Flutter + Backend** - Both must be running at the same time

## Auto-start on Windows (Optional)

Create a shortcut to `start.bat` on your desktop for quick access!
