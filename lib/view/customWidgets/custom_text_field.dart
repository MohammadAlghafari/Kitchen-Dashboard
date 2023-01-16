import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    Key? key,
    required this.controller,
    this.password = false,
    required this.hint,
    this.onValid,
  }) : super(key: key);
  final TextEditingController controller;
  final bool password;
  final String hint;
  final Function? onValid;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = false;

  void togglePassword() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  @override
  void initState() {
    obscureText = widget.password;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.key,
      controller: widget.controller,
      textInputAction:
          widget.password ? TextInputAction.done : TextInputAction.next,
      keyboardType:
          widget.password ? TextInputType.visiblePassword : TextInputType.text,
      style: const TextStyle(
        color: Colors.black,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
          filled: true,
          suffixIcon: widget.password
              ? GestureDetector(
                  onTap: () {
                    togglePassword();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide.none),
          prefixIcon: Icon(
            widget.password ? Icons.key : Icons.email,
            color: Colors.grey,
          ),
          hintText: widget.hint,
          fillColor: Colors.white),
      validator: (String? value) {
        if (widget.onValid != null) {
          var v = widget.onValid!(value);
          if (v != null) return (v.toString());
        }
        return null;
      },
    );
  }
}
