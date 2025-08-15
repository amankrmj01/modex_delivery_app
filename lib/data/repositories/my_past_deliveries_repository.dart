import '../models/order_model.dart';

class MyPastDeliveriesRepository {
  final List<OrderModel> _pastDeliveries = [];

  List<OrderModel> getPastDeliveries() {
    return List.unmodifiable(_pastDeliveries);
  }

  void addPastDelivery(OrderModel order) {
    if (order.status == 'Delivered') {
      _pastDeliveries.add(order);
    }
  }

  void addPastDeliveries(List<OrderModel> orders) {
    _pastDeliveries.addAll(
      orders.where((order) => order.status == 'Delivered'),
    );
  }

  void clear() {
    _pastDeliveries.clear();
  }
}
