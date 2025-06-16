import 'dart:convert';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final int planId;
  const PaymentPage({required this.planId, Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Payment Details",
          style: TextStyle(
              color: Pallete.whiteColor,
              fontSize: 23,
              fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Pallete.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  "Subscribe to BeatFlow Plus!",
                  style: TextStyle(
                    color: Pallete.gradient2,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "You can cancel anytime. You will be automatically charged at the end of every cycle.")
                  ],
                ),
              ), 
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Credit & Debit Cards",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Pallete.whiteColor)),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(color: Pallete.whiteColor),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Card holder name",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your name';
                        } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                          return 'Name must contain only letters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(color: Pallete.whiteColor),
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Card number",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length != 8 ||
                            int.tryParse(value) == null) {
                          return 'Card number must be 8 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(color: Pallete.whiteColor),
                            controller: _expiryController,
                            keyboardType: TextInputType.datetime,
                            decoration: const InputDecoration(
                              labelText: "Expiry date",
                              hintText: "MM/YY",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.length != 4 ||
                                  int.tryParse(value) == null) {
                                return 'Expiry must be 4 digits (MMYY)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            style: const TextStyle(color: Pallete.whiteColor),
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Security code",
                              hintText: "CVV",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.length != 3 ||
                                  int.tryParse(value) == null) {
                                return 'CVV must be 3 digits';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: const [
                        Icon(Icons.verified_user, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          "Your payment is 100% secure",
                          style: TextStyle(color: Pallete.whiteColor),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: AuthGradientButton(
                        buttonText: 'Subscribe Now',
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            final token = ref
                                .read(homeViewmodelProvider.notifier)
                                .getUserToken();
                            final url = Uri.parse(
                                '${ServerConstant.serverURL}/auth/subscribe/${widget.planId}');

                            final body = jsonEncode({
                              "card_number": _cardNumberController.text,
                              "card_expiry": _expiryController.text,
                              "card_cvv": _cvvController.text,
                            });

                            final response = await http.post(
                              url,
                              headers: {
                                'x-auth-token': token ?? '',
                                'Content-Type': 'application/json',
                              },
                              body: body,
                            );

                            final responseBody = json.decode(response.body);
                            final message = responseBody["message"];
                            String displayMessage;

                            if (message is List) {
                              displayMessage = message.join(", ");
                            } else {
                              displayMessage =
                                  message?.toString() ?? "Success!";
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(displayMessage)),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
