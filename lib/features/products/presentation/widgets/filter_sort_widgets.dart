import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/products_bloc.dart';

class FilterSortSheet extends StatefulWidget {
  final ProductsLoaded state;
  final Function() onClose;

  const FilterSortSheet({
    Key? key,
    required this.state,
    required this.onClose,
  }) : super(key: key);

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  String? _selectedBrand;
  RangeValues? _priceRange;
  SortOption _currentSortOption = SortOption.name;
  bool _sortAscending = true;
  double? _minPrice;
  double? _maxPrice;

  final _lightBlue = const Color(0xFFE3F2FD);
  final _mediumBlue = const Color(0xFF90CAF9);
  final _darkBlue = const Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = widget.state.currentFilters.category;
    _selectedBrand = widget.state.currentFilters.brand;
    _currentSortOption = widget.state.currentSortOption;
    _sortAscending = widget.state.sortAscending;

    if (widget.state.products.isNotEmpty) {
      _minPrice = widget.state.products.map((p) => p.price).reduce(min);
      _maxPrice = widget.state.products.map((p) => p.price).reduce(max);
      _priceRange = RangeValues(
        widget.state.currentFilters.minPrice ?? _minPrice!,
        widget.state.currentFilters.maxPrice ?? _maxPrice!,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _lightBlue.withOpacity(0.9),
            _lightBlue.withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFilterTab(),
                _buildSortTab(),
              ],
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter & Sort',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _darkBlue,
              letterSpacing: 0.3,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: _darkBlue),
            onPressed: widget.onClose,
            style: IconButton.styleFrom(
              backgroundColor: _lightBlue.withOpacity(0.3),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _lightBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Filter'),
          Tab(text: 'Sort'),
        ],
        labelColor: _darkBlue,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildFilterTab() {
    final categories =
        widget.state.products.map((p) => p.category).toSet().toList()..sort();
    final brands = widget.state.products.map((p) => p.brand).toSet().toList()
      ..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(
            title: 'Category',
            icon: Icons.category_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: categories.map((category) {
                return FilterChip(
                  selected: _selectedCategory == category,
                  label: Text(category),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                  selectedColor: _mediumBlue.withOpacity(0.7),
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: _selectedCategory == category
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: _selectedCategory == category
                          ? _mediumBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          _buildFilterSection(
            title: 'Brand',
            icon: Icons.shop_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 12,
              children: brands.map((brand) {
                return FilterChip(
                  selected: _selectedBrand == brand,
                  label: Text(brand),
                  onSelected: (selected) {
                    setState(() {
                      _selectedBrand = selected ? brand : null;
                    });
                  },
                  selectedColor: _mediumBlue.withOpacity(0.7),
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color:
                        _selectedBrand == brand ? Colors.white : Colors.black87,
                    fontWeight: _selectedBrand == brand
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: _selectedBrand == brand
                          ? _mediumBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_minPrice != null && _maxPrice != null) ...[
            const SizedBox(height: 32),
            _buildFilterSection(
              title: 'Price Range',
              icon: Icons.attach_money_outlined,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  RangeSlider(
                    values: _priceRange!,
                    min: _minPrice!,
                    max: _maxPrice!,
                    divisions: 100,
                    activeColor: _mediumBlue,
                    inactiveColor: _lightBlue,
                    labels: RangeLabels(
                      '\$${_priceRange!.start.toStringAsFixed(2)}',
                      '\$${_priceRange!.end.toStringAsFixed(2)}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_priceRange!.start.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${_priceRange!.end.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _selectedBrand = null;
                  if (_minPrice != null && _maxPrice != null) {
                    _priceRange = RangeValues(_minPrice!, _maxPrice!);
                  }
                });
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Reset Filters'),
              style: TextButton.styleFrom(
                foregroundColor: _darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      children: [
        _buildSortOption(
          title: 'Name',
          subtitle: 'Sort alphabetically',
          icon: Icons.sort_by_alpha,
          value: SortOption.name,
        ),
        _buildSortOption(
          title: 'Price',
          subtitle: 'Sort by product price',
          icon: Icons.attach_money,
          value: SortOption.price,
        ),
        _buildSortOption(
          title: 'Rating',
          subtitle: 'Sort by customer ratings',
          icon: Icons.star_outline,
          value: SortOption.rating,
        ),
        _buildSortOption(
          title: 'Discount',
          subtitle: 'Sort by discount percentage',
          icon: Icons.local_offer_outlined,
          value: SortOption.discount,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SwitchListTile(
            title: const Text(
              'Reverse Order',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _sortAscending ? 'Ascending' : 'Descending',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            value: !_sortAscending,
            onChanged: (value) {
              setState(() {
                _sortAscending = !value;
              });
            },
            activeColor: _darkBlue,
            activeTrackColor: _mediumBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSortOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required SortOption value,
  }) {
    final isSelected = _currentSortOption == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected ? _lightBlue.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? _mediumBlue : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RadioListTile<SortOption>(
        value: value,
        groupValue: _currentSortOption,
        onChanged: (newValue) {
          setState(() {
            _currentSortOption = newValue!;
          });
        },
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        secondary: Icon(
          icon,
          color: isSelected ? _darkBlue : Colors.grey.shade600,
        ),
        activeColor: _darkBlue,
        selected: isSelected,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _darkBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Apply filters
          context.read<ProductsBloc>().add(
                FilterProducts(
                  category: _selectedCategory,
                  brand: _selectedBrand,
                  minPrice: _priceRange?.start,
                  maxPrice: _priceRange?.end,
                ),
              );

          // Apply sorting
          context.read<ProductsBloc>().add(
                SortProducts(
                  sortOption: _currentSortOption,
                  ascending: _sortAscending,
                ),
              );

          widget.onClose();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: const Text(
          'Apply Changes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class FilterSortButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFiltered;

  const FilterSortButton({
    Key? key,
    required this.onPressed,
    this.isFiltered = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: onPressed,
            color: const Color(0xFF1976D2),
            tooltip: 'Filter & Sort',
          ),
        ),
        if (isFiltered)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
