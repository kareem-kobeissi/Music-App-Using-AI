import 'package:client/features/auth/view/widgets/auth_gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_pallette.dart';

class TermsOfServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
        centerTitle: true,
        backgroundColor: Pallete.backgroundColor,
      ),
      backgroundColor: Pallete.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("1. Introduction"),
            _buildSectionContent(
                "Welcome to BeatFlow™! These Terms of Service govern your access and use of our mobile application and services. By using our app, you agree to comply with these terms."),
            const Divider(),
            _buildSectionTitle("2. User Responsibilities"),
            _buildSectionContent(
                "You agree to use the app in compliance with all applicable laws and not to misuse our services. The following actions are strictly prohibited:\n"
                "- Violating any laws or regulations\n"
                "- Sharing false or misleading information\n"
                "- Attempting to disrupt the app’s functionality\n"
                "- Unauthorized access to other users' data"),
            const Divider(),
            _buildSectionTitle("3. Age Restrictions"),
            _buildSectionContent(
                "You must be at least **13 years old** to use this app. If you are under 18, you may use the app only with the supervision of a parent or legal guardian."),
            const Divider(),
            _buildSectionContent(
                "We respect your privacy and handle your data in accordance with our **Privacy Policy**. By using this app, you consent to the collection and use of your information as described in the policy."),
            const Divider(),
            _buildSectionTitle("5. Account Termination"),
            _buildSectionContent(
                "We reserve the right to suspend or terminate accounts that violate these terms. This includes, but is not limited to:\n"
                "- Harassment or abuse towards other users\n"
                "- Engaging in fraudulent activities\n"
                "- Using automated tools to exploit the platform"),
            const Divider(),
            _buildSectionTitle("6. Updates to Terms"),
            _buildSectionContent(
                "We may update these Terms of Service from time to time. We will notify users of any significant changes. Continued use of the app after updates constitutes acceptance of the revised terms."),
            const Divider(),
            _buildSectionTitle("7. Contact Information"),
            _buildSectionContent(
                "If you have any questions regarding these terms, please contact us at **beatflowsupport@hotmail.com**."),
            const Divider(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AuthGradientButton(
                      buttonText: "Back",
                      onTap: () {
                        Navigator.pop(context);
                      },
                      icon: CupertinoIcons.arrow_left,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AuthGradientButton(
                      buttonText: "Agree",
                      onTap: () {
                        print("User agreed");
                        Navigator.pop(context);
                      },
                      icon: CupertinoIcons.checkmark_alt,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, color: Colors.white70),
      ),
    );
  }
}
