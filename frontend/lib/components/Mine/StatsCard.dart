import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int coins;
  final int trialDays;
  final int caseCount;

  const StatsCard({
    Key? key,
    required this.coins,
    required this.trialDays,
    required this.caseCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(child: _buildStatItem(coins.toString(), "算力币", const Color(0xFFD4A856))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatItem("$trialDays天", "试用剩余", Colors.black)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatItem(caseCount.toString(), "案件数", Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
