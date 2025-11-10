const String _placeholderImage =
    "https://images.unsplash.com/photo-1506765515384-028b60a970df?auto=format&fit=crop&w=800&q=60";

String resolveProjectImage(Map<String, dynamic> project) {
  final primary = project["image"];
  if (primary is String && primary.trim().isNotEmpty) {
    return primary.trim();
  }

  final images = project["images"];
  if (images is List) {
    for (final value in images) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
  }

  return _placeholderImage;
}

