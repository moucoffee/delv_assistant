import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/contants/index.dart';
import 'package:frontend/utils/DioRequest.dart';
import 'package:frontend/stores/TokenManager.dart';
import 'package:frontend/viewmodels/chat.dart' as vm;

Future<List<vm.ChatMessage>> getChatMessagesAPI({int? caseId}) async {
  Map<String, dynamic>? params;
  if (caseId != null) {
    params = {"case_id": caseId};
  }
  final response = await dioRequest.get(HttpContants.CHAT_MESSAGES, params: params);
  return (response as List).map((item) {
    return vm.ChatMessage.fromJSON(item as Map<String, dynamic>);
  }).toList();
}

Future<Map<String, dynamic>> sendChatMessageAPI(vm.ChatRequest request) async {
  final response = await dioRequest.post(
    HttpContants.CHAT_MESSAGE,
    data: request.toJson(),
  );
  return response as Map<String, dynamic>;
}

Stream<String> sendChatMessageStreamAPI(vm.ChatRequest request) async* {
  final dio = Dio();
  dio.options
    ..baseUrl = GlobalContants.BASE_URL
    ..connectTimeout = Duration(seconds: GlobalContants.TIME_OUT)
    ..receiveTimeout = Duration(seconds: 60);

  final token = tokenManager.getToken();
  if (token.isNotEmpty) {
    dio.options.headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  try {
    final response = await dio.post(
      HttpContants.CHAT_MESSAGE_STREAM,
      data: request.toJson(),
      options: Options(
        responseType: ResponseType.stream,
      ),
    );

    String buffer = "";
    final stream = response.data.stream;
    
    await for (final chunk in stream) {
      buffer += String.fromCharCodes(chunk);
      
      while (true) {
        final newlineIndex = buffer.indexOf('\n');
        if (newlineIndex == -1) break;
        
        final line = buffer.substring(0, newlineIndex).trim();
        buffer = buffer.substring(newlineIndex + 1);
        
        if (line.startsWith('data: ')) {
          final content = line.substring(6).trim();
          if (content == '[DONE]') {
            return;
          }
          try {
            final jsonData = jsonDecode(content) as Map<String, dynamic>;
            if (jsonData['content'] != null) {
              yield jsonData['content'] as String;
            }
          } catch (_) {}
        }
      }
    }
  } catch (e) {
    rethrow;
  }
}
