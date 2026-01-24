import 'package:flutter/material.dart';
import 'package:number_pagination/number_pagination.dart';

// ---------------- GENERIC CELL BUILDER ----------------
typedef CellBuilder<T> = Widget Function(T item, int index);

class ModernTable<T> extends StatelessWidget {
  final String title;
  final List<String> columnTitles;
  final List<T> rows; // only current page data
  final List<CellBuilder<T>> cellBuilders;
  final double height;

  // Pagination
  final int currentPage; // 0-based index
  final int totalPages;
  final Function(int) onPageChanged; // callback, receives 0-based page index

  const ModernTable({
    super.key,
    required this.title,
    required this.columnTitles,
    required this.rows,
    required this.cellBuilders,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.height = 300,
  });

  double _getColumnWidth(String columnName) {
    switch (columnName.toLowerCase()) {
      case "s/n":
        return 30;
      case "item no":
        return 180;
      case "name":
        return 150;
      case "stock":
        return 45;
      case "date":
      case "order date":
        return 110;

      case "followup date":
      case "customer":
      case "staff":
        return 130;

      case "total":
      case "salary":
        return 80;
      default:
        return 90;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Divider(thickness: 2),

          // Scrollable Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minWidth: columnTitles.length * 100.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 12,
                    headingRowHeight: 40,
                    dataRowHeight: 40,
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columns: columnTitles
                        .map(
                          (t) => DataColumn(
                            label: SizedBox(
                              width: _getColumnWidth(t),
                              child: Text(
                                t,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    rows: rows.isEmpty
                        ? [
                            DataRow(
                              cells: columnTitles
                                  .map(
                                    (_) => const DataCell(
                                      Text(
                                        "-",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ]
                        : rows.asMap().entries.map((entry) {
                            final index = entry.key;
                            final row = entry.value;
                            return DataRow(
                              cells: cellBuilders
                                  .asMap()
                                  .entries
                                  .map(
                                    (cellEntry) => DataCell(
                                      SizedBox(
                                        width: _getColumnWidth(
                                            columnTitles[cellEntry.key]),
                                        child: cellEntry.value(row, index),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          }).toList(),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 30, // smaller pagination height
              child: NumberPagination(
                currentPage: currentPage + 1, // 1-based
                totalPages: totalPages,
                selectedButtonColor: Colors.blueAccent,
                onPageChanged: (page) {
                  onPageChanged(page - 1); // back to 0-based index
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
