import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/permits/client_permits_bloc.dart';
import '../bloc/permits/client_permits_event.dart';
import '../bloc/permits/client_permits_state.dart';
import '../../../core/widgets/search_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ClientPermitsScreen extends StatelessWidget {
  const ClientPermitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryGreen, Color(0xFF00331A)],
              ),
              border: Border(
                bottom: BorderSide(color: AppTheme.accentGold, width: 4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Permits',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Active & Historical Approvals',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
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
          ),

          // Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: SearchBarWidget(
              onChanged: (val) {
                context.read<ClientPermitsBloc>().add(SearchClientPermits(val));
              },
            ),
          ),

          // List body
          Expanded(
            child: BlocBuilder<ClientPermitsBloc, ClientPermitsState>(
              builder: (context, state) {
                if (state is ClientPermitsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClientPermitsError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (state is ClientPermitsLoaded) {
                  var displayPermits = state.permits;
                  if (state.searchQuery != null && state.searchQuery!.length >= 3) {
                    final sq = state.searchQuery!.toLowerCase();
                    displayPermits = state.permits.where((p) {
                      return p.permitNo.toLowerCase().contains(sq) ||
                             p.serialNo.toLowerCase().contains(sq) ||
                             p.administrativeUnitName.toLowerCase().contains(sq);
                    }).toList();
                  }

                  if (displayPermits.isEmpty) {
                    return const Center(child: Text('No permits found.'));
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!state.hasReachedMax &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        context.read<ClientPermitsBloc>().add(
                          LoadMoreClientPermits(),
                        );
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: displayPermits.length +
                          (state.hasReachedMax ? 0 : (state.searchQuery != null && state.searchQuery!.length >= 3 ? 0 : 1)),
                      itemBuilder: (context, index) {
                        if (index >= displayPermits.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final permit = displayPermits[index];
                        // Format date strings if needed
                        String issuedDateStr = permit.issuedDate;
                        String expiresDateStr = permit.expiresDate;
                        try {
                          DateTime dtIssued = DateTime.parse(permit.issuedDate);
                          List<String> months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          String monthStr =
                              dtIssued.month >= 1 && dtIssued.month <= 12
                              ? months[dtIssued.month - 1]
                              : dtIssued.month.toString();
                          issuedDateStr =
                              '$monthStr ${dtIssued.day.toString().padLeft(2, '0')}, ${dtIssued.year}';
                        } catch (_) {}

                        try {
                          if (permit.expiresDate.toLowerCase() != 'permanent') {
                            DateTime dtExpires = DateTime.parse(
                              permit.expiresDate,
                            );
                            List<String> months = [
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            String monthStr =
                                dtExpires.month >= 1 && dtExpires.month <= 12
                                ? months[dtExpires.month - 1]
                                : dtExpires.month.toString();
                            expiresDateStr =
                                '$monthStr ${dtExpires.day.toString().padLeft(2, '0')}, ${dtExpires.year}';
                          }
                        } catch (_) {}

                        Color expiresColor = const Color(0xFF333333);
                        if (expiresDateStr.toLowerCase() == 'permanent') {
                          expiresColor = AppTheme.primaryGreen;
                        }

                        return _buildPermitCard(
                          context: context,
                          permitNo: permit.permitNo,
                          serialNo: permit.serialNo,
                          type: permit.type,
                          location: permit.location,
                          classification: permit.buildingClassification,
                          unit: permit.administrativeUnitName,
                          issuedStr: issuedDateStr,
                          expiresStr: expiresDateStr,
                          expiresColor: expiresColor,
                          onDownloadTap: () async {
                            final permitUrl = permit.documents?['permit'];
                            if (permitUrl != null && permitUrl.toString().isNotEmpty) {
                              final uri = Uri.parse(permitUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            }
                          },
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            1, // Focus Applications tab for permits (could also be their own tab)
        onTap: (index) {
          if (index == 0) context.go('/client/dashboard');
          if (index == 1) context.go('/client/applications');
          if (index == 2) context.go('/client/invoices');
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
    );
  }

  Widget _buildPermitCard({
    required BuildContext context,
    required String permitNo,
    required String serialNo,
    required String type,
    required String location,
    required String classification,
    required String unit,
    required String issuedStr,
    required String expiresStr,
    Color expiresColor = const Color(0xFF333333),
    VoidCallback? onDownloadTap,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/client/permits/$serialNo');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              width: double.infinity,
              color: AppTheme.accentGold,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permitNo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    serialNo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildDetailItem('Type', type)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDetailItem(
                                'Class',
                                classification.isEmpty ? '-' : classification,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem('Location', location),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDetailItem(
                                'Unit',
                                unit.isEmpty ? '-' : unit,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildDetailItem('Issued', issuedStr)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDetailItem(
                          'Expires',
                          expiresStr,
                          valueColor: expiresColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onDownloadTap ?? () {},
                      icon: const Icon(Icons.insert_drive_file, size: 16),
                      label: const Text('DOWNLOAD PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    Color valueColor = const Color(0xFF333333),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
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
}
