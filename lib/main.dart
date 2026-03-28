/*
 * @Description: main
 * @Autor: taotao.wu
 * @Date: 2026-03-28 20:30:57
 * @LastEditors: taotao.wu
 * @LastEditTime: 2026-03-29 00:04:49
 */

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      title: 'Ark Grids',
      // 添加本地化代理
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
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
      // 添加 SafeArea 防止内容被摄像头遮挡
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
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
        elevation: 4,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FF),
              const Color(0xFFF0F2F8),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF667EEA),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "计划"),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "纪念日",
            ),
          ],
        ),
      ),
    );
  }
}
