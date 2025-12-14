import 'package:vgsync_frontend/app/data/services/item_service.dart';

class ItemRepository {
  final ItemService itemService;

  ItemRepository({required this.itemService});

  Future<List> getAllItems() {
    return itemService.getAllItems();
  }
}
