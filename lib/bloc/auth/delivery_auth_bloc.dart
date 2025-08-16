import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/delivery_auth_repository.dart';
import 'package:equatable/equatable.dart';

part 'delivery_auth_event.dart';

part 'delivery_auth_state.dart';

class DeliveryAuthBloc extends Bloc<DeliveryAuthEvent, DeliveryAuthState> {
  final DeliveryAuthRepository authRepository;

  DeliveryAuthBloc({required this.authRepository})
    : super(DeliveryAuthInitial()) {
    on<DeliveryLoginRequested>(_onLoginRequested);
  }

  void _onLoginRequested(
    DeliveryLoginRequested event,
    Emitter<DeliveryAuthState> emit,
  ) async {
    emit(DeliveryAuthLoading());
    try {
      final partnerId = await authRepository.login(event.email, event.password);
      emit(DeliveryAuthSuccess(partnerId: partnerId));
    } catch (e) {
      emit(DeliveryAuthFailure(error: e.toString()));
    }
  }
}
