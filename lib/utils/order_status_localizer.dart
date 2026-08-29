String spanishOrderStatus(String? status) {
  final normalized = (status ?? '').trim().toLowerCase();
  const labels = <String, String>{
    'pending': 'Pendiente',
    'preparing': 'Preparando',
    'ready': 'Listo',
    'enroute': 'En camino',
    'delivered': 'Entregado',
    'completed': 'Completado',
    'successful': 'Exitoso',
    'scheduled': 'Programado',
    'failed': 'Fallido',
    'fail': 'Fallido',
    'cancelled': 'Cancelado',
    'cancel': 'Cancelado',
    'request': 'Solicitado',
    'accepted': 'Aceptado',
    'assigned': 'Asignado',
    'review': 'En revisión',
    'rejected': 'Rechazado',
    'approved': 'Aprobado',
    'processing': 'Procesando',
    'refunded': 'Reembolsado',
    'paid': 'Pagado',
    'unpaid': 'Pendiente de pago',
  };

  if (normalized.isEmpty) return 'Sin estado';
  return labels[normalized] ?? _humanize(normalized);
}

String _humanize(String value) {
  return value
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
