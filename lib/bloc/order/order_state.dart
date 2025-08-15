import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class NewOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  NewOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class AssignedOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  AssignedOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class ActiveOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  ActiveOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class PastOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  PastOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderAcceptSuccess extends OrderState {}

class OrderRejectSuccess extends OrderState {}

class OrderPickupSuccess extends OrderState {}

class OrderDeliverySuccess extends OrderState {}

class OrderError extends OrderState {
  final String message;

  OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
