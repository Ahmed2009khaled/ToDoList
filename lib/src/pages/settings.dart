import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final Box settings = Hive.box('settings');

  bool notf = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: ListView(
          children: [
            SizedBox(height: 10),
            Text(
              " Appearance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: Text('Dark Mode'),
                subtitle: Text('Light or Dark Mode'),
                leading: settings.get('dark_mode')
                    ? Icon(Icons.dark_mode)
                    : Icon(Icons.light_mode),
                trailing: Switch(
                  value: settings.get('dark_mode'),
                  onChanged: (value) {
                    setState(() {
                      settings.put('dark_mode', value);
                    });
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(height: 25),
            Text(
              " Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                subtitle: Text('Allow notifications'),
                trailing: Switch(
                  value: notf,
                  onChanged: (value) {
                    setState(() {
                      notf = value;
                    });
                  },
                  activeColor: Colors.blue, // consistent active color
                  inactiveThumbColor:
                      Colors.grey, // consistent inactive thumb color
                  inactiveTrackColor:
                      Colors.grey[300], // consistent inactive track color
                ),
              ),
            ),
            SizedBox(height: 25),
            Text(
              " About",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help & Support'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Privacy Policy'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App Version'),
                trailing: Text('1.1.3'),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Developer'),
                subtitle: Text('Ahmed Khaled'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
