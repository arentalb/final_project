import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/auth_service.dart';
import 'package:forui/forui.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SignInPage> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user =
            await _auth.signin(_emailController.text, _passwordController.text);

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('چونە ژوورەوە بە سەرکەوتویی')),
          );
          // dway away basarkawty login bw ema aynerin bo pagey navigator
          Navigator.pushNamed(context, '/navigator');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "بەخێربێیتەوە",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "تکایە بچۆ ژوورەوە بۆ بەکارهێنانی سیستەم",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              FTextField.email(
                                controller: _emailController,
                                label: const Text("ئیمەیل"),
                                hint: 'example@gmail.com',
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'تکایە ئیمەیلەکەت بنووسە';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    return 'تکایە ئیمەیلەکە بە شێوازی دروست بنووسە';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              FTextField.password(
                                controller: _passwordController,
                                obscureText: true,
                                label: const Text("وشەی نهێنی"),
                                maxLines: 1,
                                hint: '* * * * * * * *',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'تکایە وشەی نهێنیەکەت بنووسە';
                                  }
                                  if (value.length < 6) {
                                    return 'وشەی نهێنی پێویستە زیاتر لە ٦ پیت بێت';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              FButton(
                                label: const Text('چونە ژوورەوە'),
                                onPress: _login,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("هەژمارت نیە؟"),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: const Text(
                                "دروستی بکە",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
