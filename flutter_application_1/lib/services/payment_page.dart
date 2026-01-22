import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stripe_services.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPackage;
  bool isProcessing = false;

  final packages = [
    {
      'name': 'Basic Plan',
      'price': 999, // $9.99
      'features': [
        'Access to all workout videos',
        'Basic training routines',
        'Progress tracking',
      ],
    },
    {
      'name': 'Premium Plan',
      'price': 1999, // $19.99
      'features': [
        'Everything in Basic',
        'Personalized coaching',
        'Advanced techniques',
        'Live Q&A sessions',
      ],
      'popular': true,
    },
    {
      'name': 'Elite Plan',
      'price': 4999, // $49.99
      'features': [
        'Everything in Premium',
        'One-on-one coaching',
        'Custom meal plans',
        'Priority support',
      ],
    },
  ];

  Future<void> _handlePayment(int amount, String packageName) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to make a payment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await StripeServices.instance.makePayment(
        context,
        amount,
        'usd',
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      // Error is already handled in StripeServices
      print('Payment error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1F33),
        elevation: 0,
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFF6B6B),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Processing payment...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                const Text(
                  'Choose the perfect plan for your fitness journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Package Cards
                ...packages.map((package) {
                  final isPopular = package['popular'] == true;
                  return _buildPackageCard(
                    name: package['name'] as String,
                    price: package['price'] as int,
                    features: package['features'] as List<String>,
                    isPopular: isPopular,
                  );
                }),

                const SizedBox(height: 30),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1F33),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFFFF6B6B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Secure Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'All payments are secured by Stripe. For testing, use card number: 4242 4242 4242 4242',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPackageCard({
    required String name,
    required int price,
    required List<String> features,
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1F33),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPopular
                    ? const Color(0xFFFF6B6B)
                    : Colors.white.withOpacity(0.1),
                width: isPopular ? 2 : 1,
              ),
              boxShadow: isPopular
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package Name
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(price / 100).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/month',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Features
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFFFF6B6B),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),

                // Payment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handlePayment(price, name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF1D1F33),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isPopular
                              ? Colors.transparent
                              : const Color(0xFFFF6B6B),
                          width: 2,
                        ),
                      ),
                      elevation: isPopular ? 8 : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card),
                        const SizedBox(width: 8),
                        Text(
                          isPopular ? 'Get Started' : 'Choose Plan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Popular Badge
          if (isPopular)
            Positioned(
              top: -5,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
