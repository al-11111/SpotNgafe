enum CrowdLevel {
  sepi('Sepi'),
  sedang('Sedang'),
  penuh('Penuh');

  final String label;
  const CrowdLevel(this.label);

  static CrowdLevel? fromString(String? value) {
    if (value == null) return null;
    switch (value.trim().toLowerCase()) {
      case 'sepi':
        return CrowdLevel.sepi;
      case 'sedang':
        return CrowdLevel.sedang;
      case 'penuh':
        return CrowdLevel.penuh;
      default:
        return null;
    }
  }
}
