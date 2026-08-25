import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/util/apiConstants.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductResponseModel product;

  String _resolveImageUrl(String? imgPath) {
    if (imgPath == null || imgPath.trim().isEmpty) return '';
    final trimmed = imgPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/images/')) {
      return '${ApiConstants.imgUrl}${trimmed.substring(8)}';
    }
    if (trimmed.startsWith('images/')) {
      return '${ApiConstants.imgUrl}${trimmed.substring(7)}';
    }
    if (trimmed.startsWith('product/')) {
      return '${ApiConstants.imgUrl}$trimmed';
    }
    return '${ApiConstants.imgUrl}product/$trimmed';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAvailable = product.quantity > 0;
    final imageUrl = _resolveImageUrl(product.image);

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
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isAvailable ? Colors.green.shade200 : Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: isAvailable ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable ? 'Available In Stock' : 'Out of Stock',
                        style: TextStyle(color: isAvailable ? Colors.green.shade700 : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SKU: ${product.productCode}',
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
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
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, st) => const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                          )
                        : const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(Icons.qr_code, 'Product Code', product.productCode, Colors.blue),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.inventory_2, 'Name', product.name, Colors.green),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.category, 'Category ID', '${product.categoryId}', Colors.indigo),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.sell_outlined, 'Price', '৳${product.sellingPrice.toStringAsFixed(2)}', const Color(0xFF2563EB)),
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('PRODUCT SPECIFICATIONS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
                  _buildDetailRow(Icons.shopping_bag_outlined, 'Stock Quantity', '${product.quantity}', Colors.blue),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.balance, 'Weight', '${product.weight} kg', Colors.green),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.attach_money, 'Unit Cost', '৳${product.unitCost.toStringAsFixed(2)}', Colors.blue),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.sell_outlined, 'Selling Price', '৳${product.sellingPrice.toStringAsFixed(2)}', Colors.green),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.refresh, 'Reorder Point', '${product.reorderPoint}', Colors.purple),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.check_circle_outline, 'Availability Status', isAvailable ? 'AVAILABLE' : 'OUT OF STOCK', Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order / Place Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.shopping_cart, size: 18),
                label: const Text('Dispatch / Order Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () {
                  Navigator.pushNamed(context, '/customer-order');
                },
              ),
            ),
            const SizedBox(height: 24),
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
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
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
    bool isRed = value == 'OUT OF STOCK';

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