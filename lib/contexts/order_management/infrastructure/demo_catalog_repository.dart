import '../domain/fruit_product.dart';
import '../domain/catalog_repository.dart';

/// Static catalog adapted from the previous FruitLogix Vue customer catalog.
/// The values are DEMO data and are not from the backend.
class DemoCatalogRepository implements CatalogRepository {
  const DemoCatalogRepository();

  @override
  List<FruitProduct> getProducts() => const [
    FruitProduct(id: 1, name: 'Mango Kent', description: 'Sweet mango from Piura', category: 'Fruits', price: 4.50, stock: 200),
    FruitProduct(id: 2, name: 'Blueberries', description: 'Fresh berries from La Libertad', category: 'Fruits', price: 18.00, stock: 80),
    FruitProduct(id: 3, name: 'Hass avocado', description: 'Fresh, creamy Hass avocado', category: 'Fruits', price: 7.50, stock: 150),
    FruitProduct(id: 4, name: 'Asparagus', description: 'Fresh green asparagus from Ica', category: 'Vegetables', price: 6.00, stock: 120),
    FruitProduct(id: 5, name: 'Red Globe grapes', description: 'Sweet red table grapes', category: 'Fruits', price: 8.00, stock: 90),
    FruitProduct(id: 6, name: 'Red pepper', description: 'Fresh red bell pepper', category: 'Vegetables', price: 5.50, stock: 200),
    FruitProduct(id: 7, name: 'Mandarin', description: 'Fresh Peruvian mandarin', category: 'Fruits', price: 3.50, stock: 300),
    FruitProduct(id: 8, name: 'Broccoli', description: 'Fresh organic broccoli', category: 'Vegetables', price: 4.00, stock: 100),
  ];
}
