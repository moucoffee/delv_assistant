import 'package:dio/dio.dart';
import 'package:frontend/contants/index.dart';
import 'package:frontend/stores/TokenManager.dart';

class DioRequest {
  final _dio = Dio();

  DioRequest() {
    _dio.options
      ..baseUrl = GlobalContants.BASE_URL
      ..connectTimeout = Duration(seconds: GlobalContants.TIME_OUT)
      ..sendTimeout = Duration(seconds: GlobalContants.TIME_OUT)
      ..receiveTimeout = Duration(seconds: GlobalContants.TIME_OUT);

    _getInterceptor();
  }

  void _getInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          //注入token
          if(tokenManager.getToken().isNotEmpty)
          {
            request.headers = {
              "Authorization" : "Bearer ${tokenManager.getToken()}",
            };
          }
          handler.next(request);
        },
        onResponse: (response, handler) {
          if (response.statusCode! >= 200 && response.statusCode! < 300) {
            handler.next(response);
            return;
          }
          handler.reject(DioException(requestOptions: response.requestOptions));
        },
        onError: (error, handler) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              message: error.response?.data["msg"] ?? "",
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> get (String url, {Map<String, dynamic>? params}){
    return _handleResponse(_dio.get(url, queryParameters: params));
  }

  Future<dynamic> post (String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.post(url, data: data));
  }

  Future<dynamic> put (String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.put(url, data: data));
  }

  Future<dynamic> delete (String url, {Map<String, dynamic>? data}) {
    return _handleResponse(_dio.delete(url, data: data));
  }

  Future<dynamic> uploadFile (String url, {required MultipartFile file}) {
    FormData formData = FormData.fromMap({
      "file": file,
    });
    return _handleResponse(_dio.post(url, data: formData));
  }

  Future<dynamic> _handleResponse(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task;
      final data = res.data as Map<String, dynamic>;
      if(data["code"] == GlobalContants.SUCCESS_CODE) {
        return data["result"];
      }
      throw DioException(requestOptions: res.requestOptions ,
      message: data["msg"] ?? "加载数据失败");
    } catch (e) {
      rethrow;
    }
  } 
}

final dioRequest = DioRequest();
