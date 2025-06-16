import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/widgets/payment_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  List<Map<String, dynamic>> plans = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
    final url = Uri.parse('${ServerConstant.serverURL}/auth/plans');

    try {
      final response = await http.get(
        url,
        headers: {
          'x-auth-token': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          plans = List<Map<String, dynamic>>.from(jsonResponse);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch plans: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Future<void> subscribeToPlan(int planId) async {
    bool? isConfirmed = await _showConfirmationDialog();

    if (isConfirmed == true) {
      final token = ref.read(homeViewmodelProvider.notifier).getUserToken();
      final url =
          Uri.parse('${ServerConstant.serverURL}/auth/subscribe/$planId');

      try {
        final response = await http.post(
          url,
          headers: {
            'x-auth-token': token ?? '',
            'Content-Type': 'application/json',
          },
        );

        final responseBody = json.decode(response.body);
        final successMessage = responseBody["message"];
        final errorMessage = responseBody["detail"];

        if (response.statusCode == 200 && successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ $successMessage")),
          );

          // Navigate to the payment page after successful subscription
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ ${errorMessage ?? 'Something went wrong'}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Subscription"),
          content: const Text(
              "Are you sure you want to subscribe to this plan? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, Subscribe"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: Pallete.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Plans",
          style: TextStyle(
            color: Pallete.whiteColor,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Pallete.whiteColor,
              size: 35,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Pallete.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Pallete.errorColor,
                          size: 30,
                        ),
                        Expanded(child: const SizedBox(width: 10)),
                        const Text(
                          "Tap on the card \n to subscribe \n to a plan.",
                          style: TextStyle(
                            color: Pallete.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      "You cannot subscribe to multiple plans simultaneously. Please wait for your current subscription to finish before subscribing to another plan.",
                      style: TextStyle(
                        color: Pallete.subtitleText,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Pallete.whiteColor),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                )
              : plans.isEmpty
                  ? const Center(
                      child: Text("No plans available!",
                          style: TextStyle(color: Colors.grey, fontSize: 18)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: plans.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.blueAccent,
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Subscribe for special features.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final plan = plans[index - 1];
                        return GestureDetector(
                          onTap: () async {
                            final token = ref
                                .read(homeViewmodelProvider.notifier)
                                .getUserToken();

                            final response = await http.get(
                              Uri.parse(
                                  '${ServerConstant.serverURL}/auth/subscription-status'),
                              headers: {
                                'x-auth-token': token ?? '',
                                'Content-Type': 'application/json',
                              },
                            );

                            if (response.statusCode == 200) {
                              final data = json.decode(response.body);
                              final isSubscribed = data['is_premium'] == true;

                              if (isSubscribed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "❌ You already have an active subscription."),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentPage(planId: plan["id"]),
                                  ),
                                );
                              }
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent.withOpacity(0.7),
                                  Colors.deepPurpleAccent.withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(plan["name"] ?? "Unknown Plan",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                const Divider(
                                    color: Colors.white54, thickness: 1.2),
                                Text(plan["description"] ?? "No description",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 14),
                                Text(
                                    "\$${plan["price"]} / ${plan["duration_days"]} days",
                                    style: const TextStyle(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
