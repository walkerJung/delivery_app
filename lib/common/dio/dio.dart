import 'package:delivery_app/common/const/data.dart';
import 'package:delivery_app/common/secure_storage/secure_storage.dart';
import 'package:delivery_app/user/provider/user_me_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>(
  (ref) {
    final dio = Dio();
    final storage = ref.watch(secureStorageProvider);

    dio.interceptors.add(CustomInterceptor(
      storage: storage,
      ref: ref,
    ));
    return dio;
  },
);

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({required this.storage, required this.ref});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      options.headers.addAll({'authorization': 'Bearer $token'});
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    if (refreshToken == null) {
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/auth/token';

    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      try {
        final resp = await dio.post(
          'http://$ip/suth/token',
          options: Options(
            headers: {
              'authorization': 'Bearer $refreshToken',
            },
          ),
        );

        final accessToken = resp.data['accessToken'];
        final options = err.requestOptions;

        options.headers.addAll(
          {
            'authorization': 'Bearer $accessToken',
          },
        );

        await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        ref.read(userMeProvider.notifier).logout();

        return handler.reject(err);
      }
    }
    return handler.reject(err);
  }
}
