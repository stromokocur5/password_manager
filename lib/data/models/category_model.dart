import 'package:hive/hive.dart';

part 'category_model.g.dart';

/// Hive model for categories.
@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? icon;

  @HiveField(3)
  late int order;

  CategoryModel();

  CategoryModel.create({
    required this.id,
    required this.name,
    this.icon,
    this.order = 0,
  });
}
