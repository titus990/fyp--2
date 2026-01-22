from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore
import datetime

# Load environment variables BEFORE importing stripe
env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)

# Now import stripe after env is loaded
import stripe


stripe_key = os.getenv("STRIPE_SECRET_KEY")
print("DEBUG STRIPE KEY repr:", repr(stripe_key))
print("DEBUG STRIPE KEY length:", len(stripe_key) if stripe_key else None)

# Initialize Firebase Admin SDK
# Try to find service account key from env or default location
firebase_cred_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY", "serviceAccountKey.json")
db = None

try:
    if os.path.exists(firebase_cred_path):
        cred = credentials.Certificate(firebase_cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print(f"[INFO] Firebase Admin initialized using {firebase_cred_path}")
    else:
        print(f"[WARNING] Firebase Service Account Key not found at '{firebase_cred_path}'.")
        print("          Firestore updates will be SKIPPED. Add the file or update .env.")
except Exception as firebase_error:
    print(f"[ERROR] Failed to initialize Firebase: {firebase_error}")


# Validate key immediately
if not stripe_key or not stripe_key.startswith("sk_"):
    raise RuntimeError(
        "❌ STRIPE_SECRET_KEY is missing, invalid, or malformed. "
        "Please check your .env file."
    )

stripe.api_key = stripe_key

app = Flask(__name__)
CORS(app)


@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'Stripe backend is running'}), 200


