import 'package:flutter/foundation.dart';
import '../models/client_model.dart';

class ClientsProvider extends ChangeNotifier {
  final List<ClientModel> _clients = [
    ClientModel(
      id: 'cli_1',
      name: 'Ana María Gómez',
      phone: '312 456 7890',
      document: '1020304050',
      email: 'ana.gomez@gmail.com',
      address: 'Calle 10 # 25-14',
      notes: 'Boda en noviembre. Tonos rosa pastel y dorado.',
    ),
    ClientModel(
      id: 'cli_2',
      name: 'Carlos Mendoza',
      phone: '315 889 1234',
      document: '900123456-1',
      email: 'carlos@eventos.co',
      address: 'Av. Las Palmas # 12',
      notes: 'Eventos corporativos y souvenirs en acrílico.',
    ),
    ClientModel(
      id: 'cli_3',
      name: 'Laura Restrepo',
      phone: '320 654 9871',
      document: '1035987654',
      email: 'laura.res@hotmail.com',
      address: 'Cra 43A # 1-50',
      notes: 'Cumpleaños infantil temática Safari.',
    ),
  ];

  List<ClientModel> get clients => List.unmodifiable(_clients);

  ClientModel? getClientById(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addClient(ClientModel client) {
    _clients.insert(0, client);
    notifyListeners();
  }

  void updateClient(ClientModel client) {
    final idx = _clients.indexWhere((c) => c.id == client.id);
    if (idx != -1) {
      _clients[idx] = client;
      notifyListeners();
    }
  }

  void deleteClient(String id) {
    _clients.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
