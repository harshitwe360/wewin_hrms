import 'dart:convert';

Tenant tenantFromMap(String str) => Tenant.fromMap(json.decode(str));

String tenantToMap(Tenant data) => json.encode(data.toMap());

class Tenant {
  final String? id;
  final String? name;
  final String? baseDomain;
  final String? contactEmail;
  final String? contactFirstName;
  final String? contactLastName;
  final IngAddress? billingAddress;
  final IngAddress? shippingAddress;
  final String? appVersion;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final dynamic deletedDate;

  Tenant({
    this.id,
    this.name,
    this.baseDomain,
    this.contactEmail,
    this.contactFirstName,
    this.contactLastName,
    this.billingAddress,
    this.shippingAddress,
    this.appVersion,
    this.createdDate,
    this.modifiedDate,
    this.deletedDate,
  });

  factory Tenant.fromMap(Map<String, dynamic> json) => Tenant(
    id: json["id"],
    name: json["name"],
    baseDomain: json["base_domain"],
    contactEmail: json["contact_email"],
    contactFirstName: json["contact_first_name"],
    contactLastName: json["contact_last_name"],
    billingAddress: json["billing_address"] == null ? null : IngAddress.fromMap(json["billing_address"]),
    shippingAddress: json["shipping_address"] == null ? null : IngAddress.fromMap(json["shipping_address"]),
    appVersion: json["app_version"],
    createdDate: json["created_date"] == null ? null : DateTime.parse(json["created_date"]),
    modifiedDate: json["modified_date"] == null ? null : DateTime.parse(json["modified_date"]),
    deletedDate: json["deleted_date"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "base_domain": baseDomain,
    "contact_email": contactEmail,
    "contact_first_name": contactFirstName,
    "contact_last_name": contactLastName,
    "billing_address": billingAddress?.toMap(),
    "shipping_address": shippingAddress?.toMap(),
    "app_version": appVersion,
    "created_date": createdDate?.toIso8601String(),
    "modified_date": modifiedDate?.toIso8601String(),
    "deleted_date": deletedDate,
  };
}

class IngAddress {
  final String? street;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final dynamic phoneNumber;

  IngAddress({
    this.street,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.phoneNumber,
  });

  factory IngAddress.fromMap(Map<String, dynamic> json) => IngAddress(
    street: json["street"],
    city: json["city"],
    state: json["state"],
    zip: json["zip"],
    country: json["country"],
    phoneNumber: json["phone_number"],
  );

  Map<String, dynamic> toMap() => {
    "street": street,
    "city": city,
    "state": state,
    "zip": zip,
    "country": country,
    "phone_number": phoneNumber,
  };
}