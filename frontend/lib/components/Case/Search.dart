import 'package:flutter/material.dart';

class MySearch extends StatefulWidget {
  MySearch({Key? key}) : super(key: key);

  @override
  _MySearchState createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  final TextEditingController _controller = TextEditingController();

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
          isDense: true, // 关键属性：让输入框更紧凑
          contentPadding: EdgeInsets.zero, 
        ),
        onChanged: (value) {
          // 当内容改变时，可以在这里处理，或者直接通过 _controller.text 获取
          print("当前搜索内容: $value");
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
