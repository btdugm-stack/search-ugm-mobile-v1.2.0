import 'dart:convert';
import 'dart:io';

import 'models.dart';

class ApiClient {
  static const _endpoint = 'https://search.ugm.ac.id/ai/search%26dsh/api/api.php';

  Future<Map<String, dynamic>> _get(Map<String, String> query) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: query);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'SearchUGM-Mobile/1.1');
      final response = await request.close().timeout(const Duration(seconds: 30));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Server merespons ${response.statusCode}');
      }
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic> || json['ok'] != true) {
        throw const FormatException('Respons API tidak valid');
      }
      return json;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _post(Map<String, String> fields) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(Uri.parse(_endpoint));
      request.headers.contentType = ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.write(fields.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&'));
      final response = await request.close().timeout(const Duration(seconds: 45));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Server merespons ${response.statusCode}');
      }
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic> || json['ok'] != true) {
        throw const FormatException('Respons AI tidak valid');
      }
      return json;
    } finally {
      client.close(force: true);
    }
  }

  Future<SearchResponse> search({
    required String query,
    String type = 'all',
    String dharma = '',
    String year = '',
  }) async {
    final params = buildSearchParameters(
      query: query,
      type: type,
      dharma: dharma,
      year: year,
    );
    final json = await _get(params);
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final raw = data['results'] ?? data['items'] ?? const [];
    var items = raw is List
        ? raw.whereType<Map>().map((item) => SearchItem.fromJson(item.cast<String, dynamic>())).toList()
        : <SearchItem>[];
    if (query.trim().isEmpty && type != 'all') {
      final expectedType = type == 'tech4disaster' ? 'publication' : type;
      items = items.where((item) => item.type == expectedType).toList();
    }
    return SearchResponse(items: items, total: (data['count'] as num?)?.toInt() ?? (data['total'] as num?)?.toInt() ?? items.length);
  }

  Future<List<Facility>> facilities() async {
    final json = await _get(const {'action': 'facility_locations'});
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final raw = data['facilities'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Facility.fromJson(item.cast<String, dynamic>()))
        .where((item) => item.latitude != 0 && item.longitude != 0)
        .toList();
  }

  Future<List<Service>> services() async {
    final all = <Service>[];
    for (var page = 1; page <= 5; page++) {
      final json = await _get({
        'action': 'browse',
        'type': 'service',
        'page': '$page',
        'limit': '100',
        'sort': 'latest',
      });
      final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
      final raw = data['results'] ?? const [];
      final items = raw is List
          ? raw.whereType<Map>().map((item) => Service.fromJson(item.cast<String, dynamic>())).toList()
          : <Service>[];
      all.addAll(items);
      if (items.length < 100) break;
    }
    return all;
  }

  Future<ChatAnswer> askSmart(String question, String sessionId) async {
    final json = await _post({
      'action': 'rag_answer',
      'q': question.trim(),
      'types': 'all',
      'session_id': sessionId,
      'smart_mode': '1',
    });
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final answer = '${data['answer'] ?? data['response'] ?? json['answer'] ?? 'Jawaban belum tersedia.'}';
    final raw = data['sources'] ?? data['results'] ?? const [];
    final sources = raw is List
        ? raw.whereType<Map>().map((item) => SearchItem.fromJson(item.cast<String, dynamic>())).toList()
        : <SearchItem>[];
    return ChatAnswer(answer: answer, sources: sources);
  }
}

Map<String, String> buildSearchParameters({
  required String query,
  String type = 'all',
  String dharma = '',
  String year = '',
}) {
  final normalizedQuery = query.trim();
  final isBrowse = normalizedQuery.isEmpty;
  final effectiveType = type == 'tech4disaster'
      ? 'publication'
      : (type == 'all' ? 'service' : type);
  final params = <String, String>{
    'action': isBrowse ? 'browse' : 'smart_search',
    if (!isBrowse) 'q': normalizedQuery,
    'page': '1',
    'limit': '30',
  };
  if (isBrowse) {
    // The current web implementation uses `type`, not `entity_type`.
    params['type'] = effectiveType;
    params['sort'] = 'latest';
    if (type == 'tech4disaster') {
      params['publication_gok'] = 'Tech4disaster';
    }
  } else {
    params['types'] = type;
  }
  if (dharma.isNotEmpty) params['dharma'] = dharma;
  if (year.isNotEmpty) params['publication_year'] = year;
  return params;
}
