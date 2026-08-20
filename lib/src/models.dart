class SearchItem {
  const SearchItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.source,
    this.dharma = '',
    this.publishDate = '',
    this.owner = '',
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final String url;
  final String source;
  final String dharma;
  final String publishDate;
  final String owner;

  factory SearchItem.fromJson(Map<String, dynamic> json) => SearchItem(
        id: '${json['id'] ?? ''}',
        title: '${json['name'] ?? json['title'] ?? 'Tanpa judul'}',
        description: '${json['description'] ?? json['content'] ?? ''}',
        type: '${json['entity_type'] ?? json['type'] ?? 'service'}',
        url: '${json['url'] ?? json['web_url'] ?? ''}',
        source: '${json['source_name'] ?? json['source_origin'] ?? json['source'] ?? 'UGM'}',
        dharma: '${json['dharma'] ?? ''}',
        publishDate: '${json['publish_date_text'] ?? json['upload_date'] ?? ''}',
        owner: '${json['owner'] ?? ''}',
      );
}

class SearchResponse {
  const SearchResponse({required this.items, required this.total});
  final List<SearchItem> items;
  final int total;
}

class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.category,
    required this.owner,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.webUrl,
    required this.routeUrl,
  });

  final String id;
  final String name;
  final String category;
  final String owner;
  final String description;
  final double latitude;
  final double longitude;
  final String webUrl;
  final String routeUrl;

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? 'Fasilitas UGM'}',
        category: '${json['category'] ?? 'Lainnya'}',
        owner: '${json['pemilik'] ?? 'UGM'}',
        description: '${json['description'] ?? ''}',
        latitude: double.tryParse('${json['latitude'] ?? ''}') ?? 0,
        longitude: double.tryParse('${json['longitude'] ?? ''}') ?? 0,
        webUrl: '${json['web_url'] ?? ''}',
        routeUrl: '${json['route_url'] ?? ''}',
      );
}

class ChatAnswer {
  const ChatAnswer({required this.answer, required this.sources});
  final String answer;
  final List<SearchItem> sources;
}

class Service {
  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.owner,
    required this.audience,
    required this.dharma,
    required this.isExternal,
  });

  final String id;
  final String name;
  final String description;
  final String url;
  final String owner;
  final String audience;
  final String dharma;
  final bool isExternal;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? json['title'] ?? 'Tanpa nama'}',
        description: '${json['description'] ?? ''}',
        url: '${json['url'] ?? ''}',
        owner: '${json['owner'] ?? ''}',
        audience: '${json['audience'] ?? ''}',
        dharma: '${json['dharma'] ?? ''}',
        isExternal: json['is_external'] == 1 ||
            json['is_external'] == '1' ||
            json['is_external'] == true,
      );
}
