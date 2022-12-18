import 'package:flutter/material.dart';
import 'package:gb_shopping_list/models/user.dart';

import 'package:gb_shopping_list/pages/home/home.dart';
import 'package:gb_shopping_list/pages/auth/start.dart';
import 'package:provider/provider.dart';

import 'auth/email_notverified.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  final user = Provider.of<UserModel?>(context);

  if(user == null)
    {
      return StartPage();
    }
  else if(user.emailVerified == false)
    {
      return VerifyEmail();
    }
  else
    {
      return HomePage();
    }
  }
}
