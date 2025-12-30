import '../models/stock_model.dart';
import '../services/stock_service.dart';

class StockRepository {
  final StockService stockService;

  StockRepository({required this.stockService});

  Future<List<Result>> getStocks() => stockService.getStocks();
  Future<Result> create(Result stock) => stockService.createStock(stock);
  Future<Result> update(Result stock) => stockService.updateStock(stock);
  Future<void> delete(int id) => stockService.deleteStock(id);
}
