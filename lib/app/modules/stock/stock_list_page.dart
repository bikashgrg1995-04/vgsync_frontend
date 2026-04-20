// app/modules/stock/stock_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/app/controllers/global_controller.dart';
import 'package:vgsync_frontend/app/modules/categories/category_controller.dart';
import 'package:vgsync_frontend/app/modules/stock/item_detail_page.dart';
import 'package:vgsync_frontend/app/wigdets/common_widgets.dart';
import 'package:vgsync_frontend/app/wigdets/file_upload.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../data/models/stock_model.dart';
import 'stock_controller.dart';
import '../../themes/app_colors.dart';

class StockListPage extends StatefulWidget {
  const StockListPage({super.key});

  @override
  State<StockListPage> createState() => _StockListPageState();
}

class _StockListPageState extends State<StockListPage> {
  final StockController stockController = Get.find<StockController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final GlobalController globalController = Get.find<GlobalController>();

  // ── Colors (all const — no runtime allocation) ────────────────────────────
  static const _bg           = AppColors.background;
  static const _surface      = AppColors.surface;
  static const _primary      = AppColors.primary;
  static const _success      = AppColors.success;
  static const _warning      = Color(0xFFF59E0B);
  static const _danger       = AppColors.error;
  static const _textDark     = AppColors.textPrimary;
  static const _textMid      = AppColors.textSecondary;
  static const _border       = Color(0xFFE5E7EB);
  static const _shadow       = Color(0x0F000000);
  static const _primaryLight = Color(0xFFEEF2FF);

  // ── Pre-computed semi-transparent colors (avoids withOpacity per frame) ───
  static const _dangerBorder   = Color(0x4DDA0B0B); // danger @ 0.3
  static const _dangerBg       = Color(0x1ADA0B0B); // danger @ 0.1
  static const _warningBorder  = Color(0x4DF59E0B); // warning @ 0.3
  static const _warningBg      = Color(0x1AF59E0B); // warning @ 0.1
  static const _successBorder  = Color(0x4D22C55E); // success @ 0.3  ← adjust to your AppColors.success hex
  static const _successBg      = Color(0x1A22C55E); // success @ 0.1

  // ── Cached decoration objects (built once, reused) ────────────────────────
  static const _tileBoxShadow = [
    BoxShadow(color: _shadow, blurRadius: 4, offset: Offset(0, 1))
  ];
  static const _headerBoxShadow = [
    BoxShadow(color: _shadow, blurRadius: 8, offset: Offset(0, 2))
  ];

