/// Modelo para los datos básicos y comerciales del negocio en Zentra.
/// Estos datos se integran en las cotizaciones, recibos de WhatsApp y encabezados.
class BusinessProfileModel {
  final String businessName;
  final String ownerName;
  final String phone;
  final String city;
  final String logoIconName;
  final String nequi;
  final String daviplata;
  final String bancolombia;
  final String customNote;
  final String businessType; // 'SERVICIOS' o 'RETAIL'
  final bool isConfigured;

  const BusinessProfileModel({
    this.businessName = '',
    this.ownerName = '',
    this.phone = '',
    this.city = 'Colombia',
    this.logoIconName = 'auto_awesome',
    this.nequi = '',
    this.daviplata = '',
    this.bancolombia = '',
    this.customNote = '¡Muchas gracias por apoyar nuestro talento local! 🌸',
    this.businessType = 'SERVICIOS',
    this.isConfigured = false,
  });

  BusinessProfileModel copyWith({
    String? businessName,
    String? ownerName,
    String? phone,
    String? city,
    String? logoIconName,
    String? nequi,
    String? daviplata,
    String? bancolombia,
    String? customNote,
    String? businessType,
    bool? isConfigured,
  }) {
    return BusinessProfileModel(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      logoIconName: logoIconName ?? this.logoIconName,
      nequi: nequi ?? this.nequi,
      daviplata: daviplata ?? this.daviplata,
      bancolombia: bancolombia ?? this.bancolombia,
      customNote: customNote ?? this.customNote,
      businessType: businessType ?? this.businessType,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'phone': phone,
      'city': city,
      'logoIconName': logoIconName,
      'nequi': nequi,
      'daviplata': daviplata,
      'bancolombia': bancolombia,
      'customNote': customNote,
      'businessType': businessType,
      'isConfigured': isConfigured,
    };
  }

  factory BusinessProfileModel.fromMap(Map<String, dynamic> map) {
    return BusinessProfileModel(
      businessName: map['businessName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phone: map['phone'] ?? '',
      city: map['city'] ?? 'Colombia',
      logoIconName: map['logoIconName'] ?? 'auto_awesome',
      nequi: map['nequi'] ?? '',
      daviplata: map['daviplata'] ?? '',
      bancolombia: map['bancolombia'] ?? '',
      customNote: map['customNote'] ?? '¡Muchas gracias por apoyar nuestro talento local! 🌸',
      businessType: map['businessType'] ?? 'SERVICIOS',
      isConfigured: map['isConfigured'] ?? false,
    );
  }
}
