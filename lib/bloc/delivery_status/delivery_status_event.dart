part of 'delivery_status_bloc.dart';

// Events
abstract class DeliveryStatusEvent extends Equatable {
  const DeliveryStatusEvent();

  @override
  List<Object> get props => [];
}

class UpdateDeliveryStatus extends DeliveryStatusEvent {
  final String orderId;
  final String status;

  const UpdateDeliveryStatus(this.orderId, this.status);

  @override
  List<Object> get props => [orderId, status];
}
