/*
 * @Description: main
 * @Autor: taotao.wu
 * @Date: 2026-03-28 20:30:57
 * @LastEditors: taotao.wu
 * @LastEditTime: 2026-03-28 23:05:39
 */

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'PingFang SC',
      ),
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
    // 确保 PlanPageState 存在且已初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _planKey.currentState?.changePlanType(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 完全删除 AppBar
      appBar: null,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 0) {
            PlanPage.addPlan(context, _planKey);
          } else {
            MemorialDayPage.addMemorialDay(context, _memorialKey);
          }
        },
        child: const Icon(Icons.add),
        elevation: 4,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
            if (i == 0) {
              // 切换到计划页面时，重置为收集箱
              _updatePlanType("collect");
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
