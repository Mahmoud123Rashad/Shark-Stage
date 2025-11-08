import 'package:freezed_annotation/freezed_annotation.dart';

import '../../auth/domain/app_user.dart';
import '../../projects/domain/project.dart';

part 'offer.freezed.dart';
part 'offer.g.dart';

@freezed
class Offer with _$Offer {
  const factory Offer({
    @JsonKey(name: '_id') required String id,
    required String status,
    @Default(0) double amount,
    DateTime? createdAt,
    Project? project,
    AppUser? offeredBy,
    AppUser? offeredTo,
    String? terms,
    String? message,
  }) = _Offer;

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);
}
