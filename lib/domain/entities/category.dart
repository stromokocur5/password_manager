import 'package:equatable/equatable.dart';

/// Represents a category or folder for organizing password entries.
class Category extends Equatable {
  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Icon identifier.
  final String? icon;

  /// Sort order.
  final int order;

  const Category({
    required this.id,
    required this.name,
    this.icon,
    this.order = 0,
  });

  Category copyWith({String? id, String? name, String? icon, int? order}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, order];
}

/// Default categories provided by the application.
class DefaultCategories {
  DefaultCategories._();

  static const login = Category(
    id: 'login',
    name: 'Login',
    icon: 'person',
    order: 0,
  );

  static const card = Category(
    id: 'card',
    name: 'Card',
    icon: 'credit_card',
    order: 1,
  );

  static const identity = Category(
    id: 'identity',
    name: 'Identity',
    icon: 'badge',
    order: 2,
  );

  static const secureNote = Category(
    id: 'secure_note',
    name: 'Secure Note',
    icon: 'note',
    order: 3,
  );

  static const all = [login, card, identity, secureNote];
}
