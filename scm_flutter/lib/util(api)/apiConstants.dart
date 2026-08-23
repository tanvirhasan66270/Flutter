import 'package:flutter/foundation.dart';

class ApiConstants {

  ApiConstants._();

  static String get host {
    if (kIsWeb) {
// Flutter Web
      return 'localhost';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
// Android Emulator
        return '10.0.2.2';

      case TargetPlatform.iOS:
// iOS Simulator
        return 'localhost';

      default:
// Windows / macOS / Linux
        return 'localhost';
    }
  }

  static String get baseUrl => 'http://$host:8085/api/';
  static String get imgUrl => 'http://$host:8085/images/';
  // ── Auth ───────────────────────────────────────────────
  static const String login = 'auth/login';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String verifyEmail = 'auth/verify-email';

  // ── Customer ───────────────────────────────────────────
  static const String customer = 'customer/';
  static String customerByUserId(int userId) => 'customer/user/$userId';
  static String customerById(int id) => 'customer/$id';


  // ── Drivers ────────────────────────────────────────────
  static const String drivers = 'drivers';

  static String driverById(int id) => 'drivers/$id';
  static String driverByUserId(int id) => 'drivers/user/$id';


  // ── Managers ───────────────────────────────────────────
  static const String managers = 'managers';

  static String managerById(int id) => 'managers/$id';
  static String managerByUserId(int id) => 'managers/user/$id';



  // ── Suppliers ──────────────────────────────────────────
  static const String suppliers = 'suppliers';

  static String supplierById(int id) => 'suppliers/$id';
  static String supplierByUserId(int id) => 'suppliers/user/$id';




  // ── Address hierarchy ────────────────────────────────────
  static const String country = 'country/';
  static String divisionsByCountry(int countryId) =>
      'division/country/$countryId';
  static String districtsByDivision(int divisionId) => 'district/$divisionId';
  static String policeStationsByDistrict(int districtId) =>
      'policeStation/district/$districtId';
  static String policeStationSearch(String keyword) =>
      'policeStation/search?keyword=$keyword';



// ── Customer Orders ────────────────────────────────────
  static const String customerOrders = 'customerOrders';
  static const String createCustomerOrder = 'customerOrders'; // POST
  static const String customerOrdersByEmail = 'customerOrders/customer';
  static const String trackCustomerOrder = 'customerOrders/track'; // queryParam: orderNumber
  static const String verifyPaymentLink = 'customerOrders/verify-link'; // queryParam: orderId, amountPaid, method

  static String customerOrderById(int id) => 'customerOrders/$id';
  static String updateCustomerOrderStatus(int id) => 'customerOrders/$id/status';

  // ── Order Line Items ───────────────────────────────────
  static const String orderItems = 'order-items';

  static String orderItemById(int id) => 'order-items/$id';
  static String orderItemsByOrderId(int orderId) => 'order-items/order/$orderId';


  // ── Delivery Trips ─────────────────────────────────────
  static const String deliveryTrips = 'delivery-trips';

  static String deliveryTripById(int id) => 'delivery-trips/$id';
  static String updateDeliveryTripStatus(int id) => 'delivery-trips/$id/status';


  // ── Purchase Requisitions ──────────────────────────────
  static const String purchaseRequisitions = 'purchase-requisitions';

  static String purchaseRequisitionById(int id) => 'purchase-requisitions/$id';
  static String approvePurchaseRequisition(int id) => 'purchase-requisitions/$id/approve';
  static String rejectOrCancelPurchaseRequisition(int id) => 'purchase-requisitions/$id/reject-or-cancel';


  // ── Quotations ─────────────────────────────────────────
  static const String quotations = 'quotations';

  static String quotationById(int id) => 'quotations/$id';
  static String updateQuotationStatus(int id) => 'quotations/$id/status';


  // ── Purchase Orders ────────────────────────────────────
  static const String purchaseOrders = 'purchase-orders';
  static const String emailIssueOrder = 'purchase-orders/email-issue'; // queryParam: token
  static const String emailReceiveOrder = 'purchase-orders/email-receive'; // queryParam: token

  static String purchaseOrderById(int id) => 'purchase-orders/$id';
  static String purchaseOrdersBySupplier(int supplierId) => 'purchase-orders/supplier/$supplierId';
  static String updatePurchaseOrderStatus(int id) => 'purchase-orders/$id/status';
  static String approvePurchaseOrder(int id) => 'purchase-orders/$id/approve';

// ── Purchase Order Line Items ──────────────────────────
  static const String poLineItems = 'po-line-items';

  static String poLineItemById(int id) => 'po-line-items/$id';
  static String trackPoLineItem(String trackingNumber) => 'po-line-items/track/$trackingNumber';


  // ── Goods Received Notes (GRN) ─────────────────────────
  static const String goodsReceivedNotes = 'goods-received-notes';

  static String goodsReceivedNoteById(int id) => 'goods-received-notes/$id';



  // ── Invoices ───────────────────────────────────────────
  static const String invoices = 'invoices';

  static String invoiceById(int id) => 'invoices/$id';




  // ── Payment Statements ─────────────────────────────────
  static const String paymentStatements = 'payment-statements';

  static String paymentStatementById(int id) => 'payment-statements/$id';
  static String updatePaymentStatus(int id) => 'payment-statements/$id/status'; // queryParam: status
  static String paymentsByOrderId(int orderId) => 'payment-statements/order/$orderId';
  static String paymentsByOrderNumber(String orderNumber) => 'payment-statements/order-number/$orderNumber';
  static String paymentsByStatus(String status) => 'payment-statements/status/$status';




  // ── QC Inspections & Checklists ────────────────────────
  static const String qcInspections = 'qc-inspections';
  static const String qcChecklists = 'qc-checklists';

  static String qcInspectionById(int id) => 'qc-inspections/$id';

  static String qcChecklistById(int id) => 'qc-checklists/$id';
  static String qcChecklistsByInspectionId(int inspectionId) => 'qc-checklists/inspection/$inspectionId';


// ── Products ───────────────────────────────────────────
  static const String products = 'products';

  static String productById(int id) => 'products/$id';


  // ── Product Requirements ───────────────────────────────
  static const String productRequirements = 'product-requirements';

  static String productRequirementById(int id) => 'product-requirements/$id';
  static String updateProductRequirementStatus(int id) => 'product-requirements/$id/status';


  // ── Vehicles ───────────────────────────────────────────
  static const String vehicles = 'vehicles';

  static String vehicleById(int id) => 'vehicles/$id';


}