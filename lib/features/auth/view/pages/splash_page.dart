import 'dart:async';
import 'dart:math';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallette.dart';
import 'package:client/features/auth/view/pages/welcome_page.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showExplosion = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _showBombEffect();
        }
      });

    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward();
    });
  }

  void _showBombEffect() {
    setState(() {
      _showExplosion = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      final currentUser = ref.read(currentUserNotifierProvider);
      Navigator.pushReplacement(
        context,
        _fadeRoute(
          currentUser == null ? const WelcomePage() : const HomePage(),
        ),
      );
    });
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: Center(
        child: _showExplosion
            ? ExplosionEffect(imagePath: 'assets/images/lo.png')
            : ScaleTransition(
                scale: CurvedAnimation(
                    parent: _controller, curve: Curves.bounceOut),
                child: Image.asset(
                  'assets/images/lo.png',
                  width: 120,
                ),
              ),
      ),
    );
  }
}

class ExplosionEffect extends StatefulWidget {
  final String imagePath;
  const ExplosionEffect({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ExplosionEffectState createState() => _ExplosionEffectState();
}

class _ExplosionEffectState extends State<ExplosionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final List<IconData> _icons = [
    Icons.music_note,
    Icons.headphones,
    Icons.audiotrack,
    Icons.graphic_eq,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..addListener(() {
        setState(() {});
      })
      ..forward();

    _generateParticles();
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(icon: _icons[Random().nextInt(_icons.length)]));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ExplosionPainter(_particles, _controller.value),
      child: SizedBox.expand(),
    );
  }
}

class Particle {
  final double x = Random().nextDouble() * 200 - 100;
  final double y = Random().nextDouble() * 200 - 100;
  final double size = Random().nextDouble() * 60 + 18;
  final Color color =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];
  final IconData icon;

  Particle({required this.icon});
}

class ExplosionPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ExplosionPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(particle.icon.codePoint),
          style: TextStyle(
            fontSize: particle.size * (1 - progress),
            color: particle.color.withOpacity(1 - progress),
            fontFamily: particle.icon.fontFamily,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 + particle.x * progress,
          size.height / 2 + particle.y * progress,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
