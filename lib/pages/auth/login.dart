import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gb_shopping_list/models/user.dart';
import 'package:gb_shopping_list/services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                        width: 250,
                        height: 250,
                        margin: const EdgeInsets.only(top: 50),
                        padding: const EdgeInsets.all(25),
                        child: Image.asset('assets/icon.png')),
                    Container(
                      padding: const EdgeInsets.all(25),
                      child: Text('Witamy ponownie!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          )),
                    ),
                    Container(
                      height: 75,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      child: TextField(
                        controller: loginController,
                        scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        obscureText: false,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Adres e-mail',
                        ),
                      ),
                    ),
                    Container(
                      height: 75,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      child: TextField(
                        controller: passwordController,
                        scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Hasło',
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 25, left: 25, right: 25),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String login = loginController.text;
                          String pass = passwordController.text;

                          if (login == "" || pass == "") {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Błąd logowania!'),
                                content: const Text(
                                    'Niewystarczające dane logowania!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          try {
                            assert(EmailValidator.validate(login));
                          } catch (ex) {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Błąd logowania!'),
                                content:
                                    const Text('Niepoprawny adres e-mail!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            loginController.text = "";
                            return;
                          }

                          UserModel? result = await _auth.signInEmail(
                              email: login, password: pass);

                          if (result == null) //error
                          {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Błąd logowania!'),
                                content:
                                    const Text('Nieprawidłowe dane logowania!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            loginController.text = "";
                            passwordController.text = "";
                          } else {
                            Navigator.pushNamed(context, '/');
                          }
                        },
                        icon: Icon(
                          Icons.login,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        label: Center(
                          child: Text('Zaloguj się',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              )),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        TextEditingController emailController =
                            TextEditingController();
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Resetowanie hasła'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    'Podaj e-mail na który będzie wysłany link do resetowania hasła'),
                                TextField(
                                  autofocus: true,
                                  controller: emailController,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  emailController.text = "";
                                  Navigator.pop(context, "");
                                },
                                child: const Text('Anuluj'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String text = emailController.text;
                                  emailController.text = "";
                                  Navigator.pop(context, text);
                                },
                                child: const Text('Wyślij e-mail'),
                              ),
                            ],
                          ),
                        ).then((val) {
                          String email = val!.trim();
                          {
                            if (email.isNotEmpty) {
                              _auth.instance
                                  .sendPasswordResetEmail(email: email);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Wysłano e-mail"),
                              ));
                            }
                          }
                        });
                      },
                      child: const Text('Zapomniałem hasła'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          return true;
        });
  }
}
