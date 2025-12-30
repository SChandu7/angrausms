import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const SmsSchedulerApp());
}

class SmsSchedulerApp extends StatelessWidget {
  const SmsSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final start = DateTime.now();

    // Ensure splash is visible at least 2 seconds
    final elapsed = DateTime.now().difference(start);
    const minDuration = Duration(seconds: 3);

    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RootPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 35),

                /// --- University Heading Text ---
                Text(
                  "ACHARYA N.G RANGA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  "AGRICULTURAL UNIVERSITY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "LAM, GUNTUR, ANDHRA PRADESH",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),

                SizedBox(height: 30),

                /// --- Logo ---
                Image.asset(
                  "assets/angrauicon.png",
                  width: MediaQuery.of(context).size.width * 0.45,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 10),
                Text(
                  "SMS SCHEDULER",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),

                SizedBox(height: 10),

                /// Developed By
                Text(
                  "Developed by",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),

                SizedBox(height: 12),

                /// Developer card
                Container(
                  width: MediaQuery.of(context).size.width * 0.93,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.shade800, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Dr. P.B. Pradeep Kumar\nCoordinator & Senior Scientist (T.O.T) DAATTC, PADERU, A.S.R. District.A.P.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Dr. G. SivaNarayana \nDirector Of Extension, ANGRAU",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Dr. K. Tejaswara Rao\nPrincipal Scientist, (Agronomy)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Dr. S. Srinivasa Raju \n(SMS Horticulture)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Dr. K.DhanaSree \Associate Professor (Extension Education)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                //    const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmsHome extends StatefulWidget {
  const SmsHome({super.key});

  @override
  State<SmsHome> createState() => _SmsHomeState();
}

class _SmsHomeState extends State<SmsHome> {
  static const MethodChannel _channel = MethodChannel('sms_scheduler_channel');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();

  List<String> selectedPhones = [];
  final TextEditingController msgCtrl = TextEditingController();
  List<String> selectedNames = [];
  List<DateTime> scheduledTimes = [];

  String status = "Waiting";

  Future<void> setDefaultSms() async {
    await _channel.invokeMethod('requestDefaultSms');
  }

