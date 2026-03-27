import 'package:flutter/material.dart';
import '../theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hintText = 'Search PRN or Serial No...',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            return value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : const SizedBox.shrink();
          },
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accentGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.accentGold),
        ),
      ),
    );
  }
}
