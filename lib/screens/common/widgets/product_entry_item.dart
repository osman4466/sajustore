import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_styles.dart';

/// State model for dynamic product row inputs.
class ProductRowModel {
  final TextEditingController nameController;
  final TextEditingController amountController;

  ProductRowModel({String initialName = '', String initialAmount = ''})
      : nameController = TextEditingController(text: initialName),
        amountController = TextEditingController(text: initialAmount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }

  String get name => nameController.text.trim();
  double? get amount => double.tryParse(amountController.text.trim());
  bool get isValid => name.isNotEmpty && amount != null && amount! > 0;
}

/// Dynamic Product Row item widget.
class ProductRowWidget extends StatelessWidget {
  final int index;
  final ProductRowModel model;
  final VoidCallback onAmountChanged;
  final VoidCallback? onRemove;

  const ProductRowWidget({
    super.key,
    required this.index,
    required this.model,
    required this.onAmountChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: model.nameController,
              decoration: const InputDecoration(
                hintText: AppStrings.productNameHint,
              ),
            ),
          ),
          const SizedBox(width: AppStyles.p8),
          Expanded(
            flex: 2,
            child: TextField(
              controller: model.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: AppStrings.productAmountHint,
                prefixText: '৳ ',
              ),
              onChanged: (_) => onAmountChanged(),
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 22),
              tooltip: 'মুছুন',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
