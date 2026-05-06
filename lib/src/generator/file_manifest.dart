class GeneratedFile {
  const GeneratedFile({
    required this.path,
    required this.contents,
    required this.ownershipMarker,
    this.appendIfExists = false,
  });

  final bool appendIfExists;
  final String contents;
  final String ownershipMarker;
  final String path;
}
