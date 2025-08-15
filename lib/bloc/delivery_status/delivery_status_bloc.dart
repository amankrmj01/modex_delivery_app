import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/delivery_repository.dart';

part 'delivery_status_event.dart';

part 'delivery_status_state.dart';

// BLoC
class DeliveryStatusBloc
    extends Bloc<DeliveryStatusEvent, DeliveryStatusState> {
  final DeliveryRepository deliveryRepository;

  DeliveryStatusBloc({required this.deliveryRepository})
    : super(DeliveryStatusInitial()) {
    on<UpdateDeliveryStatus>((
      UpdateDeliveryStatus event,
      Emitter<DeliveryStatusState> emit,
    ) async {
      emit(DeliveryStatusUpdateInProgress(event.orderId));
      try {
        await deliveryRepository.updateOrderStatus(event.orderId, event.status);
        // Move to past deliveries if status is Delivered
        if (event.status == 'Delivered') {
          final deliveredOrder = deliveryRepository.getOrderById(event.orderId);
        }
        emit(DeliveryStatusUpdateSuccess(event.orderId));
      } catch (e) {
        emit(DeliveryStatusUpdateFailure(e.toString()));
      }
    });
  }
}
