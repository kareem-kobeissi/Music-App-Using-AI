import 'package:client/core/theme/app_pallette.dart';
import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscureText;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final void Function(String)? onChanged; 

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Pallete.backgroundColor,
        hintText: hintText,
        hintStyle: TextStyle(color: Pallete.greyColor),
        prefixIcon: icon != null ? Icon(icon, color: Pallete.greyColor) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Pallete.greyColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Pallete.gradient2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Pallete.gradient2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Pallete.gradient2),
        ),
        errorStyle: TextStyle(color: Pallete.gradient2),
      ),
      validator: (val) {
        if (val!.trim().isEmpty) {
          return '$hintText is missing!';
        }
        return null;
      },
      obscureText: isObscureText,
      style: TextStyle(color: Pallete.whiteColor),
    );
  }
}
