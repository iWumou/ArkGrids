import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  static Future addPlan(
    BuildContext context,
    GlobalKey<PlanPageState> key, {
    Map<String, dynamic>? editItem,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: editItem?["title"] ?? "");
    final descCtrl = TextEditingController(text: editItem?["desc"] ?? "");

    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    int priority = 2;

    if (editItem != null &&
        editItem["date"] != null &&
        editItem["date"].isNotEmpty) {
      try {
        DateTime date = DateTime.parse(editItem["date"]);
        selectedDate = date;
        selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
      } catch (e) {}
    }

    priority = editItem?["priority"] ?? 2;

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
                      editItem == null ? "创建新计划" : "编辑计划",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      editItem == null ? "让每一天都有目标" : "修改你的计划内容",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: "计划标题",
                        labelText: "标题",
                        prefixIcon: Icon(Icons.title, color: Colors.blue[400]),
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        hintText: "详细描述",
                        labelText: "描述（选填）",
                        prefixIcon: Icon(
                          Icons.description,
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
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGradientButton(
                            onPressed: () async {
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
                            icon: Icons.calendar_today,
                            label: selectedDate == null
                                ? "选择日期"
                                : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGradientButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setStateDialog(() => selectedTime = time);
                              }
                            },
                            icon: Icons.access_time,
                            label: selectedTime == null
                                ? "选择时间"
                                : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "优先级",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPriorityChip(
                          label: "紧急",
                          color: Colors.red,
                          isSelected: priority == 0,
                          onPressed: () => setStateDialog(() => priority = 0),
                        ),
                        _buildPriorityChip(
                          label: "一般",
                          color: Colors.orange,
                          isSelected: priority == 1,
                          onPressed: () => setStateDialog(() => priority = 1),
                        ),
                        _buildPriorityChip(
                          label: "不急",
                          color: Colors.green,
                          isSelected: priority == 2,
                          onPressed: () => setStateDialog(() => priority = 2),
                        ),
                      ],
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
                              if (titleCtrl.text.isNotEmpty) {
                                String? dateString;
                                if (selectedDate != null) {
                                  DateTime temp = selectedDate!;
                                  if (selectedTime != null) {
                                    temp = DateTime(
                                      selectedDate!.year,
                                      selectedDate!.month,
                                      selectedDate!.day,
                                      selectedTime!.hour,
                                      selectedTime!.minute,
                                    );
                                  }
                                  dateString = temp.toIso8601String();
                                }

                                final prefs =
                                    await SharedPreferences.getInstance();

                                if (editItem != null && editIndex != null) {
                                  List<String> list = [];
                                  String type = editItem["type"] ?? "collect";
                                  if (type == "collect")
                                    list =
                                        prefs.getStringList("plans_collect") ??
                                        [];
                                  if (type == "done")
                                    list =
                                        prefs.getStringList("plans_done") ?? [];
                                  if (type == "deleted")
                                    list =
                                        prefs.getStringList("plans_deleted") ??
                                        [];

                                  list[editIndex] = jsonEncode({
                                    "title": titleCtrl.text,
                                    "desc": descCtrl.text,
                                    "date": dateString ?? "",
                                    "priority": priority,
                                    "done": false,
                                    "type": type,
                                  });
                                  if (type == "collect")
                                    await prefs.setStringList(
                                      "plans_collect",
                                      list,
                                    );
                                  if (type == "done")
                                    await prefs.setStringList(
                                      "plans_done",
                                      list,
                                    );
                                  if (type == "deleted")
                                    await prefs.setStringList(
                                      "plans_deleted",
                                      list,
                                    );
                                } else {
                                  List<String> list =
                                      prefs.getStringList("plans_collect") ??
                                      [];
                                  list.add(
                                    jsonEncode({
                                      "title": titleCtrl.text,
                                      "desc": descCtrl.text,
                                      "date": dateString ?? "",
                                      "priority": priority,
                                      "done": false,
                                      "type": "collect",
                                    }),
                                  );
                                  await prefs.setStringList(
                                    "plans_collect",
                                    list,
                                  );
                                }

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

  static Widget _buildGradientButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.white]),
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPriorityChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> showList = [];
  String currentPlanType = "collect";
  int? selectedIndex;
  Set<int> fadingItems = {};
  late TabController _tabController;

  // 统计数据
  int _collectCount = 0;
  int _doneCount = 0;
  int _deletedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              currentPlanType = "collect";
              break;
            case 1:
              currentPlanType = "done";
              break;
            case 2:
              currentPlanType = "deleted";
              break;
          }
        });
        loadData();
      }
    });
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void changePlanType(String type) {
    if (!mounted) return;
    setState(() {
      currentPlanType = type;
      selectedIndex = null;
      fadingItems.clear();
      switch (type) {
        case "collect":
          _tabController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
          );
          break;
        case "done":
          _tabController.animateTo(
            1,
            duration: const Duration(milliseconds: 300),
          );
          break;
        case "deleted":
          _tabController.animateTo(
            2,
            duration: const Duration(milliseconds: 300),
          );
          break;
      }
    });
    loadData();
  }

  Future<void> _updateCounts() async {
    final prefs = await SharedPreferences.getInstance();
    _collectCount = prefs.getStringList("plans_collect")?.length ?? 0;
    _doneCount = prefs.getStringList("plans_done")?.length ?? 0;
    _deletedCount = prefs.getStringList("plans_deleted")?.length ?? 0;
    if (mounted) setState(() {});
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    if (currentPlanType == "collect")
      list = prefs.getStringList("plans_collect") ?? [];
    if (currentPlanType == "done")
      list = prefs.getStringList("plans_done") ?? [];
    if (currentPlanType == "deleted")
      list = prefs.getStringList("plans_deleted") ?? [];

    await _updateCounts();

    if (mounted) {
      setState(() {
        showList = list
            .map((e) {
              try {
                return jsonDecode(e) as Map<String, dynamic>;
              } catch (e) {
                return <String, dynamic>{};
              }
            })
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> saveList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> result = showList.map((e) => jsonEncode(e)).toList();
    switch (currentPlanType) {
      case "collect":
        await prefs.setStringList("plans_collect", result);
        break;
      case "done":
        await prefs.setStringList("plans_done", result);
        break;
      case "deleted":
        await prefs.setStringList("plans_deleted", result);
        break;
    }
    await _updateCounts();
  }

  Future<void> _moveToDone(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];
    List<String> collect = prefs.getStringList("plans_collect") ?? [];
    if (index < collect.length) collect.removeAt(index);
    await prefs.setStringList("plans_collect", collect);
    List<String> done = prefs.getStringList("plans_done") ?? [];
    item["type"] = "done";
    done.add(jsonEncode(item));
    await prefs.setStringList("plans_done", done);
    setState(() => fadingItems.remove(index));
    loadData();
  }

  Future<void> _moveToCollect(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];
    List<String> done = prefs.getStringList("plans_done") ?? [];
    if (index < done.length) done.removeAt(index);
    await prefs.setStringList("plans_done", done);
    List<String> collect = prefs.getStringList("plans_collect") ?? [];
    item["type"] = "collect";
    collect.add(jsonEncode(item));
    await prefs.setStringList("plans_collect", collect);
    setState(() => fadingItems.remove(index));
    loadData();
  }

  Future<void> _moveToDeleted(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];
    if (currentPlanType == "collect") {
      List<String> collect = prefs.getStringList("plans_collect") ?? [];
      if (index < collect.length) collect.removeAt(index);
      await prefs.setStringList("plans_collect", collect);
    }
    if (currentPlanType == "done") {
      List<String> done = prefs.getStringList("plans_done") ?? [];
      if (index < done.length) done.removeAt(index);
      await prefs.setStringList("plans_done", done);
    }
    List<String> deleted = prefs.getStringList("plans_deleted") ?? [];
    item["type"] = "deleted";
    deleted.add(jsonEncode(item));
    await prefs.setStringList("plans_deleted", deleted);
    setState(() {
      selectedIndex = null;
      fadingItems.remove(index);
    });
    loadData();
  }

  Future<void> _restorePlan(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];
    List<String> deleted = prefs.getStringList("plans_deleted") ?? [];
    if (index < deleted.length) deleted.removeAt(index);
    await prefs.setStringList("plans_deleted", deleted);
    List<String> collect = prefs.getStringList("plans_collect") ?? [];
    item["type"] = "collect";
    collect.add(jsonEncode(item));
    await prefs.setStringList("plans_collect", collect);
    setState(() {
      selectedIndex = null;
      fadingItems.remove(index);
    });
    loadData();
  }

  // 美化后的双击菜单
  void _showLongPressMenu(int index) {
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
              // 顶部指示条
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
              // 标题
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
                      child: Icon(
                        currentPlanType != "deleted"
                            ? Icons.edit_note
                            : Icons.restore_from_trash,
                        color: const Color(0xFF667EEA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentPlanType != "deleted" ? "操作选项" : "回收站操作",
                        style: const TextStyle(
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

              if (currentPlanType != "deleted") ...[
                _buildMenuItem(
                  icon: Icons.edit,
                  iconColor: const Color(0xFF667EEA),
                  title: "编辑计划",
                  subtitle: "修改计划内容",
                  onTap: () {
                    Navigator.pop(context);
                    PlanPage.addPlan(
                      context,
                      widget.key as GlobalKey<PlanPageState>,
                      editItem: showList[index],
                      editIndex: index,
                    );
                    setState(() => selectedIndex = null);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: "删除计划",
                  subtitle: "移动到回收站",
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirm(index);
                  },
                  isDestructive: true,
                ),
              ] else ...[
                _buildMenuItem(
                  icon: Icons.restore,
                  iconColor: Colors.green,
                  title: "恢复计划",
                  subtitle: "恢复到进行中",
                  onTap: () {
                    Navigator.pop(context);
                    _restorePlan(index);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.delete_forever,
                  iconColor: Colors.red,
                  title: "彻底删除",
                  subtitle: "永久删除，不可恢复",
                  onTap: () {
                    Navigator.pop(context);
                    _showForeverDeleteConfirm(index);
                  },
                  isDestructive: true,
                ),
              ],

              const SizedBox(height: 8),
              // 取消按钮
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

  // 美化后的删除确认对话框
  void _showDeleteConfirm(int index) {
    String title = showList[index]["title"] ?? "";
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
                // 动画图标
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
                  "删除后可在回收站中恢复",
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
                          _moveToDeleted(index);
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

  // 美化后的彻底删除确认对话框
  void _showForeverDeleteConfirm(int index) {
    String title = showList[index]["title"] ?? "";
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
                // 动画图标
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
                          Icons.delete_forever,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "彻底删除",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "是否彻底删除 \"$title\"？",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "此操作不可恢复",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w500,
                  ),
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
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => fadingItems.add(index));
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          final prefs = await SharedPreferences.getInstance();
                          List<String> deleted =
                              prefs.getStringList("plans_deleted") ?? [];
                          if (index < deleted.length) deleted.removeAt(index);
                          await prefs.setStringList("plans_deleted", deleted);
                          setState(() {
                            selectedIndex = null;
                            fadingItems.remove(index);
                          });
                          loadData();
                        },
                        child: const Text(
                          "彻底删除",
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
      ),
    );
  }

  String _getCountDownText(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      DateTime target = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      int diff = target
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      if (diff < 0) return "已过期";
      if (diff == 0) return "今天";
      return "$diff 天";
    } catch (e) {
      return "";
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getTabText(String type, int count) {
    String name = type == "collect"
        ? "进行中"
        : type == "done"
        ? "已完成"
        : "回收站";
    return count > 0 ? "$name($count)" : name;
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
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
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
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: _getTabText("collect", _collectCount)),
                  Tab(text: _getTabText("done", _doneCount)),
                  Tab(text: _getTabText("deleted", _deletedCount)),
                ],
              ),
            ),
            Expanded(
              child: showList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentPlanType == "collect"
                                ? "暂无计划"
                                : currentPlanType == "done"
                                ? "暂无已完成计划"
                                : "回收站是空的",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "点击 + 按钮添加新计划",
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
                        vertical: 4,
                      ),
                      itemCount: showList.length,
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
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex--;
                        final item = showList.removeAt(oldIndex);
                        showList.insert(newIndex, item);
                        setState(() {});
                        saveList();
                      },
                      itemBuilder: (c, i) {
                        final item = showList[i];
                        final color = _getPriorityColor(item["priority"] ?? 2);
                        final isSelected = selectedIndex == i;
                        final deadline = _getCountDownText(item["date"]);
                        final isFading = fadingItems.contains(i);

                        return TweenAnimationBuilder(
                          key: ValueKey(
                            item["title"] + i.toString() + (item["date"] ?? ""),
                          ),
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
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              key: ValueKey(
                                item["title"] +
                                    i.toString() +
                                    (item["date"] ?? ""),
                              ),
                              child: ReorderableDragStartListener(
                                index: i,
                                child: GestureDetector(
                                  onDoubleTap: () => _showLongPressMenu(i),
                                  onTap: () =>
                                      setState(() => selectedIndex = null),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(isSelected ? 1.02 : 1.0),
                                    child: Container(
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
                                                    ? Colors.blue.shade50
                                                    : Colors.grey.shade50,
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                if (currentPlanType !=
                                                    "deleted")
                                                  Transform.scale(
                                                    scale: 1.1,
                                                    child: Checkbox(
                                                      value:
                                                          currentPlanType ==
                                                          "done",
                                                      onChanged: (v) {
                                                        if (currentPlanType ==
                                                            "collect") {
                                                          _moveToDone(i);
                                                        } else if (currentPlanType ==
                                                            "done") {
                                                          _moveToCollect(i);
                                                        }
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      activeColor: const Color(
                                                        0xFF667EEA,
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 8,
                                                            height: 8,
                                                            decoration:
                                                                BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: color,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              item["title"] ??
                                                                  "",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .grey[800],
                                                                decoration:
                                                                    currentPlanType ==
                                                                        "done"
                                                                    ? TextDecoration
                                                                          .lineThrough
                                                                    : null,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      if (item["desc"]
                                                              ?.isNotEmpty ??
                                                          false)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 16,
                                                                top: 2,
                                                              ),
                                                          child: Text(
                                                            item["desc"] ?? "",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (deadline.isNotEmpty)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          deadline == "已过期"
                                                          ? LinearGradient(
                                                              colors: [
                                                                Colors
                                                                    .red
                                                                    .shade50,
                                                                Colors
                                                                    .red
                                                                    .shade100,
                                                              ],
                                                            )
                                                          : LinearGradient(
                                                              colors: [
                                                                const Color(
                                                                  0xFF667EEA,
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                                const Color(
                                                                  0xFF764BA2,
                                                                ).withOpacity(
                                                                  0.1,
                                                                ),
                                                              ],
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      deadline,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: deadline == "已过期"
                                                            ? Colors.red
                                                            : const Color(
                                                                0xFF667EEA,
                                                              ),
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
        onPressed: () =>
            PlanPage.addPlan(context, widget.key as GlobalKey<PlanPageState>),
        child: const Icon(Icons.add),
        elevation: 4,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
    );
  }
}
