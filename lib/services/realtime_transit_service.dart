import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../shared/models/transit_vehicle.dart';

/// Reads RapidKL's official GTFS-Realtime vehicle-position feed. The feed is
/// protobuf rather than JSON; this deliberately decodes only the fields used
/// here (vehicle id, route id, latitude, longitude, and timestamp).
class RealtimeTransitService {
  RealtimeTransitService._();
  static final instance = RealtimeTransitService._();

  static const _url =
      'https://api.data.gov.my/gtfs-realtime/vehicle-position/prasarana?category=rapid-bus-kl';

  Future<List<TransitVehicle>> fetchVehicles() async {
    final response =
        await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw http.ClientException(
          'Realtime API returned ${response.statusCode}');
    }
    final vehicles = <TransitVehicle>[];
    for (final entity
        in _fields(response.bodyBytes).where((field) => field.number == 2)) {
      final vehicle = _parseVehicle(entity.bytes!);
      if (vehicle != null) vehicles.add(vehicle);
    }
    return vehicles;
  }

  TransitVehicle? _parseVehicle(Uint8List entity) {
    Uint8List? vehicleMessage;
    String entityId = '';
    for (final field in _fields(entity)) {
      if (field.number == 1 && field.bytes != null)
        entityId = String.fromCharCodes(field.bytes!);
      if (field.number == 2 && field.bytes != null)
        vehicleMessage = field.bytes;
    }
    if (vehicleMessage == null) return null;
    String route = '';
    String vehicleId = entityId;
    double? latitude;
    double? longitude;
    int timestamp = 0;
    for (final field in _fields(vehicleMessage)) {
      if (field.number == 1 && field.bytes != null) {
        for (final trip in _fields(field.bytes!)) {
          if (trip.number == 5 && trip.bytes != null)
            route = String.fromCharCodes(trip.bytes!);
        }
      } else if (field.number == 2 && field.bytes != null) {
        for (final point in _fields(field.bytes!)) {
          if (point.number == 1 && point.fixed32 != null)
            latitude = _float(point.fixed32!);
          if (point.number == 2 && point.fixed32 != null)
            longitude = _float(point.fixed32!);
        }
      } else if (field.number == 3 && field.bytes != null) {
        for (final descriptor in _fields(field.bytes!)) {
          if (descriptor.number == 1 && descriptor.bytes != null)
            vehicleId = String.fromCharCodes(descriptor.bytes!);
        }
      } else if (field.number == 5 && field.value != null) {
        timestamp = field.value!;
      }
    }
    if (latitude == null || longitude == null) return null;
    return TransitVehicle(
      id: vehicleId.isEmpty ? 'Vehicle' : vehicleId,
      routeLabel: route.isEmpty ? 'Rapid KL bus' : 'Rapid KL $route',
      position: LatLng(latitude, longitude),
      updatedAt: timestamp > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
          : DateTime.now(),
    );
  }

  double _float(int bits) {
    final data = ByteData(4)..setUint32(0, bits, Endian.little);
    return data.getFloat32(0, Endian.little);
  }

  List<_ProtoField> _fields(Uint8List data) {
    final fields = <_ProtoField>[];
    var index = 0;
    while (index < data.length) {
      final tag = _readVarint(data, index);
      index = tag.next;
      final number = tag.value >> 3;
      switch (tag.value & 7) {
        case 0:
          final value = _readVarint(data, index);
          fields.add(_ProtoField(number, value: value.value));
          index = value.next;
          break;
        case 2:
          final length = _readVarint(data, index);
          index = length.next;
          final end = index + length.value;
          if (end > data.length) return fields;
          fields.add(_ProtoField(number,
              bytes: Uint8List.sublistView(data, index, end)));
          index = end;
          break;
        case 5:
          if (index + 4 > data.length) return fields;
          fields.add(_ProtoField(number,
              fixed32: ByteData.sublistView(data, index, index + 4)
                  .getUint32(0, Endian.little)));
          index += 4;
          break;
        default:
          return fields;
      }
    }
    return fields;
  }

  _Varint _readVarint(Uint8List data, int index) {
    var value = 0;
    var shift = 0;
    while (index < data.length) {
      final byte = data[index++];
      value |= (byte & 0x7f) << shift;
      if (byte & 0x80 == 0) break;
      shift += 7;
    }
    return _Varint(value, index);
  }
}

class _ProtoField {
  final int number;
  final int? value;
  final int? fixed32;
  final Uint8List? bytes;
  const _ProtoField(this.number, {this.value, this.fixed32, this.bytes});
}

class _Varint {
  final int value;
  final int next;
  const _Varint(this.value, this.next);
}
