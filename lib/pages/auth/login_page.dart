import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/components/buttons.dart';

/// Halaman Login (H1).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      context.go(auth.isAdmin ? '/admin' : '/beranda');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Login gagal.')),
      );
    }
  }

  void _fillDemo({required bool admin}) {
    setState(() {
      _emailController.text = admin ? 'admin@caca.test' : 'pembeli@caca.test';
      _passwordController.text = '123456';
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final form = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Selamat Datang',
          style: AppTypography.title.copyWith(fontSize: isWide ? 36 : 30),
        ),
        const SizedBox(height: 4),
        Text(
          'Masuk untuk menemukan case yang benar-benar cocok dengan iPhone kamu.',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledField(
                label: 'Email',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    hintText: 'nama@email.com',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              LabeledField(
                label: 'Kata Sandi',
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      tooltip: _obscurePassword
                          ? 'Tampilkan kata sandi'
                          : 'Sembunyikan kata sandi',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: 'Masuk',
          isLoading: isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun? ',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Daftar'),
            ),
          ],
        ),
        const Divider(height: AppSpacing.lg),
        Text(
          'Akun demo',
          style: AppTypography.caption.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSpacing.buttonHeight),
              ),
              onPressed: () => _fillDemo(admin: false),
              icon: const Icon(Icons.person_outline, size: 18),
              label: const Text('Isi akun pembeli'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppSpacing.buttonHeight),
              ),
              onPressed: () => _fillDemo(admin: true),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
              label: const Text('Isi akun admin'),
            ),
          ],
        ),
      ],
    );

    final illustration = _LoginIllustration(isWide: isWide);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: illustration),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: form,
                          ),
                        ),
                      ],
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          illustration,
                          const SizedBox(height: AppSpacing.md),
                          form,
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginIllustration extends StatelessWidget {
  const _LoginIllustration({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isWide ? 420 : 150,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_iphone_rounded,
            size: isWide ? 96 : 56,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Case iPhone Caca',
            style: AppTypography.subtitle.copyWith(
              fontSize: isWide ? 26 : 20,
              color: AppColors.primaryDark,
            ),
          ),
          if (isWide) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Pilih model iPhone kamu, dan hanya lihat case yang benar-benar pas.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
