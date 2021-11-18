import 'package:nm/nm.dart';

class NetworkService extends NetworkManagerClient {
  bool get isOnline => connectivity == NetworkManagerConnectivityState.full;
}
