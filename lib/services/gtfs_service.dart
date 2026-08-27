import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'gtfs_models.dart';

/// Client for Malaysia's official Open API GTFS Static feed.
///
/// Docs: https://developer.data.gov.my/realtime-api/gtfs-static
/// No API key required. Returns a ZIP of standard GTFS text files
/// (stops.txt, routes.txt, trips.txt, stop_times.txt, calendar.txt).
///
/// `category` for the Prasarana endpoint (LRT/MRT/monorail/bus) is one of:
/// rapid-rail-kl, rapid-bus-kl, rapid-bus-mrtfeeder, rapid-bus-penang,
/// rapid-bus-kuantan.
class GtfsService {
  static const _baseUrl = 'https://api.data.gov.my/gtfs-static/prasarana';
  static const _timeout = Duration(seconds: 20);

  /// Fetches and parses stops.txt for the given Prasarana category.
  /// Throws on any network/parse failure — callers should catch and fall
  /// back to cached/mock data rather than let this bubble up to the UI.
  static Future<List<GtfsStop>> fetchStops({String category = 'rapid-rail-kl'}) async {
    final rows = await _fetchCsvFile(category: category, fileName: 'stops.txt');
    if (rows.isEmpty) return [];

    final header = rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final idIdx = header.indexOf('stop_id');
    final nameIdx = header.indexOf('stop_name');
    final latIdx = header.indexOf('stop_lat');
    final lonIdx = header.indexOf('stop_lon');
    if (idIdx < 0 || nameIdx < 0 || latIdx < 0 || lonIdx < 0) {
      throw const FormatException('stops.txt missing expected GTFS columns');
    }

    final stops = <GtfsStop>[];
    for (final row in rows.skip(1)) {
      if (row.length <= [idIdx, nameIdx, latIdx, lonIdx].reduce((a, b) => a > b ? a : b)) {
        continue; // malformed row, skip
      }
      final lat = double.tryParse(row[latIdx].toString());
      final lon = double.tryParse(row[lonIdx].toString());
      if (lat == null || lon == null) continue;
      stops.add(GtfsStop(
        stopId: row[idIdx].toString(),
        name: row[nameIdx].toString().trim(),
        lat: lat,
        lon: lon,
      ));
    }
    return stops;
  }

  /// Fetches and parses routes.txt for the given Prasarana category.
  static Future<List<GtfsRoute>> fetchRoutes({String category = 'rapid-rail-kl'}) async {
    final rows = await _fetchCsvFile(category: category, fileName: 'routes.txt');
    if (rows.isEmpty) return [];

    final header = rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final idIdx = header.indexOf('route_id');
    final shortIdx = header.indexOf('route_short_name');
    final longIdx = header.indexOf('route_long_name');
    if (idIdx < 0) throw const FormatException('routes.txt missing route_id column');

    final routes = <GtfsRoute>[];
    for (final row in rows.skip(1)) {
      if (row.length <= idIdx) continue;
      routes.add(GtfsRoute(
        routeId: row[idIdx].toString(),
        shortName: shortIdx >= 0 && row.length > shortIdx ? row[shortIdx].toString() : '',
        longName: longIdx >= 0 && row.length > longIdx ? row[longIdx].toString() : '',
      ));
    }
    return routes;
  }

  /// Downloads the GTFS ZIP for [category], extracts [fileName], and
  /// parses it as CSV. Returns rows including the header row.
  static Future<List<List<dynamic>>> _fetchCsvFile({
    required String category,
    required String fileName,
  }) async {
    final uri = Uri.parse('$_baseUrl?category=$category');
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw http.ClientException('GTFS Static API returned ${response.statusCode}', uri);
    }

    final archive = ZipDecoder().decodeBytes(response.bodyBytes);
    final file = archive.files.firstWhere(
          (f) => f.name.toLowerCase() == fileName.toLowerCase(),
      orElse: () => throw FormatException('$fileName not found in GTFS feed for $category'),
    );

    final content = utf8.decode(file.content as List<int>, allowMalformed: true);
    return const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(content);
  }
}