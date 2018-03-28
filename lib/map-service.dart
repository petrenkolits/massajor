// import 'package:map_view/map_view.dart';

class MapService {
  static final MapService _instance = new MapService._internal();

  MapService._internal();

  factory MapService() {
    return _instance;
  }
}
