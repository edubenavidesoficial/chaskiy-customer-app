import 'package:chaskiy/requests/taxi.request.dart';
import 'package:flutter/material.dart';

class DriverReviewsSheet extends StatelessWidget {
  const DriverReviewsSheet({super.key, required this.driverId});

  final int driverId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: TaxiRequest().getDriverReviews(driverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final reviews = snapshot.data ?? const [];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opiniones de pasajeros',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mostramos comentarios recientes sin datos personales.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Text('Aún no hay comentarios para mostrar.'),
                  ),
                for (final review in reviews)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text('${review['author'] ?? 'U'}'),
                    ),
                    title: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text('${review['rating'] ?? ''}/5'),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${review['review'] ?? ''}'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
