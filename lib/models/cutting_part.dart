class CuttingPart {
  final String name; 
  final double width;
  final double length;
  final String material;
  final int quantity;
  final bool isCover; 

  CuttingPart({
    required this.name,
    required this.width,
    required this.length,
    required this.material,
    required this.quantity,
    this.isCover = false,
  });

  // cm2 -> m2 çevrimi
  double get area => (width * length * quantity) / 10000; 
}