import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/invoices/client_invoices_bloc.dart';
import '../bloc/invoices/client_invoices_event.dart';
import '../bloc/invoices/client_invoices_state.dart';
import '../bloc/inspection_invoices/client_inspection_invoices_bloc.dart';
import '../bloc/inspection_invoices/client_inspection_invoices_event.dart';
import '../bloc/inspection_invoices/client_inspection_invoices_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/search_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ClientInvoicesScreen extends StatelessWidget {
  final int initialIndex;

  const ClientInvoicesScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 0,
                left: 20,
                right: 20,
              ),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                border: Border(
                  bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invoices & PRNs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Manage Payment References',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go('/client/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const TabBar(
                    indicatorColor: AppTheme.accentGold,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(text: 'General Invoices'),
                      Tab(text: 'Inspection Fees'),
                    ],
                  ),
                ],
              ),
            ),

            // TabBarView Body
            Expanded(
              child: TabBarView(
                children: [
                  _buildGeneralInvoicesView(context),
                  _buildInspectionInvoicesView(context),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2, // Invoices index
          onTap: (index) {
            if (index == 0) context.go('/client/dashboard');
            if (index == 1) context.go('/client/applications');
            if (index == 2) return;
            if (index == 3) context.go('/client/profile');
          },
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Applications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Invoices'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInvoicesView(BuildContext context) {
    return Column(
      children: [
        // Search & Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              SearchBarWidget(
                onChanged: (val) => context.read<ClientInvoicesBloc>().add(SearchClientInvoices(val)),
              ),
              const SizedBox(height: 15),
              BlocBuilder<ClientInvoicesBloc, ClientInvoicesState>(
                builder: (context, state) {
                  String currentFilter = 'ALL';
                  String? pendingBadge;
                  if (state is ClientInvoicesLoaded) {
                    currentFilter = state.selectedFilter;
                    if (state.totalUnpaid != null && state.totalUnpaid!.isNotEmpty && state.totalUnpaid != '0.00' && state.totalUnpaid != '0') {
                       try {
                         pendingBadge = CurrencyFormatter.formatUgx(double.parse(state.totalUnpaid!));
                       } catch (_) {}
                    }
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildGeneralFilterChip(context, 'ALL', currentFilter, null),
                        _buildGeneralFilterChip(
                            context, 'PENDING', currentFilter, pendingBadge),
                        _buildGeneralFilterChip(context, 'PAID', currentFilter, null),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // List body
        Expanded(
          child: BlocBuilder<ClientInvoicesBloc, ClientInvoicesState>(
            builder: (context, state) {
              if (state is ClientInvoicesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ClientInvoicesError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is ClientInvoicesLoaded) {
                var displayInvoices = state.invoices;
                if (state.searchQuery != null && state.searchQuery!.length >= 3) {
                  final sq = state.searchQuery!.toLowerCase();
                  displayInvoices = state.invoices.where((i) {
                     return (i.applicationKey.toLowerCase().contains(sq)) ||
                            (i.prn.toLowerCase().contains(sq)) ||
                            (i.searchCode.toLowerCase().contains(sq));
                  }).toList();
                }

                if (displayInvoices.isEmpty) {
                  return const Center(child: Text('No invoices found.'));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      context.read<ClientInvoicesBloc>().add(
                        LoadMoreClientInvoices(),
                      );
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount:
                        displayInvoices.length + (state.hasReachedMax ? 0 : (state.searchQuery != null && state.searchQuery!.length >= 3 ? 0 : 1)),
                    itemBuilder: (context, index) {
                      if (index >= displayInvoices.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final invoice = displayInvoices[index];
                      final isPaid = invoice.paymentStatus == 'PAID';
                      final currentStatus = isPaid ? 'PAID' : 'PENDING PAYMENT';

                      Color statusColor = const Color(0xFF1E7E34);
                      Color statusBg = const Color(0xFFE6F4EA);
                      Color borderColor = const Color(0xFF1E7E34);
                      String actionText = '📄 DOWNLOAD RECEIPT';
                      Color actionColor = Colors.white;
                      Color actionTextColor = AppTheme.primaryGreen;
                      
                      String? secondaryActionText;
                      Color? secondaryActionColor;
                      Color? secondaryActionTextColor;
                      VoidCallback? onSecondaryActionTap;

                      if (!isPaid) {
                        statusColor = const Color(0xFFB8860B);
                        statusBg = const Color(0xFFFFF9E6);
                        borderColor = AppTheme.accentGold;
                        actionText = '💸 PAY NOW';
                        actionColor = AppTheme.primaryGreen;
                        actionTextColor = Colors.white;
                        
                        secondaryActionText = '📄 INVOICE';
                        secondaryActionColor = Colors.white;
                        secondaryActionTextColor = AppTheme.primaryGreen;
                        onSecondaryActionTap = () async {
                           final invoiceUrl = invoice.documents?['invoice'];
                           if (invoiceUrl != null && invoiceUrl.toString().isNotEmpty) {
                             final uri = Uri.parse(invoiceUrl);
                             if (await canLaunchUrl(uri)) {
                               await launchUrl(uri, mode: LaunchMode.externalApplication);
                             }
                           }
                        };
                      }

                      return GestureDetector(
                        onTap: () {
                          context.push('/client/invoices/${invoice.prn}');
                        },
                        child: _buildInvoiceCard(
                          prn: invoice.prn,
                          statusText: currentStatus,
                          statusColor: statusColor,
                          statusBg: statusBg,
                          refId: invoice.applicationKey,
                          refLabel: 'App Key',
                          refColor: const Color(0xFF444444),
                          searchCode: invoice.searchCode,
                          searchLabel: 'Search Code',
                          amount: CurrencyFormatter.formatUgx(
                            double.parse(invoice.assessmentAmount) +
                                double.parse(invoice.inspectionFees) +
                                double.parse(invoice.landscapingFees),
                          ),
                          borderColor: borderColor,
                          actionText: actionText,
                          actionColor: actionColor,
                          actionTextColor: actionTextColor,
                          onActionTap: isPaid
                              ? () async {
                                  final receiptUrl = invoice.documents?['receipt'];
                                  if (receiptUrl != null && receiptUrl.toString().isNotEmpty) {
                                    final uri = Uri.parse(receiptUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  }
                                }
                              : () async {
                                  final uri = Uri.parse('tel:*185%23');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                          secondaryActionText: secondaryActionText,
                          secondaryActionColor: secondaryActionColor,
                          secondaryActionTextColor: secondaryActionTextColor,
                          onSecondaryActionTap: onSecondaryActionTap,
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(child: Text('Initializing...'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionInvoicesView(BuildContext context) {
    return Column(
      children: [
        // Search & Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              SearchBarWidget(
                onChanged: (val) => context.read<ClientInspectionInvoicesBloc>().add(SearchClientInspectionInvoices(val)),
              ),
              const SizedBox(height: 15),
              BlocBuilder<ClientInspectionInvoicesBloc, ClientInspectionInvoicesState>(
                builder: (context, state) {
                  String currentFilter = 'ALL';
                  String? pendingBadge;
                  if (state is ClientInspectionInvoicesLoaded) {
                    currentFilter = state.selectedFilter;
                    if (state.totalUnpaid != null && state.totalUnpaid!.isNotEmpty && state.totalUnpaid != '0.00' && state.totalUnpaid != '0') {
                       try {
                         pendingBadge = CurrencyFormatter.formatUgx(double.parse(state.totalUnpaid!));
                       } catch (_) {}
                    }
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildInspectionFilterChip(context, 'ALL', currentFilter, null),
                        _buildInspectionFilterChip(
                            context, 'PENDING', currentFilter, pendingBadge),
                        _buildInspectionFilterChip(context, 'PAID', currentFilter, null),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // List body
        Expanded(
          child: BlocBuilder<ClientInspectionInvoicesBloc, ClientInspectionInvoicesState>(
            builder: (context, state) {
              if (state is ClientInspectionInvoicesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ClientInspectionInvoicesError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is ClientInspectionInvoicesLoaded) {
                var displayInvoices = state.invoices;
                if (state.searchQuery != null && state.searchQuery!.length >= 3) {
                  final sq = state.searchQuery!.toLowerCase();
                  displayInvoices = state.invoices.where((i) {
                     return (i.prn.toLowerCase().contains(sq)) ||
                            (i.searchCode.toLowerCase().contains(sq)) ||
                            (i.referencedPermitSerial.toLowerCase().contains(sq));
                  }).toList();
                }

                if (displayInvoices.isEmpty) {
                  return const Center(child: Text('No inspection invoices found.'));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      context.read<ClientInspectionInvoicesBloc>().add(
                        LoadMoreClientInspectionInvoices(),
                      );
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount:
                        displayInvoices.length + (state.hasReachedMax ? 0 : (state.searchQuery != null && state.searchQuery!.length >= 3 ? 0 : 1)),
                    itemBuilder: (context, index) {
                      if (index >= displayInvoices.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final invoice = displayInvoices[index];
                      final isPaid = invoice.paymentStatus.toUpperCase() == 'PAID';
                      final currentStatus = isPaid ? 'PAID' : 'PENDING PAYMENT';

                      Color statusColor = const Color(0xFF1E7E34);
                      Color statusBg = const Color(0xFFE6F4EA);
                      Color borderColor = const Color(0xFF1E7E34);
                      String actionText = '📄 DOWNLOAD RECEIPT';
                      Color actionColor = Colors.white;
                      Color actionTextColor = AppTheme.primaryGreen;
                      
                      String? secondaryActionText;
                      Color? secondaryActionColor;
                      Color? secondaryActionTextColor;
                      VoidCallback? onSecondaryActionTap;

                      if (!isPaid) {
                        statusColor = const Color(0xFFB8860B);
                        statusBg = const Color(0xFFFFF9E6);
                        borderColor = AppTheme.accentGold;
                        actionText = '💸 PAY NOW';
                        actionColor = AppTheme.primaryGreen;
                        actionTextColor = Colors.white;
                        
                        secondaryActionText = '📄 INVOICE';
                        secondaryActionColor = Colors.white;
                        secondaryActionTextColor = AppTheme.primaryGreen;
                        onSecondaryActionTap = () async {
                           final invoiceUrl = invoice.documents?['invoice'];
                           if (invoiceUrl != null && invoiceUrl.toString().isNotEmpty) {
                             final uri = Uri.parse(invoiceUrl);
                             if (await canLaunchUrl(uri)) {
                               await launchUrl(uri, mode: LaunchMode.externalApplication);
                             }
                           }
                        };
                      }

                      return GestureDetector(
                        onTap: () {
                          context.push(
                              '/client/inspection-invoices/${invoice.prn}');
                        },
                        child: _buildInvoiceCard(
                          prn: invoice.prn,
                          statusText: currentStatus,
                          statusColor: statusColor,
                          statusBg: statusBg,
                          refId: invoice.referencedPermitSerial,
                          refLabel: 'Permit',
                          refColor: const Color(0xFF444444),
                          searchCode: invoice.inspectionFeesCoverPeriod,
                          searchLabel: 'Period',
                          amount: CurrencyFormatter.formatUgx(
                            invoice.invoiceAmount.toDouble()
                          ),
                          borderColor: borderColor,
                          actionText: actionText,
                          actionColor: actionColor,
                          actionTextColor: actionTextColor,
                          onActionTap: isPaid
                              ? () async {
                                  final receiptUrl = invoice.documents?['receipt'];
                                  if (receiptUrl != null && receiptUrl.toString().isNotEmpty) {
                                    final uri = Uri.parse(receiptUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  }
                                }
                              : () async {
                                  final uri = Uri.parse('tel:*185%23');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                          secondaryActionText: secondaryActionText,
                          secondaryActionColor: secondaryActionColor,
                          secondaryActionTextColor: secondaryActionTextColor,
                          onSecondaryActionTap: onSecondaryActionTap,
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(child: Text('Initializing...'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard({
    required String prn,
    required String statusText,
    required Color statusColor,
    required Color statusBg,
    required String refId,
    String refLabel = 'Ref ID',
    Color refColor = const Color(0xFF444444),
    required String searchCode,
    String searchLabel = 'Search Code',
    required String amount,
    required Color borderColor,
    required String actionText,
    Color actionColor = Colors.white,
    Color actionTextColor = AppTheme.primaryGreen,
    VoidCallback? onActionTap,
    String? secondaryActionText,
    Color? secondaryActionColor,
    Color? secondaryActionTextColor,
    VoidCallback? onSecondaryActionTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: borderColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PRN NUMBER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prn,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF0F0F0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDetailBox(refLabel, refId, refColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDetailBox(
                              searchLabel,
                              searchCode,
                              const Color(0xFF444444),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (secondaryActionText != null)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onSecondaryActionTap ?? () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: secondaryActionTextColor ?? AppTheme.primaryGreen,
                                side: BorderSide(
                                  color: secondaryActionTextColor ?? AppTheme.primaryGreen,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                secondaryActionText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onActionTap ?? () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: actionColor,
                                foregroundColor: actionTextColor,
                                elevation: 0,
                                side: BorderSide(
                                  color: actionTextColor == Colors.white
                                      ? actionColor
                                      : actionTextColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                actionText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onActionTap ?? () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionColor,
                            foregroundColor: actionTextColor,
                            elevation: 0,
                            side: BorderSide(
                              color: actionTextColor == Colors.white
                                  ? actionColor
                                  : actionTextColor,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            actionText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralFilterChip(
    BuildContext context,
    String label,
    String currentFilter,
    String? badgeStr,
  ) {
    final isActive = label == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<ClientInvoicesBloc>().add(
          ChangeClientInvoicesFilter(label),
        );
      },
      child: _buildChipUI(label, isActive, badgeStr),
    );
  }

  Widget _buildInspectionFilterChip(
    BuildContext context,
    String label,
    String currentFilter,
    String? badgeStr,
  ) {
    final isActive = label == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<ClientInspectionInvoicesBloc>().add(
          ChangeClientInspectionInvoicesFilter(label),
        );
      },
      child: _buildChipUI(label, isActive, badgeStr),
    );
  }

  Widget _buildChipUI(String label, bool isActive, String? badgeStr) {
    String displayLabel = badgeStr != null ? '$label ($badgeStr)' : label;

    bool isPendingInactive = !isActive && label == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryGreen
            : (isPendingInactive ? const Color(0xFFFFF9E6) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppTheme.primaryGreen
              : (isPendingInactive
                  ? AppTheme.accentGold
                  : const Color(0xFFDDDDDD)),
        ),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (isPendingInactive ? const Color(0xFFB8860B) : Colors.grey),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
