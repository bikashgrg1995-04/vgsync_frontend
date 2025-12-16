import 'package:vgsync_frontend/app/data/services/item_service.dart';
import '../../modules/dashboard/dashboard_controller.dart'; // For LowStockItem

class ItemRepository {
  final ItemService itemService;

  ItemRepository({required this.itemService});

  Future<List> getAllItems() {
    return itemService.getAllItems();
  }

  Future<int> getCount() async {
    final items = await getAllItems();
    return items.length;
  }

  // ------------------------
  // Dashboard helper: low stock items
  // ------------------------
  Future<List<LowStockItem>> getLowStock({int threshold = 5}) async {
    final items = await getAllItems();

    // Filter items with stock <= threshold
    final lowStockItems = items.where((item) {
      final stock = item['stock'] ?? 0;
      return stock <= threshold;
    }).toList();

    return lowStockItems
        .map((item) => LowStockItem(
              name: item['name'] ?? 'Unknown',
              stock: item['stock'] ?? 0,
            ))
        .toList();
  }
}
