import 'package:flutter/material.dart';
import 'package:frontend/pages/Case/index.dart';
import 'package:frontend/pages/Mine/index.dart';
import 'package:frontend/pages/Template_library/index.dart';
import 'package:frontend/pages/Tools/index.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<String, String>> _tabList = [
    {
      "icon": "lib/assets/case_normal.png",
      "active_icon": "lib/assets/case_active.png",
      "text": "案件",
    },
    {
      "icon": "lib/assets/template_normal.png",
      "active_icon": "lib/assets/template_active.png",
      "text": "模版库",
    },
    {
      "icon": "lib/assets/tool_normal.png",
      "active_icon": "lib/assets/tool_active.png",
      "text": "工具",
    },
    {
      "icon": "lib/assets/Mine_normal.png",
      "active_icon": "lib/assets/Mine_active.png",
      "text": "我的",
    },
  ];

  List<BottomNavigationBarItem> _getTabBarWidget() {
    return List.generate(_tabList.length, (int index) {
      return BottomNavigationBarItem(
        icon: Image.asset(_tabList[index]["icon"]!, width: 20, height: 20),
        activeIcon: Image.asset(
          _tabList[index]["active_icon"]!,
          width: 20,
          height: 20,
        ),
        label: _tabList[index]["text"],
      );
    });
  }

  int _currentIndex = 0;

  List<Widget> _getShowWidget() {
    return [CaseView(), TemplateLibraryView(), ToolsView(), MineView()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _getShowWidget()),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12), // 距离屏幕边缘的间距
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30), // 四周圆角
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // 剪裁内部内容以适应圆角
          child: BottomNavigationBar(
            items: _getTabBarWidget(),
            showUnselectedLabels: true,
            selectedItemColor: Colors.blue, // 建议选中颜色改为蓝色，更有区分度
            unselectedItemColor: Colors.black,
            onTap: (int index) {
              _currentIndex = index;
              setState(() {});
            },
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed, // 确保图标平铺
            backgroundColor: Colors.transparent, // 设置透明，显示 Container 的背景
            elevation: 0, // 去掉自带阴影，改用 Container 的阴影
          ),
        ),
      ),
    );
  }
}
