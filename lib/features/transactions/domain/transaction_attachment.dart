class TransactionAttachmentFile {
  const TransactionAttachmentFile({
    required this.path,
    required this.filename,
    required this.sizeBytes,
    required this.mimeType,
  });

  final String path;
  final String filename;
  final int sizeBytes;
  final String mimeType;

  static const maxSizeBytes = 5 * 1024 * 1024;

  bool get isValidSize => sizeBytes <= maxSizeBytes;
  bool get isValidMimeType => allowedMimeTypes.contains(mimeType);

  static const allowedMimeTypes = <String>{'image/jpeg', 'image/png'};

  static String? mimeTypeFromFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    return null;
  }

  static String formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
  }
}
