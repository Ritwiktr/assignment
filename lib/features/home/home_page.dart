import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve:
              Interval(index * 0.2, (index * 0.2) + 0.5, curve: Curves.easeOut),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final features = [
    FeatureItem(
      title: 'Products',
      subtitle: 'Browse our product catalog',
      icon: Icons.shopping_bag,
      route: '/products',
      gradient: [Color(0xFFB5E2FA), Color(0xFFCAB8FF)],
    ),
    FeatureItem(
      title: 'Registration',
      subtitle: 'Fill out the registration form',
      icon: Icons.person_add,
      route: '/form',
      gradient: [Color(0xFFFFE5E5), Color(0xFFFFF1E6)],
    ),
    FeatureItem(
      title: 'Audio Player',
      subtitle: 'Play audio from assets',
      icon: Icons.music_note,
      route: '/audio',
      gradient: [Color(0xFFE0F4FF), Color(0xFFDCF2E5)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Multi-Feature App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFF8F8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeText(context),
                SizedBox(height: size.height * 0.04),
                ...List.generate(
                  features.length,
                  (index) => Expanded(
                    child: FadeTransition(
                      opacity: _cardAnimations[index],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(_cardAnimations[index]),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.01),
                          child:
                              _buildFeatureCard(context, features[index], size),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        Text(
          'Choose a feature to explore',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black54,
              ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, FeatureItem feature, Size size) {
    return Hero(
      tag: feature.title,
      child: Material(
        elevation: 4,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            feature.route,
            arguments: feature,
          ),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: feature.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Row(
                children: [
                  _buildFeatureIcon(context, feature.icon),
                  SizedBox(width: size.width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feature.title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black54,
                    size: size.width * 0.05,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.black87,
        size: 32,
      ),
    );
  }
}

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final List<Color> gradient;

  FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.gradient,
  });
}
