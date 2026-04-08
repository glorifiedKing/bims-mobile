import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../bloc/application_attachments/bco_application_attachments_bloc.dart';
import '../bloc/application_attachments/bco_application_attachments_event.dart';
import '../bloc/application_attachments/bco_application_attachments_state.dart';

class BcoApplicationAttachmentsScreen extends StatefulWidget {
  final String applicationKey;

  const BcoApplicationAttachmentsScreen({super.key, required this.applicationKey});

  @override
  State<BcoApplicationAttachmentsScreen> createState() => _BcoApplicationAttachmentsScreenState();
}

class _BcoApplicationAttachmentsScreenState extends State<BcoApplicationAttachmentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BcoApplicationAttachmentsBloc>().add(FetchBcoApplicationAttachments(widget.applicationKey));
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch URL.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Attachments', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<BcoApplicationAttachmentsBloc, BcoApplicationAttachmentsState>(
        builder: (context, state) {
          if (state is BcoApplicationAttachmentsLoading || state is BcoApplicationAttachmentsInitial) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          } else if (state is BcoApplicationAttachmentsError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
          } else if (state is BcoApplicationAttachmentsLoaded) {
            if (state.attachments.isEmpty) {
              return const Center(child: Text('No attachments found.'));
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!state.hasReachedMax &&
                    scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  context.read<BcoApplicationAttachmentsBloc>().add(LoadMoreBcoApplicationAttachments(widget.applicationKey));
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: state.attachments.length + (state.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= state.attachments.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                    );
                  }

                  final attachment = state.attachments[index];
                  String formattedDate = attachment.created;
                  
                  try {
                    final d = DateTime.parse(attachment.created);
                    formattedDate = "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}";
                  } catch (_) {}

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
                      ]
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 36),
                      title: Text(attachment.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                      subtitle: Text('Uploaded: $formattedDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.download, color: AppTheme.accentGold),
                        onPressed: () => _launchUrl(attachment.fileUrl),
                      ),
                      onTap: () => _launchUrl(attachment.fileUrl),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
