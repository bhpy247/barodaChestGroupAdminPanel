import 'dart:convert';

class AboutModel {
  String description = "", contact = "", whatsapp = "", facebook = "";

  AboutModel({
    this.description = "",
    this.contact = "",
    this.whatsapp = "",
    this.facebook = "",
  });

  AboutModel.fromMap(Map<String, dynamic> map) {
    description = map['description']?.toString() ?? "";
    contact = map['contact']?.toString() ?? "";
    whatsapp = map['whatsapp']?.toString() ?? "";
    facebook = map['facebook']?.toString() ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "description" : description,
      "contact" : contact,
      "whatsapp" : whatsapp,
      "facebook" : facebook,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}