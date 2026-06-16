import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme.dart';
import '../bloc/attachments/professional_attachments_bloc.dart';
import '../bloc/attachments/professional_attachments_event.dart';
import '../bloc/attachments/professional_attachments_state.dart';
import '../bloc/profile/professional_profile_bloc.dart';
import '../bloc/profile/professional_profile_state.dart';
import '../models/pro_attachment_model.dart';
import '../models/pro_attachment_type_model.dart';

class ProfessionalAttachmentsScreen extends StatefulWidget {
  const ProfessionalAttachmentsScreen({super.key});

  @override
  State<ProfessionalAttachmentsScreen> createState() => _ProfessionalAttachmentsScreenState();
}

class _ProfessionalAttachmentsScreenState extends State<ProfessionalAttachmentsScreen> {
  final _scrollController = ScrollController();
  String _selectedStatus = 'ALL';
  String _selectedType = 'ALL';
  List<ProAttachmentTypeModel> _types = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  void _loadData() {
    context.read<ProfessionalAttachmentsBloc>().add(
          FetchProfessionalAttachments(
            status: _selectedStatus == 'ALL' ? null : _selectedStatus,
            type: _selectedType == 'ALL' ? null : _selectedType,
          ),
        );
    context.read<ProfessionalAttachmentsBloc>().add(FetchProfessionalAttachmentTypes());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProfessionalAttachmentsBloc>().add(LoadMoreProfessionalAttachments());
    }
  }

  Future<void> _shareCode(String code) async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Use this BIMS Attachment Code to link the design: $code',
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Professional Header with Profile BlocBuilder
          BlocBuilder<ProfessionalProfileBloc, ProfessionalProfileState>(
            builder: (context, state) {
              String name = 'Loading...';
              String profession = 'PROFESSIONAL';

              if (state is ProfessionalProfileLoaded) {
                name = state.profile.name;
                profession = state.profile.profession.toUpperCase();
              } else if (state is ProfessionalProfileError) {
                name = 'Professional';
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
                  border: Border(
                    bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                  ),
                ),
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
                            Text(
                              profession,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.architecture,
                                size: 14,
                                color: AppTheme.accentGold,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'DRAWINGS',
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
                  ],
                ),
              );
            },
          ),

          // Filters bar using select dropdowns
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                // Status Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Statuses', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'UNLINKED', child: Text('UNLINKED', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'LINKED', child: Text('LINKED', style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'REVOKED', child: Text('REVOKED', style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                        _loadData();
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                      labelText: 'Status',
                      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Type Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: [
                      const DropdownMenuItem(value: 'ALL', child: Text('All Types', style: TextStyle(fontSize: 12))),
                      ..._types.map((type) => DropdownMenuItem(
                            value: type.title,
                            child: Text(
                              type.title,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedType = val;
                        });
                        _loadData();
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                      labelText: 'Type',
                      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List Area
          Expanded(
            child: BlocListener<ProfessionalAttachmentsBloc, ProfessionalAttachmentsState>(
              listener: (context, state) {
                if (state is AttachmentTypesLoaded) {
                  setState(() {
                    _types = state.types;
                    if (_selectedType != 'ALL' && !_types.any((t) => t.title == _selectedType)) {
                      _selectedType = 'ALL';
                    }
                  });
                }
              },
              child: BlocBuilder<ProfessionalAttachmentsBloc, ProfessionalAttachmentsState>(
                buildWhen: (previous, current) =>
                    current is ProfessionalAttachmentsLoading ||
                    current is ProfessionalAttachmentsLoaded ||
                    current is ProfessionalAttachmentsError,
                builder: (context, state) {
                  if (state is ProfessionalAttachmentsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
                  }

                  if (state is ProfessionalAttachmentsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProfessionalAttachmentsLoaded) {
                    final attachments = state.attachments;

                    if (attachments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No attachments found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedStatus != 'ALL' || _selectedType != 'ALL'
                                  ? 'Try changing your filters'
                                  : 'Upload your architectural or structural plans',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: attachments.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= attachments.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                            ),
                          );
                        }

                        final attachment = attachments[index];
                        return _buildAttachmentCard(attachment);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/professional/attachments/upload');
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/professional/dashboard');
          if (index == 1) context.go('/professional/applications');
          if (index == 2) context.go('/professional/profile');
        },
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: const Color(0xFF999999),
        showUnselectedLabels: true,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment, size: 28),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(ProAttachmentModel attachment) {
    Color statusColor;
    switch (attachment.status) {
      case 'LINKED':
        statusColor = Colors.green;
        break;
      case 'UNLINKED':
        statusColor = AppTheme.accentGold;
        break;
      default:
        statusColor = Colors.grey;
    }

    final isUnlinked = attachment.status == 'UNLINKED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    attachment.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    attachment.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content of card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Type:', attachment.attachmentType),
                const SizedBox(height: 8),
                _buildInfoRow('Particulars:', attachment.particulars),
                if (attachment.applicationRef != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Linked App:', attachment.applicationRef!),
                ],
                const SizedBox(height: 8),
                _buildInfoRow('File Name:', attachment.attachmentFile),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isUnlinked) ...[
                      OutlinedButton.icon(
                        onPressed: () => _shareCode(attachment.code),
                        icon: const Icon(Icons.share, size: 16, color: AppTheme.primaryGreen),
                        label: const Text('Share Code', style: TextStyle(color: AppTheme.primaryGreen)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await context.push(
                            '/professional/attachments/upload',
                            extra: attachment,
                          );
                          if (result == true) {
                            _loadData();
                          }
                        },
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                        label: const Text('Edit', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }
}
