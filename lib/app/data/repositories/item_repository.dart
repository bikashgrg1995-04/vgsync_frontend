import 'package:vgsync_frontend/app/data/models/dashboard_model.dart';
import 'package:vgsync_frontend/app/data/services/item_service.dart';

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
  // Dashboard helper
  // ------------------------
  Future<List<LowStockItem>> getLowStock({int threshold = 5}) async {
    final items = await getAllItems();

    return items
        .where((item) => (item['stock'] ?? 0) <= threshold)
        .map((item) => LowStockItem.fromJson(item))
        .toList();
  }
}
