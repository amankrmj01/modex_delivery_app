import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/delivery_orders/delivery_orders_bloc.dart';
import '../../../data/models/order_model.dart';

class NewOrdersScreen extends StatefulWidget {
  const NewOrdersScreen({super.key});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  final Map<String, Timer> _timers = {};
  final Map<String, int> _remainingSeconds = {};

  @override
  void dispose() {
    _timers.forEach((_, timer) => timer.cancel());
    super.dispose();
  }

  void _startTimer(OrderModel order) {
    final now = DateTime.now();
    final orderTime = order.date;
    final expiry = orderTime.add(const Duration(minutes: 5));
    final secondsLeft = expiry.difference(now).inSeconds;
    if (secondsLeft <= 0) {
      _expireOrder(order.id);
      return;
    }
    _remainingSeconds[order.id] = secondsLeft;
    _timers[order.id]?.cancel();
    _timers[order.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds[order.id] = (_remainingSeconds[order.id] ?? 1) - 1;
        if (_remainingSeconds[order.id]! <= 0) {
          timer.cancel();
          _expireOrder(order.id);
        }
      });
    });
  }

  void _expireOrder(String orderId) {
    context.read<DeliveryOrdersBloc>().add(RejectOrder(orderId));
    _timers[orderId]?.cancel();
    _timers.remove(orderId);
    _remainingSeconds.remove(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF1E824C)],
          ),
        ),
        child: BlocBuilder<DeliveryOrdersBloc, DeliveryOrdersState>(
          builder: (context, state) {
            if (state is DeliveryOrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (state is DeliveryOrdersLoaded) {
              final newOrders = state.orders
                  .where((order) => order.status == 'Ready for Pickup')
                  .toList();
              if (newOrders.isEmpty) {
                return Center(
                  child: Text(
                    'No new orders available.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                );
              }
              for (final order in newOrders) {
                if (!_timers.containsKey(order.id)) {
                  _startTimer(order);
                }
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: newOrders.length,
                itemBuilder: (context, index) {
                  final order = newOrders[index];
                  final secondsLeft = _remainingSeconds[order.id] ?? 300;
                  final minutes = (secondsLeft ~/ 60).toString().padLeft(
                    2,
                    '0',
                  );
                  final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
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
                                'Time left to accept:',
                                style: GoogleFonts.poppins(
                                  color: Colors.amber.shade300,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$minutes:$seconds',
                                style: GoogleFonts.poppins(
                                  color: Colors.redAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: secondsLeft > 0
                                    ? () {
                                        context.read<DeliveryOrdersBloc>().add(
                                          AcceptOrder(order.id),
                                        );
                                        _timers[order.id]?.cancel();
                                        _timers.remove(order.id);
                                        _remainingSeconds.remove(order.id);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Accept',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: secondsLeft > 0
                                    ? () {
                                        context.read<DeliveryOrdersBloc>().add(
                                          RejectOrder(order.id),
                                        );
                                        _timers[order.id]?.cancel();
                                        _timers.remove(order.id);
                                        _remainingSeconds.remove(order.id);
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Reject',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is DeliveryOrderUpdating) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (state is DeliveryOrderUpdateError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: GoogleFonts.poppins(
                    color: Colors.redAccent,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return Center(
              child: Text(
                'No orders found.',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }
}
