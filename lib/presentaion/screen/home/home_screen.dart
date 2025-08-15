import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/order/order_bloc.dart';
import '../../../bloc/order/order_event.dart';
import '../new_orders/new_orders_screen.dart';
import '../assigned_orders/assigned_orders_screen.dart';
import '../active_orders/active_orders_screen.dart';
import '../past_orders/past_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ─────────────  COLOR PALETTE  ─────────────
  static const Color primaryColor = Color(0xFF1E824C);
  static const Color secondaryColor = Color(0xFF2C3E50);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)..addListener(_onTab);
    // Load first page
    context.read<OrderBloc>().add(FetchNewOrders());
  }

  void _onTab() {
    switch (_tabController.index) {
      case 0:
        context.read<OrderBloc>().add(FetchNewOrders());
        break;
      case 1:
        context.read<OrderBloc>().add(FetchAssignedOrders());
        break;
      case 2:
        context.read<OrderBloc>().add(FetchActiveOrders());
        break;
      case 3:
        context.read<OrderBloc>().add(FetchPastOrders());
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────  BUILD  ─────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: secondaryColor,
        title: Text(
          'My Deliveries',
          style: GoogleFonts.sansita(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          // ── DECORATED REFRESH BUTTON ──
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [primaryColor, Color(0xFF18995C)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha((0.4 * 255).toInt()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                splashRadius: 24,
                tooltip: 'Refresh',
                onPressed: _onTab,
              ),
            ),
          ),
        ],
        // ── DECORATED TAB BAR ──
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            // ↓ tighter padding keeps text+icon centred in the pill
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            // ↓ make the indicator cover the whole tab (icon + text area)
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [primaryColor, primaryColor],
              ),
            ),
            // ↓ zero padding so the green pill hugs its tab completely
            indicatorPadding: EdgeInsets.only(bottom: 4, top: 4),
            tabAlignment: TabAlignment.fill,
            tabs: const [
              _TabItem(text: 'New'),
              _TabItem(text: 'Assigned'),
              _TabItem(text: 'Active'),
              _TabItem(text: 'Past'),
            ],
          ),
        ),
      ),

      // ── BODY WITH GRADIENT BACKGROUND ──
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [secondaryColor, primaryColor],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            NewOrdersScreen(),
            AssignedOrdersScreen(),
            ActiveOrdersScreen(),
            PastOrdersScreen(),
          ],
        ),
      ),
    );
  }
}

/// A reusable, nicely styled tab item (icon + text).
class _TabItem extends StatelessWidget {
  const _TabItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Tab(child: Text(text, style: TextStyle(fontSize: 16)));
}
