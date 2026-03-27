import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class BcoChecklistScreen extends StatefulWidget {
  const BcoChecklistScreen({super.key});

  @override
  State<BcoChecklistScreen> createState() => _BcoChecklistScreenState();
}

class _BcoChecklistScreenState extends State<BcoChecklistScreen> {
  // Map to store pass(true)/fail(false)/null status
  final Map<int, bool?> _statusMap = {
    0: true, // Mock pre-filled AI verify
    1: true,
    2: null,
    3: null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text(
          'Technical Checklist',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              // Open Camera
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const _CategoryTitle(title: 'Accessibility (AI Assisted)'),
                _buildCheckItem(
                  index: 0,
                  title: 'Ramp Slope Gradient',
                  desc: 'Must not exceed 1:12 ratio.',
                  aiBadge: '✓ AI VERIFIED (1:12)',
                ),
                _buildCheckItem(
                  index: 1,
                  title: 'Emergency Exit Width',
                  desc: 'Min 1200mm required.',
                  aiBadge: '✓ AI VERIFIED (1250mm)',
                ),

                const SizedBox(height: 10),
                const _CategoryTitle(title: 'Structural Elements'),
                _buildCheckItem(
                  index: 2,
                  title: 'Column Reinforcement',
                  desc: 'Check rebar size and spacing.',
                ),
                _buildCheckItem(
                  index: 3,
                  title: 'Foundation Depth',
                  desc: 'Check depth vs approved plans.',
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Stop Order
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'STOP ORDER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inspection Report Submitted to NBRB'),
                        ),
                      );
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'SUBMIT REPORT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required int index,
    required String title,
    required String desc,
    String? aiBadge,
  }) {
    final status = _statusMap[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (aiBadge != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      aiBadge,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Row(
            children: [
              _StatusToggle(
                icon: Icons.check,
                color: const Color(0xFF2E7D32),
                isActive: status == true,
                onTap: () {
                  setState(() {
                    _statusMap[index] = true;
                  });
                },
              ),
              if (aiBadge == null) ...[
                const SizedBox(width: 8),
                _StatusToggle(
                  icon: Icons.close,
                  color: AppTheme.danger,
                  isActive: status == false,
                  onTap: () {
                    setState(() {
                      _statusMap[index] = false;
                    });
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final String title;
  const _CategoryTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusToggle({
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? color : Colors.transparent,
          border: Border.all(
            color: isActive ? color : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Icon(icon, size: 16, color: isActive ? Colors.white : color),
      ),
    );
  }
}
