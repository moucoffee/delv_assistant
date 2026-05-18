//底部导航栏组件
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onTextTap;
  final VoidCallback? onFileTap;

  const BottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTap,
    this.onMicTap,
    this.onImageTap,
    this.onChatTap,
    this.onTextTap,
    this.onFileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      height: 70,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(
              Icons.mic,
              "录音",
              isSelected: selectedIndex == 0,
              onTap: () {
                onItemTap(0);
                if (onMicTap != null) onMicTap!();
              },
            ),
            _buildItem(
              Icons.image,
              "图片",
              isSelected: selectedIndex == 1,
              onTap: () {
                onItemTap(1);
                if (onImageTap != null) onImageTap!();
              },
            ),
            _buildItem(
              Icons.chat_bubble,
              "AI对话",
              isSelected: selectedIndex == 2,
              onTap: () {
                onItemTap(2);
                if (onChatTap != null) onChatTap!();
              },
            ),
            _buildItem(
              Icons.notes,
              "文本",
              isSelected: selectedIndex == 3,
              onTap: () {
                onItemTap(3);
                if (onTextTap != null) onTextTap!();
              },
            ),
            _buildItem(
              Icons.upload_file,
              "文件",
              isSelected: selectedIndex == 4,
              onTap: () {
                onItemTap(4);
                if (onFileTap != null) onFileTap!();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
