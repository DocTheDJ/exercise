import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? start = DateTime.now();
  DateTime? end = DateTime.now().add(const Duration(minutes: 1));
  double progress = 0.0;
  DateTime _now = DateTime.now();
  bool _changing = false;
  late Timer _times;

  @override
  void initState() {
    super.initState();
    _times = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
      if (!_changing) {
        final t = _now.difference(start ?? DateTime.now()).inMilliseconds / (end?.difference(start ?? DateTime.now()).inMilliseconds ?? 1);
        if (t <= 1.0) {
          if (t < 0.0) {
            setState(() {
              progress = 0.0;
            });
          } else {
            setState(() {
              progress = t;
            });
          }
        } else {
          setState(() {
            progress = 1.0;
          });
        }
      }
    });
  }

  void setUsingProgress(double val) {
    if (start != null || end != null) {
      if (start != null && end != null) {
        if (_now.isAfter(start!)) {
          final t = _now.difference(start!).inSeconds;
          final tDiff = (t / val).round();
          setState(() {
            end = start!.add(Duration(seconds: tDiff));
          });
        } else {
          final t = end!.difference(_now).inSeconds;
          final tDiff = (t / (1.0 - val)).round();
          setState(() {
            start = end!.subtract(Duration(seconds: tDiff));
          });
        }
      } else {
        if (start == null) {
          final t = end!.difference(_now).inSeconds;
          final tDiff = (t / (1.0 - val)).round();
          setState(() {
            start = end!.subtract(Duration(seconds: tDiff));
          });
        } else {
          final t = _now.difference(start!).inSeconds;
          final tDiff = (t / val).round();
          setState(() {
            end = start!.add(Duration(seconds: tDiff));
          });
        }
      }
    }
    setState(() {
      progress = val;
    });
  }

  @override
  void dispose() {
    _times.cancel();
    super.dispose();
  }

  void _flipChange() {
    setState(() => _changing = !_changing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("${(progress * 100).toStringAsFixed(3)} %"),
            Text(_now.toString()),
            Row(
              children: [
                const Text("Start:"),
                ElevatedButton(
                    onPressed: () {
                      _flipChange();
                      showDatePicker(
                              context: context,
                              initialDate: start ?? DateTime.now(),
                              firstDate: (start ?? DateTime.now()).subtract(const Duration(days: 365)),
                              lastDate: (start ?? DateTime.now()).add(const Duration(days: 365)))
                          .then((value) {
                        if (value != null && value != start) {
                          value = DateTime(value.year, value.month, value.day, start?.hour ?? 0, start?.minute ?? 0);
                          if (value.isBefore(end ?? DateTime.now())) {
                            setState(() => start = value!);
                          }
                        }
                        _flipChange();
                      });
                    },
                    child: Text(start != null ? DateFormat(DateFormat.YEAR_MONTH_DAY).format(start!) : "Start date")),
                ElevatedButton(
                    onPressed: () {
                      _flipChange();
                      showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(start ?? DateTime.now())).then((value) {
                        if (value != null && value != TimeOfDay.fromDateTime(start ?? DateTime.now())) {
                          var n = DateTime.now();
                          var t = DateTime(start?.year ?? n.year, start?.month ?? n.month, start?.day ?? n.day, value.hour, value.minute);
                          if (t.isBefore(end ?? n)) {
                            setState(() => start = t);
                          }
                        }
                        _flipChange();
                      });
                    },
                    child: Text(start != null ? DateFormat(DateFormat.HOUR24_MINUTE).format(start!) : "StartTime")),
                ElevatedButton(onPressed: () => setState(() => start = null), child: const Text("Clear"))
              ],
            ),
            Row(
              children: [
                const Text("end:"),
                ElevatedButton(
                    onPressed: () {
                      _flipChange();
                      showDatePicker(
                              context: context,
                              initialDate: end ?? DateTime.now(),
                              firstDate: (end ?? DateTime.now()).subtract(const Duration(days: 365)),
                              lastDate: (end ?? DateTime.now()).add(const Duration(days: 365)))
                          .then((value) {
                        if (value != null && value != end) {
                          value = DateTime(value.year, value.month, value.day, end?.hour ?? 0, end?.minute ?? 0);
                          if (value.isAfter(start ?? DateTime.now())) {
                            setState(() => end = value!);
                          }
                        }
                        _flipChange();
                      });
                    },
                    child: Text(end != null ? DateFormat(DateFormat.YEAR_MONTH_DAY).format(end!) : "end date")),
                ElevatedButton(
                    onPressed: () {
                      _flipChange();
                      showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(end ?? DateTime.now())).then((value) {
                        if (value != null && value != TimeOfDay.fromDateTime(end ?? DateTime.now())) {
                          var n = DateTime.now();
                          var t = DateTime(end?.year ?? n.year, end?.month ?? n.month, end?.day ?? n.day, value.hour, value.minute);
                          if (t.isAfter(start ?? n)) {
                            setState(() => end = t);
                          }
                        }
                        _flipChange();
                      });
                    },
                    child: Text(end != null ? DateFormat(DateFormat.HOUR24_MINUTE).format(end!) : "endTime")),
                ElevatedButton(onPressed: () => setState(() => end = null), child: const Text("Clear"))
              ],
            ),
            Slider(
              value: progress,
              onChanged: (v) => setState(() => progress = v),
              onChangeStart: (v) => _flipChange(),
              onChangeEnd: (v) => {_flipChange(), setUsingProgress(v)},
            ),
          ],
        ),
      ),
    );
  }
}
