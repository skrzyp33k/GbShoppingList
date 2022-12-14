import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gb_shopping_list/services/auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();

  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final repasswordController = TextEditingController();

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    repasswordController.dispose();
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
                      child: Text('Miło nam Cię poznać!',
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
                      height: 75,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      child: TextField(
                        controller: repasswordController,
                        scrollPadding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Powtórz hasło',
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 25, right: 25),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String login = loginController.text;
                          String pass = passwordController.text;
                          String repass = repasswordController.text;

                          if (login == "" || pass == "" || repass == "") {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Błąd rejestracji!'),
                                content: const Text(
                                    'Niewystarczające dane rejestracji!'),
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

                          if (pass != repass) {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Błąd rejestracji!'),
                                content: const Text('Hasła różnią się!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            passwordController.text = "";
                            repasswordController.text = "";
                            return;
                          }

                          dynamic result = await _auth.registerEmail(
                              email: login, password: pass);

                          if (result == null) //error
                          {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Błąd rejestracji!'),
                                content: const Text(
                                    'Podczas rejestracji wystąpił błąd!'),
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
                          Icons.app_registration,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        label: Center(
                          child: Text('Zarejestruj się',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              )),
                        ),
                      ),
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