  Future<void> pickAnotherDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    setState(() {
      final dt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      if (!scheduledTimes.contains(dt)) {
        scheduledTimes.add(dt);
        scheduledTimes.sort();
      }
    });
  }

  Future<void> requestSmsPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      // Request the permission
      final result = await Permission.sms.request();
      if (result.isGranted) {
        print("SMS permission granted");
        // Proceed with your SMS functionality
      } else if (result.isPermanentlyDenied) {
        // User permanently denied, guide them to app settings
        openAppSettings();
      } else {
        print("SMS permission denied");
      }
    } else if (status.isGranted) {
      print("SMS permission already granted");
      // Permission already granted, proceed
    }
  }

  Future<void> pickMultipleContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      setState(() => status = "Contacts permission denied");
    }

    final allContacts = await FlutterContacts.getContacts(withProperties: true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        List<Contact> filteredContacts = allContacts;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // 🔍 SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search contacts",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          final q = value.toLowerCase();
                          filteredContacts = allContacts.where((c) {
                            final name = c.displayName.toLowerCase();
                            final phone = c.phones.isNotEmpty
                                ? c.phones.first.number
                                : "";
                            return name.contains(q) || phone.contains(q);
                          }).toList();
                        });
                      },
                    ),
                  ),

                  // CONTACT LIST
                  Expanded(
                    child: ListView(
                      children: filteredContacts
                          .where((c) => c.phones.isNotEmpty)
                          .map((c) {
                            final phone = c.phones.first.number;
                            final checked = selectedPhones.contains(phone);

                            return CheckboxListTile(
                              title: Text(c.displayName),
                              subtitle: Text(phone),
                              value: checked,
                              onChanged: (val) {
                                setModalState(() {
                                  if (val == true &&
                                      !selectedPhones.contains(phone)) {
                                    selectedPhones.add(phone);
                                    selectedNames.add(c.displayName);
                                  } else {
                                    selectedPhones.remove(phone);
                                    selectedNames.remove(c.displayName);
                                  }
                                });
                              },
                            );
                          })
                          .toList(),
                    ),
                  ),

                  // DONE BUTTON
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text("Done (${selectedPhones.length} selected)"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> scheduleSms() async {
    if (selectedPhones.isEmpty ||
        scheduledTimes.isEmpty ||
        msgCtrl.text.isEmpty) {
      setState(() => status = "Select contacts, message & times");
      return;
    }

    await requestSmsPermission();
    await setDefaultSms();

    await _channel.invokeMethod('scheduleMultipleSms', {
      "phones": selectedPhones,
      "message": msgCtrl.text,
      "times": scheduledTimes.map((e) => e.millisecondsSinceEpoch).toList(),
    });

    final logs = await SmsLogStore.load();

    for (final time in scheduledTimes) {
      for (final phone in selectedPhones) {
        logs.add(
          SmsLog(
            id: "${phone}_${time.millisecondsSinceEpoch}",
            phone: phone,
            message: msgCtrl.text,
            scheduledTime: time,
          ),
        );
      }
    }

    await SmsLogStore.save(logs);

    setState(
      () => status =
          "Scheduled ${selectedPhones.length} × ${scheduledTimes.length} SMS",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SizedBox(
        width:
            MediaQuery.of(context).size.width *
            0.69, // Set the width to 50% of the screen
        child: Drawer(
          child: Column(
            children: [
              // Profile Section
              const UserAccountsDrawerHeader(
                accountName: Text("Pradeep"),
                accountEmail: Text("Administrator"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/imgicon1.png'),
                ),
                decoration: BoxDecoration(color: Colors.blue),
              ),
              // Menu Items
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
                  print("Profile tapped");
                  Navigator.pop(context); // Close the drawer
                },
              ),

              ListTile(
                leading: const Icon(Icons.help),
                title: const Text("Help."),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_emergency),
                title: const Text("Raise Query"),
                onTap: () {
                  print("Info tapped");
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  print("Settings tapped");
                  Navigator.pop(context); // Close the drawer
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Center(child: const Text("ANGRAU SMS ")),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the left drawer
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), // Right-side menu icon
            onPressed: () {
              showMenu<int>(
                context: context,
                position: const RelativeRect.fromLTRB(
                  100,
                  80,
                  0,
                  0,
                ), // Adjust position
                items: [
                  const PopupMenuItem(value: 1, child: Text("Log-in")),
                  const PopupMenuItem(value: 2, child: Text("Log-out")),
                  const PopupMenuItem(value: 3, child: Text("Help")),
                ],
              ).then((value) {
                // Handle the selected option
                if (value == 1) {
                  // Action for Option 1
                } else if (value == 2) {
                  // Action for Option 2
                } else if (value == 3) {
                  // Action for Option 2
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
              icon: Icons.contacts,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Contacts",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (selectedPhones.isEmpty)
                    const Text(
                      "No contacts selected",
                      style: TextStyle(color: Colors.grey),
                    ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: List.generate(selectedNames.length, (i) {
                      return Chip(
                        label: Text(selectedNames[i]),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            selectedPhones.removeAt(i);
                            selectedNames.removeAt(i);
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.contacts),
                      label: const Text("Select Contacts"),
                      onPressed: pickMultipleContacts,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _card(
              icon: Icons.message,
              child: TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _card(
              icon: Icons.schedule,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Scheduled Times",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (scheduledTimes.isEmpty)
                    const Text(
                      "No times selected",
                      style: TextStyle(color: Colors.grey),
                    ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: scheduledTimes.map((dt) {
                      return Chip(
                        label: Text(DateFormat('dd MMM • hh:mm a').format(dt)),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            scheduledTimes.remove(dt);
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Time"),
                      onPressed: pickAnotherDateTime,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _gradientButton(
              text: "Schedule SMS",
              icon: Icons.send,
              onTap: scheduleSms,
              colors: const [Colors.deepPurple, Colors.purpleAccent],
            ),
            const SizedBox(height: 10),
            Text(
              "Status: $status",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child, required IconData icon}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required List<Color> colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SmsLog {
  final String id;
  final String phone;
  final String message;
  final DateTime scheduledTime;
  bool sent;

  SmsLog({
    required this.id,
    required this.phone,
    required this.message,
    required this.scheduledTime,
    this.sent = false,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "phone": phone,
    "message": message,
    "time": scheduledTime.millisecondsSinceEpoch,
    "sent": sent,
  };

  static SmsLog fromJson(Map<String, dynamic> json) => SmsLog(
    id: json["id"],
    phone: json["phone"],
    message: json["message"],
    scheduledTime: DateTime.fromMillisecondsSinceEpoch(json["time"]),
    sent: json["sent"],
  );
}

class SmsLogStore {
  static const _key = "sms_logs";

  static Future<List<SmsLog>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => SmsLog.fromJson(e)).toList();
  }

  static Future<void> save(List<SmsLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int index = 0;

  final pages = [
    const SmsHome(), // your existing home
    const LogsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Logs"),
        ],
      ),
    );
  }
}

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<SmsLog> logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
    Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> loadLogs() async {
    logs = await SmsLogStore.load();
    setState(() {});
  }

  String remainingTime(DateTime time) {
    final diff = time.difference(DateTime.now());
    if (diff.isNegative) return "Sent";
    return "${diff.inMinutes} min ${diff.inSeconds % 60} sec";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Logs"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Icon(
                log.sent ? Icons.check_circle : Icons.timer,
                color: log.sent ? Colors.green : Colors.orange,
              ),
              title: Text(
                log.phone,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.message),
                  const SizedBox(height: 6),
                  Text(
                    log.sent
                        ? "Status: Sent"
                        : "Time left: ${remainingTime(log.scheduledTime)}",
                    style: TextStyle(
                      color: log.sent ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
