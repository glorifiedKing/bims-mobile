import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme.dart';
import '../bloc/general_invoices/bco_general_invoices_bloc.dart';
import '../bloc/general_invoices/bco_general_invoices_event.dart';
import '../bloc/general_invoices/bco_general_invoices_state.dart';
import '../bloc/inspection_invoices_list/bco_inspection_invoices_list_bloc.dart';
import '../bloc/inspection_invoices_list/bco_inspection_invoices_list_event.dart';
import '../bloc/inspection_invoices_list/bco_inspection_invoices_list_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/search_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/bloc/bco_auth_bloc.dart';
import '../../auth/bloc/bco_auth_state.dart';
import '../../../core/repositories/auxiliary_repository.dart';

class BcoInvoicesScreen extends StatelessWidget {
  final int initialIndex;

  const BcoInvoicesScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          children: [
            // Internal BCO Header Details
            BlocBuilder<BcoAuthBloc, BcoAuthState>(
              builder: (context, state) {
                String name = 'Officer';
                String roleName = 'BUILDING CONTROL OFFICER';
                String adminUnitName = 'NBRB';

                if (state is BcoAuthAuthenticated) {
                  final user = state.user;
                  name = '${user.fname} ${user.lname}';

                  final auxRepo = context.read<AuxiliaryRepository>();

                  // Get Role Name
                  final roles = auxRepo.getUserRoles();
                  final roleObj = roles.cast().firstWhere(
                    (r) => r.id == user.roleId,
                    orElse: () => null,
                  );
                  if (roleObj != null) roleName = roleObj.name;

                  // Get Admin Unit Name
                  if (user.administrativeUnitId != null) {
                    final units = auxRepo.getAllAdminUnits();
                    final unitObj = units.cast().firstWhere(
                      (u) => u.id == user.administrativeUnitId,
                      orElse: () => null,
                    );
                    if (unitObj != null) adminUnitName = unitObj.name;
                  }
                }

                return Container(
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 20,
                    left: 25,
                    right: 25,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00331a), AppTheme.primaryGreen],
                    ),
                    // border: Border(
                    //   bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                    // ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  roleName.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.receipt_long,
                                  size: 14,
                                  color: AppTheme.accentGold,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'INVOICES',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            const TextSpan(text: "Location: "),
                            TextSpan(
                              text: adminUnitName,
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // The Original TabBar
            Container(
              color: AppTheme.primaryGreen,
              child: const TabBar(
                indicatorColor: AppTheme.accentGold,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: [
                  Tab(text: '1st Year Invoices'),
                  Tab(text: 'Inspection Fees'),
                ],
              ),
            ),
            // The Original TabBarView
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
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) context.go('/bco/dashboard');
            if (index == 1) context.go('/bco/applications');
            if (index == 2) return;
            if (index == 3) context.go('/bco/profile');
          },
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInvoicesView(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              SearchBarWidget(
                onChanged: (val) {
                  // In the future: Add local search filtering. We omit for brevity,
                  // or dispatch an event, but currently there is no 'SearchBcoGeneralInvoices' in BLoC.
                  // We'll leave the search bar static or implement simple empty callback.
                },
              ),
              const SizedBox(height: 15),
              BlocBuilder<BcoGeneralInvoicesBloc, BcoGeneralInvoicesState>(
                builder: (context, state) {
                  String currentFilter = 'ALL';
                  if (state is BcoGeneralInvoicesLoaded) {
                    currentFilter = state.selectedFilter;
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildGeneralFilterChip(context, 'ALL', currentFilter),
                        _buildGeneralFilterChip(
                          context,
                          'PENDING',
                          currentFilter,
                        ),
                        _buildGeneralFilterChip(context, 'PAID', currentFilter),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<BcoGeneralInvoicesBloc, BcoGeneralInvoicesState>(
            builder: (context, state) {
              if (state is BcoGeneralInvoicesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BcoGeneralInvoicesError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is BcoGeneralInvoicesLoaded) {
                if (state.invoices.isEmpty) {
                  return const Center(
                    child: Text('No general invoices found.'),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      context.read<BcoGeneralInvoicesBloc>().add(
                        LoadMoreBcoGeneralInvoices(),
                      );
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount:
                        state.invoices.length + (state.hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index >= state.invoices.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final invoice = state.invoices[index];
                      final isPaid =
                          invoice.paymentStatus.toUpperCase() == 'PAID';
                      final currentStatus = isPaid ? 'PAID' : 'PENDING PAYMENT';

                      Color statusColor = isPaid
                          ? const Color(0xFF1E7E34)
                          : const Color(0xFFB8860B);
                      Color statusBg = isPaid
                          ? const Color(0xFFE6F4EA)
                          : const Color(0xFFFFF9E6);
                      Color borderColor = isPaid
                          ? const Color(0xFF1E7E34)
                          : AppTheme.accentGold;

                      String actionText = isPaid
                          ? '📄 DOWNLOAD RECEIPT'
                          : '📄 DOWNLOAD INVOICE';
                      Color actionColor = Colors.white;
                      Color actionTextColor = AppTheme.primaryGreen;

                      return GestureDetector(
                        onTap: () {
                          context.push('/bco/invoices/${invoice.prn}');
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
                          onActionTap: () async {
                            final docUrl = isPaid
                                ? (invoice.documents != null
                                      ? invoice.documents!['receipt']
                                      : null)
                                : (invoice.documents != null
                                      ? invoice.documents!['invoice']
                                      : null);
                            if (docUrl != null &&
                                docUrl.toString().isNotEmpty) {
                              final uri = Uri.parse(docUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              SearchBarWidget(onChanged: (val) {}),
              const SizedBox(height: 15),
              BlocBuilder<
                BcoInspectionInvoicesListBloc,
                BcoInspectionInvoicesListState
              >(
                builder: (context, state) {
                  String currentFilter = 'ALL';
                  if (state is BcoInspectionInvoicesListLoaded) {
                    currentFilter = state.selectedFilter;
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildInspectionFilterChip(
                          context,
                          'ALL',
                          currentFilter,
                        ),
                        _buildInspectionFilterChip(
                          context,
                          'PENDING',
                          currentFilter,
                        ),
                        _buildInspectionFilterChip(
                          context,
                          'PAID',
                          currentFilter,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child:
              BlocBuilder<
                BcoInspectionInvoicesListBloc,
                BcoInspectionInvoicesListState
              >(
                builder: (context, state) {
                  if (state is BcoInspectionInvoicesListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BcoInspectionInvoicesListError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is BcoInspectionInvoicesListLoaded) {
                    if (state.invoices.isEmpty) {
                      return const Center(
                        child: Text('No inspection invoices found.'),
                      );
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!state.hasReachedMax &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          context.read<BcoInspectionInvoicesListBloc>().add(
                            LoadMoreBcoInspectionInvoicesList(),
                          );
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount:
                            state.invoices.length +
                            (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= state.invoices.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final invoice = state.invoices[index];
                          final isPaid =
                              invoice.paymentStatus.toUpperCase() == 'PAID';
                          final currentStatus = isPaid
                              ? 'PAID'
                              : 'PENDING PAYMENT';

                          Color statusColor = isPaid
                              ? const Color(0xFF1E7E34)
                              : const Color(0xFFB8860B);
                          Color statusBg = isPaid
                              ? const Color(0xFFE6F4EA)
                              : const Color(0xFFFFF9E6);
                          Color borderColor = isPaid
                              ? const Color(0xFF1E7E34)
                              : AppTheme.accentGold;

                          String actionText = isPaid
                              ? '📄 DOWNLOAD RECEIPT'
                              : '📄 DOWNLOAD INVOICE';
                          Color actionColor = Colors.white;
                          Color actionTextColor = AppTheme.primaryGreen;

                          return GestureDetector(
                            onTap: () {
                              context.push(
                                '/bco/inspection-invoices/${invoice.prn}',
                              );
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
                                invoice.invoiceAmount.toDouble(),
                              ),
                              borderColor: borderColor,
                              actionText: actionText,
                              actionColor: actionColor,
                              actionTextColor: actionTextColor,
                              onActionTap: () async {
                                final docUrl = isPaid
                                    ? (invoice.documents != null
                                          ? invoice.documents!['receipt']
                                          : null)
                                    : (invoice.documents != null
                                          ? invoice.documents!['invoice']
                                          : null);
                                if (docUrl != null &&
                                    docUrl.toString().isNotEmpty) {
                                  final uri = Uri.parse(docUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                }
                              },
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
  ) {
    final isActive = label == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<BcoGeneralInvoicesBloc>().add(
          ChangeBcoGeneralInvoicesFilter(label),
        );
      },
      child: _buildChipUI(label, isActive),
    );
  }

  Widget _buildInspectionFilterChip(
    BuildContext context,
    String label,
    String currentFilter,
  ) {
    final isActive = label == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<BcoInspectionInvoicesListBloc>().add(
          ChangeBcoInspectionInvoicesListFilter(label),
        );
      },
      child: _buildChipUI(label, isActive),
    );
  }

  Widget _buildChipUI(String label, bool isActive) {
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
        label,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (isPendingInactive ? AppTheme.accentGold : Colors.black54),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
