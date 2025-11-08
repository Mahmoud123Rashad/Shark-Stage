import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    @JsonKey(name: '_id') required String id,
    @Default('') String email,
    @Default('investor') String accountType,
    String? firstName,
    String? lastName,
    String? profilePicUrl,
    String? company,
    String? phone,
    String? bio,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
