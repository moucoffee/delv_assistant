//全局变量
class GlobalContants {
  static const String BASE_URL = "http://127.0.0.1:8000";
  static const int TIME_OUT = 10;
  static const int SUCCESS_CODE = 1;
  static const String TOKEN_KEY = "delv_assistant";
}

//存放请求地址接口变量
class HttpContants {
  static const String CASE_LIST = "/cases"; //获取当前用户的案件信息
  static const String CASE_DETAIL = "/cases/"; 
  static const String CASE_CREATE = "/cases"; // 创建案件
  static const String UPLOAD_FILE = "/upload"; // 文件上传接口
  static const String MATERIALS = "/materials"; // 材料CRUD接口
  static const String USER_ME = "/user/me"; // 获取当前用户信息
  static const String USER_LOGIN = "/user/login"; // 用户登录
  static const String CHAT_MESSAGES = "/chat/messages"; // 获取聊天消息
  static const String CHAT_MESSAGE = "/chat/message"; // 聊天消息
  static const String CHAT_MESSAGE_STREAM = "/chat/message/stream"; // 流式聊天消息
}
