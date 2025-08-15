import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/order/order_bloc.dart';
import '../../../bloc/order/order_event.dart';
import '../../../bloc/order/order_state.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/delivery_repository.dart';

class AssignedOrdersScreen extends StatefulWidget {
  const AssignedOrdersScreen({super.key});

  @override
  State<AssignedOrdersScreen> createState() => _AssignedOrdersScreenState();
}

class _AssignedOrdersScreenState extends State<AssignedOrdersScreen> {
  // ─────────────  CONSTANT PALETTE  ─────────────
  static const Color primaryColor = Color(0xFF1E824C);
  static const Color secondaryColor = Color(0xFF2C3E50);

  // ─────────────  AUTO-REFRESH TIMER  ─────────────
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-refresh timer to check for orders that are ready
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to update countdown displays
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ─────────────  GOOGLE MAPS LAUNCHER  ─────────────
  Future<void> _launchMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  // ─────────────  BUILD  ─────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state is AssignedOrdersLoaded) {
          if (state.orders.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.orders.length,
            itemBuilder: (_, i) => _AssignedCard(
              order: state.orders[i],
              onLaunchMaps: _launchMaps,
              // Pass repository for getting real-time remaining time
              repository: RepositoryProvider.of<DeliveryRepository>(context),
            ),
          );
        }

        if (state is OrderError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────  EMPTY-STATE WIDGET  ─────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_outlined, size: 80, color: Colors.white54),
        const SizedBox(height: 16),
        Text(
          'No assigned orders',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
        ),
      ],
    ),
  );
}

// ─────────────  CARD WIDGET  ─────────────
class _AssignedCard extends StatelessWidget {
  const _AssignedCard({
    required this.order,
    required this.onLaunchMaps,
    required this.repository,
  });

  final OrderModel order;
  final void Function(String) onLaunchMaps;
  final DeliveryRepository repository;

  static const Color primaryColor = Color(0xFF1E824C);
  static const Color secondaryColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    final bool isReady = order.status == 'Ready for Pickup';

    // Build "mm:ss" for live count-down, fallback to static minutes
    String _prepText() {
      if (isReady) return 'Ready for pickup';
      final remaining = repository.getRemainingPreparationTime(order.id);
      if (remaining == null) {
        return '${order.preparationTime?.inMinutes ?? 0} min remaining';
      }
      final totalSeconds = remaining.inSeconds;
      if (totalSeconds <= 0) return 'Ready for pickup';

      final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
      final s = (totalSeconds % 60).toString().padLeft(2, '0');
      return '$m:$s remaining';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Row(
              children: [
                _iconBox(Icons.assignment_turned_in, Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Order',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '#${order.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusChip(isReady),
              ],
            ),
            const SizedBox(height: 20),

            // ── PREPARATION INFO ──
            if (!isReady)
              _infoBox(
                icon: Icons.timer,
                iconBg: Colors.orange,
                title: 'Preparation Time',
                subtitle: _prepText(),
                subtitleColor: Colors.orange.shade800,
              ),
            if (!isReady) const SizedBox(height: 16),

            // ── ADDRESSES ──
            _addressRow(
              icon: Icons.restaurant,
              iconColor: Colors.red.shade600,
              label: 'Restaurant',
              address: order.restaurantAddress ?? 'Address not available',
              onTap: () => onLaunchMaps(
                order.restaurantAddress ?? order.deliveryAddress,
              ),
            ),
            const SizedBox(height: 12),
            _addressRow(
              icon: Icons.location_on,
              iconColor: primaryColor,
              label: 'Delivery Address',
              address: order.deliveryAddress,
              onTap: () => onLaunchMaps(order.deliveryAddress),
            ),

            // ── AUTOMATIC TRANSITION MESSAGE ──
            if (isReady) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_mode,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Order automatically moved to Active Orders!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────  UI HELPERS  ─────────────
  Widget _iconBox(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 28),
  );

  Widget _statusChip(bool isReady) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isReady
            ? [primaryColor, primaryColor.withOpacity(0.8)]
            : [Colors.orange, Colors.orange.withOpacity(0.8)],
      ),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: (isReady ? primaryColor : Colors.orange).withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Text(
      isReady ? 'Ready' : 'Preparing',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _infoBox({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: iconBg.withOpacity(0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: iconBg.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _addressRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.pin_drop, color: Colors.grey[400], size: 18),
        ],
      ),
    ),
  );
}
