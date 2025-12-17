import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemRepository {
  final ItemService itemService;

  ItemRepository({required this.itemService});

  Future<List<ItemModel>> fetchItems() async {
    return await itemService.getItems();
  }

  Future<ItemModel> addItem(ItemModel item) async {
    return await itemService.createItem(item);
  }

  Future<ItemModel> editItem(ItemModel item) async {
    return await itemService.updateItem(item);
  }

  Future<void> removeItem(int id) async {
    return await itemService.deleteItem(id);
  }
}
