import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/productModel.dart'; 

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductResponseModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PRODUCT DETAILS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(radius: 4, backgroundColor: Colors.red),
                      SizedBox(width: 6),
                      Text('Inactive Product', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detailed information about the selected product',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: product.image.isNotEmpty
                        ? Image.network(product.image, fit: BoxFit.contain, errorBuilder: (ctx, err, st) => const Icon(Icons.image, size: 60, color: Colors.grey))
                        : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(Icons.qr_code, 'Product Code', product.productCode, Colors.blue),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.inventory_2, 'Name', product.name, Colors.green),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.category, 'Category', 'Electronics (ID: 1)', Colors.indigo), // ডাইনামিক ক্যাটাগরি নাম দিতে পারেন
                  const Divider(height: 24),
                  _buildInfoRow(Icons.layers, 'Unit', 'PCS', Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.list_alt, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('PRODUCT INFORMATION', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.shopping_bag_outlined, 'Quantity', '${product.quantity}', Colors.blue),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.balance, 'Weight', '${product.weight}', Colors.green),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.attach_money, 'Unit Cost', '৳${product.unitCost.toStringAsFixed(1)}', Colors.blue),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.sell_outlined, 'Selling Price', '৳${product.sellingPrice.toStringAsFixed(1)}', Colors.green),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.refresh, 'Reorder Point', '${product.reorderPoint}', Colors.purple),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.check_circle_outline, 'Availability', product.quantity > 0 ? 'AVAILABLE' : 'OUT OF STOCK', Colors.teal),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.calendar_today, 'Has Expiry Date', 'NO', Colors.orange),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.power_settings_new, 'Active Status', 'Inactive', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    bool isGreen = value == 'AVAILABLE' || value.startsWith('৳');
    bool isRed = value == 'Inactive' || value == 'OUT OF STOCK';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500))),
        const Text(':  ', style: TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isGreen ? Colors.green : (isRed ? Colors.red : Colors.black87),
          ),
        ),
      ],
    );
  }
}