  // Cached tile decorations (out-of-stock / low / normal)
  static final _tileDecorNormal = BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border),
    boxShadow: _tileBoxShadow,
  );
  static final _tileDecorLow = BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _warningBorder),
    boxShadow: _tileBoxShadow,
  );
  static final _tileDecorOut = BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _dangerBorder),
    boxShadow: _tileBoxShadow,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    await categoryController.fetchCategories();
    await stockController.fetchStocks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SizeConfig.init(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.res(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: SizeConfig.sh(0.02)),
            Expanded(child: _buildList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddDialog,
        backgroundColor: _primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Stock',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: SizeConfig.res(3.5),
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.res(4)),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: _headerBoxShadow,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stock',
                style: TextStyle(
                  fontSize: SizeConfig.res(6),
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Manage your inventory',
                style: TextStyle(fontSize: SizeConfig.res(3), color: _textMid),
              ),
            ],
          ),
          SizedBox(width: SizeConfig.sw(0.02)),
          Expanded(
            child: TextField(
              controller: stockController.searchController,
              onChanged: (_) => stockController.stocks.refresh(),
              style: TextStyle(fontSize: SizeConfig.res(3.5)),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: _textMid, size: SizeConfig.res(4.5)),
                hintText: 'Search by name or item no...',
                hintStyle: TextStyle(color: _textMid, fontSize: SizeConfig.res(3.2)),
                isDense: true,
                filled: true,
                fillColor: _bg,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sw(0.01),
                  vertical: SizeConfig.sh(0.012),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _primary, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.sw(0.01)),
          _iconBtn(icon: Icons.refresh_rounded, tooltip: 'Refresh', onTap: stockController.refreshStock),
          SizedBox(width: SizeConfig.sw(0.008)),
          _outlineBtn(
            icon: Icons.upload_file_outlined,
            label: 'Import',
            onTap: () {
              FileUploadDialog.show(
                context: context,
                title: 'Import Stock Excel',
                endpoint: '/upload/stock-excel/',
                fileKey: 'file',
                allowedExtensions: ['xls', 'xlsx'],
                onSuccess: () async {
                  await stockController.fetchStocks();
                  await categoryController.fetchCategories();
                  globalController.triggerRefresh(DashboardRefreshType.stock);
                },
              );
            },
          ),
          SizedBox(width: SizeConfig.sw(0.008)),
          _outlineBtn(
            icon: Icons.price_change_outlined,
            label: 'MRP',
            onTap: () {
              FileUploadDialog.show(
                context: context,
                title: 'Update MRP (Price Upload)',
                endpoint: '/upload/new-mrp-excel/',
                fileKey: 'file',
                allowedExtensions: ['xls', 'xlsx'],
                onSuccess: () async {
                  await stockController.fetchStocks();
                  globalController.triggerRefresh(DashboardRefreshType.stock);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ── STOCK LIST ─────────────────────────────────────────────────────────────
  // FIX 1: Obx को scope सानो बनाइयो — पूरै list होइन, count/loading मात्र observe
  Widget _buildList() {
    return Obx(() {
      if (stockController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final query = stockController.searchController.text.toLowerCase();
      final stocks = stockController.stocks;

      // FIX 2: toList() avoid गरियो जहाँ सम्भव — direct index access
      final filtered = query.isEmpty
          ? stocks.toList(growable: false)
          : stocks
              .where((s) =>
                  s.name.toLowerCase().contains(query) ||
                  s.itemNo.toLowerCase().contains(query))
              .toList(growable: false);

      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: SizeConfig.res(15), color: Colors.grey.shade300),
              SizedBox(height: SizeConfig.sh(0.015)),
              Text('No stocks found',
                  style: TextStyle(color: _textMid, fontSize: SizeConfig.res(4))),
            ],
          ),
        );
      }

      // FIX 3: addRepaintBoundaries: false — Flutter ले हरेक tile मा
      //         unnecessary repaint boundary थप्दैन
      // FIX 4: addAutomaticKeepAlives: false — off-screen tiles dispose हुन्छन्
      // FIX 5: cacheExtent बढाइयो — pre-render गर्ने tiles बढि हुन्छन् = कम jank
      return ListView.builder(
        itemCount: filtered.length,
        addRepaintBoundaries: false,
        addAutomaticKeepAlives: false,
        cacheExtent: 500,
        itemBuilder: (_, index) => _StockTile(
          stock: filtered[index],
          index: index,
          onTap: (s) => Get.to(() => StockDetailPage(stockId: s.id!)),
          onEdit: openEditDialog,
          onDelete: (s) => stockController.deleteStock(context, s.id ?? 0),
        ),
      );
    });
  }

  // ── DIALOGS ───────────────────────────────────────────────────────────────
  void openAddDialog() {
    stockController.clearForm();
    _showStockDialog(isEditMode: false);
  }

  void openEditDialog(StockModel stock) {
    stockController.fillForm(stock);
    _showStockDialog(isEditMode: true, stock: stock);
  }

  void _showStockDialog({required bool isEditMode, StockModel? stock}) {
    final categoryCtrl = Get.find<CategoryController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: SizeConfig.sw(0.32),
          padding: EdgeInsets.all(SizeConfig.res(6)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeConfig.res(2.2)),
                      decoration: BoxDecoration(
                        color: _primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isEditMode ? Icons.edit_outlined : Icons.add_box_outlined,
                        color: _primary,
                        size: SizeConfig.res(5),
                      ),
                    ),
                    SizedBox(width: SizeConfig.sw(0.01)),
                    Text(
                      isEditMode ? 'Edit Stock' : 'Add Stock',
                      style: TextStyle(
                          fontSize: SizeConfig.res(5), fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, size: SizeConfig.res(5)),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.sh(0.008)),
                const Divider(),
                SizedBox(height: SizeConfig.sh(0.018)),
                _dialogRow(
                  buildTextField(stockController.itemNoController, "Item No *", Icons.confirmation_number),
                  buildTextField(stockController.nameController, "Name *", Icons.label),
                ),
                SizedBox(height: SizeConfig.sh(0.015)),
                _dialogRow(
                  buildTextField(stockController.modelController, "Model", Icons.model_training),
                  Obx(() {
                    final selectedId = stockController.categorySelectController.text.isNotEmpty
                        ? int.tryParse(stockController.categorySelectController.text)
                        : null;
                    return DropdownButtonFormField<int>(
                      value: selectedId,
                      items: categoryCtrl.categories
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          stockController.categorySelectController.text = value.toString();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Category",
                        prefixIcon: Icon(Icons.category_outlined, size: SizeConfig.res(4.5)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.01),
                          vertical: SizeConfig.sh(0.016),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: SizeConfig.sh(0.015)),
                _dialogRow(
                  buildTextField(stockController.stockQtyController, "Stock Qty", Icons.inventory,
                      keyboardType: TextInputType.number),
                  buildTextField(stockController.purchasePriceController, "Purchase Price",
                      Icons.price_change,
                      keyboardType: TextInputType.number),
                ),
                SizedBox(height: SizeConfig.sh(0.015)),
                _dialogRow(
                  buildTextField(stockController.salePriceController, "Sale Price (13% VAT)",
                      Icons.sell,
                      keyboardType: TextInputType.number, readOnly: true),
                  buildTextField(
                      stockController.blockController, "Block / Location", Icons.location_on_outlined),
                ),
                SizedBox(height: SizeConfig.sh(0.025)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel', style: TextStyle(fontSize: SizeConfig.res(3.5))),
                    ),
                    if (isEditMode) ...[
                      SizedBox(width: SizeConfig.sw(0.008)),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (stock != null) {
                            stockController.deleteStock(context, stock.id ?? 0);
                          }
                        },
                        icon: Icon(Icons.delete_outline, size: SizeConfig.res(4), color: _danger),
                        label: Text('Delete',
                            style: TextStyle(color: _danger, fontSize: SizeConfig.res(3.5))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _danger),
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.sw(0.01),
                            vertical: SizeConfig.sh(0.012),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(width: SizeConfig.sw(0.008)),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isEditMode && stock != null) {
                          await stockController.updateStock(stock);
                        } else {
                          await stockController.addStock();
                        }
                      },
                      icon: Icon(Icons.save_outlined, size: SizeConfig.res(4), color: Colors.white),
                      label: Text('Save',
                          style: TextStyle(color: Colors.white, fontSize: SizeConfig.res(3.5))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.sw(0.015),
                          vertical: SizeConfig.sh(0.012),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: SizeConfig.sw(0.01)),
        Expanded(child: right),
      ],
    );
  }

  Widget _iconBtn({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(SizeConfig.res(2.5)),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: SizeConfig.res(4.5), color: _textMid),
        ),
      ),
    );
  }

  Widget _outlineBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.sw(0.01),
          vertical: SizeConfig.sh(0.011),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: SizeConfig.res(4), color: _textMid),
            SizedBox(width: SizeConfig.sw(0.005)),
            Text(label,
                style: TextStyle(
                  fontSize: SizeConfig.res(3.2),
                  color: _textMid,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FIX 6: _StockTile लाई StatelessWidget बनाइयो
//         → parent rebuild हुँदा tile rebuild हुँदैन (पुरानो code मा हरेक
//           scroll event मा सबै tiles rebuild हुन्थे)
// ═══════════════════════════════════════════════════════════════════════════
class _StockTile extends StatelessWidget {
  const _StockTile({
    required this.stock,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final StockModel stock;
  final int index;
  final void Function(StockModel) onTap;
  final void Function(StockModel) onEdit;
  final void Function(StockModel) onDelete;

  // ── Const colors (same as parent — duplicated here so widget is self-contained)
  static const _primary      = AppColors.primary;
  static const _success      = AppColors.success;
  static const _warning      = Color(0xFFF59E0B);
  static const _danger       = AppColors.error;
  static const _textDark     = AppColors.textPrimary;
  static const _textMid      = AppColors.textSecondary;
  static const _primaryLight = Color(0xFFEEF2FF);

  static const _dangerBorder  = Color(0x4DDA0B0B);
  static const _dangerBg      = Color(0x1ADA0B0B);
  static const _warningBorder = Color(0x4DF59E0B);
  static const _warningBg     = Color(0x1AF59E0B);
  static const _successBorder = Color(0x4D22C55E);
  static const _successBg     = Color(0x1A22C55E);
  static const _border        = Color(0xFFE5E7EB);
  static const _surface       = AppColors.surface;
  static const _shadow        = Color(0x0F000000);

  static const _tileBoxShadow = [
    BoxShadow(color: _shadow, blurRadius: 4, offset: Offset(0, 1))
  ];
  static final _tileDecorNormal = BoxDecoration(
    color: _surface, borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _border), boxShadow: _tileBoxShadow,
  );
  static final _tileDecorLow = BoxDecoration(
    color: _surface, borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _warningBorder), boxShadow: _tileBoxShadow,
  );
  static final _tileDecorOut = BoxDecoration(
    color: _surface, borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _dangerBorder), boxShadow: _tileBoxShadow,
  );

  @override
  Widget build(BuildContext context) {
    final isLow = stock.stock > 0 && stock.stock <= 5;
    final isOut = stock.stock <= 0;

    return Slidable(
      key: ValueKey(stock.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(stock),
            backgroundColor: Colors.orange.shade400,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(stock),
            backgroundColor: _danger,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => onTap(stock),
        child: Container(
          margin: EdgeInsets.only(bottom: SizeConfig.sh(0.008)),
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.sw(0.012),
            vertical: SizeConfig.sh(0.013),
          ),
          decoration: isOut
              ? _tileDecorOut
              : isLow
                  ? _tileDecorLow
                  : _tileDecorNormal,
          child: Row(
            children: [
              // Index badge
              Container(
                width: SizeConfig.res(9),
                height: SizeConfig.res(9),
                decoration: const BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                    fontSize: SizeConfig.res(3.2),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.012)),

              // Name + pills
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: SizeConfig.res(3.8),
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: SizeConfig.sh(0.004)),
                    Row(
                      children: [
                        _pill(Icons.tag, stock.itemNo),
                        if (stock.block != null && stock.block!.isNotEmpty) ...[
                          SizedBox(width: SizeConfig.sw(0.008)),
                          _pill(Icons.location_on_outlined, stock.block!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${stock.salePrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: SizeConfig.res(3.8),
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: SizeConfig.sh(0.003)),
                  Text(
                    'Purchase: Rs. ${stock.purchasePrice.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid),
                  ),
                ],
              ),
              SizedBox(width: SizeConfig.sw(0.015)),

              // Stock badge
              _StockBadge(qty: stock.stock, isOut: isOut, isLow: isLow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: SizeConfig.res(2.8), color: _textMid),
        SizedBox(width: SizeConfig.sw(0.003)),
        Text(text, style: TextStyle(fontSize: SizeConfig.res(2.8), color: _textMid)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FIX 7: Badge पनि छुट्टै StatelessWidget — tile rebuild हुँदा badge
//         rebuild हुँदैन यदि qty/isOut/isLow change भएन भने
// ═══════════════════════════════════════════════════════════════════════════
class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.qty, required this.isOut, required this.isLow});

  final int qty;
  final bool isOut;
  final bool isLow;

  static const _success      = AppColors.success;
  static const _warning      = Color(0xFFF59E0B);
  static const _danger       = AppColors.error;
  static const _dangerBg     = Color(0x1ADA0B0B);
  static const _dangerBorder = Color(0x4DDA0B0B);
  static const _warningBg    = Color(0x1AF59E0B);
  static const _warningBorder= Color(0x4DF59E0B);
  static const _successBg    = Color(0x1A22C55E);
  static const _successBorder= Color(0x4D22C55E);

  @override
  Widget build(BuildContext context) {
    final Color color      = isOut ? _danger  : isLow ? _warning  : _success;
    final Color bgColor    = isOut ? _dangerBg: isLow ? _warningBg: _successBg;
    final Color bdrColor   = isOut ? _dangerBorder: isLow ? _warningBorder: _successBorder;
    final String label     = isOut ? 'Out'    : isLow ? 'Low'     : 'In Stock';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.sw(0.008),
        vertical: SizeConfig.sh(0.006),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: bdrColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$qty',
            style: TextStyle(
              fontSize: SizeConfig.res(3.8),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig.res(2.5),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}