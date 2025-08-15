// ----------------------------------------------------------------
// data/repositories/delivery_repository.dart
import '../models/order_model.dart';

class DeliveryRepository {
  // Track when preparation started for each order
  final Map<String, DateTime> _preparationStartTimes = {};

  // Simulated backend data - in real app this would be API calls
  final List<OrderModel> _newOrders = [
    OrderModel(
      id: 'ord_new_001',
      userId: 'user_999',
      status: 'Pending Acceptance',
      totalPrice: 22.50,
      deliveryAddress: 'No. 12, TTK Road, Alwarpet, Chennai, Tamil Nadu 600018',
      restaurantAddress:
          'Saravana Bhavan, No. 20, North Usman Road, T. Nagar, Chennai, Tamil Nadu 600017',
      items: [],
      date: DateTime.now(),
      preparationTime: Duration(minutes: 25),
    ),
    OrderModel(
      id: 'ord_new_002',
      userId: 'user_888',
      status: 'Pending Acceptance',
      totalPrice: 35.75,
      deliveryAddress:
          'No. 5, Gandhi Irwin Road, Egmore, Chennai, Tamil Nadu 600008',
      restaurantAddress:
          'Anjappar Chettinad Restaurant, No. 77, Nungambakkam High Rd, Chennai, Tamil Nadu 600034',
      items: [],
      date: DateTime.now(),
      preparationTime: Duration(minutes: 30),
    ),
  ];

  final List<OrderModel> _assignedOrders = [
    OrderModel(
      id: 'ord_1001',
      userId: 'user_123',
      status: 'Assigned',
      totalPrice: 27.49,
      deliveryAddress:
          'No. 18, Cathedral Road, Gopalapuram, Chennai, Tamil Nadu 600086',
      restaurantAddress:
          'Sangeetha Veg Restaurant, No. 27, Dr. Radhakrishnan Salai, Mylapore, Chennai, Tamil Nadu 600004',
      items: [],
      date: DateTime.now(),
      preparationTime: Duration(minutes: 1),
    ),
    OrderModel(
      id: 'ord_1002',
      userId: 'user_456',
      status: 'Assigned',
      totalPrice: 32.75,
      items: [],
      deliveryAddress:
          'No. 3, College Road, Nungambakkam, Chennai, Tamil Nadu 600006',
      restaurantAddress:
          'Aasife Biriyani, No. 1, Sterling Road, Nungambakkam, Chennai, Tamil Nadu 600034',
      date: DateTime.now(),
      preparationTime: Duration(minutes: 20),
    ),
  ];

  final List<OrderModel> _activeOrders = [];
  final List<OrderModel> _pastOrders = [];

  // Constructor - initialize preparation start times for existing assigned orders
  DeliveryRepository() {
    // Set preparation start times for orders that are already assigned
    for (final order in _assignedOrders) {
      if (order.status == 'Assigned') {
        _preparationStartTimes[order.id] = DateTime.now().subtract(
          Duration(minutes: 2), // Simulate orders started 2 minutes ago
        );
      }
    }
  }

  // Calculate remaining preparation time for an order
  Duration? getRemainingPreparationTime(String orderId) {
    final startTime = _preparationStartTimes[orderId];
    if (startTime == null) return null;

    final order = _assignedOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => OrderModel(
        id: '',
        userId: '',
        status: '',
        totalPrice: 0,
        deliveryAddress: '',
        items: [],
        date: DateTime.now(),
      ),
    );

    if (order.id.isEmpty || order.preparationTime == null) return null;

    final elapsed = DateTime.now().difference(startTime);
    final remaining = order.preparationTime! - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Check and auto-move orders that are ready
  void _checkAndMoveReadyOrders() {
    final ordersToMove = <OrderModel>[];

    for (final order in List.from(_assignedOrders)) {
      final remaining = getRemainingPreparationTime(order.id);
      if (remaining != null && remaining <= Duration.zero) {
        // Order is ready - move to active orders
        ordersToMove.add(order.copyWith(status: 'Ready for Pickup'));
      }
    }

    // Move ready orders to active orders
    for (final readyOrder in ordersToMove) {
      _assignedOrders.removeWhere((o) => o.id == readyOrder.id);
      _activeOrders.add(readyOrder);
    }
  }

  // Fetch new orders available for acceptance
  Future<List<OrderModel>> fetchNewOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    return List<OrderModel>.from(_newOrders);
  }

  // Fetch orders assigned to delivery partner
  Future<List<OrderModel>> fetchAssignedOrders() async {
    await Future.delayed(const Duration(seconds: 1));

    // Check and auto-move ready orders before returning
    _checkAndMoveReadyOrders();

    return List<OrderModel>.from(_assignedOrders);
  }

  // Fetch orders that are picked up and being delivered
  Future<List<OrderModel>> fetchActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Check and auto-move ready orders before returning
    _checkAndMoveReadyOrders();

    return List<OrderModel>.from(_activeOrders);
  }

  // Fetch completed deliveries
  Future<List<OrderModel>> fetchPastOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<OrderModel>.from(_pastOrders);
  }

  // Accept a new order - moves from new to assigned
  Future<void> acceptOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newIndex = _newOrders.indexWhere((order) => order.id == orderId);
    if (newIndex == -1) {
      throw Exception('Order not found in new orders');
    }

    final order = _newOrders[newIndex];
    final assignedOrder = order.copyWith(status: 'Assigned');

    // Start preparation timer when order is assigned
    _preparationStartTimes[orderId] = DateTime.now();

    _assignedOrders.add(assignedOrder);
    _newOrders.removeAt(newIndex);
  }

  // Reject a new order - removes it completely
  Future<void> rejectOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newIndex = _newOrders.indexWhere((order) => order.id == orderId);
    if (newIndex != -1) {
      _newOrders.removeAt(newIndex);
    }
  }

  // Mark order as picked up from restaurant - moves from assigned/active to active
  Future<void> pickupOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // First check if it's in assigned orders
    final assignedIndex = _assignedOrders.indexWhere(
      (order) => order.id == orderId,
    );
    if (assignedIndex != -1) {
      final order = _assignedOrders[assignedIndex];
      final pickedUpOrder = order.copyWith(status: 'Picked Up');

      _activeOrders.add(pickedUpOrder);
      _assignedOrders.removeAt(assignedIndex);
      _preparationStartTimes.remove(orderId); // Clean up timer
      return;
    }

    // Otherwise check if it's already in active orders (status update)
    final activeIndex = _activeOrders.indexWhere(
      (order) => order.id == orderId,
    );
    if (activeIndex != -1) {
      _activeOrders[activeIndex] = _activeOrders[activeIndex].copyWith(
        status: 'Picked Up',
      );
      return;
    }

    throw Exception('Order not found in assigned or active orders');
  }

  // Mark order as delivered - moves from active to past
  Future<void> deliverOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final activeIndex = _activeOrders.indexWhere(
      (order) => order.id == orderId,
    );
    if (activeIndex == -1) {
      throw Exception('Order not found in active orders');
    }

    final order = _activeOrders[activeIndex];
    final deliveredOrder = order.copyWith(
      status: 'Delivered',
      deliveredAt: DateTime.now(),
    );

    _pastOrders.add(deliveredOrder);
    _activeOrders.removeAt(activeIndex);
  }

  // Update order status when preparation time is over (legacy method - now automated)
  Future<void> markOrderReady(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // This is now handled automatically by _checkAndMoveReadyOrders()
    // But keeping for backward compatibility
    _checkAndMoveReadyOrders();
  }
}
