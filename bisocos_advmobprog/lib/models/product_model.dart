// Product Model
class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? '',
    // Handle both 'image' (fakestoreapi) and 'thumbnail' (dummyjson)
    image: json['image'] as String? ?? json['thumbnail'] as String? ?? '',
  );
}
