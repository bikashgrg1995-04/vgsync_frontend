// app/modules/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vgsync_frontend/app/data/models/dashboard/credit.dart'
    as credit_model;
import 'package:vgsync_frontend/app/data/models/dashboard/low_stock.dart'
    as stock_model;
import 'package:vgsync_frontend/app/data/models/dashboard/orders.dart'
    as order_model;
import 'package:vgsync_frontend/app/data/models/dashboard/staffs_salary.dart'
    as staff_model;
import 'package:vgsync_frontend/app/data/models/dashboard/followup.dart'
    as followup_model;
import 'package:vgsync_frontend/app/data/repositories/dashboard_repository.dart';
import 'package:vgsync_frontend/app/modules/dashboard/dashboard_controller.dart';
import 'package:vgsync_frontend/app/wigdets/paginated_table.dart';
import 'package:vgsync_frontend/app/wigdets/dashboard_charts.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../themes/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = Get.find();

  // ── Derived constants from AppColors ──────────────────────────────────────
  static const _bg         = AppColors.background;
  static const _surface    = AppColors.surface;
  static const _primary    = AppColors.primary;
  static final _primaryLight = const Color(0xFF4A6CF7).withOpacity(0.1);
  static const _accent     = Color(0xFF0EA5E9);
  static const _success    = AppColors.success;
  static const _warning    = Color(0xFFF59E0B);
  static const _danger     = AppColors.error;
  static const _textDark   = AppColors.textPrimary;
  static const _textMid    = AppColors.textSecondary;
  static const _border     = Color(0xFFE5E7EB);
  static const _shadow     = Color(0x0F000000);

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.res(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(isWide),
              SizedBox(height: SizeConfig.sh(0.025)),
              _chartSection(isWide),
              SizedBox(height: SizeConfig.sh(0.02)),
              _creditSummaryRow(),
              SizedBox(height: SizeConfig.sh(0.02)),
              _tablesSection(isWide),
              SizedBox(height: SizeConfig.sh(0.02)),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────
  Widget _topBar(bool isWide) {
    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _pageTitle(),
              SizedBox(width: SizeConfig.sw(0.02)),
              _chartToggle(),
              const Spacer(),
              _periodSelector(),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageTitle(),
              SizedBox(height: SizeConfig.sh(0.015)),
              _chartToggle(),
              SizedBox(height: SizeConfig.sh(0.01)),
              _periodSelector(),
            ],
          );
  }

  Widget _pageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: TextStyle(
            fontSize: SizeConfig.res(7),
            fontWeight: FontWeight.w800,
            color: _textDark,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Overview of your business',
          style: TextStyle(
            fontSize: SizeConfig.res(3.5),
            color: _textMid,
          ),
        ),
      ],
    );
  }

  Widget _chartToggle() {
    final labels = ['Income', 'Expense', 'Installments'];
    final keys   = ['income', 'expense', 'emi'];
    final icons  = [Icons.trending_up, Icons.trending_down, Icons.payment];

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: _shadow, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(keys.length, (i) {
              final selected = controller.selectedChart.value == keys[i];
              return GestureDetector(
                onTap: () => controller.selectedChart.value = keys[i],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.012),
                    vertical: SizeConfig.sh(0.012),
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icons[i],
                          size: SizeConfig.res(4),
                          color: selected ? Colors.white : _textMid),
                      SizedBox(width: SizeConfig.sw(0.004)),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: SizeConfig.res(3.2),
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : _textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ));
  }

  Widget _periodSelector() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
            boxShadow: const [BoxShadow(color: _shadow, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ChartPeriod.values.map((p) {
              final active = controller.selectedPeriod.value == p;
              return GestureDetector(
                onTap: () => controller.changePeriod(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.sw(0.01),
                    vertical: SizeConfig.sh(0.012),
                  ),
                  decoration: BoxDecoration(
                    color: active ? _accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    p.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: SizeConfig.res(3),
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : _textMid,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  // ── CHART SECTION ─────────────────────────────────────────────────────────
  Widget _chartSection(bool isWide) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _surfaceCard(
              child: SizedBox(height: SizeConfig.sh(0.38), child: DashboardCharts()),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.015)),
          Expanded(
            flex: 6,
            child: SizedBox(height: SizeConfig.sh(0.38), child: _creditTable()),
          ),
        ],
      );
    }
    return Column(
      children: [
        _surfaceCard(
          child: SizedBox(height: SizeConfig.sh(0.35), child: DashboardCharts()),
        ),
        SizedBox(height: SizeConfig.sh(0.02)),
        SizedBox(height: SizeConfig.sh(0.38), child: _creditTable()),
      ],
    );
  }

  Widget _surfaceCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  // ── CREDIT TABLE ──────────────────────────────────────────────────────────
  Widget _creditTable() {
    return Obx(() {
      if (controller.isCreditLoading.value) {
        return _surfaceCard(child: const Center(child: CircularProgressIndicator()));
      }

      if (controller.selectedChart.value == 'emi') {
        return _surfaceCard(
          padding: EdgeInsets.all(SizeConfig.res(3)),
          child: ModernTable<credit_model.CreditItem>(
            title: "EMI / Installments",
            rows: controller.pagedCreditItems,

            currentPage: controller.creditCurrentPageBackend - 1,
            totalPages: controller.creditTotalPages,
            onPageChanged: (page) => controller.fetchCredits(page: page),
            columnTitles: const ["S/N", "Amount", "Due Date", "Customer", "Contact", "Status"],
            cellBuilders: [
              (i, idx) => Text('${idx + 1 + (controller.creditCurrentPageBackend - 1) * controller.credit.emi.pagination.pageSize}'),
              (i, _) => Text(i.remainingAmount.toStringAsFixed(0)),
              (i, _) => Text(i.dueDate?.split("T").first ?? "-"),
              (i, _) => Text(i.customerName ?? "-"),
              (i, _) => Text(i.contactNo ?? "-"),
              (i, _) => _statusChip(i.status),
            ],
          ),
        );
      }

      return _surfaceCard(
         padding: EdgeInsets.all(SizeConfig.res(3)),
        child: ModernTable<credit_model.CreditItem>(
          title: controller.selectedChart.value == 'income'
              ? "Income Credits : Sales"
              : "Expense Credits : Purchases",
          rows: controller.pagedCreditItems,
          currentPage: controller.creditCurrentPageBackend - 1,
          totalPages: controller.creditTotalPages,
          onPageChanged: (page) => controller.fetchCredits(page: page),
          columnTitles: const ["S/N", "Date", "Name", "Total", "Remaining", "Credit Days"],
          cellBuilders: [
            (i, idx) {
              final serial = idx + 1 + ((controller.creditCurrentPageBackend - 1) * controller.credit.sale.pagination.pageSize);
              return Text('$serial');
            },
            (i, _) => Text(controller.getCreditDate(i)),
            (i, _) => Text(controller.getCreditName(i)),
            (i, _) => Text(controller.getCreditNet(i).toStringAsFixed(0)),
            (i, _) => Text(controller.getCreditRemaining(i).toStringAsFixed(0)),
            (i, _) => _daysChip(controller.getCreditDays(i)),
          ],
        ),
      );
    });
  }

  // ── CREDIT SUMMARY ────────────────────────────────────────────────────────
  Widget _creditSummaryRow() {
    return Obx(() {
      if (controller.isCreditLoading.value) return const SizedBox();
      if (controller.selectedChart.value == 'emi') return const SizedBox();

      final credit = controller.selectedChart.value == 'income'
          ? controller.credit.sale
          : controller.credit.purchase;

      return Row(
        children: [
          Expanded(child: _summaryTile('Net Total', credit.totals.totalNetAmount, Icons.account_balance_wallet_outlined, _primary)),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(child: _summaryTile('Paid', credit.totals.totalPaidAmount, Icons.check_circle_outline, _success)),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(child: _summaryTile('Remaining', credit.totals.totalCreditAmount, Icons.pending_outlined, _warning)),
        ],
      );
    });
  }

  Widget _summaryTile(String label, double value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.012),
        vertical: SizeConfig.sh(0.018),
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.res(2.2)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: SizeConfig.res(5)),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid)),
                SizedBox(height: SizeConfig.sh(0.003)),
                Text(
                  'Rs. ${value.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: SizeConfig.res(3.8),
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TABLES SECTION ────────────────────────────────────────────────────────
  Widget _tablesSection(bool isWide) {
    if (isWide) {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: SizeConfig.sw(0.34),
                  child: _surfaceCard(
                    padding: EdgeInsets.all(SizeConfig.res(3)),
                    child: SizedBox(height: SizeConfig.sh(0.46), child: _lowStockTable()),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.015)),
                Expanded(
                  child: _surfaceCard(
                     padding: EdgeInsets.all(SizeConfig.res(3)),
                    child: SizedBox(height: SizeConfig.sh(0.46), child: _followupTable()),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeConfig.sh(0.02)),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                   width: SizeConfig.sw(0.44),
                  child: _surfaceCard(
                     padding: EdgeInsets.all(SizeConfig.res(3)),
                    child: SizedBox(height: SizeConfig.sh(0.46), child: _ordersTable()),
                  ),
                ),
                SizedBox(width: SizeConfig.sw(0.015)),
                Expanded(
                  child: _surfaceCard(
                     padding: EdgeInsets.all(SizeConfig.res(3)),
                    child: SizedBox(height: SizeConfig.sh(0.46), child: _staffSalaryTable()),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _surfaceCard(padding: EdgeInsets.zero, child: SizedBox(height: SizeConfig.sh(0.46), child: _lowStockTable())),
        SizedBox(height: SizeConfig.sh(0.02)),
        _surfaceCard(padding: EdgeInsets.zero, child: SizedBox(height: SizeConfig.sh(0.46), child: _followupTable())),
        SizedBox(height: SizeConfig.sh(0.02)),
        _surfaceCard(padding: EdgeInsets.zero, child: SizedBox(height: SizeConfig.sh(0.46), child: _ordersTable())),
        SizedBox(height: SizeConfig.sh(0.02)),
        _surfaceCard(padding: EdgeInsets.zero, child: SizedBox(height: SizeConfig.sh(0.46), child: _staffSalaryTable())),
      ],
    );
  }

  // ── TABLE WIDGETS ─────────────────────────────────────────────────────────
  Widget _lowStockTable() {
    return Obx(() {
      if (controller.isLowStockLoading.value) return const Center(child: CircularProgressIndicator());
      return ModernTable<stock_model.StockItem>(
        title: "Low Stocks",
        rows: controller.pagedStockItems,
        currentPage: controller.stockCurrentPageBackend - 1,
        totalPages: controller.stockTotalPages,
        onPageChanged: (page) => controller.fetchLowStock(page: page),
        columnTitles: const ["S/N", "Item No", "Name", "Stock"],
        cellBuilders: [
          (i, idx) => Text('${idx + 1 + (controller.stockCurrentPageBackend - 1) * controller.stockData.value.pagination.pageSize}'),
          (i, _) => Text(i.itemNo, style: TextStyle(fontSize: SizeConfig.res(3.5)),),
          (i, _) => Text(i.name, style: TextStyle(fontSize: SizeConfig.res(3.5)),),
          (i, _) => _stockBadge(i.stock),
        ],
      );
    });
  }

  Widget _followupTable() {
    return Obx(() {
      if (controller.isFollowupLoading.value) return const Center(child: CircularProgressIndicator());
      return ModernTable<followup_model.FollowupItem>(
        title: "Follow-ups",
        rows: controller.pagedFollowups,
        currentPage: controller.followupCurrentPageBackend - 1,
        totalPages: controller.followupTotalPages,
        onPageChanged: (page) => controller.fetchFollowups(page: page),
        columnTitles: const ["S/N", "Date", "Customer", "Vehicle", "Contact", "Status"],
        cellBuilders: [
          (i, idx) => Text('${idx + 1 + (controller.followupCurrentPageBackend - 1) * controller.followupData.value.pagination.pageSize}'),
          (i, _) => Text(i.followUpDate.split("T").first),
          (i, _) => Text(i.customerName),
          (i, _) => Text(i.vehicle),
          (i, _) => Text(i.contactNo),
          (i, _) => _statusChip(i.status),
        ],
      );
    });
  }

  Widget _ordersTable() {
    return Obx(() {
      if (controller.isOrdersLoading.value) return const Center(child: CircularProgressIndicator());
      return ModernTable<order_model.OrderItem>(
        title: "Orders",
        rows: controller.pagedOrders,
        currentPage: controller.ordersCurrentPageBackend - 1,
        totalPages: controller.ordersTotalPages,
        onPageChanged: (page) => controller.fetchOrders(page: page),
        columnTitles: const ["S/N", "Date", "Customer", "Total", "Remaining", "Status"],
        cellBuilders: [
          (i, idx) => Text('${idx + 1 + (controller.ordersCurrentPageBackend - 1) * controller.orderData.value.pagination.pageSize}'),
          (i, _) => Text(i.orderDate.split("T").first),
          (i, _) => Text(i.customerName),
          (i, _) => Text(i.totalAmount.toStringAsFixed(0)),
          (i, _) => Text(i.remainingAmount.toStringAsFixed(0)),
          (i, _) => _statusChip(i.status),
        ],
      );
    });
  }

  Widget _staffSalaryTable() {
    return Obx(() {
      if (controller.isStaffSalaryLoading.value) return const Center(child: CircularProgressIndicator());
      return ModernTable<staff_model.StaffSalaryItem>(
        title: "Staff Salary",
        rows: controller.pagedStaffSalaries,
        currentPage: controller.staffCurrentPageBackend - 1,
        totalPages: controller.staffTotalPages,
        onPageChanged: (page) => controller.fetchStaffSalaries(page: page),
        columnTitles: const ["S/N", "Staff Name", "Salary", "Remaining"],
        cellBuilders: [
          (i, idx) => Text('${idx + 1 + (controller.staffCurrentPageBackend - 1) * controller.staffData.value.pagination.pageSize}'),
          (i, _) => Text(i.name),
          (i, _) => Text('Rs. ${i.totalSalary.toStringAsFixed(0)}'),
          (i, _) => _remainingBadge(i.remainingAmount),
        ],
      );
    });
  }

  // ── HELPER CHIPS & BADGES ─────────────────────────────────────────────────
  Widget _statusChip(String status) {
    final s = status.toLowerCase();
    final Color bg;
    final Color fg;
    if (s == 'paid' || s == 'completed' || s == 'done') {
      bg = _success.withOpacity(0.1); fg = _success;
    } else if (s == 'partial' || s == 'pending') {
      bg = _warning.withOpacity(0.1); fg = _warning;
    } else {
      bg = _danger.withOpacity(0.1); fg = _danger;
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.007),
        vertical: SizeConfig.sh(0.004),
      ),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(fontSize: SizeConfig.res(2.8), fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _stockBadge(int qty) {
    final color = qty <= 0 ? _danger : qty <= 5 ? _warning : _success;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.007),
        vertical: SizeConfig.sh(0.004),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$qty',
          style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _remainingBadge(double amount) {
    final color = amount <= 0 ? _success : _warning;
    return Text(
      'Rs. ${amount.toStringAsFixed(0)}',
      style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _daysChip(int days) {
    final color = days > 30 ? _danger : days > 15 ? _warning : _textMid;
    return Text(
      '$days days',
      style: TextStyle(fontSize: SizeConfig.res(3), fontWeight: FontWeight.w600, color: color),
    );
  }
}