import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/cutomer/provider/customer_provider.dart';
import 'package:scm_flutter/entity/customerModel.dart';
import 'package:scm_flutter/them/allAppThim.dart';
import 'package:scm_flutter/util/apiClint.dart';
import 'package:scm_flutter/widget/commonWidget.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(currentCustomerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ],
      ),
      body: customerAsync.when(
        data: (customer) => customer == null ? const Center(child: Text('Customer not found')) : _buildProfileBody(customer),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: ErrorBanner(message: apiErrorMessage(e))),
      ),
    );
  }

  Widget _buildProfileBody(CustomerResponseModel customer) {
    // Calculate completion percentage (mock logic)
    int completedFields = 0;
    if (customer.name.isNotEmpty) completedFields++;
    if (customer.email.isNotEmpty) completedFields++;
    if (customer.phone.isNotEmpty) completedFields++;
    if (customer.gender.isNotEmpty) completedFields++;
    if (customer.dob.isNotEmpty) completedFields++;
    if (customer.nidNumber.isNotEmpty) completedFields++;
    if (customer.image.isNotEmpty) completedFields++;
    final completion = (completedFields / 7 * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Section ──────────────────────────
          _buildHeader(customer),
          const SizedBox(height: 24),

          // ── Action Buttons ──────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Choose New Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('UPLOAD NEW AVATAR'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),

          // ── Completion Section ──────────────────────
          _buildCompletionSection(completion),
          const SizedBox(height: 24),

          // ── Edit Personal Settings ──────────────────
          const Text('EDIT PERSONAL SETTINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _buildSettingsList(customer),
          const SizedBox(height: 24),

          // ── Logistics & Location Metadata ───────────
          const Text('LOGISTICS & LOCATION METADATA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          _buildLocationSection(customer),
          const SizedBox(height: 12),
          
          // Registered Date
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Registered: ${customer.createdAt}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Update Button ───────────────────────────
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('UPDATE PROFILE REGISTRY'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(CustomerResponseModel customer) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              backgroundImage: customer.image.isNotEmpty ? NetworkImage(customer.image) : null,
              child: customer.image.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF0D6EFD), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Row(
                children: [
                  const Text('Role: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(customer.role.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D6EFD))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade100)),
                      child: Column(
                        children: [
                          const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            Icon(Icons.star, color: Colors.orange, size: 12),
                            SizedBox(width: 4),
                            Text('SCORE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade100)),
                      child: Column(
                        children: [
                          const Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 12),
                            SizedBox(width: 4),
                            Text('STATUS', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionSection(int completion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Completion Profile', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              Text('$completion%', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: Colors.grey.shade100,
            color: AppTheme.primary,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          _buildCompletionStep('Customer Name Node', true),
          _buildCompletionStep('Communication Link', true),
          _buildCompletionStep('Identity Avatar Image', completion > 80),
        ],
      ),
    );
  }

  Widget _buildCompletionStep(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.circle_outlined, size: 16, color: isDone ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: isDone ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsList(CustomerResponseModel customer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingTile(Icons.person_outline, 'Full Customer Name', customer.name),
          const Divider(height: 1, indent: 60),
          _buildSettingTile(Icons.email_outlined, 'Corporate Secure Email', customer.email),
          const Divider(height: 1, indent: 60),
          _buildSettingTile(Icons.phone_outlined, 'Secure Mobile Route', customer.phone),
          const Divider(height: 1, indent: 60),
          _buildSettingTile(Icons.male_outlined, 'Gender Node', customer.gender.toUpperCase(), hasChevron: true),
          const Divider(height: 1, indent: 60),
          _buildSettingTile(Icons.calendar_today_outlined, 'Date of Birth', customer.dob, hasChevron: true),
          const Divider(height: 1, indent: 60),
          _buildSettingTile(Icons.badge_outlined, 'National ID (NID)', customer.nidNumber, hasChevron: true),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String label, String value, {bool hasChevron = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      trailing: hasChevron ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildLocationSection(CustomerResponseModel customer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: AppTheme.primary, size: 18),
              SizedBox(width: 8),
              Text('SYSTEM TRACK TERMINAL', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _locationMeta('Division Node', customer.divisionName),
          _locationMeta('District Sector', customer.districtName),
          _locationMeta('Police Station', customer.policeStationName),
          const Divider(color: Color(0xFFDBEAFE), height: 24),
          const Text('Detailed Dispatch Address HQ', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(customer.address, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _locationMeta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
