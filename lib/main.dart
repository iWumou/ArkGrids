import 'package:flutter/material.dart';
import 'pages/plan_page.dart';
import 'pages/memorial_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '计划&纪念日',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _currentPlanType = "collect";

  final _planKey = GlobalKey<PlanPageState>();
  final _memorialKey = GlobalKey<MemorialDayPageState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [PlanPage(key: _planKey), MemorialDayPage(key: _memorialKey)];
  }

  void _updatePlanType(String type) {
    setState(() {
      _currentPlanType = type;
    });
    _planKey.currentState?.changePlanType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            if (_currentIndex == 0) {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text("收集箱"),
                        onTap: () {
                          Navigator.pop(context);
                          _updatePlanType("collect");
                        },
                      ),
                      ListTile(
                        title: const Text("收货箱"),
                        onTap: () {
                          Navigator.pop(context);
                          _updatePlanType("done");
                        },
                      ),
                      ListTile(
                        title: const Text("垃圾箱"),
                        onTap: () {
                          Navigator.pop(context);
                          _updatePlanType("deleted");
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        title: _currentIndex == 0
            ? GestureDetector(
                onTap: () {
                  if (_currentPlanType == "collect") {
                    _updatePlanType("done");
                  } else if (_currentPlanType == "done") {
                    _updatePlanType("collect");
                  } else if (_currentPlanType == "deleted") {
                    _updatePlanType("collect");
                  }
                },
                child: Text(
                  _currentPlanType == "collect"
                      ? "收集箱"
                      : _currentPlanType == "done"
                      ? "收货箱"
                      : "垃圾箱",
                ),
              )
            : const Text("纪念日"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 0) {
            PlanPage.addPlan(context, _planKey);
          } else {
            MemorialDayPage.addMemorialDay(context, _memorialKey);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 0) {
            _updatePlanType("collect");
          }
          setState(() {
            _currentIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "计划"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "纪念日",
          ),
        ],
      ),
    );
  }
}
