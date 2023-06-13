import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paml_20190140086_ewallet/config/constant.dart';
import 'package:paml_20190140086_ewallet/presentation/pages/auth/bloc/auth_bloc.dart';
import 'package:paml_20190140086_ewallet/presentation/pages/auth/register_page.dart';
import 'package:paml_20190140086_ewallet/presentation/pages/home_page.dart';
import 'package:paml_20190140086_ewallet/presentation/widgets/buttons/button_screen.dart';
import 'package:paml_20190140086_ewallet/presentation/widgets/inputs/input_email.dart';
import 'package:paml_20190140086_ewallet/presentation/widgets/inputs/input_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthBloc _authBloc = AuthBloc();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _formLoginKey = GlobalKey<FormState>();

  Widget _buildInputEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Email", style: labelStyle),
        const SizedBox(height: 10.0),
        InputEmail(
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
            labelText: "Masukkan email",
            style: 1,
            controller: _emailCtrl)
      ],
    );
  }

  Widget _buildInputPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("Password", style: labelStyle),
        const SizedBox(height: 10.0),
        InputPassword(
            prefixIcon: const Icon(Icons.key_outlined, color: Colors.white),
            labelText: "Masukkan password",
            style: 1,
            controller: _passwordCtrl)
      ],
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const RegisterPage())),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Belum punya akun? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Daftar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AuthLoginLoaded) {
            if (state.response.status) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false);
            }
          }
        },
        child: Scaffold(
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Stack(
                children: <Widget>[
                  Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF74AFF5), Color(0xFF398AE5)]))),
                  SizedBox(
                    height: double.infinity,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 40,
                        right: 40,
                        top: 100,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Expense\nTracker",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            "Masuk",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          Form(
                            key: _formLoginKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildInputEmail(),
                                const SizedBox(height: 10),
                                _buildInputPassword(),
                                const SizedBox(height: 10),
                                ButtonScreen(
                                  isLoading: (state is AuthLoginLoading) ? true : false,
                                  text: 'MASUK',
                                  action: () {
                                    if (_formLoginKey.currentState!.validate()) {
                                      _formLoginKey.currentState!.save();

                                      _authBloc.add(AuthLogin(
                                        email: _emailCtrl.text, password: _passwordCtrl.text
                                      ));
                                    } else {
                                      debugPrint("Not Validate");
                                    }
                                  }
                                ),
                              ],
                            ),
                          ),
                          _buildSignupBtn(),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}