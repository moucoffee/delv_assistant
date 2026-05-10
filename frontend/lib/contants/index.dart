//全局变量
class GlobalContants {
  static const String BASE_URL = "http://127.0.0.1:8000";
  static const int TIME_OUT = 10;
  static const int SUCCESS_CODE = 1;
}

//存放请求地址接口变量
class HttpContants {
  static const String CASE_LIST = "/cases"; //获取当前用户的案件信息
  static const String CASE_DETAIL = "/cases/"; 
  static const String UPLOAD_FILE = "/upload"; // 文件上传接口
  static const String MATERIALS = "/materials"; // 材料CRUD接口
}
