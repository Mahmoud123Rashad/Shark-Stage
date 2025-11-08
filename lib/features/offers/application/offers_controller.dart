import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exceptions.dart';
import '../data/offers_repository.dart';
import '../domain/offer.dart';
import 'offers_state.dart';

final StateNotifierProvider<OffersController, OffersState>
    offersControllerProvider =
    StateNotifierProvider<OffersController, OffersState>((Ref ref) {
  return OffersController(
    repository: ref.watch(offersRepositoryProvider),
  )..load();
});

class OffersController extends StateNotifier<OffersState> {
  OffersController({required OffersRepository repository})
      : _repository = repository,
        super(const OffersState(loading: true));

  final OffersRepository _repository;

  Future<void> load() async {
    try {
      state = state.copyWith(loading: true, error: null);
      final List<Offer> sent = await _repository.fetchSent();
      final List<Offer> received = await _repository.fetchReceived();
      state = state.copyWith(
        sent: sent,
        received: received,
        loading: false,
      );
    } on NetworkException catch (error) {
      state = state.copyWith(
        loading: false,
        error: error.message,
      );
    }
  }

  Future<void> accept(String offerId) async {
    await _repository.acceptOffer(offerId);
    state = state.copyWith(
      received: state.received
          .map(
            (Offer offer) => offer.id == offerId
                ? offer.copyWith(status: 'accepted')
                : offer,
          )
          .toList(),
    );
  }

  Future<void> reject(String offerId) async {
    await _repository.rejectOffer(offerId);
    state = state.copyWith(
      received: state.received
          .map(
            (Offer offer) => offer.id == offerId
                ? offer.copyWith(status: 'rejected')
                : offer,
          )
          .toList(),
    );
  }

  Future<void> cancel(String offerId) async {
    await _repository.cancelOffer(offerId);
    state = state.copyWith(
      sent: state.sent
          .map(
            (Offer offer) =>
                offer.id == offerId ? offer.copyWith(status: 'cancelled') : offer,
          )
          .toList(),
    );
  }
}

