import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/product.dart';
import '../../data/repositories/products_repository.dart';

abstract class ProductsEvent {}

class LoadProducts extends ProductsEvent {}

class LoadProductDetails extends ProductsEvent {
  final int productId;
  LoadProductDetails(this.productId);
}

class FilterProducts extends ProductsEvent {
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;

  FilterProducts({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
  });
}

class SortProducts extends ProductsEvent {
  final SortOption sortOption;
  final bool ascending;

  SortProducts({
    required this.sortOption,
    this.ascending = true,
  });
}

// States
abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final Product? selectedProduct;
  final FilterOptions currentFilters;
  final SortOption currentSortOption;
  final bool sortAscending;

  ProductsLoaded({
    required this.products,
    required this.filteredProducts,
    this.selectedProduct,
    required this.currentFilters,
    required this.currentSortOption,
    required this.sortAscending,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    Product? selectedProduct,
    FilterOptions? currentFilters,
    SortOption? currentSortOption,
    bool? sortAscending,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      currentFilters: currentFilters ?? this.currentFilters,
      currentSortOption: currentSortOption ?? this.currentSortOption,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class ProductDetailsLoading extends ProductsState {}

class ProductDetailsLoaded extends ProductsState {
  final Product product;
  final List<Product> products;

  ProductDetailsLoaded({
    required this.product,
    required this.products,
  });
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

// Enums and Helper Classes
enum SortOption { price, rating, name, discount }

class FilterOptions {
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;

  const FilterOptions({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
  });

  bool get isActive =>
      category != null || brand != null || minPrice != null || maxPrice != null;

  FilterOptions copyWith({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool clearCategory = false,
    bool clearBrand = false,
    bool clearPriceRange = false,
  }) {
    return FilterOptions(
      category: clearCategory ? null : (category ?? this.category),
      brand: clearBrand ? null : (brand ?? this.brand),
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
    );
  }
}

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository repository;
  List<Product> _cachedProducts = [];

  ProductsBloc({required this.repository}) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<FilterProducts>(_onFilterProducts);
    on<SortProducts>(_onSortProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(ProductsLoading());
      final products = await repository.getProducts();
      _cachedProducts = products;

      emit(ProductsLoaded(
        products: products,
        filteredProducts: products,
        currentFilters: const FilterOptions(),
        currentSortOption: SortOption.name,
        sortAscending: true,
      ));
    } catch (e) {
      emit(ProductsError(_getErrorMessage(e)));
    }
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      emit(ProductDetailsLoading());

      // First try to get from cache for immediate display
      final cachedProduct = _cachedProducts.firstWhere(
        (p) => p.id == event.productId,
        orElse: () => throw Exception('Product not found'),
      );

      emit(ProductDetailsLoaded(
        product: cachedProduct,
        products: _cachedProducts,
      ));

      // Then try to get fresh data from repository
      try {
        final freshProduct = await repository.getProductById(event.productId);
        // Update cache with fresh data
        _cachedProducts = _cachedProducts
            .map((p) => p.id == freshProduct.id ? freshProduct : p)
            .toList();

        emit(ProductDetailsLoaded(
          product: freshProduct,
          products: _cachedProducts,
        ));
      } catch (e) {
        // If fresh data fetch fails, we already have cached data displayed
        print('Failed to fetch fresh product details: ${e.toString()}');
      }
    } catch (e) {
      emit(ProductsError(_getErrorMessage(e)));
    }
  }

  void _onFilterProducts(
    FilterProducts event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;

      final newFilters = FilterOptions(
        category: event.category,
        brand: event.brand,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );

      final filteredProducts = _filterProducts(
        currentState.products,
        newFilters,
      );

      final sortedAndFilteredProducts = _sortProducts(
        filteredProducts,
        currentState.currentSortOption,
        currentState.sortAscending,
      );

      emit(currentState.copyWith(
        filteredProducts: sortedAndFilteredProducts,
        currentFilters: newFilters,
      ));
    }
  }

  void _onSortProducts(
    SortProducts event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;

      final sortedProducts = _sortProducts(
        currentState.filteredProducts,
        event.sortOption,
        event.ascending,
      );

      emit(currentState.copyWith(
        filteredProducts: sortedProducts,
        currentSortOption: event.sortOption,
        sortAscending: event.ascending,
      ));
    }
  }

  List<Product> _filterProducts(List<Product> products, FilterOptions filters) {
    return products.where((product) {
      final categoryMatch =
          filters.category == null || product.category == filters.category;
      final brandMatch =
          filters.brand == null || product.brand == filters.brand;
      final priceMatch =
          (filters.minPrice == null || product.price >= filters.minPrice!) &&
              (filters.maxPrice == null || product.price <= filters.maxPrice!);

      return categoryMatch && brandMatch && priceMatch;
    }).toList();
  }

  List<Product> _sortProducts(
    List<Product> products,
    SortOption sortOption,
    bool ascending,
  ) {
    final sortedProducts = List<Product>.from(products);

    switch (sortOption) {
      case SortOption.price:
        sortedProducts.sort((a, b) => ascending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sortedProducts.sort((a, b) => ascending
            ? a.rating.compareTo(b.rating)
            : b.rating.compareTo(a.rating));
        break;
      case SortOption.name:
        sortedProducts.sort((a, b) => ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case SortOption.discount:
        sortedProducts.sort((a, b) => ascending
            ? a.discountPercentage.compareTo(b.discountPercentage)
            : b.discountPercentage.compareTo(a.discountPercentage));
        break;
    }

    return sortedProducts;
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
