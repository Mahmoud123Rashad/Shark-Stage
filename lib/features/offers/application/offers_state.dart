import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/offer.dart';

part 'offers_state.freezed.dart';

@freezed
class OffersState with _$OffersState {
  const factory OffersState({
    @Default(<Offer>[]) List<Offer> sent,
    @Default(<Offer>[]) List<Offer> received,
    @Default(false) bool loading,
    String? error,
  }) = _OffersState;
}

