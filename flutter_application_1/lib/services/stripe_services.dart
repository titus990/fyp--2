import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../consts.dart';
import 'premium_service.dart';

class StripeServices {
  StripeServices._();
  static final StripeServices instance = StripeServices._();

  /// Initialize Stripe with publishable key
  Future<void> initializeStripe() async {
    Stripe.publishableKey = stripePublishablekey;
  }

  /// Make a payment by calling the secure Python backend
  /// 
  /// [context] - BuildContext for showing messages
  /// [amount] - Amount in cents (e.g., 1000 = $10.00)
  /// [currency] - Currency code (e.g., 'usd')
  Future<void> makePayment(
    BuildContext context,
    int amount,
    String currency,
  ) async {
    try {
     
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      
      final clientSecret = await _createPaymentIntent(
        amount,
        currency,
        user.uid,
      );

    
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
          merchantDisplayName: 'Strike Force',
        ),
      );

      
      await _displayPaymentSheet(context);
    } catch (e) {
      print('Payment error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  
  Future<String> _createPaymentIntent(
    int amount,
    String currency,
    String uid,
  ) async {
    try {
      print('🔵 Creating payment intent...');
      print('   Backend URL: $backendUrl');
      print('   Amount: $amount cents (\$${amount / 100})');
      print('   Currency: $currency');
      print('   User ID: $uid');
     
      final response = await http.post(
        Uri.parse('$backendUrl/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'uid': uid,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
            'Connection timeout. Backend at $backendUrl did not respond within 10 seconds. '
            'Please ensure the Python backend is running.',
          );
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final clientSecret = data['client_secret'];
        
        if (clientSecret == null || clientSecret.isEmpty) {
          throw Exception('Invalid response from backend: missing client_secret');
        }
        
        print('✅ Payment intent created successfully');
        print('   Client secret received: ${clientSecret.substring(0, 20)}...');
        return clientSecret;
      } else {
        print('❌ Backend returned error status: ${response.statusCode}');
        try {
          final error = jsonDecode(response.body);
          throw Exception('Backend error: ${error['error'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Backend error (status ${response.statusCode}): ${response.body}');
        }
      }
    } on http.ClientException catch (e) {
      print('❌ Network error (ClientException): $e');
      throw Exception(
        'Cannot connect to payment server at $backendUrl. '
        'Please ensure:\n'
        '1. The Python backend is running (python stripe_backend.py)\n'
        '2. The backend is accessible on port 5000\n'
        'Error details: $e',
      );
    } on SocketException catch (e) {
      print('❌ Network error (SocketException): $e');
      throw Exception(
        'Network connection failed to $backendUrl. '
        'Please check:\n'
        '1. Backend server is running\n'
        '2. No firewall blocking port 5000\n'
        'Error details: $e',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout error: $e');
      rethrow;
    } on FormatException catch (e) {
      print('❌ JSON parsing error: $e');
      throw Exception('Invalid response format from backend. Error: $e');
    } catch (e) {
      print('❌ Unexpected error creating payment intent: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  
  Future<void> _displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - refresh premium status immediately
      print('✅ Payment successful! Setting premium status optimistically...');
      await PremiumService.instance.setPremiumStatusOptimistically(true);
      // Also trigger a background refresh just in case
      PremiumService.instance.refreshPremiumStatus();
      print('✅ Premium status updated!');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment completed! Premium access granted.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on StripeException catch (e) {
      print('Stripe Exception: ${e.error.localizedMessage}');
      
     
      if (context.mounted && e.error.code != FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment error: ${e.error.localizedMessage ?? "Unknown error"}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error displaying payment sheet: $e');
      rethrow;
    }
  }

  
  Future<Map<String, dynamic>> verifyPayment(String paymentIntentId) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'payment_intent_id': paymentIntentId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify payment');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      rethrow;
    }
  }
}
