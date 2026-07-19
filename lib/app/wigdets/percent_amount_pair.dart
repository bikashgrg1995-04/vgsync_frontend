import 'package:flutter/material.dart';
import 'package:vgsync_frontend/app/themes/app_colors.dart';
import 'package:vgsync_frontend/utils/size_config.dart';

Widget buildPercentAmountPair({
  required String label,
  required TextEditingController percentController,
  required TextEditingController amountController,
  required VoidCallback onChanged,
  double width = 0.16,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(
              fontSize: SizeConfig.res(3.2), color: AppColors.textSecondary)),
      SizedBox(height: SizeConfig.sh(0.005)),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: SizeConfig.sw(width),
            height: SizeConfig.sh(0.03),
            child: TextField(
              controller: percentController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontSize: SizeConfig.res(3.4), color: AppColors.textPrimary),
              decoration: const InputDecoration(
                isDense: true,
                suffixText: '%',
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          SizedBox(
            width: SizeConfig.sw(0.08),
            height: SizeConfig.sh(0.03),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                  fontSize: SizeConfig.res(3.4), color: AppColors.textPrimary),
              decoration: const InputDecoration(
                isDense: true,
                prefixText: 'Rs.',
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    ],
  );
}
