import '../../data/models/order_model.dart';

abstract class PastDeliveriesState {}

class PastDeliveriesInitial extends PastDeliveriesState {}

class PastDeliveriesLoading extends PastDeliveriesState {}

class PastDeliveriesLoaded extends PastDeliveriesState {
  final List<OrderModel> deliveries;

  PastDeliveriesLoaded(this.deliveries);
}

class PastDeliveriesError extends PastDeliveriesState {
  final String message;

  PastDeliveriesError(this.message);
}
