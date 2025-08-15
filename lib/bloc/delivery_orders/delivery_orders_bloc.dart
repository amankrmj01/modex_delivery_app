import 'package:bloc/bloc.dart';

import '../../data/models/order_model.dart';
import '../../data/repositories/delivery_repository.dart';
import 'package:equatable/equatable.dart';

part 'delivery_orders_event.dart';

part 'delivery_orders_state.dart';

// DeliveryOrdersBloc handles fetching assigned orders and emits states accordingly.
class DeliveryOrdersBloc
    extends Bloc<DeliveryOrdersEvent, DeliveryOrdersState> {
  final DeliveryRepository deliveryRepository;

  DeliveryOrdersBloc({required this.deliveryRepository})
      : super(DeliveryOrdersInitial()) {
    on<FetchAssignedOrders>((event, emit) async {
      emit(DeliveryOrdersLoading());
      try {
        final orders = await deliveryRepository.fetchAssignedOrders();
        emit(DeliveryOrdersLoaded(orders: orders));
      } catch (e) {
        emit(DeliveryOrdersError(message: e.toString()));
      }
    });
    on<AcceptOrder>((event, emit) async {
      emit(DeliveryOrderUpdating(orderId: event.orderId));
      try {
        await deliveryRepository.acceptOrder(event.orderId);
        emit(DeliveryOrderUpdateSuccess(
            orderId: event.orderId, newStatus: 'Accepted'));
        // Optionally, refresh the orders list
        final orders = await deliveryRepository.fetchAssignedOrders();
        emit(DeliveryOrdersLoaded(orders: orders));
      } catch (e) {
        emit(DeliveryOrderUpdateError(
            orderId: event.orderId, message: e.toString()));
      }
    });

    on<RejectOrder>((event, emit) async {
      emit(DeliveryOrderUpdating(orderId: event.orderId));
      try {
        await deliveryRepository.rejectOrder(event.orderId);
        emit(DeliveryOrderUpdateSuccess(
            orderId: event.orderId, newStatus: 'Rejected'));
        // Optionally, refresh the orders list
        final orders = await deliveryRepository.fetchAssignedOrders();
        emit(DeliveryOrdersLoaded(orders: orders));
      } catch (e) {
        emit(DeliveryOrderUpdateError(
            orderId: event.orderId, message: e.toString()));
      }
    });
    // Add more event handlers here as needed for extensibility.
  }
}