@app.route('/create-payment-intent', methods=['POST'])
def create_payment_intent():
    try:
        print("\n" + "="*50)
        print("📥 Received payment intent request")
        print("="*50)
        
        data = request.get_json()
        print(f"Request data: {data}")

        if not data or 'amount' not in data or 'currency' not in data:
            error_msg = 'Missing required fields: amount and currency'
            print(f"❌ Validation error: {error_msg}")
            return jsonify({'error': error_msg}), 400

        amount = int(data['amount'])
        currency = data['currency'].lower()
        uid = data.get('uid', 'anonymous')

        print(f"✅ Validated request:")
        print(f"   Amount: {amount} cents (${amount/100})")
        print(f"   Currency: {currency}")
        print(f"   User ID: {uid}")

        if amount < 50:  # minimum 50 cents
            error_msg = 'Amount must be at least 50 cents'
            print(f"❌ Amount validation failed: {error_msg}")
            return jsonify({'error': error_msg}), 400

        print(f"🔵 Creating Stripe PaymentIntent...")
        payment_intent = stripe.PaymentIntent.create(
            amount=amount,
            currency=currency,
            automatic_payment_methods={'enabled': True},
            metadata={'user_id': uid, 'app': 'Strike Force'}
        )

        print(f"✅ PaymentIntent created successfully!")
        print(f"   ID: {payment_intent.id}")
        print(f"   Status: {payment_intent.status}")
        print(f"   Client Secret: {payment_intent.client_secret[:20]}...")

        response_data = {
            'client_secret': payment_intent.client_secret,
            'payment_intent_id': payment_intent.id
        }
        print(f"📤 Sending response: {list(response_data.keys())}")
        print("="*50 + "\n")

        return jsonify(response_data), 200

    except stripe.error.StripeError as e:
        print(f"\n❌ Stripe Error: {str(e)}")
        print(f"   Error type: {type(e).__name__}")
        return jsonify({'error': str(e)}), 400
    except ValueError as e:
        print(f"\n❌ Validation Error: {str(e)}")
        return jsonify({'error': 'Invalid amount format'}), 400
    except Exception as e:
        print(f"\n❌ Unexpected Error: {str(e)}")
        print(f"   Error type: {type(e).__name__}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': 'An unexpected error occurred'}), 500


@app.route('/webhook', methods=['POST'])
def stripe_webhook():
    payload = request.data
    sig_header = request.headers.get('Stripe-Signature')
    webhook_secret = os.getenv('STRIPE_WEBHOOK_SECRET')

    if not webhook_secret:
        print("[WARNING] STRIPE_WEBHOOK_SECRET not configured")
        return jsonify({'error': 'Webhook not configured'}), 400

    try:
        event = stripe.Webhook.construct_event(payload, sig_header, webhook_secret)
    except ValueError as e:
        print(f"[ERROR] Invalid payload: {e}")
        return jsonify({'error': 'Invalid payload'}), 400
    except stripe.error.SignatureVerificationError as e:
        print(f"[ERROR] Invalid signature: {e}")
        return jsonify({'error': 'Invalid signature'}), 400

    if event['type'] == 'payment_intent.succeeded':
        payment_intent = event['data']['object']
        print(f"[SUCCESS] Payment succeeded: {payment_intent['id']}")
        user_id = payment_intent.get('metadata', {}).get('user_id')
        if user_id:
            print(f"   User: {user_id} - Payment: ${payment_intent['amount']/100}")
            print(f"   User: {user_id} - Payment: ${payment_intent['amount']/100}")
            
            # Update Firestore with payment record
            if db:
                try:
                    # 1. Add record to 'payments' collection
                    payment_doc = {
                        'userId': user_id,
                        'amount': payment_intent['amount'], # In cents
                        'currency': payment_intent['currency'],
                        'status': 'succeeded',
                        'paymentIntentId': payment_intent['id'],
                        'createdAt': firestore.SERVER_TIMESTAMP,
                        'description': 'Coach Hire / Subscription' 
                    }
                    db.collection('payments').add(payment_doc)
                    print(f"[DB] Payment record added to 'payments' collection.")

                    # 2. Update user's profile (e.g., enable premium access)
                    # Assuming 'users' collection where document ID is the user_id (uid)
                    user_ref = db.collection('users').document(user_id)
                    user_ref.set({
                        'isPremium': True, # Example field
                        'lastPaymentDate': firestore.SERVER_TIMESTAMP,
                        # Add other fields as necessary for your specific app logic
                    }, merge=True)
                    print(f"[DB] User {user_id} updated to Premium.")

                except Exception as db_e:
                    print(f"[ERROR] Failed to update Firestore: {db_e}")
            else:
                 print("[SKIPPED] Database update skipped (Firebase not initialized).")
    elif event['type'] == 'payment_intent.payment_failed':
        payment_intent = event['data']['object']
        print(f"[FAILED] Payment failed: {payment_intent['id']}")

    return jsonify({'status': 'success'}), 200



# ... (Previous imports)
from punch_analysis import PunchAnalyzer
from werkzeug.utils import secure_filename
import tempfile

# ... (Previous routes)

try:
    analyzer = PunchAnalyzer()
    print("[INFO] PunchAnalyzer initialized successfully")
except Exception as e:
    print(f"[WARNING] Failed to initialize PunchAnalyzer: {e}")
    analyzer = None

@app.route('/analyze_punch', methods=['POST'])
def analyze_punch():
    if analyzer is None:
        return jsonify({'error': 'Punch analysis service is currently unavailable'}), 503
    if 'video' not in request.files:
        return jsonify({'error': 'No video file provided'}), 400
        
    file = request.files['video']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        filename = secure_filename(file.filename)
        # Save to a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp4') as temp:
            file.save(temp.name)
            temp_path = temp.name

        try:
            # Process video
            print(f"Analyzing video: {temp_path}")
            result = analyzer.analyze_video(temp_path)
            
            # Clean up
            os.remove(temp_path)
            
            return jsonify(result), 200
        except Exception as e:
            print(f"Analysis error: {e}")
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return jsonify({'error': str(e)}), 500

@app.route('/verify-payment', methods=['POST'])
def verify_payment():
    try:
        data = request.get_json()
        payment_intent_id = data.get('payment_intent_id')

        if not payment_intent_id:
            return jsonify({'error': 'payment_intent_id is required'}), 400

        payment_intent = stripe.PaymentIntent.retrieve(payment_intent_id)

        return jsonify({
            'status': payment_intent.status,
            'amount': payment_intent.amount,
            'currency': payment_intent.currency,
        }), 200

    except stripe.error.StripeError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': 'An unexpected error occurred'}), 500


if __name__ == '__main__':
    print("=" * 50)
    print("Starting Stripe Payment Backend...")
    print("=" * 50)
    print(f"Stripe API Key: {'Configured' if stripe.api_key else 'Missing'}")
    print(f"Running on: http://localhost:5000")
    print(f"Health Check: http://localhost:5000/health")
    print("=" * 50)
    print()

    app.run(debug=True, host='0.0.0.0', port=5000)
