import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageOpacity;
  late Animation<double> _imageScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Initial scale and fade in for the central splash logo
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _imageScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Fade in and slide up for the "Cradle" text name
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutQuad),
      ),
    );

    _controller.forward().then((_) {
      _checkLoginState();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginState() async {
    // Keep splash page visible for a short duration after animation completes
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Check login/session state
    // Replace the boolean value below with actual auth check integration (e.g. FirebaseAuth status or SharedPreferences token check)
    const bool isLoggedIn = false; 

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors as requested by user
    const Color primaryColor = Color(0xFFF7F2F6); // Main background
    const Color secondaryColor = Color(0xFFEE93B4); // Icons, texts, etc.

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Animated Logo
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _imageScale.value,
                        child: Opacity(
                          opacity: _imageOpacity.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryColor.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.asset(
                                'lib/core/theme/splash.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback in case asset is not fully declared in pubspec.yaml
                                  return Container(
                                    color: secondaryColor.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.child_care,
                                      size: 70,
                                      color: secondaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. Animated App Name "Cradle"
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FractionalTranslation(
                        translation: _textSlide.value,
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: const Text(
                            'Cradle',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: secondaryColor,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // 3. Subtle Animated Progress indicator at the bottom
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacity.value,
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


