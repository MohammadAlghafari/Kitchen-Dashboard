import 'dart:convert';

class LoginResponse {
  String? apiToken;
  String? kitchenName;
  bool? resetPassword;
  LoginResponse({
    this.apiToken,
    this.kitchenName,
    this.resetPassword,
  });

  LoginResponse copyWith({
    String? apiToken,
    String? kitchenName,
    bool? resetPassword,
  }) {
    return LoginResponse(
      apiToken: apiToken ?? this.apiToken,
      kitchenName: kitchenName ?? this.kitchenName,
      resetPassword: resetPassword ?? this.resetPassword,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (apiToken != null) {
      result.addAll({'token': apiToken});
    }
    if (kitchenName != null) {
      result.addAll({'kitchen_name': kitchenName});
    }
    if (resetPassword != null) {
      result.addAll({'reset_password': resetPassword});
    }
    return result;
  }

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    if (map.isNotEmpty) {
      return LoginResponse(
        apiToken: map['token'].toString() ?? '',
        kitchenName: map['kitchen_name'].toString() ?? '',
        resetPassword: map['reset_password'] ?? false,
      );
    }
    return LoginResponse(apiToken: '', kitchenName: '');
  }

  String toJson() => json.encode(toMap());

  factory LoginResponse.fromJson(String source) =>
      LoginResponse.fromMap(json.decode(source));

  @override
  String toString() =>
      'LoginResponse(apiToken: $apiToken, kitchenName: $kitchenName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginResponse &&
        other.apiToken == apiToken &&
        other.kitchenName == kitchenName;
  }

  @override
  int get hashCode => apiToken.hashCode ^ kitchenName.hashCode;
}
