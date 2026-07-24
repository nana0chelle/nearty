import 'package:latlong2/latlong.dart'; 
void main() { 
  final Distance distance = const Distance(); 
  final num km = distance.as(LengthUnit.Kilometer, LatLng(-6.9200, 107.6059), LatLng(-6.8427, 107.4739)); 
  final num m = distance.as(LengthUnit.Meter, LatLng(-6.9200, 107.6059), LatLng(-6.8427, 107.4739)); 
  final double kmReal = distance(LatLng(-6.9200, 107.6059), LatLng(-6.8427, 107.4739)) / 1000.0;
  print('km (as): $km');
  print('m (as): $m');
  print('kmReal: $kmReal');
}
