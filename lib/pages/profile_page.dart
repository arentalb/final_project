import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/services/auth_service.dart';
import 'package:flutter_test_app/services/notification_service.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final _auth = AuthService();
  TimeOfDay selectedTime = const TimeOfDay(hour: 14, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notif_hour') ?? 14;
    final minute = prefs.getInt('notif_minute') ?? 0;
    setState(() {
      selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSelectedTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_hour', time.hour);
    await prefs.setInt('notif_minute', time.minute);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
      await _saveSelectedTime(picked);

      await NotificationService.scheduleDailyNotification(
        hour: picked.hour,
        minute: picked.minute,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('کاتی ئاگاداری هەڵبژێردرا: ${picked.format(context)}')),
      );
    }
  }

  void _signOut() async {
    await _auth.signout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('چویتە دەرەوە')),
    );
    Navigator.pushNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [


              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(" ${user?.displayName ?? 'نەناسراو'}",
                        style: const TextStyle(fontSize: 22)),
                    Text("  ${user?.email ?? 'نەناسراو'}",
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 80),
                    FButton(
                      onPress: _pickTime,
                      label: Text(
                          'کاتی ئاگادارکردنەوە: ${selectedTime.format(context)}'),
                    ),


SizedBox(height: 40,),
                    FButton(
                      onPress: () {
                        NotificationService
                            .sendTestNotification();
                      },
                      label: const Text("تاقی کردنەوەی ئاگاداری"),
                    ),
                    SizedBox(height: 40,),
                    FButton(
                      style: FButtonStyle.destructive ,


                      onPress:_signOut,
                      label: const Text(
                          "رۆشتنە دەرەوە"),
                    ),

                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
