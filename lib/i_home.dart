import 'dart:async';
import 'package:flutter/material.dart';

class IHome extends StatefulWidget {
  const IHome({super.key});

  @override
  State<IHome> createState() => _IHomeState();
}

class _IHomeState extends State<IHome> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  Timer? timer;
  Duration duration = Duration.zero;
  List<Duration> laps = [];
  int total = 0;

  bool get isStop => timer == null;
  bool get isActive => (timer != null && timer!.isActive);

  add() {
    Duration dur = Duration(milliseconds: (isActive ? total : 0) + timer!.tick);
    laps.add(dur);
    setState(() {});
  }

  start() {
    if (isStop || !isActive) {
      controller.forward();
      if (isStop) laps.clear();
      timer = Timer.periodic(const Duration(milliseconds: 1), (_timer) {
        duration = Duration(milliseconds: total + _timer.tick);
        setState(() {});
      });
    } else {
      controller.reverse();
      pause();
    }
  }

  pause() {
    if (!isStop) {
      total += timer!.tick;
      timer!.cancel();
    }
  }

  stop() {
    if (!isStop) {
      timer!.cancel();
      timer = null;
      total = 0;
      duration = Duration.zero;
      controller.reverse();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text(
              (duration).toString(),
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            if (laps.iterator.moveNext())
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(15)),
                  child: ListView.builder(
                    itemCount: laps.length,
                    itemBuilder: (context, index) => Container(
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${index + 1}"),
                          SizedBox(width: 10),
                          Expanded(child: Text("${laps[index]}")),
                          GestureDetector(
                              onTap: () {
                                laps.removeAt(index);
                                setState(() {});
                              },
                              child: Icon(Icons.delete)),
                        ],
                      ),
                    ),
                    // children: laps.map((e) => Text(e.toString())).toList(),
                  ),
                ),
              ),
            Container(
              color: Colors.redAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!isStop)
                    IconButton(
                        onPressed: () {
                          stop();
                        },
                        icon: Icon(Icons.stop)),
                  IconButton(
                      onPressed: () {
                        start();
                      },
                      icon: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: animation,
                      )),
                  if (!isStop)
                    IconButton(
                        onPressed: () {
                          add();
                        },
                        icon: Icon(Icons.flag)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
