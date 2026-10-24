import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme.dart';
import '../../models/copilot_model.dart';
import '../../repositories/ai_compliance_repository.dart';

class ProfessionalCopilotSheet extends StatefulWidget {
  final String? initialContextTitle;
  final String? initialContextDescription;
  final String? drawingVersionId;

  const ProfessionalCopilotSheet({
    super.key,
    this.initialContextTitle,
    this.initialContextDescription,
    this.drawingVersionId,
  });

  @override
  State<ProfessionalCopilotSheet> createState() =>
      _ProfessionalCopilotSheetState();
}

class _ProfessionalCopilotSheetState extends State<ProfessionalCopilotSheet> {
  final _repository = AiComplianceRepository();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  CopilotPersona _activePersona = CopilotPersona.personas.first; // Inspector Okello by default
  bool _isSending = false;

  final List<CopilotMessage> _messages = [];

  final List<String> _suggestedPrompts = [
    'What is the minimum window-to-floor ventilation ratio for habitable rooms?',
    'What are the minimum corridor widths and PWD accessibility standards?',
    'What drawing scale is mandatory for municipal blueprint submission?',
    'What are the column schedule requirements under the Uganda Building Code?',
  ];

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _scrollToBottom();
        });
      }
    });

    // Add initial welcome greeting from the active persona
    _messages.add(
      CopilotMessage(
        id: 'welcome',
        text: 'Hello! I am **${_activePersona.name}**, ${_activePersona.title}.\n\n'
            'Ask me any regulatory questions regarding statutory **Uganda Building Control Regulations (2020)**, '
            'the **Uganda National Building Code (2019)**, or drawing compliance.',
        isUser: false,
        persona: _activePersona,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _switchPersona(CopilotPersona persona) {
    if (_activePersona.id == persona.id) return;
    setState(() {
      _activePersona = persona;
      _messages.add(
        CopilotMessage(
          id: 'switch_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Switched to **${persona.name}** (${persona.title}).\n\n_${persona.description}_',
          isUser: false,
          persona: persona,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage([String? presetText]) async {
    final query = presetText ?? _textController.text.trim();
    if (query.isEmpty || _isSending) return;

    if (presetText == null) {
      _textController.clear();
    }

    final userMsg = CopilotMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final res = await _repository.askCopilot(
        query: query,
        persona: _activePersona.id,
        drawingVersionId: widget.drawingVersionId,
      );

      // Safe extraction across multiple backend conventions
      String responseText = '';
      if (res['response'] != null && res['response'].toString().trim().isNotEmpty) {
        responseText = res['response'].toString().trim();
      } else if (res['answer'] != null && res['answer'].toString().trim().isNotEmpty) {
        responseText = res['answer'].toString().trim();
      } else if (res['reply'] != null && res['reply'].toString().trim().isNotEmpty) {
        responseText = res['reply'].toString().trim();
      } else if (res['content'] != null && res['content'].toString().trim().isNotEmpty) {
        responseText = res['content'].toString().trim();
      } else if (res['message'] != null && res['message'].toString().trim().isNotEmpty) {
        responseText = res['message'].toString().trim();
      } else if (res['text'] != null && res['text'].toString().trim().isNotEmpty) {
        responseText = res['text'].toString().trim();
      } else if (res['result'] != null && res['result'].toString().trim().isNotEmpty) {
        responseText = res['result'].toString().trim();
      } else if (res['markdown'] != null && res['markdown'].toString().trim().isNotEmpty) {
        responseText = res['markdown'].toString().trim();
      }

      if (responseText.isEmpty) {
        responseText = 'No statutory recommendation returned by the AI Engine.';
      }

      List<ReferencedClause> clauses = [];
      if (res['referenced_clauses'] is List) {
        clauses = (res['referenced_clauses'] as List)
            .whereType<Map<String, dynamic>>()
            .map((c) => ReferencedClause.fromJson(c))
            .toList();
      } else if (res['clauses'] is List) {
        clauses = (res['clauses'] as List)
            .whereType<Map<String, dynamic>>()
            .map((c) => ReferencedClause.fromJson(c))
            .toList();
      }

      final aiMsg = CopilotMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: responseText,
        isUser: false,
        persona: _activePersona,
        referencedClauses: clauses,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMsg);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = CopilotMessage(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Apologies, could not connect to Uganda Building Code AI Engine: $e',
          isUser: false,
          persona: _activePersona,
          timestamp: DateTime.now(),
        );
        setState(() {
          _messages.add(errorMsg);
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;

    // Constrain height so the sheet never goes under the top status bar / notch
    final maxAvailableHeight = screenHeight - topPadding - 12;
    final defaultHeight = screenHeight * 0.88;
    final sheetHeight = isKeyboardOpen
        ? (maxAvailableHeight - bottomInset).clamp(260.0, defaultHeight)
        : defaultHeight.clamp(260.0, maxAvailableHeight);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Material(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: sheetHeight,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Text(_activePersona.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Interactive AI Copilot',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _activePersona.name,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGreen,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Uganda National Building Code & Regulations Assistant',
                              style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Active Context Card (if provided and keyboard not obscuring)
                if (widget.initialContextTitle != null && !isKeyboardOpen) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pin_drop, size: 16, color: Color(0xFF996500)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grounded on: ${widget.initialContextTitle}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF996500)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.initialContextDescription != null &&
                                  widget.initialContextDescription!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.initialContextDescription!,
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF805500)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Persona Selector Tabs
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: CopilotPersona.personas.map((p) {
                      final isSelected = p.id == _activePersona.id;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _switchPersona(p),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryGreen : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryGreen : Colors.grey.withValues(alpha: 0.2),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Text(p.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppTheme.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Divider(height: 1),

                // Message List
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.opaque,
                    child: ListView.builder(
                      controller: _scrollController,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, idx) {
                        final msg = _messages[idx];
                        return _buildMessageBubble(msg);
                      },
                    ),
                  ),
                ),

                // Suggested Prompts horizontal carousel (hidden while typing to maximize reading space)
                if (!isKeyboardOpen) ...[
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _suggestedPrompts.length,
                      itemBuilder: (context, idx) {
                        final prompt = _suggestedPrompts[idx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            backgroundColor: Colors.white,
                            labelStyle: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen),
                            label: Text(prompt),
                            onPressed: () => _sendMessage(prompt),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Input Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            hintText: 'Ask ${_activePersona.name} a code query...',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                            ),
                            filled: true,
                            fillColor: AppTheme.background,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen,
                        radius: 22,
                        child: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                onPressed: () => _sendMessage(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(CopilotMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00331a), AppTheme.primaryGreen],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
          ),
        ),
      );
    }

    final persona = msg.persona ?? _activePersona;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 24),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(persona.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  persona.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    persona.title,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF996500)),
                  ),
                ),
                const Spacer(),
                // Copy entire response to clipboard
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Response copied to clipboard'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.copy_outlined, size: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Formatted Markdown content
            SelectionArea(
              child: MarkdownBody(
                data: msg.text.trim().isEmpty ? '*(No content)*' : msg.text,
                selectable: false,
                shrinkWrap: true,
                onTapLink: (text, href, title) {
                  if (href != null) {
                    final uri = Uri.tryParse(href);
                    if (uri != null) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                styleSheet: _buildMarkdownStyleSheet(context),
              ),
            ),

            // Statutory Reference Badges
            if (msg.referencedClauses.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'UGANDAN STATUTORY CITATIONS:',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.blueGrey),
              ),
              const SizedBox(height: 4),
              ...msg.referencedClauses.map((clause) => Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bookmark_added, size: 14, color: AppTheme.primaryGreen),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${clause.document} — Clause ${clause.clauseNumber}: ${clause.clauseTitle}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    // Guarantee non-null fontSize on bodyMedium to prevent crashes in flutter_markdown's fromTheme
    final effectiveTheme = (theme.textTheme.bodyMedium?.fontSize == null)
        ? theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              bodyMedium: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                fontSize: 14.0,
                color: AppTheme.textDark,
              ),
            ),
          )
        : theme;

    return MarkdownStyleSheet.fromTheme(effectiveTheme).copyWith(
      p: const TextStyle(
        fontSize: 13,
        color: AppTheme.textDark,
        height: 1.45,
      ),
      h1: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
        height: 1.3,
      ),
      h2: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
        height: 1.3,
      ),
      h3: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryGreen,
        height: 1.3,
      ),
      h4: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
        height: 1.3,
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
      ),
      em: const TextStyle(
        fontStyle: FontStyle.italic,
        color: AppTheme.textDark,
      ),
      listBullet: const TextStyle(
        fontSize: 13,
        color: AppTheme.primaryGreen,
        fontWeight: FontWeight.bold,
      ),
      code: TextStyle(
        fontSize: 12,
        color: AppTheme.primaryGreen,
        backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.08),
        fontFamily: 'monospace',
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: const Border(
          left: BorderSide(color: AppTheme.accentGold, width: 3),
        ),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1.0,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      tableHead: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
      ),
      tableBody: const TextStyle(
        fontSize: 12,
        color: AppTheme.textDark,
      ),
      tableBorder: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      blockSpacing: 8.0,
      listIndent: 18.0,
    );
  }
}
