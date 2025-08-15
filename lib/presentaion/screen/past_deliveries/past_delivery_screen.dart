import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/past_deliveries/past_deliveries_bloc.dart';
import '../../../bloc/past_deliveries/past_deliveries_event.dart';
import '../../../bloc/past_deliveries/past_deliveries_state.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/my_past_deliveries_repository.dart';

class PastDeliveryScreen extends StatelessWidget {
  const PastDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PastDeliveriesBloc>(
      create: (context) => PastDeliveriesBloc(
        repository: RepositoryProvider.of<MyPastDeliveriesRepository>(context),
      )..add(LoadPastDeliveries()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Past Deliveries',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<PastDeliveriesBloc, PastDeliveriesState>(
              builder: (context, state) {
                if (state is PastDeliveriesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PastDeliveriesLoaded) {
                  if (state.deliveries.isEmpty) {
                    return Center(
                      child: Text(
                        'No past deliveries found.',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.deliveries.length,
                    itemBuilder: (context, index) {
                      final OrderModel order = state.deliveries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'User ID: ${order.userId}',
                                style: GoogleFonts.montserrat(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Address: ${order.deliveryAddress}',
                                style: GoogleFonts.montserrat(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Delivered on: ${_formatDate(order.date)}',
                                style: GoogleFonts.montserrat(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is PastDeliveriesError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
