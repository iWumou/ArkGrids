import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MemorialDayPage extends StatefulWidget {
  const MemorialDayPage({super.key});

  static Future addMemorialDay(
    BuildContext context,
    GlobalKey<MemorialDayPageState> key, {
    Map<String, dynamic>? editItem,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: editItem?["title"] ?? "");
    DateTime? selectedDate = editItem != null && editItem["date"] != null
        ? DateTime.parse(editItem["date"])
        : null;

    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFFF8F9FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      editItem == null ? "创建纪念日" : "编辑纪念日",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      editItem == null ? "记录每一个重要时刻" : "修改纪念日信息",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: "纪念日名称",
                        labelText: "名称",
                        prefixIcon: Icon(
                          Icons.celebration,
                          color: Colors.blue[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade50, Colors.white],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setStateDialog(() => selectedDate = date);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDate == null
                                      ? "选择日期"
                                      : "${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selectedDate == null
                                        ? Colors.grey[700]
                                        : const Color(0xFF667EEA),
                                    fontWeight: selectedDate != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(c),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              if (titleCtrl.text.isNotEmpty &&
                                  selectedDate != null) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                List<String> list =
                                    prefs.getStringList("memorialDays") ?? [];

                                final item = {
                                  "title": titleCtrl.text,
                                  "date": selectedDate!.toIso8601String(),
                                };

                                if (editIndex != null) {
                                  list[editIndex] = jsonEncode(item);
                                } else {
                                  list.add(jsonEncode(item));
                                }

                                await prefs.setStringList("memorialDays", list);
                                Navigator.pop(c);
                                key.currentState?.loadData();
                              }
                            },
                            child: const Text(
                              "保存",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  MemorialDayPageState createState() => MemorialDayPageState();
}

class MemorialDayPageState extends State<MemorialDayPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> days = [];
  int? selectedIndex;
  Set<int> fadingItems = {};
  int _totalCount = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList("memorialDays") ?? [];
    setState(() {
      days = list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _totalCount = days.length;
    });
  }

  Future<void> saveList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> result = days.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList("memorialDays", result);
  }

  Future<void> deleteItem(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      days.removeAt(index);
      fadingItems.remove(index);
      _totalCount = days.length;
    });
    await prefs.setStringList(
      "memorialDays",
      days.map((e) => jsonEncode(e)).toList(),
    );
  }

  void _editMemorialDay(int index) {
    MemorialDayPage.addMemorialDay(
      context,
      widget.key as GlobalKey<MemorialDayPageState>,
      editItem: days[index],
      editIndex: index,
    );
  }

  void _showDeleteConfirm(int index) {
    String title = days[index]["title"] ?? "";
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, const Color(0xFFFEF5F5)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade50, Colors.red.shade100],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "确认删除",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "是否删除 \"$title\"？",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "删除后无法恢复",
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("取消", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          deleteItem(index);
                        },
                        child: const Text("删除", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLongPressMenu(int index) {
    if (_isDragging) return;
    setState(() => selectedIndex = index);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFF8F9FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667EEA).withOpacity(0.1),
                            const Color(0xFF764BA2).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: Color(0xFF667EEA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "纪念日操作",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              _buildMenuItem(
                icon: Icons.edit,
                iconColor: const Color(0xFF667EEA),
                title: "编辑纪念日",
                subtitle: "修改名称或日期",
                onTap: () {
                  Navigator.pop(context);
                  _editMemorialDay(index);
                  setState(() => selectedIndex = null);
                },
              ),
              _buildMenuItem(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                title: "删除纪念日",
                subtitle: "永久删除",
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirm(index);
                },
                isDestructive: true,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => selectedIndex = null);
                  },
                  child: const Text(
                    "取消",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getDaysPassed(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return "今天";
    if (difference == 1) return "昨天";
    if (difference < 0) return "还有 ${-difference} 天";
    return "$difference 天";
  }

  String _getYearMonthDay(DateTime date) {
    return "${date.year}年${date.month}月${date.day}日";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "纪念日 $_totalCount",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: days.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "暂无纪念日",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "点击 + 按钮添加纪念日",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[350],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: days.length,
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final value = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ).value;
                            return Transform.scale(
                              scale: 0.95 + (value * 0.05),
                              child: Material(
                                elevation: 8,
                                color: Colors.transparent,
                                child: child,
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      onReorderStart: (index) {
                        _isDragging = true;
                      },
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex--;
                        final item = days.removeAt(oldIndex);
                        days.insert(newIndex, item);
                        setState(() {});
                      },
                      onReorderEnd: (index) async {
                        await saveList();
                        _isDragging = false;
                      },
                      itemBuilder: (c, i) {
                        final item = days[i];
                        final date = DateTime.parse(item["date"]);
                        final daysPassed = _getDaysPassed(date);
                        final isSelected = selectedIndex == i;
                        final isFading = fadingItems.contains(i);
                        final isToday = daysPassed == "今天";
                        final isPast =
                            daysPassed.contains("天") &&
                            !daysPassed.contains("还有");

                        return Container(
                          key: ValueKey(
                            item["title"] + i.toString() + item["date"],
                          ), // 添加 key
                          child: ReorderableDragStartListener(
                            index: i,
                            child: TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isFading ? 0.0 : 1.0,
                                child: GestureDetector(
                                  onDoubleTap: () => _showLongPressMenu(i),
                                  onTap: () =>
                                      setState(() => selectedIndex = null),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(isSelected ? 1.02 : 1.0),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white,
                                                isSelected
                                                    ? Colors.pink.shade50
                                                    : Colors.grey.shade50,
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: isToday
                                                          ? [
                                                              Colors
                                                                  .pink
                                                                  .shade100,
                                                              Colors
                                                                  .pink
                                                                  .shade200,
                                                            ]
                                                          : [
                                                              Colors
                                                                  .purple
                                                                  .shade50,
                                                              Colors
                                                                  .purple
                                                                  .shade100,
                                                            ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    isToday
                                                        ? Icons.today
                                                        : Icons.celebration,
                                                    color: isToday
                                                        ? Colors.pink.shade700
                                                        : Colors
                                                              .purple
                                                              .shade400,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item["title"] ?? "",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _getYearMonthDay(date),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[500],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: isPast
                                                          ? [
                                                              Colors
                                                                  .blue
                                                                  .shade50,
                                                              Colors
                                                                  .blue
                                                                  .shade100,
                                                            ]
                                                          : isToday
                                                          ? [
                                                              Colors
                                                                  .pink
                                                                  .shade50,
                                                              Colors
                                                                  .pink
                                                                  .shade100,
                                                            ]
                                                          : [
                                                              Colors
                                                                  .orange
                                                                  .shade50,
                                                              Colors
                                                                  .orange
                                                                  .shade100,
                                                            ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    daysPassed,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isPast
                                                          ? Colors.blue.shade700
                                                          : isToday
                                                          ? Colors.pink.shade700
                                                          : Colors
                                                                .orange
                                                                .shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MemorialDayPage.addMemorialDay(
          context,
          widget.key as GlobalKey<MemorialDayPageState>,
        ),
        child: const Icon(Icons.add),
        elevation: 4,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
    );
  }
}
