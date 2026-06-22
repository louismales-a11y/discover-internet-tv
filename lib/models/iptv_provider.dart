class IptvProvider {
  final String name;
  final String website;
  final String? description;
  final String? pricing;
  final String? channels;
  final String? trialInfo;
  final String? rating;
  final String source;

  IptvProvider({
    required this.name,
    required this.website,
    this.description,
    this.pricing,
    this.channels,
    this.trialInfo,
    this.rating,
    required this.source,
  });
}
