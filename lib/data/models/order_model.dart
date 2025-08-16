import 'package:equatable/equatable.dart';

class CartItemModel extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderModel extends Equatable {
  final String id;
  final String userId;
  final String status;
  final double totalPrice;
  final String deliveryAddress;
  final List<CartItemModel> items;
  final DateTime date;
  final Duration? preparationTime;
  final String? restaurantAddress;
  final DateTime? deliveryDate;
  final DateTime? deliveredAt;
  final double? totalAmount;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.deliveryAddress,
    required this.items,
    required this.date,
    this.preparationTime,
    this.restaurantAddress,
    this.deliveryDate,
    this.deliveredAt,
    this.totalAmount,
  });

  OrderModel copyWith({
    String? status,
    Duration? preparationTime,
    String? restaurantAddress,
    DateTime? deliveryDate,
    DateTime? deliveredAt,
    double? totalAmount,
  }) {
    return OrderModel(
      id: id,
      userId: userId,
      status: status ?? this.status,
      totalPrice: totalPrice,
      deliveryAddress: deliveryAddress,
      items: items,
      date: date,
      preparationTime: preparationTime ?? this.preparationTime,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    totalPrice,
    deliveryAddress,
    items,
    date,
    preparationTime,
    restaurantAddress,
    deliveryDate,
    deliveredAt,
    totalAmount,
  ];
}
