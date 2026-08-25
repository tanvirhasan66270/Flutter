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
import 'package:scm_flutter/invoice/invoice_portal_screen.dart';
import 'package:scm_flutter/product/screen/product_details_screen.dart';
import 'package:scm_flutter/product/screen/product_screen.dart';
import 'package:scm_flutter/system/massage/chat_workspace_screen.dart';
import 'package:scm_flutter/system/notification/notification_screen.dart';


/// Mirrors app.routes.ts + guards/auth-guard.ts + role-redirect component.
///
/// This app currently implements the CUSTOMER role end-to-end (matching the
/// "Auth + Customer module first" scope). AGENT/ADMIN/RIDER dashboards can
/// be added the same way: new screens under `features/<role>/screens`, and a
/// branch in [RoleRedirectScreen].
class AppRouter {
AppRouter._();

static Route<dynamic> onGenerateRoute(RouteSettings settings) {
final name = settings.name ?? '/';

    // Deep-link style routes with a path segment, e.g. /track/CM12345
    if (name.startsWith('/track/')) {
      // final code = Uri.decodeComponent(name.substring('/track/'.length));
      // return MaterialPageRoute(
      //   builder: (_) => ParcelDetailScreen(trackingCode: code),
      //   settings: settings,
      // );
    }

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
// case '/reset-password':
// final token = (settings.arguments as Map?)?['token'] as String?;
// return MaterialPageRoute(
// builder: (_) => ResetPasswordScreen(token: token),
// settings: settings,
// );
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

// ── Customer (auth-guarded) ─────────────────────────
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

  case '/':
  default:
    return MaterialPageRoute(
      builder: (_) => const RoleRedirectScreen(),
      settings: settings,
    );


}
}
}

/// Mirrors components/auth/role-redirect/role-redirect.ts — decides where to
/// send the user based on session state + role.
class RoleRedirectScreen extends ConsumerWidget {
  const RoleRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () =>
      const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (user) {
        if (user == null) return const LoginScreen();


        switch (user.role.toUpperCase()) {

          case 'CUSTOMER':
            return const CustomerDashboardScreen();
          case 'ADMIN':
          case 'MANAGER':
          case 'PROCUREMENT':
          case 'QC_INSPECTOR':
          case 'LOGISTICS_OFFICER':
          case 'COMMERCIAL_OFFICER':
          case 'SALES_OFFICER':
          case 'SUPPLIER':
          // Not yet implemented in this module pass — see class doc.
            return Scaffold(
              appBar: AppBar(title: Text('${user.role} Dashboard')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'The ${user.role} dashboard is not built yet in this '
                        'Flutter conversion pass. The Customer module is fully '
                        'wired up — ask to have this role added next.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

/// Route guard: mirrors authGuard (canActivate) — redirects to /login if
/// there's no active session by the time this widget builds.
class _RequireAuth extends ConsumerWidget {
  const _RequireAuth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () =>
      const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const LoginScreen(),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          });
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return child;
      },
    );
  }
}