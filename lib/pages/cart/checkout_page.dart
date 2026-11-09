import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/components/buttons.dart';
import '../../widgets/components/empty_state.dart';

/// Halaman Checkout (H6b) — halaman yang belum ada wireframe-nya di Minggu 4.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String _paymentMethod = 'Transfer Manual';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    setState(() => _isSubmitting = true);

    final order = await context.read<OrderProvider>().createOrder(
      cartItems: cart.items,
      shippingCost: cart.shippingCost,
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
      note: _noteController.text.trim(),
    );

    await cart.clear();

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    context.go('/konfirmasi/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: EmptyState(
          title: 'Tidak ada item untuk di-checkout',
          message: 'Tambahkan case ke keranjang terlebih dahulu.',
          icon: Icons.shopping_bag_outlined,
          actionLabel: 'Lihat katalog',
          onAction: () => context.go('/katalog'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Kembali',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data penerima',
                      style: AppTypography.subtitle.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Nama Penerima',
                      child: TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        validator: Validators.name,
                        decoration: const InputDecoration(
                          hintText: 'Nama lengkap penerima',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Nomor Telepon',
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: Validators.phone,
                        decoration: const InputDecoration(
                          hintText: '08xxxxxxxxxx',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Alamat Pengiriman',
                      hint: 'Sertakan kota dan kode pos agar mudah dikirim.',
                      child: TextFormField(
                        controller: _addressController,
                        minLines: 2,
                        maxLines: 4,
                        validator: (value) => Validators.required(
                          value,
                          label: 'Alamat',
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Jalan, nomor rumah, kota, kode pos',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Metode pembayaran (simulasi)',
                      style: AppTypography.subtitle.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final method in const ['Transfer Manual', 'COD'])
                      RadioListTile<String>(
                        value: method,
                        // ignore: deprecated_member_use
                        groupValue: _paymentMethod,
                        // ignore: deprecated_member_use
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                        title: Text(
                          method,
                          style: AppTypography.caption.copyWith(fontSize: 16),
                        ),
                        subtitle: Text(
                          method == 'Transfer Manual'
                              ? 'Instruksi transfer ditampilkan setelah pesanan dibuat.'
                              : 'Bayar tunai saat paket diterima.',
                          style: AppTypography.caption.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryDark,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Catatan (opsional)',
                      child: TextFormField(
                        controller: _noteController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Mis. minta bubble wrap tambahan',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Ringkasan pesanan',
                      style: AppTypography.subtitle.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final item in cart.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.caseItem.name} × ${item.quantity}',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              formatRupiah(item.lineTotal),
                              style: AppTypography.caption.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    PriceSummaryCard(
                      subtotal: cart.subtotal,
                      shippingCost: cart.shippingCost,
                      total: cart.total,
                      itemCount: cart.itemCount,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: 'Buat Pesanan',
                      icon: Icons.check_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tidak ada payment gateway asli. Pesanan hanya dicatat '
                      'sebagai simulasi sesuai batasan proyek.',
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
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
