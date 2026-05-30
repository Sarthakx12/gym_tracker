import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AnimationController _entryCtrl;
  late final Animation<double>   _entrySlide;
  late final Animation<double>   _entryFade;

  bool    _showEmail = false;
  bool    _isLogin   = true;
  bool    _loading   = false;
  bool    _gLoading  = false;
  bool    _obscure   = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _entrySlide = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );
    _entryFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.65),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _gLoading = true; _error = null; });
    try {
      await SupabaseService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _gLoading = false);
    }
  }

  Future<void> _submitEmail() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await SupabaseService.signIn(email, password);
      } else {
        await SupabaseService.signUp(email, password);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size        = MediaQuery.of(context).size;
    final keyboardPad = MediaQuery.of(context).viewInsets.bottom;
    final navBarPad   = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          // ── Background image ────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // ── Cinematic dark overlay (bottom-heavy for text) ──────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.40),
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.97),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Decorative grid lines ───────────────────────────────
          SizedBox(
            width: size.width,
            height: size.height,
            child: CustomPaint(painter: _GridPainter()),
          ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, child) => Opacity(
                opacity: _entryFade.value,
                child: Transform.translate(
                  offset: Offset(0, _entrySlide.value),
                  child: child,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App mark
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // Hero text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PUSH YOUR',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.38),
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'LIMITS.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -3.5,
                            height: 0.92,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Every rep tracked.\nEvery set remembered.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 14,
                            height: 1.65,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Bottom panel ──────────────────────────────────
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(bottom: keyboardPad),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                          width: 0.5,
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(24, 12, 24, 28 + navBarPad),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            width: 38, height: 4,
                            margin: const EdgeInsets.only(bottom: 28),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // Google button
                          _GoogleSignInButton(
                            loading: _gLoading,
                            onPressed: _signInWithGoogle,
                          ),

                          const SizedBox(height: 16),

                          // Divider
                          Row(children: [
                            Expanded(child: Divider(
                              color: Colors.white.withValues(alpha: 0.09),
                              thickness: 0.5,
                            )),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('or', style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.28),
                                fontSize: 12,
                              )),
                            ),
                            Expanded(child: Divider(
                              color: Colors.white.withValues(alpha: 0.09),
                              thickness: 0.5,
                            )),
                          ]),

                          const SizedBox(height: 16),

                          // Email toggle button
                          _OutlineButton(
                            label: _showEmail ? 'Hide email form' : 'Continue with Email',
                            onTap: () => setState(() => _showEmail = !_showEmail),
                          ),

                          // Expandable email form
                          AnimatedSize(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                            child: _showEmail
                                ? _EmailForm(
                                    emailCtrl: _emailCtrl,
                                    passwordCtrl: _passwordCtrl,
                                    isLogin: _isLogin,
                                    loading: _loading,
                                    obscure: _obscure,
                                    error: _error,
                                    onToggleObscure: () =>
                                        setState(() => _obscure = !_obscure),
                                    onToggleMode: () => setState(() {
                                      _isLogin = !_isLogin;
                                      _error = null;
                                    }),
                                    onSubmit: _submitEmail,
                                  )
                                : const SizedBox.shrink(),
                          ),

                          if (_showEmail) const SizedBox(height: 12)
                          else const SizedBox(height: 20),

                          // Skip
                          GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushReplacementNamed('/home'),
                            child: Text(
                              'Continue without account',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.22),
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ────────────────────────────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: loading ? Colors.white70 : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.black45,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleGlyph(),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue   = Color(0xFF4285F4);
  static const _red    = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green  = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final sw     = size.width * 0.22;
    final radius = (size.width - sw) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect   = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style    = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap   = StrokeCap.butt;

    // Angles clockwise from 3 o'clock. G opening is on the right (~310°→10°).
    // Green  10° →  55°  (45°)
    paint.color = _green;
    canvas.drawArc(rect, 10 * pi / 180, 45 * pi / 180, false, paint);

    // Yellow  55° → 115°  (60°)
    paint.color = _yellow;
    canvas.drawArc(rect, 55 * pi / 180, 60 * pi / 180, false, paint);

    // Red  115° → 175°  (60°)
    paint.color = _red;
    canvas.drawArc(rect, 115 * pi / 180, 60 * pi / 180, false, paint);

    // Blue  175° → 310°  (135°) — the long arc through 9 and 12 o'clock
    paint.color = _blue;
    canvas.drawArc(rect, 175 * pi / 180, 135 * pi / 180, false, paint);

    // Horizontal bar (blue) — from center to right edge at mid-height
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - sw / 2,
        size.width - sw * 0.3,
        center.dy + sw / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter old) => false;
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool isLogin;
  final bool loading;
  final bool obscure;
  final String? error;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;

  const _EmailForm({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.isLogin,
    required this.loading,
    required this.obscure,
    required this.error,
    required this.onToggleObscure,
    required this.onToggleMode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Sign in / Create account tabs
        Row(children: [
          _ModeChip(label: 'Sign In',        active: isLogin,  onTap: isLogin  ? null : onToggleMode),
          const SizedBox(width: 8),
          _ModeChip(label: 'Create Account', active: !isLogin, onTap: !isLogin ? null : onToggleMode),
        ]),

        const SizedBox(height: 14),

        _AuthTextField(
          controller: emailCtrl,
          hint: 'Email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        _AuthTextField(
          controller: passwordCtrl,
          hint: 'Password',
          obscureText: obscure,
          onSubmitted: (_) => onSubmit(),
          suffixIcon: GestureDetector(
            onTap: onToggleObscure,
            child: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white30,
              size: 18,
            ),
          ),
        ),

        if (error != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF453A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, size: 15, color: Color(0xFFFF453A)),
              const SizedBox(width: 8),
              Expanded(child: Text(error!,
                style: const TextStyle(color: Color(0xFFFF453A), fontSize: 12))),
            ]),
          ),
        ],

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
            ),
            onPressed: loading ? null : onSubmit,
            child: loading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black45),
                  )
                : Text(isLogin ? 'Sign In' : 'Create Account'),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _ModeChip({required this.label, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.white : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: false,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.22)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.022)
      ..strokeWidth = 0.5;
    const step = 58.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
