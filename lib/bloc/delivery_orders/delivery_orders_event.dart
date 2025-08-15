part of 'delivery_orders_bloc.dart';

// DeliveryOrdersEvent is the base class for all delivery order events.
abstract class DeliveryOrdersEvent extends Equatable {
  const DeliveryOrdersEvent();

  @override
  List<Object?> get props => [];
}

// Event to fetch assigned orders.
class FetchAssignedOrders extends DeliveryOrdersEvent {}

// Event to accept an order.
class AcceptOrder extends DeliveryOrdersEvent {
  final String orderId;

  const AcceptOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

// Event to reject an order.
class RejectOrder extends DeliveryOrdersEvent {
  final String orderId;

  const RejectOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
