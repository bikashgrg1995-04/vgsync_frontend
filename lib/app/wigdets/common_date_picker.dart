import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

class CommonDatePicker extends StatelessWidget {
  final String label;
  final Rxn<DateTime> selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CommonDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: SizeConfig.sh(0.01)),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value ?? DateTime.now(),
                      firstDate: firstDate ?? DateTime(2000),
                      lastDate: lastDate ?? DateTime(2100),
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                  child: Container(
                    height: SizeConfig.sh(0.075),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedDate.value == null
                                ? 'Select date'
                                : _formatDate(selectedDate.value!),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.sw(0.01)),
              SizedBox(
                height: SizeConfig.sh(0.06),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    selectedDate.value = DateTime.now();
                  },
                  child: const Text(
                    'Today',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  String _formatDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
