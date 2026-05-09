import 'package:flutter/material.dart';

class MySearch extends StatefulWidget {
  final Function(String)? onChanged; // 添加回调函数

  MySearch({Key? key, this.onChanged}) : super(key: key);

  @override
  _MySearchState createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getLeftWidget() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Image.asset("lib/assets/search.png", fit: BoxFit.fill),
    );
  }

  Widget _getRightWidget() {
    return Expanded(
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: "搜索案件标题、当事人",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          // 触发父组件传进来的回调
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [_getLeftWidget(), SizedBox(width: 5), _getRightWidget()],
      ),
    );
  }
}
