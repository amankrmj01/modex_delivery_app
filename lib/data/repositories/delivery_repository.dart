// ----------------------------------------------------------------
// data/repositories/delivery_repository.dart
import '../models/order_model.dart';

class DeliveryRepository {
  // Use a stateful list to simulate a real backend database for the session
  final List<OrderModel> _assignedOrders = [
    OrderModel(
      id: 'ord_1001',
      userId: 'user_123',
      status: 'Ready for Pickup',
      totalPrice: 27.49,
      deliveryAddress: '1600 Amphitheatre Parkway, Mountain View, CA',
      items: [],
      date: DateTime.now(),
    ),
    OrderModel(
      id: 'ord_1003',
      userId: 'user_789',
      status: 'Ready for Pickup',
      totalPrice: 45.50,
      deliveryAddress: '1 Infinite Loop, Cupertino, CA',
      items: [],
      date: DateTime.now(),
    ),
    OrderModel(
      id: 'ord_1004',
      userId: 'user_ABC',
      status: 'Out for Delivery',
      totalPrice: 15.25,
      deliveryAddress: '24 Willie Mays Plaza, San Francisco, CA',
      items: [],
      date: DateTime.now(),
    ),
  ];
  final List<OrderModel> _activeOrders = [];
  final List<OrderModel> _pastDeliveries = [];

  Future<List<OrderModel>> fetchAssignedOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    // Only orders that are not accepted or delivered
    return _assignedOrders
        .where((order) => order.status == 'Ready for Pickup')
        .toList();
  }

  Future<List<OrderModel>> fetchActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _activeOrders.where((order) => order.status != 'Delivered').toList();
  }

  Future<List<OrderModel>> fetchPastDeliveries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<OrderModel>.from(_pastDeliveries);
  }

  Future<void> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _assignedOrders.indexWhere(
      (order) => order.id == orderId && order.status == 'Ready for Pickup',
    );
    if (index != -1) {
      final acceptedOrder = _assignedOrders[index].copyWith(status: 'Accepted');
      _activeOrders.add(acceptedOrder);
      _assignedOrders.removeAt(index);
    } else {
      throw Exception('Order not found or not ready for pickup');
    }
  }

  Future<void> pickUpOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _activeOrders.indexWhere(
      (order) => order.id == orderId && order.status == 'Accepted',
    );
    if (index != -1) {
      _activeOrders[index] = _activeOrders[index].copyWith(status: 'Picked Up');
    } else {
      throw Exception('Order not found or not accepted');
    }
  }

  Future<void> deliverOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _activeOrders.indexWhere(
      (order) => order.id == orderId && order.status == 'Picked Up',
    );
    if (index != -1) {
      final deliveredOrder = _activeOrders[index].copyWith(status: 'Delivered');
      _pastDeliveries.add(deliveredOrder);
      _activeOrders.removeAt(index);
    } else {
      throw Exception('Order not found or not picked up');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // Try to update in assigned orders
    final assignedIndex = _assignedOrders.indexWhere((o) => o.id == orderId);
    if (assignedIndex != -1) {
      _assignedOrders[assignedIndex] = _assignedOrders[assignedIndex].copyWith(
        status: newStatus,
      );
      return;
    }
    // Try to update in active orders
    final activeIndex = _activeOrders.indexWhere((o) => o.id == orderId);
    if (activeIndex != -1) {
      _activeOrders[activeIndex] = _activeOrders[activeIndex].copyWith(
        status: newStatus,
      );
      return;
    }
    throw Exception('Order not found');
  }

  OrderModel? getOrderById(String orderId) {
    final assigned = _assignedOrders.where((o) => o.id == orderId);
    if (assigned.isNotEmpty) return assigned.first;
    final active = _activeOrders.where((o) => o.id == orderId);
    if (active.isNotEmpty) return active.first;
    final past = _pastDeliveries.where((o) => o.id == orderId);
    if (past.isNotEmpty) return past.first;
    return null;
  }

  Future<void> rejectOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _assignedOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _assignedOrders.removeAt(index);
    } else {
      throw Exception('Order not found');
    }
  }
}
