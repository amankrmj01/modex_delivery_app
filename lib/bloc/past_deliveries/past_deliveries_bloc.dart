import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/my_past_deliveries_repository.dart';
import 'past_deliveries_event.dart';
import 'past_deliveries_state.dart';

class PastDeliveriesBloc
    extends Bloc<PastDeliveriesEvent, PastDeliveriesState> {
  final MyPastDeliveriesRepository repository;

  PastDeliveriesBloc({required this.repository})
    : super(PastDeliveriesInitial()) {
    on<LoadPastDeliveries>((event, emit) async {
      emit(PastDeliveriesLoading());
      try {
        final deliveries = repository.getPastDeliveries();
        emit(PastDeliveriesLoaded(deliveries));
      } catch (e) {
        emit(PastDeliveriesError('Failed to load past deliveries'));
      }
    });

    on<AddPastDelivery>((event, emit) async {
      repository.addPastDelivery(event.order);
      final deliveries = repository.getPastDeliveries();
      emit(PastDeliveriesLoaded(deliveries));
    });
  }
}
