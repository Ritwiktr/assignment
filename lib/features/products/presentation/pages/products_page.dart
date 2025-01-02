import 'package:assignment/features/products/presentation/widgets/filter_sort_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_card.dart';

import 'product_details_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterSortSheet(BuildContext context, ProductsLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSortSheet(
        state: state,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: _buildBody(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'E-Shop',
        style: TextStyle(
          color: Colors.indigo[900],
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoaded) {
              final isFiltered = state.currentFilters.category != null ||
                  state.currentFilters.brand != null ||
                  state.currentFilters.minPrice != null ||
                  state.currentFilters.maxPrice != null ||
                  state.currentSortOption != SortOption.name ||
                  !state.sortAscending;

              return FilterSortButton(
                isFiltered: isFiltered,
                onPressed: () => _showFilterSortSheet(context, state),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: Colors.indigo[900]),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.indigo[900]),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Container(
      color: Colors.grey[50],
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsInitial) {
            context.read<ProductsBloc>().add(LoadProducts());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoading) {
            return _buildLoadingState(theme);
          }

          if (state is ProductsLoaded) {
            if (state.filteredProducts.isEmpty) {
              return _buildEmptyState(theme, context);
            }
            return _buildProductList(state);
          }

          if (state is ProductsError) {
            return _buildErrorState(state, theme, context);
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading amazing products...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              context.read<ProductsBloc>().add(FilterProducts());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      ProductsError state, ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! ${state.message}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProductsBloc>().add(LoadProducts());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductsLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                (index / state.filteredProducts.length),
                1.0,
                curve: Curves.easeOut,
              ),
            )),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProductCard(
                product: product,
                heroTag:
                    'product_${product.id}', // Pass the hero tag to ProductCard
                onTap: () => _navigateToProductDetails(context, product.id),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToProductDetails(BuildContext context, int productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: BlocProvider.of<ProductsBloc>(context),
          child: ProductDetailsPage(
            productId: productId,
            heroTag: 'product_$productId',
          ),
        ),
      ),
    );
  }
}
