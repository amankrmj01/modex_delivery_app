part of 'delivery_orders_bloc.dart';

// DeliveryOrdersState is the base class for all delivery order states.
abstract class DeliveryOrdersState extends Equatable {
  const DeliveryOrdersState();

  @override
  List<Object?> get props => [];
}

// Initial state before any orders are loaded.
class DeliveryOrdersInitial extends DeliveryOrdersState {}

// State when orders are being loaded.
class DeliveryOrdersLoading extends DeliveryOrdersState {}

// State when orders are successfully loaded.
class DeliveryOrdersLoaded extends DeliveryOrdersState {
  final List<OrderModel> orders;

  const DeliveryOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

// State when there is an error loading orders.
class DeliveryOrdersError extends DeliveryOrdersState {
  final String message;

  const DeliveryOrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}

// State when an order is being updated (accept/reject).
class DeliveryOrderUpdating extends DeliveryOrdersState {
  final String orderId;

  const DeliveryOrderUpdating({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// State when an order update succeeds.
class DeliveryOrderUpdateSuccess extends DeliveryOrdersState {
  final String orderId;
  final String newStatus;

  const DeliveryOrderUpdateSuccess({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}

// State when an order update fails.
class DeliveryOrderUpdateError extends DeliveryOrdersState {
  final String orderId;
  final String message;

  const DeliveryOrderUpdateError({
    required this.orderId,
    required this.message,
  });

  @override
  List<Object?> get props => [orderId, message];
}
