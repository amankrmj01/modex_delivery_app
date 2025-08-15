part of 'delivery_auth_bloc.dart';

abstract class DeliveryAuthState extends Equatable {
  const DeliveryAuthState();

  @override
  List<Object?> get props => [];
}

class DeliveryAuthInitial extends DeliveryAuthState {}

class DeliveryAuthLoading extends DeliveryAuthState {}

class DeliveryAuthSuccess extends DeliveryAuthState {
  final String partnerId;

  const DeliveryAuthSuccess({required this.partnerId});

  @override
  List<Object?> get props => [partnerId];
}

class DeliveryAuthFailure extends DeliveryAuthState {
  final String error;

  const DeliveryAuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
