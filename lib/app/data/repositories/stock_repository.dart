import '../models/stock_model.dart';
import '../services/stock_service.dart';

class StockRepository {
  final StockService stockService;

  StockRepository({required this.stockService});

  Future<List<StockModel>> getStocks() =>
      stockService.getStocks();

  Future<StockModel> create(StockModel stock) =>
      stockService.createStock(stock);

  Future<StockModel> update(StockModel stock) =>
      stockService.updateStock(stock);

  Future<void> delete(int id) =>
      stockService.deleteStock(id);
}