import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecloud/common/prefs_keys.dart';
import 'package:thecloud/injection_container.dart';
import 'package:thecloud/view/customWidgets/custom_text_field.dart';

import '../../../common/colors.dart';
import '../../../common/images.dart';
import '../../../util/global_functions.dart';
import '../../../viewModels/auth_view_model.dart';
import '../../customWidgets/loading_icon_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> loginFromKey = GlobalKey<FormState>();

  final TextEditingController userNameCon = TextEditingController();

  final TextEditingController passwordCon = TextEditingController();

  late AppLocalizations _trans;

  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    sharedPreferences = serviceLocator<SharedPreferences>();
    String? userName = sharedPreferences.getString(PrefsKeys.userName);
    if (userName != null) {
      userNameCon.text = userName;
    }
    String? password = sharedPreferences.getString(PrefsKeys.password);
    if (password != null) {
      passwordCon.text = password;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _trans = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: isTablet || kIsWeb
            ? MyColors.backgroundLevel0
            : MyColors.backgroundLevel1,
        body: Center(
          child: DelayedDisplay(
            delay: const Duration(milliseconds: 200),
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
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 700),
                      fadeIn: true,
                      child: Image.asset(
                        Images.appIcon,
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 800),
                      child: Text(
                        _trans.kitchen_login,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 800),
                      child: Text(
                        _trans.sign_in_to_start_your_session,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DelayedDisplay(
                      delay: const Duration(milliseconds: 700),
                      child: Form(
                          key: loginFromKey,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _trans.user_name,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextField(
                                  controller: userNameCon,
                                  hint: _trans.user,
                                  onValid: (userName) {
                                    return userName!.isEmpty
                                        ? _trans.this_field_cant_be_empty
                                        : null;
                                  },
                                ),
                                /* TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  controller: userNameCon,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(7),
                                          borderSide: BorderSide.none),
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color: Colors.grey,
                                      ),
                                      hintText: _trans.user,
                                      fillColor: Colors.white),
                                  validator: (userName) {
                                    return userName!.isEmpty
                                        ? _trans.this_field_cant_be_empty
                                        : null;
                                  },
                                ), */
                                const SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  _trans.password,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                CustomTextField(
                                  controller: passwordCon,
                                  hint: _trans.enter_a_password,
                                  password: true,
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
                                  height: 50,
                                ),
                                Consumer<AuthViewModel>(
                                    builder: (context, authModel, child) {
                                  return authModel.isLoading
                                      ? const LoadingIconWidget()
                                      : ElevatedButton(
                                          onPressed: () {
                                            if (loginFromKey.currentState!
                                                .validate()) {
                                              authModel.login(
                                                  username: userNameCon.text,
                                                  password: passwordCon.text);
                                            }
                                          },
                                          child: Text(_trans.sign_in),
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
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userNameCon.dispose();
    passwordCon.dispose();
    super.dispose();
  }
}
