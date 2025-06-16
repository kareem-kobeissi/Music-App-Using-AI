import 'package:client/core/theme/app_pallette.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/auth/view/pages/forgot_password_page.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:client/core/widgets/custom_field.dart';
import 'package:client/features/auth/view_model/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool rememberMe = false;
  @override
  void initState() {
    super.initState();
    _loadEmailFromPreferences();
  }

  Future<void> _loadEmailFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('rememberedEmail');
    if (savedEmail != null) {
      setState(() {
        emailController.text = savedEmail;
        rememberMe = true;
      });
    }
  }

  Future<void> _saveEmailToPreferences(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setString('rememberedEmail', emailController.text);
    } else {
      await prefs.remove('rememberedEmail');
    }
  }

  @override
  void dispose() {
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
              'Account created successfully! 🎉 Thank you!',
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (_) => false,
            );
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
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: SafeArea(
                                child: Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 40),
                                      Center(
                                        child: Image.asset(
                                          'assets/images/lo.png',
                                          width: 120,
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      const Text(
                                        'Log in to BeatFlow™!',
                                        style: TextStyle(
                                          color: Pallete.whiteColor,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      CustomField(
                                        hintText: 'Email',
                                        controller: emailController,
                                        icon: Icons.email,
                                      ),
                                      const SizedBox(height: 15),
                                      CustomField(
                                        hintText: 'Password',
                                        controller: passwordController,
                                        isObscureText: _isPasswordObscured,
                                        icon: Icons.lock,
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
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: rememberMe,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                rememberMe = value ?? false;
                                              });
                                              _saveEmailToPreferences(
                                                  rememberMe);
                                            },
                                          ),
                                          const Text('Remember Me'),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      AuthGradientButton(
                                        buttonText: 'Sign In',
                                        onTap: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            await ref
                                                .read(authViewModelProvider
                                                    .notifier)
                                                .loginUser(
                                                    email: emailController.text,
                                                    password: passwordController
                                                        .text);
                                          } else {
                                            showSnackBar(
                                              context,
                                              '❌ Missing fields!',
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      GestureDetector(
                                        onTap: () {
                                          _navigateWithSlideTransition(
                                            context,
                                            ForgotPasswordPage(),
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Pallete.gradient2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      GestureDetector(
                                        onTap: () {
                                          _navigateWithSlideTransition(
                                            context,
                                            const SignupPage(),
                                          );
                                        },
                                        child: RichText(
                                          text: const TextSpan(
                                            text: 'Don\'t have an account? ',
                                            style: TextStyle(
                                                color: Pallete.whiteColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: 'Sign Up',
                                                style: TextStyle(
                                                  color: Pallete.gradient2,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
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
                            )));
                  },
                ),
              ],
            ),
    );
  }
}
