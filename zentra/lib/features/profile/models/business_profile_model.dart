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

  const BusinessProfileModel({
    this.businessName = 'TM Diseños Creativos',
    this.ownerName = 'Tatiana Marín',
    this.phone = '312 456 7890',
    this.city = 'Colombia',
    this.logoIconName = 'auto_awesome',
    this.nequi = '312 456 7890',
    this.daviplata = '312 456 7890',
    this.bancolombia = '123-456789-01',
    this.customNote = '¡Muchas gracias por apoyar nuestro talento local! 🌸',
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
    };
  }

  factory BusinessProfileModel.fromMap(Map<String, dynamic> map) {
    return BusinessProfileModel(
      businessName: map['businessName'] ?? 'TM Diseños Creativos',
      ownerName: map['ownerName'] ?? 'Tatiana Marín',
      phone: map['phone'] ?? '312 456 7890',
      city: map['city'] ?? 'Colombia',
      logoIconName: map['logoIconName'] ?? 'auto_awesome',
      nequi: map['nequi'] ?? '312 456 7890',
      daviplata: map['daviplata'] ?? '312 456 7890',
      bancolombia: map['bancolombia'] ?? '123-456789-01',
      customNote: map['customNote'] ?? '¡Muchas gracias por apoyar nuestro talento local! 🌸',
    );
  }
}
