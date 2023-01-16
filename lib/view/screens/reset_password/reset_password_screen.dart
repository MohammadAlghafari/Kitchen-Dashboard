import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thecloud/view/customWidgets/custom_text_field.dart';

import '../../../common/colors.dart';
import '../../../common/images.dart';
import '../../../util/global_functions.dart';
import '../../../viewModels/auth_view_model.dart';
import '../../customWidgets/loading_icon_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  static const routeName = '/reset_password_screen';

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> resetPasswordFromKey = GlobalKey<FormState>();

  final TextEditingController passwordCon = TextEditingController();

  final TextEditingController confirmPasswordCon = TextEditingController();

  late AppLocalizations _trans;

  @override
  Widget build(BuildContext context) {
    _trans = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: isTablet || kIsWeb
            ? MyColors.backgroundLevel0
            : MyColors.backgroundLevel1,
        body: Center(
          child: Container(
            width: isTablet || kIsWeb ? 500 : double.infinity,
            decoration: BoxDecoration(
              color: MyColors.backgroundLevel1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    Images.appIcon,
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    _trans.reset_password,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    _trans.please_reset_password,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Form(
                      key: resetPasswordFromKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _trans.new_password,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              controller: passwordCon,
                              password: true,
                              hint: _trans.enter_a_password,
                              onValid: (password) {
                                return password!.isEmpty
                                    ? _trans.this_field_cant_be_empty
                                    : password.length < 6
                                        ? _trans
                                            .the_password_must_be_at_least_6_characters
                                        : null;
                              },
                            ),
                            /* TextFormField(
                              controller: passwordCon,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide.none),
                                prefixIcon: const Icon(
                                  Icons.key,
                                  color: Colors.grey,
                                ),
                                hintText: _trans.enter_a_password,
                              ),
                              validator: (password) {
                                return password!.isEmpty
                                    ? _trans.this_field_cant_be_empty
                                    : password.length < 6
                                        ? _trans
                                            .the_password_must_be_at_least_6_characters
                                        : null;
                              },
                              onFieldSubmitted: (_) {
                                if (loginFromKey.currentState!.validate()) {
                                  Provider.of<AuthViewModel>(context,
                                          listen: false)
                                      .login(
                                          username: userNameCon.text,
                                          password: passwordCon.text);
                                }
                              },
                            ), */
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              _trans.confirm_password,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextField(
                              controller: confirmPasswordCon,
                              hint: _trans.enter_a_password,
                              password: true,
                              onValid: (confirmPassword) {
                                return confirmPassword!.isEmpty
                                    ? _trans.this_field_cant_be_empty
                                    : confirmPassword != passwordCon.text
                                        ? _trans.passwords_dont_match
                                        : null;
                              },
                            ),
                            /* TextFormField(
                              controller: passwordCon,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: BorderSide.none),
                                prefixIcon: const Icon(
                                  Icons.key,
                                  color: Colors.grey,
                                ),
                                hintText: _trans.enter_a_password,
                              ),
                              validator: (password) {
                                return password!.isEmpty
                                    ? _trans.this_field_cant_be_empty
                                    : password.length < 6
                                        ? _trans
                                            .the_password_must_be_at_least_6_characters
                                        : null;
                              },
                              onFieldSubmitted: (_) {
                                if (loginFromKey.currentState!.validate()) {
                                  Provider.of<AuthViewModel>(context,
                                          listen: false)
                                      .login(
                                          username: userNameCon.text,
                                          password: passwordCon.text);
                                }
                              },
                            ), */
                            const SizedBox(
                              height: 50,
                            ),
                            Consumer<AuthViewModel>(
                                builder: (context, authModel, child) {
                              return authModel.resetPasswordLoading
                                  ? const LoadingIconWidget()
                                  : ElevatedButton(
                                      onPressed: () {
                                        if (resetPasswordFromKey.currentState!
                                            .validate()) {
                                          authModel.resetPassword(
                                              password: passwordCon.text);
                                        }
                                      },
                                      child: Text(_trans.reset_password),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: MyColors.green,
                                          textStyle:
                                              const TextStyle(fontSize: 16),
                                          minimumSize:
                                              const Size.fromHeight(45)));
                            }),
                            const SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    confirmPasswordCon.dispose();
    passwordCon.dispose();
    super.dispose();
  }
}
