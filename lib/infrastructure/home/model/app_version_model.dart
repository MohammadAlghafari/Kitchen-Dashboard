import 'dart:convert';

class AppVersionModel {
  String appVersion;
  String appDownloadUrl;
  AppVersionModel({
    required this.appVersion,
    required this.appDownloadUrl,
  });

  AppVersionModel copyWith({
    String? appVersion,
    String? appDownloadUrl,
  }) {
    return AppVersionModel(
      appVersion: appVersion ?? this.appVersion,
      appDownloadUrl: appDownloadUrl ?? this.appDownloadUrl,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'version': appVersion});
    result.addAll({'url': appDownloadUrl});
  
    return result;
  }

  factory AppVersionModel.fromMap(Map<String, dynamic> map) {
    return AppVersionModel(
      appVersion: map['version'].toString() ?? '',
      appDownloadUrl: map['url'].toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppVersionModel.fromJson(String source) => AppVersionModel.fromMap(json.decode(source));

  @override
  String toString() => 'AppVersionModel(appVersion: $appVersion, appDownloadUrl: $appDownloadUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AppVersionModel &&
      other.appVersion == appVersion &&
      other.appDownloadUrl == appDownloadUrl;
  }

  @override
  int get hashCode => appVersion.hashCode ^ appDownloadUrl.hashCode;
}
