import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scm_flutter/auth/authProvider.dart';
import 'package:scm_flutter/auth/screen/forgetPasswordScreen.dart';
import 'package:scm_flutter/auth/screen/loginScreen.dart';
import 'package:scm_flutter/auth/screen/verifyEmail.dart';
import 'package:scm_flutter/cutomer/screen/add_payment_screen.dart';
import 'package:scm_flutter/cutomer/screen/billing_ledger_screen.dart';
import 'package:scm_flutter/cutomer/screen/customerDashboardScreen.dart';
import 'package:scm_flutter/cutomer/screen/customer_order_data_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_order_screen.dart';
import 'package:scm_flutter/cutomer/screen/customer_oredr_track_page.dart';
import 'package:scm_flutter/cutomer/screen/customer_profile_screen.dart';
import 'package:scm_flutter/entity/productModel.dart';
import 'package:scm_flutter/entity/purchase_requisition_model.dart';
import 'package:scm_flutter/entity/quatation_model.dart';
import 'package:scm_flutter/entity/shipment_model.dart';
import 'package:scm_flutter/invoice/invoice_portal_screen.dart';
import 'package:scm_flutter/procourment/screen/procourmet_dashboard_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase-order_screen.dart';
import 'package:scm_flutter/procourment/screen/po_line_item_data_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_order_data_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_data_pdf_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_data_screen.dart';
import 'package:scm_flutter/procourment/screen/purchase_requisition_screen.dart';
import 'package:scm_flutter/procourment/screen/shipment_data_screen.dart';
import 'package:scm_flutter/procourment/screen/shipment_pdf_screen.dart';
import 'package:scm_flutter/procourment/screen/supplier_data_screen.dart';
import 'package:scm_flutter/procourment/screen/track_po_screen.dart';
import 'package:scm_flutter/product/screen/product_details_screen.dart';
import 'package:scm_flutter/product/screen/product_screen.dart';
import 'package:scm_flutter/suppplier/screen/po_line_item_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/quotation_data_pdf_screen.dart';
import 'package:scm_flutter/suppplier/screen/quotation_data_screen.dart';
import 'package:scm_flutter/suppplier/screen/register_quotation_screen.dart';
import 'package:scm_flutter/suppplier/screen/shipment_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/shipment_update_form_screen.dart';
import 'package:scm_flutter/suppplier/screen/supplier_dashboard_screen.dart';
import 'package:scm_flutter/suppplier/screen/supplier_form_screen.dart';
import 'package:scm_flutter/system/massage/chat_workspace_screen.dart';
import 'package:scm_flutter/system/notification/notification_screen.dart';

/// App routing & role redirection manager.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';

    switch (name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case '/verify-email':
        final token = (settings.arguments as Map?)?['token'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(token: token),
          settings: settings,
        );

      case '/products':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ProductScreen()),
          settings: settings,
        );

      case '/product-details':
        final product = settings.arguments as ProductResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: ProductDetailsScreen(product: product)),
          settings: settings,
        );

      // ── Customer Routes ─────────────────────────
      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerDashboardScreen()),
          settings: settings,
        );

      case '/customer-orders':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerOrderDataScreen()),
          settings: settings,
        );

      case '/customer-order':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerOrderScreen()),
          settings: settings,
        );

      case '/customer-order-track':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: CustomerOrderTrackScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/add-payment':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: AddPaymentScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/billing-ledger':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: BillingLedgerScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/invoice-portal':
        final orderNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: InvoicePortalScreen(initialOrderNumber: orderNo)),
          settings: settings,
        );

      case '/messages':
      case '/support':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ChatWorkspaceScreen()),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: CustomerProfileScreen()),
          settings: settings,
        );

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: NotificationScreen()),
          settings: settings,
        );

      // ── Procurement Routes ─────────────────────────
      case '/procurement-dashboard':
      case '/procurement':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ProcurementDashboardScreen()),
          settings: settings,
        );

      case '/purchase-orders':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseOrderDataScreen()),
          settings: settings,
        );

      case '/track-po':
        final poNo = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: PurchaseOrderTrackingScreen(initialPoNumber: poNo)),
          settings: settings,
        );

      case '/purchase-order-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseOrderScreen()),
          settings: settings,
        );

      case '/purchase-requisitions':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseRequisitionDataScreen()),
          settings: settings,
        );

      case '/purchase-requisition-pdf':
        final requisition = settings.arguments as PurchaseRequisitionResponse;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: PurchaseRequisitionDataPDFScreen(requisition: requisition)),
          settings: settings,
        );

      case '/purchase-requisition-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: PurchaseRequisitionScreen()),
          settings: settings,
        );

      case '/quotations':
        final statusArg = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: QuotationDataScreen(initialStatus: statusArg)),
          settings: settings,
        );

      case '/quotation-create':
        final quotationToEdit = settings.arguments as QuotationResponseModel?;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: RegisterQuotationScreen(quotationToEdit: quotationToEdit)),
          settings: settings,
        );

      case '/quotation-pdf':
        final quotation = settings.arguments as QuotationResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: QuotationDataPDFScreen(quotation: quotation)),
          settings: settings,
        );

      case '/shipments':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ShipmentDataScreen()),
          settings: settings,
        );

      case '/shipment-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ShipmentFormScreen()),
          settings: settings,
        );

      case '/shipment-update':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: ShipmentUpdateFormScreen()),
          settings: settings,
        );

      case '/shipment-pdf':
        final shipment = settings.arguments as ShipmentResponseModel;
        return MaterialPageRoute(
          builder: (_) => _RequireAuth(child: ShipmentPDFScreen(shipment: shipment)),
          settings: settings,
        );

      case '/po-line-items':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: POLineItemDataScreen()),
          settings: settings,
        );

      case '/po-line-item-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: POLineItemFormScreen()),
          settings: settings,
        );

      case '/supplier-create':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: SupplierFormScreen()),
          settings: settings,
        );

      case '/suppliers':
        return MaterialPageRoute(
          builder: (_) => const _RequireAuth(child: SupplierDataScreen()),
          settings: settings,
        );

      case '/':
      default:
        return MaterialPageRoute(
          builder: (_) => const RoleRedirectScreen(),
          settings: settings,
        );
    }
  }
}

/// Decides initial route based on active user session & role.
class RoleRedirectScreen extends ConsumerWidget {
  const RoleRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();

        switch (user.role.toUpperCase()) {
          case 'CUSTOMER':
            return const CustomerDashboardScreen();
          case 'ADMIN':
          case 'MANAGER':
          case 'PROCUREMENT':
          case 'PROCUREMENT_OFFICER':
          case 'PURCHASING':
          case 'COMMERCIAL_OFFICER':
            return const ProcurementDashboardScreen();
          case 'SUPPLIER':
            return const SupplierDashboardScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Route guard for auth session check.
class _RequireAuth extends ConsumerWidget {
  const _RequireAuth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return child;
      },
    );
  }
}