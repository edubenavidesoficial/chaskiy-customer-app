import 'package:chaskiy/models/cart.dart';
import 'package:chaskiy/models/delivery_address.dart';

class MultiDelivery {
  MultiDelivery({
    required this.deliveryAddress,
    Map<int, int>? quantities,
    this.recipientName = '',
    this.recipientPhone = '',
    this.note = '',
  }) : quantities = quantities ?? {};

  final DeliveryAddress deliveryAddress;
  final Map<int, int> quantities;
  String recipientName;
  String recipientPhone;
  String note;

  int quantityFor(int lineIndex) => quantities[lineIndex] ?? 0;

  int get totalQuantity =>
      quantities.values.fold(0, (total, quantity) => total + quantity);

  Map<String, dynamic> toPayload(List<Cart> cartItems) {
    final items = <Map<String, dynamic>>[];
    quantities.forEach((lineIndex, quantity) {
      if (quantity > 0 && lineIndex < cartItems.length) {
        items.add({
          'line_index': lineIndex,
          'product_id': cartItems[lineIndex].product?.id,
          'quantity': quantity,
        });
      }
    });

    return {
      'delivery_address_id': deliveryAddress.id,
      'recipient_name': recipientName.trim(),
      'recipient_phone': recipientPhone.trim(),
      'note': note.trim(),
      'items': items,
    };
  }
}
