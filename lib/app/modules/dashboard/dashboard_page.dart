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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Container(
      margin: EdgeInsets.all(SizeConfig.res(2)),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.res(5)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerRow(),
                const SizedBox(height: 10),
                _chartAndCreditRow(),
                const SizedBox(height: 16),
                _creditSummary(),
                const Divider(),
                const SizedBox(height: 16),
                _tablesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _headerRow() {
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 900;
        return narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chartToggle(),
                  const SizedBox(height: 8),
                  _periodSelector(),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _chartToggle(),
                  _periodSelector(),
                ],
              );
      },
    );
  }

  Widget _chartToggle() {
    final labels = ['Income', 'Expense'];
    final keys = ['income', 'expense'];

    return Obx(() => ToggleButtons(
          isSelected:
              keys.map((k) => controller.selectedChart.value == k).toList(),
          onPressed: (i) => controller.selectedChart.value = keys[i],
          borderRadius: BorderRadius.circular(8),
          fillColor: Colors.blueAccent,
          selectedColor: Colors.white,
          children: labels
              .map((e) => Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: SizeConfig.res(3)),
                    child: Text(e,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ))
              .toList(),
        ));
  }

  Widget _periodSelector() {
    return Wrap(
      spacing: SizeConfig.res(1),
      children: ChartPeriod.values.map((p) {
        return Obx(() {
          final active = controller.selectedPeriod.value == p;
          return ChoiceChip(
            label: Text(p.name.toUpperCase()),
            selected: active,
            onSelected: (_) => controller.changePeriod(p),
            selectedColor: Colors.blueAccent,
            labelStyle: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        });
      }).toList(),
    );
  }

  // ================= CHART + CREDIT =================
  Widget _chartAndCreditRow() {
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 900;

        if (narrow) {
          return Column(
            children: [
              SizedBox(height: SizeConfig.sh(0.4), child: DashboardCharts()),
              const SizedBox(height: 16),
              _creditTable(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 4,
                child: SizedBox(height: SizeConfig.sh(0.4), child: DashboardCharts())),
            const SizedBox(width: 16),
            Expanded(
                flex: 6,
                child: SizedBox(height: SizeConfig.sh(0.4), child: _creditTable())),
          ],
        );
      },
    );
  }

  Widget _creditTable() {
    return Obx(() {
      if (controller.isCreditLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ModernTable<credit_model.CreditItem>(
        title: controller.selectedChart.value == 'income'
            ? "Income Credits : Sales"
            : "Expense Credits : Purchases",
        rows: controller.pagedCreditItems,
        currentPage: controller.creditCurrentPageBackend - 1,
        totalPages: controller.creditTotalPages,
        onPageChanged: (page) => controller.fetchCredits(page: page),
        columnTitles: const [
          "S/N",
          "Date",
          "Name",
          "Total",
          "Remaining",
          "Credit Days"
        ],
        cellBuilders: [
          (i, idx) {
            final serial = idx +
                1 +
                ((controller.creditCurrentPageBackend - 1) *
                    controller.creditData.value.sale.pagination.pageSize);
            return Text('$serial');
          },
          (i, _) => Text(controller.getCreditDate(i).split("T").first),
          (i, _) => Text(controller.getCreditName(i)),
          (i, _) => Text(controller.getCreditNet(i).toStringAsFixed(0)),
          (i, _) => Text(controller.getCreditRemaining(i).toStringAsFixed(0)),
          (i, _) => Text(controller.getCreditDays(i).toString()),
        ],
      );
    });
  }

  // ================= CREDIT SUMMARY =================
  Widget _creditSummary() {
    return Obx(() {
      if (controller.isCreditLoading.value) {
        return const SizedBox();
      }

      final credit = controller.selectedChart.value == 'income'
          ? controller.credit.sale
          : controller.credit.purchase;

      return Row(
        children: [
          Expanded(child: _creditTile("Net Total", credit.totals.totalNetAmount)),
          Expanded(child: _creditTile("Paid", credit.totals.totalPaidAmount)),
          Expanded(child: _creditTile("Remaining", credit.totals.totalCreditAmount)),
        ],
      );
    });
  }

  Widget _creditTile(String title, double value) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text("Rs. ${value.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ================= TABLES SECTION =================
  Widget _tablesSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: SizeConfig.sw(0.34),
                height: SizeConfig.sh(0.48),
                child: _lowStockCard()),
            SizedBox(width: SizeConfig.res(1)),
            Expanded(
              child: SizedBox(height: SizeConfig.sh(0.48), child: _followupCard()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: SizeConfig.sw(0.44),
                height: SizeConfig.sh(0.48),
                child: _ordersCard()),
            SizedBox(width: SizeConfig.res(1)),
            Expanded(child: _staffSalaryCard()),
          ],
        ),
      ],
    );
  }

  // ================= TABLE CARDS =================
  Widget _lowStockCard() {
    return Obx(() {
      if (controller.isLowStockLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ModernTable<stock_model.StockItem>(
        title: "Low Stocks",
        rows: controller.pagedStockItems,
        currentPage: controller.stockCurrentPageBackend - 1,
        totalPages: controller.stockTotalPages,
        onPageChanged: (page) => controller.fetchLowStock(page: page),
        columnTitles: const ["S/N", "Item No", "Name", "Stock"],
        cellBuilders: [
          (i, idx) => Text(
              '${idx + 1 + (controller.stockCurrentPageBackend - 1) * controller.stockData.value.pagination.pageSize}'),
          (i, _) => Text(i.itemNo),
          (i, _) => Text(i.name),
          (i, _) => Text(i.stock.toString()),
        ],
      );
    });
  }

  Widget _followupCard() {
    return Obx(() {
      if (controller.isFollowupLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ModernTable<followup_model.FollowupItem>(
        title: "Follow-ups",
        rows: controller.pagedFollowups,
        currentPage: controller.followupCurrentPageBackend - 1,
        totalPages: controller.followupTotalPages,
        onPageChanged: (page) => controller.fetchFollowups(page: page),
        columnTitles: const ["S/N", "Followup Date", "Customer", "Contact", "Status"],
        cellBuilders: [
          (i, idx) => Text(
              '${idx + 1 + (controller.followupCurrentPageBackend - 1) * controller.followupData.value.pagination.pageSize}'),
          (i, _) => Text(i.followUpDate.split("T").first),
          (i, _) => Text(i.customerName),
          (i, _) => Text(i.contactNo),
          (i, _) => Text(i.status),
        ],
      );
    });
  }

  Widget _ordersCard() {
    return Obx(() {
      if (controller.isOrdersLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ModernTable<order_model.OrderItem>(
        title: "Orders",
        rows: controller.pagedOrders,
        currentPage: controller.ordersCurrentPageBackend - 1,
        totalPages: controller.ordersTotalPages,
        onPageChanged: (page) => controller.fetchOrders(page: page),
        columnTitles: const [
          "S/N",
          "Order Date",
          "Customer",
          "Contact",
          "Total",
          "Remaining"
        ],
        cellBuilders: [
          (i, idx) => Text(
              '${idx + 1 + (controller.ordersCurrentPageBackend - 1) * controller.orderData.value.pagination.pageSize}'),
          (i, _) => Text(i.orderDate.split("T").first),
          (i, _) => Text(i.customerName),
          (i, _) => Text(i.contactNo),
          (i, _) => Text(i.totalAmount.toStringAsFixed(0)),
          (i, _) => Text(i.remainingAmount.toStringAsFixed(0)),
        ],
      );
    });
  }

  Widget _staffSalaryCard() {
    return Obx(() {
      if (controller.isStaffSalaryLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return ModernTable<staff_model.StaffSalaryItem>(
        title: "Staffs Salary",
        rows: controller.pagedStaffSalaries,
        currentPage: controller.staffCurrentPageBackend - 1,
        totalPages: controller.staffTotalPages,
        onPageChanged: (page) => controller.fetchStaffSalaries(page: page),
        columnTitles: const ["S/N", "Name", "Salary", "Remaining"],
        cellBuilders: [
          (i, idx) => Text(
              '${idx + 1 + (controller.staffCurrentPageBackend - 1) * controller.staffData.value.pagination.pageSize}'),
          (i, _) => Text(i.name),
          (i, _) => Text(i.totalSalary.toStringAsFixed(0)),
          (i, _) => Text(i.remainingAmount.toStringAsFixed(0)),
        ],
      );
    });
  }
}
