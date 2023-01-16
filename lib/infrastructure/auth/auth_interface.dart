import '../apiUtil/response_wrapper.dart';
import 'model/login_response.dart';

abstract class AuthInterface {
  Future<ResponseWrapper<LoginResponse>> login({required String username, required String password,});
  Future<ResponseWrapper<bool>> resetPassword({required String password,});
  Future<ResponseWrapper<LoginResponse>> logout();
}
