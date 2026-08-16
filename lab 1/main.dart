import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool edit = false;
  bool dark = false;

  final dummy = <String, String>{
    'name': 'Aarav Sharma',
    'roll': 'R5CO4004L001',
    'year': '3rd Year',
    'branch': 'CSE',
    'semester': '6th Semester',
    'email': 'aarav@example.com',
    'phone': '9876543210',
  };

  Map<String, String> s = {};
  final c = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    s = Map<String, String>.from(dummy);

    for (var e in s.entries) {
      c[e.key] = TextEditingController(text: e.value);
    }
  }

  @override
  void dispose() {
    for (var controller in c.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void save() {
    FocusScope.of(context).unfocus();

    setState(() {
      s.updateAll(
        (key, value) => c[key]!.text.trim().isEmpty
            ? value
            : c[key]!.text.trim(),
      );
      edit = false;
    });

    snack('Profile updated successfully!');
  }

  void toggleEdit() {
    if (edit) {
      save();
    } else {
      c.forEach((key, controller) => controller.text = s[key]!);
      setState(() => edit = true);
      snack('Edit mode enabled');
    }
  }

  void reset() {
    setState(() {
      s = Map<String, String>.from(dummy);
      edit = false;
      dark = false;
      c.forEach((key, controller) => controller.text = s[key]!);
    });

    snack('Dummy data reset successfully!');
  }

  void details() {
    snack('Profile details verified!');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Student Summary'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: s.entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${e.key.toUpperCase()}: ${e.value}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: dark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget field(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: c[key],
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(() => dark = !dark),
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            onPressed: toggleEdit,
            icon: Icon(edit ? Icons.save : Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: dark ? Colors.blueGrey : Colors.indigo,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                s['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s['branch']!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.blueGrey.shade800
                      : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: dark
                        ? Colors.blueGrey.shade300
                        : Colors.indigo.shade200,
                  ),
                ),
                child: Column(
                  children: edit
                      ? [
                          field('name', 'Name'),
                          field('roll', 'Roll No.'),
                          field('year', 'Year'),
                          field('branch', 'Branch'),
                          field('semester', 'Semester'),
                          field('email', 'Email'),
                          field('phone', 'Phone'),
                        ]
                      : [
                          row('Roll No.', s['roll']!),
                          row('Year', s['year']!),
                          row('Branch', s['branch']!),
                          row('Semester', s['semester']!),
                          row('Email', s['email']!),
                          row('Phone', s['phone']!),
                        ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: details,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View Details'),
                  ),
                  OutlinedButton.icon(
                    onPressed: toggleEdit,
                    icon: Icon(edit ? Icons.save : Icons.edit),
                    label: Text(edit ? 'Save' : 'Edit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
