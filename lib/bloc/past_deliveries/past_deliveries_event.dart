import '../../data/models/order_model.dart';

abstract class PastDeliveriesEvent {}

class LoadPastDeliveries extends PastDeliveriesEvent {}

class AddPastDelivery extends PastDeliveriesEvent {
  final OrderModel order;

  AddPastDelivery(this.order);
}
