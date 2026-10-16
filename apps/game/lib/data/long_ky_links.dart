/// Links into Long Ký (build-spec section 6) from one config template.
///
/// The template holds `{id}` and may hold `{kind}`, which becomes `person` or
/// `event`. The real format is an open input (see `LongKyConfig`), so nothing
/// is assumed about it here.
final class LongKyLinks {
  const LongKyLinks({this.template = '', this.storeUrl = ''});

  final String template;
  final String storeUrl;

  bool get isConfigured =>
      template.contains('{id}') && _parse(template.replaceAll('{id}', 'x').replaceAll('{kind}', 'x')) != null;

  Uri? person(String id) => _build('person', id);

  Uri? event(String id) => _build('event', id);

  /// The store page, if one is configured.
  Uri? get store => storeUrl.isEmpty ? null : _parse(storeUrl);

  Uri? _build(String kind, String id) {
    if (!template.contains('{id}')) return null;
    return _parse(template.replaceAll('{kind}', kind).replaceAll('{id}', Uri.encodeComponent(id)));
  }

  static Uri? _parse(String s) {
    final uri = Uri.tryParse(s);
    return uri != null && uri.hasScheme ? uri : null;
  }
}
