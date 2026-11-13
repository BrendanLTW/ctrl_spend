import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/brand_colors.dart';
import 'package:ctrl_spend/core/widgets/brand_symbol.dart';
import 'package:ctrl_spend/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S01 Splash, shown on every launch while settings load. Moves on once
/// they have loaded and the loading bar has run, or straight away on tap.
class SplashScreen extends ConsumerStatefulWidget {
  const new({super.key});

  static const minimumDuration = Duration(milliseconds: 1500);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _progress = AnimationController(
    vsync: this,
    duration: SplashScreen.minimumDuration,
  );
  var _ready = false;
  var _left = false;

  @override
  void initState() {
    super.initState();
    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) _continue();
    });
    _progress.forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// Leaves once settings have loaded; called when the bar finishes, on
  /// tap, and when the settings arrive after either.
  void _continue() {
    _ready = true;
    final onboarded = ref.read(onboardingCompleteProvider);
    if (onboarded == null || _left || !mounted) return;
    _left = true;
    context.go(onboarded ? Routes.home : Routes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingCompleteProvider, (_, next) {
      if (_ready && next != null) _continue();
    });
    final l10n = context.l10n;
    final text = context.text;
    // Navy in both themes (S01): the dark palette's text on it.
    const onSplash = AppColors.dark;
    final background = Theme.of(context).brightness == Brightness.light
        ? BrandColors.navy
        : context.colors.ground;
    return Scaffold(
      backgroundColor: background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _continue,
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _Rings()),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandSymbol(),
                    const SizedBox(height: 28),
                    Semantics(
                      label: l10n.appName,
                      excludeSemantics: true,
                      child: Text.rich(
                        TextSpan(
                          style: text.wordmark.copyWith(color: onSplash.ink),
                          children: const [
                            TextSpan(text: 'ctrl'),
                            TextSpan(
                              text: 'Spend',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.splashTagline,
                      style: text.body.copyWith(color: onSplash.muted),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: SizedBox(
                        width: 120,
                        height: 4,
                        child: AnimatedBuilder(
                          animation: _progress,
                          builder: (context, _) => ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              backgroundColor: onSplash.raised,
                              color: BrandColors.amber,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    Text.rich(
                      TextSpan(
                        style: text.body.copyWith(color: onSplash.muted),
                        children: [
                          TextSpan(text: '${l10n.splashBy} '),
                          TextSpan(
                            // A name, not translated.
                            text: 'BrendanLTW',
                            style: TextStyle(
                              color: onSplash.chipText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two faint rings behind the symbol.
class _Rings extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(painter: _RingsPainter(AppColors.dark.raised)),
  );
}

class _RingsPainter extends CustomPainter {
  new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke;
    // Centred a little above the middle, on the symbol.
    final centre = Offset(size.width / 2, size.height / 2 - 14);
    canvas
      ..drawCircle(centre, 150, paint)
      ..drawCircle(centre, 210, paint);
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => oldDelegate.color != color;
}
