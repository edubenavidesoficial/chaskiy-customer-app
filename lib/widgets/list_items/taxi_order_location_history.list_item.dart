import 'package:chaskiy/models/tax_order_location.history.dart';
import 'package:flutter/material.dart';

class TaxiOrderHistoryListItem extends StatelessWidget {
  const TaxiOrderHistoryListItem(
    this.taxiOrderLocationHistory, {
    super.key,
    required this.onPressed,
  });

  final TaxiOrderLocationHistory taxiOrderLocationHistory;
  final Function(TaxiOrderLocationHistory) onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onPressed(taxiOrderLocationHistory),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 22,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                taxiOrderLocationHistory.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.north_west_rounded, size: 18, color: colors.outline),
          ],
        ),
      ),
    );
  }
}
