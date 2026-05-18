import 'package:flutter/material.dart';
import 'dart:async';

class Alarm {
  UniqueKey id;
  TimeOfDay time;
  bool enabled;
  String label;

  Alarm({required this.time, this.enabled = true, this.label = 'منبه'}) : id = UniqueKey();

  String get formattedTime {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق المنبه',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AlarmListScreen(),
    );
  }
}

class AlarmListScreen extends StatefulWidget {
  @override
  _AlarmListScreenState createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  List<Alarm> _alarms = [];
  Timer? _alarmCheckTimer;

  @override
  void initState() {
    super.initState();
    _startAlarmChecker();
  }

  @override
  void dispose() {
    _alarmCheckTimer?.cancel();
    super.dispose();
  }

  void _startAlarmChecker() {
    _alarmCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkAlarms();
    });
  }

  void _checkAlarms() {
    final now = DateTime.now();
    for (var alarm in _alarms) {
      if (alarm.enabled &&
          alarm.time.hour == now.hour &&
          alarm.time.minute == now.minute &&
          now.second == 0) {
        _triggerAlarm(alarm);
      }
    }
  }

  void _triggerAlarm(Alarm alarm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('وقت المنبه!'),
          content: Text('${alarm.label} يرن الآن!'),
          actions: <Widget>[
            TextButton(
              child: Text('إيقاف'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAlarm() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _alarms.add(Alarm(time: picked));
        _alarms.sort((a, b) =>
            (a.time.hour * 60 + a.time.minute)
                .compareTo(b.time.hour * 60 + b.time.minute));
      });
    }
  }

  void _toggleAlarm(Alarm alarm, bool value) {
    setState(() {
      alarm.enabled = value;
    });
  }

  void _deleteAlarm(Alarm alarm) {
    setState(() {
      _alarms.removeWhere((element) => element.id == alarm.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المنبه'),
        centerTitle: true,
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Text(
                'لا يوجد منبهات. اضغط على + لإضافة منبه جديد.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alarm.formattedTime,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: alarm.enabled ? Colors.black : Colors.grey,
                                ),
                              ),
                              Text(
                                alarm.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: alarm.enabled ? Colors.black54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: alarm.enabled,
                          onChanged: (value) => _toggleAlarm(alarm, value),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAlarm(alarm),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: Icon(Icons.add),
        tooltip: 'إضافة منبه جديد',
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}