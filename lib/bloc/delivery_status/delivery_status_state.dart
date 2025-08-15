part of 'delivery_status_bloc.dart';

abstract class DeliveryStatusState extends Equatable {
  const DeliveryStatusState();

  @override
  List<Object> get props => [];
}

class DeliveryStatusInitial extends DeliveryStatusState {}

class DeliveryStatusUpdateInProgress extends DeliveryStatusState {
  final String orderId;

  const DeliveryStatusUpdateInProgress(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class DeliveryStatusUpdateSuccess extends DeliveryStatusState {
  final String orderId;

  const DeliveryStatusUpdateSuccess(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class DeliveryStatusUpdateFailure extends DeliveryStatusState {
  final String message;

  const DeliveryStatusUpdateFailure(this.message);

  @override
  List<Object> get props => [message];
}
