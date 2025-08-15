import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNewOrders extends OrderEvent {}

class FetchAssignedOrders extends OrderEvent {}

class FetchActiveOrders extends OrderEvent {}

class FetchPastOrders extends OrderEvent {}

class AcceptOrder extends OrderEvent {
  final String orderId;

  AcceptOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RejectOrder extends OrderEvent {
  final String orderId;

  RejectOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderPreparationTimeOver extends OrderEvent {
  final String orderId;

  OrderPreparationTimeOver(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderPickedUp extends OrderEvent {
  final String orderId;

  OrderPickedUp(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderDelivered extends OrderEvent {
  final String orderId;

  OrderDelivered(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
