// presentation/screens/orders/assigned_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:badges/badges.dart' as badges;

import '../../../bloc/delivery_orders/delivery_orders_bloc.dart';
import '../../../bloc/delivery_status/delivery_status_bloc.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/delivery_repository.dart';

class AssignedOrdersScreen extends StatelessWidget {
  const AssignedOrdersScreen({super.key});

  // Helper function to launch maps
  Future<void> _launchMaps(String address, BuildContext context) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryOrdersBloc(
        deliveryRepository: RepositoryProvider.of<DeliveryRepository>(context),
      )..add(FetchAssignedOrders()),
      child: BlocProvider<DeliveryStatusBloc>(
        create: (context) => DeliveryStatusBloc(
          deliveryRepository: RepositoryProvider.of<DeliveryRepository>(
            context,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'My Deliveries',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF2C3E50),
            elevation: 0,
            actions: [
              BlocBuilder<DeliveryOrdersBloc, DeliveryOrdersState>(
                builder: (context, state) {
                  if (state is DeliveryOrdersLoading) {
                    return IconButton(
                      icon: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      onPressed: null,
                    );
                  } else if (state is DeliveryOrdersLoaded ||
                      state is DeliveryOrdersInitial) {
                    return IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<DeliveryOrdersBloc>().add(
                        FetchAssignedOrders(),
                      ),
                    );
                  } else {
                    // Defensive: always return a widget
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2C3E50), Color(0xFF1E824C)],
              ),
            ),
            child: BlocListener<DeliveryStatusBloc, DeliveryStatusState>(
              listener: (context, state) {
                if (state is DeliveryStatusUpdateSuccess) {
                  // Refresh the list after a successful status update
                  context.read<DeliveryOrdersBloc>().add(FetchAssignedOrders());
                }
              },
              child: BlocBuilder<DeliveryOrdersBloc, DeliveryOrdersState>(
                builder: (context, state) {
                  if (state is DeliveryOrdersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  if (state is DeliveryOrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return Center(
                        child: Text(
                          'No jobs available.',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) {
                        final order = state.orders[index];
                        return _buildDeliveryCard(context, order);
                      },
                    );
                  }
                  // Handle other states
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          floatingActionButton:
              BlocBuilder<DeliveryOrdersBloc, DeliveryOrdersState>(
                builder: (context, state) {
                  int newOrdersCount = 0;
                  if (state is DeliveryOrdersLoaded) {
                    newOrdersCount = state.orders
                        .where((order) => order.status == 'Ready for Pickup')
                        .length;
                  }
                  return badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -10, end: -10),
                    showBadge: newOrdersCount > 0,
                    badgeContent: Text(
                      newOrdersCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/new-orders');
                      },
                      child: const Icon(Icons.delivery_dining),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, OrderModel order) {
    bool isReadyForPickup = order.status == 'Ready for Pickup';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.split('_').last}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryAddress,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${order.status}',
                  style: GoogleFonts.poppins(
                    color: Colors.amber.shade300,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    color: Colors.green.shade300,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isReadyForPickup
                    ? () => _launchMaps(order.deliveryAddress, context)
                    : null,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate to Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReadyForPickup
                      ? Colors.blue.shade600
                      : Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Add status update buttons here later
          ],
        ),
      ),
    );
  }
}
