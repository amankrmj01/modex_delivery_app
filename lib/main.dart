import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modex_delivery_app/presentaion/screen/auth/delivery_login_screen.dart';
import 'package:modex_delivery_app/presentaion/screen/home/home_screen.dart';
import 'bloc/auth/delivery_auth_bloc.dart';
import 'data/repositories/delivery_auth_repository.dart';
import 'data/repositories/delivery_repository.dart';
import 'bloc/order/order_bloc.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DeliveryAuthRepository>(
          create: (context) => DeliveryAuthRepository(),
        ),
        RepositoryProvider<DeliveryRepository>(
          create: (context) => DeliveryRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DeliveryAuthBloc(
              authRepository: RepositoryProvider.of<DeliveryAuthRepository>(
                context,
              ),
            ),
          ),
          BlocProvider(
            create: (context) => OrderBloc(
              deliveryRepository: RepositoryProvider.of<DeliveryRepository>(
                context,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Delivery Partner',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          home: DeliveryLoginScreen(),
          routes: {'/orders': (context) => const HomeScreen()},
        ),
      ),
    );
  }
}
