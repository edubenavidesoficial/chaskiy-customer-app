import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/models/order_attachment.dart';

class OrderStop {
  OrderStop({
    this.id,
    this.orderId,
    this.stopId,
    this.name,
    this.price,
    this.phone,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.formattedDate,
    this.deliveryAddress,
    this.attachments,
    this.sequence = 1,
    this.verified = false,
    this.items = const [],
  });

  int? id;
  int? orderId;
  int? stopId;
  String? name;
  double? price;
  String? phone;
  String? note;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? formattedDate;
  DeliveryAddress? deliveryAddress;
  List<OrderAttachment>? attachments;
  int sequence;
  bool verified;
  List<Map<String, dynamic>> items;

  factory OrderStop.fromJson(Map<String, dynamic> json) {
    return OrderStop(
      id: json["id"] == null ? null : json["id"],
      orderId:
          json["order_id"] == null
              ? null
              : int.parse(json["order_id"].toString()),
      stopId:
          json["stop_id"] == null
              ? null
              : int.parse(json["stop_id"].toString()),
      name: json["name"] == null ? "" : json["name"],
      price: double.tryParse(json["price"].toString()),
      phone: json["phone"] == null ? "" : json["phone"],
      note: json["note"] == null ? "" : json["note"],
      createdAt:
          json["created_at"] == null
              ? null
              : DateTime.parse(json["created_at"]),
      updatedAt:
          json["updated_at"] == null
              ? null
              : DateTime.parse(json["updated_at"]),
      formattedDate:
          json["formatted_date"] == null ? null : json["formatted_date"],
      sequence: int.tryParse(json["sequence"].toString()) ?? 1,
      verified: json["verified"] == true || json["verified"].toString() == "1",
      items:
          json["items"] is List
              ? List<Map<String, dynamic>>.from(
                json["items"].map((item) => Map<String, dynamic>.from(item)),
              )
              : const [],
      deliveryAddress:
          json["delivery_address"] == null
              ? null
              : DeliveryAddress.fromJson(json["delivery_address"]),
      //attachments
      attachments:
          json["attachments"] == null
              ? []
              : List<OrderAttachment>.from(
                json["attachments"].map((x) => OrderAttachment.fromJson(x)),
              ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "stop_id":
        stopId == null && deliveryAddress != null
            ? deliveryAddress?.id
            : stopId,
    "name": name,
    "price": price,
    "phone": phone,
    "note": note,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "formatted_date": formattedDate == null ? null : formattedDate,
    "sequence": sequence,
    "verified": verified,
    "items": items,
    "delivery_address": deliveryAddress?.toJson(),
    "attachments":
        attachments != null
            ? List<dynamic>.from(attachments!.map((x) => x.toJson()))
            : [],
  };
}
