import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'order_event.dart';
import 'order_state.dart';
import '../../data/repositories/delivery_repository.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final DeliveryRepository deliveryRepository;
  Timer? _autoRefreshTimer;

  OrderBloc({required this.deliveryRepository}) : super(OrderInitial()) {
    on<FetchNewOrders>(_onFetchNewOrders);
    on<FetchAssignedOrders>(_onFetchAssignedOrders);
    on<FetchActiveOrders>(_onFetchActiveOrders);
    on<FetchPastOrders>(_onFetchPastOrders);
    on<AcceptOrder>(_onAcceptOrder);
    on<RejectOrder>(_onRejectOrder);
    on<OrderPreparationTimeOver>(_onOrderPreparationTimeOver);
    on<OrderPickedUp>(_onOrderPickedUp);
    on<OrderDelivered>(_onOrderDelivered);

    // Start auto-refresh timer to check for orders that moved between tabs
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Silently refresh current tab data to catch auto-moved orders
      _silentRefresh();
    });
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }

  // Silent refresh to update order lists without showing loading
  Future<void> _silentRefresh() async {
    try {
      if (state is AssignedOrdersLoaded) {
        add(FetchAssignedOrders());
      } else if (state is ActiveOrdersLoaded) {
        add(FetchActiveOrders());
      }
    } catch (e) {
      // Ignore errors during silent refresh
    }
  }

  Future<void> _onFetchNewOrders(
    FetchNewOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await deliveryRepository.fetchNewOrders();
      emit(NewOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onFetchAssignedOrders(
    FetchAssignedOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await deliveryRepository.fetchAssignedOrders();
      emit(AssignedOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onFetchActiveOrders(
    FetchActiveOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await deliveryRepository.fetchActiveOrders();
      emit(ActiveOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onFetchPastOrders(
    FetchPastOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await deliveryRepository.fetchPastOrders();
      emit(PastOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onAcceptOrder(
    AcceptOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await deliveryRepository.acceptOrder(event.orderId);
      emit(OrderAcceptSuccess());
      // Refresh new orders list
      final orders = await deliveryRepository.fetchNewOrders();
      emit(NewOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onRejectOrder(
    RejectOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await deliveryRepository.rejectOrder(event.orderId);
      emit(OrderRejectSuccess());
      // Refresh new orders list
      final orders = await deliveryRepository.fetchNewOrders();
      emit(NewOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onOrderPreparationTimeOver(
    OrderPreparationTimeOver event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await deliveryRepository.markOrderReady(event.orderId);
      // Refresh assigned orders to show updated status
      final orders = await deliveryRepository.fetchAssignedOrders();
      emit(AssignedOrdersLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onOrderPickedUp(
    OrderPickedUp event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await deliveryRepository.pickupOrder(event.orderId);
      emit(OrderPickupSuccess());
      // Refresh assigned orders
      final assignedOrders = await deliveryRepository.fetchAssignedOrders();
      emit(AssignedOrdersLoaded(orders: assignedOrders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onOrderDelivered(
    OrderDelivered event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await deliveryRepository.deliverOrder(event.orderId);
      emit(OrderDeliverySuccess());
      // Refresh active orders
      final activeOrders = await deliveryRepository.fetchActiveOrders();
      emit(ActiveOrdersLoaded(orders: activeOrders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }
}
