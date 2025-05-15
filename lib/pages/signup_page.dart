import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/auth_service.dart';
import 'package:forui/forui.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.signup(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );

       if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هەژمارەکەت دروست کرا')),
          );
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
                          "هەژمار دروست بکە",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "زانیاریەکانت بنووسە بۆ دروستکردنی هەژمارەکەت",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                             FTextField(
                                controller: _nameController,
                                label: const Text("ناوی تەواو"),
                                hint: "ناوت بنووسە",
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'تکایە ناوت بنووسە';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
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
                                hint: '* * * * * * * *',
                                maxLines: 1,
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
                                label: const Text('تۆمارکردن'),
                                onPress: _signUp,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("پێشتر هەژمارم هەیە؟"),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signin');
                              },
                              child: const Text(
                                "چونە ژوورەوە",
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
