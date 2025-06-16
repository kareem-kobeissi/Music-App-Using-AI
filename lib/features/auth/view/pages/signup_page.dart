import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/signin_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole = "User";
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;

  bool _isPasswordObscured = true;

  final String allowedAdminEmail = "kareemliu@gmail.com";

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return SlideTransition(
            position: tween.animate(curveAnimation),
            child: child,
          );
        },
      ),
    );
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthLabel = '';
        _passwordStrengthColor = Colors.red;
      });
      return;
    }

    double strength = 0;
    if (password.length >= 5) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordStrengthLabel = 'Weak';
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 0.5) {
        _passwordStrengthLabel = 'Good';
        _passwordStrengthColor = Colors.orange;
      } else if (strength <= 0.75) {
        _passwordStrengthLabel = 'Strong';
        _passwordStrengthColor = Colors.blue;
      } else {
        _passwordStrengthLabel = 'Very Strong';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _saveEmailToPreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rememberedEmail', email);
  }

  bool _isEmailValid(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(authViewModelProvider.select((val) => val?.isLoading == true));

    ref.listen(
      authViewModelProvider,
      (_, next) {
        next?.when(
          data: (data) {
            showSnackBar(
              context,
              '\u2705 Account created successfully! Please login to enjoy listening to music.',
            );
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          error: (error, st) {
            showSnackBar(context, error.toString());
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Pallete.whiteColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? const Loader()
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/k.webp',
                    fit: BoxFit.cover,
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: SafeArea(
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/lo.png',
                                        width: 120,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  Text(
                                    'Sign up to start listening!',
                                    style: TextStyle(
                                        color: Pallete.whiteColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomField(
                                    hintText: 'Name',
                                    controller: nameController,
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomField(
                                    hintText: 'Email',
                                    controller: emailController,
                                    icon: Icons.email,
                                  ),
                                  const SizedBox(height: 15),
                                  CustomField(
                                    hintText: 'Password (min 5 characters)',
                                    controller: passwordController,
                                    isObscureText: _isPasswordObscured,
                                    icon: Icons.lock,
                                    onChanged: _checkPasswordStrength,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordObscured
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Pallete.greyColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordObscured =
                                              !_isPasswordObscured;
                                        });
                                      },
                                    ),
                                  ),
                                  if (_passwordStrength > 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          LinearProgressIndicator(
                                            value: _passwordStrength,
                                            backgroundColor: Colors.grey[800],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    _passwordStrengthColor),
                                            minHeight: 6,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _passwordStrengthLabel,
                                            style: TextStyle(
                                              color: _passwordStrengthColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  CustomField(
                                    hintText: 'Choose Role',
                                    controller: TextEditingController(
                                        text: selectedRole),
                                    icon: Icons.person_outline,
                                    readOnly: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor:
                                            Pallete.backgroundColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(15)),
                                        ),
                                        builder: (BuildContext context) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: Text('User',
                                                    style: TextStyle(
                                                        color: Pallete
                                                            .whiteColor)),
                                                onTap: () {
                                                  setState(() {
                                                    selectedRole = 'User';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: Text('Admin',
                                                    style: TextStyle(
                                                        color: Pallete
                                                            .whiteColor)),
                                                onTap: () {
                                                  setState(() {
                                                    selectedRole = 'Admin';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  AuthGradientButton(
                                      buttonText: 'Sign Up',
                                      onTap: () async {
                                        if (formKey.currentState!.validate()) {
                                          if (!_isEmailValid(
                                              emailController.text)) {
                                            showSnackBar(
                                              context,
                                              'Oops! The email you entered is invalid!',
                                            );
                                            return;
                                          }

                                          if (passwordController.text.length <
                                              5) {
                                            showSnackBar(
                                              context,
                                              '❌ Password should be at least 5 characters!',
                                            );
                                            return;
                                          }

                                          if (selectedRole == "Admin" &&
                                              emailController.text !=
                                                  allowedAdminEmail) {
                                            showSnackBar(
                                              context,
                                              '❌ This email is not authorized for an Admin account!',
                                            );
                                            return;
                                          }

                                          await _saveEmailToPreferences(
                                              emailController.text);

                                          await ref
                                              .read(authViewModelProvider
                                                  .notifier)
                                              .signUpUser(
                                                name: nameController.text,
                                                email: emailController.text,
                                                password:
                                                    passwordController.text,
                                                role: selectedRole!,
                                              );
                                        } else {
                                          showSnackBar(
                                            context,
                                            '\u274C Missing fields!',
                                          );
                                        }
                                      }),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      _navigateWithSlideTransition(
                                        context,
                                        const LoginPage(),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Already have an account? ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                color: Pallete.whiteColor),
                                        children: const [
                                          TextSpan(
                                            text: 'Sign In',
                                            style: TextStyle(
                                              color: Pallete.gradient2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
