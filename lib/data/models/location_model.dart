// lib/data/models/location_model.dart

class LocationModel {
  final String id;
  final String name;
  final String address;
  final bool isSaved;
  final bool isCustom; // For manually entered addresses

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    this.isSaved = false,
    this.isCustom = false,
  });

  static List<LocationModel> getSectors() {
    return [
      LocationModel(
        id: 'sec_1',
        name: 'Khalabat Sector 1',
        address: 'Main Market Road, Sector 1',
        isSaved: true,
      ),
      LocationModel(
        id: 'sec_2',
        name: 'Khalabat Sector 2',
        address: 'Near Jamia Masjid, Sector 2',
        isSaved: false,
      ),
      LocationModel(
        id: 'sec_3',
        name: 'Khalabat Sector 3',
        address: 'Opposite Park, Sector 3',
        isSaved: false,
      ),
      LocationModel(
        id: 'sec_4',
        name: 'Khalabat Sector 4',
        address: 'Main Boulevard, Sector 4',
        isSaved: false,
      ),
    ];
  }
}
