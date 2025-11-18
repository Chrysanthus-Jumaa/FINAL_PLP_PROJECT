import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../auth/login_screen.dart';
import 'role_selection_screen.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({Key? key}) : super(key: key);

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<CarouselItem> _items = [
    CarouselItem(
      icon: Icons.eco,
      title: 'Restore Our Planet',
      description: 'Connect your land to meaningful restoration projects',
    ),
    CarouselItem(
      icon: Icons.handshake,
      title: 'Build Partnerships',
      description: 'Partner with organizations driving environmental change',
    ),
    CarouselItem(
      icon: Icons.trending_up,
      title: 'Generate Value',
      description: 'Participate in carbon credit markets and sustainable projects',
    ),
    CarouselItem(
      icon: Icons.forest,
      title: 'Make an Impact',
      description: 'Be part of the solution to climate change',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll carousel
    Future.delayed(const Duration(seconds: 3), () {
      _autoScroll();
    });
  }

  void _autoScroll() {
    if (!mounted) return;
    
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      
      int nextPage = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
      _autoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carousel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildCarouselPage(_items[index]);
            },
          ),

          // Page indicator
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryBlue
                        : AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Buttons at bottom
          Positioned(
            bottom: 80,
            left: AppTheme.lg,
            right: AppTheme.lg,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Log In'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselPage(CarouselItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryBlueLight.withOpacity(0.3),
            AppTheme.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon with zoom effect
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        item.icon,
                        size: 60,
                        color: AppTheme.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.xxl),
              Text(
                item.title,
                style: AppTheme.h2.copyWith(
                  color: AppTheme.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.md),
              Text(
                item.description,
                style: AppTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarouselItem {
  final IconData icon;
  final String title;
  final String description;

  CarouselItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}