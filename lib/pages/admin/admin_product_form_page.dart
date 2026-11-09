import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../models/case_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/buttons.dart';

/// Form tambah/edit produk untuk admin.
class AdminProductFormPage extends StatefulWidget {
  const AdminProductFormPage({super.key, this.caseId});

  /// null = mode tambah baru.
  final String? caseId;

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _material = 'TPU';
  String _category = 'Trending';
  String _cutoutType = 'universal';
  final Set<String> _features = {};
  final Set<String> _compatibleIds = {};
  bool _initialized = false;
  bool _isSaving = false;

  static const List<String> _materials = [
    'TPU',
    'Silicone',
    'Polycarbonate',
    'Leather',
    'Hybrid',
    'Carbon Fiber',
  ];

  static const List<String> _cutoutTypes = [
    'universal',
    'single',
    'dual_vertical',
    'dual_diagonal',
    'triple_vertical',
    'triple_square',
  ];

  static const List<String> _featureOptions = [
    'Shockproof',
    'Slim',
    'MagSafe',
    'Anti-Yellowing',
    'Anti-Slip',
    'Soft Touch',
    'Premium',
    'Kickstand',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final id = widget.caseId;
    if (id == null) {
      _brandController.text = 'Caca';
      return;
    }

    final existing = context.read<ProductProvider>().caseById(id);
    if (existing == null) return;

    _nameController.text = existing.name;
    _brandController.text = existing.brand;
    _priceController.text = existing.price.toStringAsFixed(0);
    _stockController.text = existing.stock.toString();
    _descriptionController.text = existing.description;
    _material = existing.material;
    _category = existing.category;
    _cutoutType = existing.cameraCutoutType;
    _features.addAll(existing.features);
    _compatibleIds.addAll(existing.compatibleModelIds);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_compatibleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu model iPhone yang kompatibel.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final products = context.read<ProductProvider>();
    final existing = widget.caseId == null
        ? null
        : products.caseById(widget.caseId!);

    final caseItem = CaseModel(
      id: existing?.id ??
          'c${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      material: _material,
      features: _features.toList(),
      compatibleModelIds: _compatibleIds.toList(),
      cameraCutoutType: _cutoutType,
      category: _category,
      imageUrl: existing?.imageUrl,
      description: _descriptionController.text.trim(),
      rating: existing?.rating ?? 0,
    );

    await products.saveCase(caseItem);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null ? 'Produk baru ditambahkan.' : 'Produk diperbarui.',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final isEdit = widget.caseId != null;
    final notFound = isEdit && products.caseById(widget.caseId!) == null;

    if (notFound) {
      return Scaffold(
        appBar: AppBar(title: const Text('Form Produk')),
        body: Center(
          child: Text(
            'Produk tidak ditemukan.',
            style: AppTypography.caption,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Produk' : 'Tambah Produk'),
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
                    LabeledField(
                      label: 'Nama Produk',
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) =>
                            Validators.required(value, label: 'Nama produk'),
                        decoration: const InputDecoration(
                          hintText: 'Mis. Caca Clear Shield Pro Max',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Brand',
                      child: TextFormField(
                        controller: _brandController,
                        validator: (value) =>
                            Validators.required(value, label: 'Brand'),
                        decoration: const InputDecoration(hintText: 'Caca'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: LabeledField(
                            label: 'Harga (Rp)',
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final parsed = double.tryParse(
                                  value?.trim() ?? '',
                                );
                                if (parsed == null || parsed <= 0) {
                                  return 'Harga harus lebih dari 0.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: '89000',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: LabeledField(
                            label: 'Stok',
                            child: TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                final parsed = int.tryParse(
                                  value?.trim() ?? '',
                                );
                                if (parsed == null || parsed < 0) {
                                  return 'Stok tidak valid.';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(hintText: '24'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Material',
                      child: DropdownButtonFormField<String>(
                        initialValue: _material,
                        items: [
                          for (final item in _materials)
                            DropdownMenuItem(value: item, child: Text(item)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _material = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Kategori',
                      child: DropdownButtonFormField<String>(
                        initialValue: caseCategories.contains(_category)
                            ? _category
                            : 'Trending',
                        items: [
                          for (final item in caseCategories.where(
                            (item) => item != 'Semua',
                          ))
                            DropdownMenuItem(value: item, child: Text(item)),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _category = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LabeledField(
                      label: 'Tipe Cutout Kamera',
                      hint: 'Harus cocok dengan layout kamera perangkat '
                          'agar lolos Compatibility Checker.',
                      child: DropdownButtonFormField<String>(
                        initialValue: _cutoutType,
                        items: [
                          for (final item in _cutoutTypes)
                            DropdownMenuItem(
                              value: item,
                              child: Text(_cutoutLabel(item)),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _cutoutType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Fitur',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final feature in _featureOptions)
                          FilterChip(
                            label: Text(feature),
                            selected: _features.contains(feature),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _features.add(feature);
                                } else {
                                  _features.remove(feature);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Model iPhone kompatibel',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_compatibleIds.length} model dipilih',
                      style: AppTypography.caption.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final model in products.iphones)
                          FilterChip(
                            label: Text(model.displayName),
                            selected: _compatibleIds.contains(model.id),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _compatibleIds.add(model.id);
                                } else {
                                  _compatibleIds.remove(model.id);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledField(
                      label: 'Deskripsi (opsional)',
                      child: TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Ceritakan keunggulan case ini',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                      icon: Icons.save_rounded,
                      isLoading: _isSaving,
                      onPressed: _save,
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

  static String _cutoutLabel(String code) {
    switch (code) {
      case 'universal':
        return 'Universal';
      case 'single':
        return 'Kamera tunggal';
      case 'dual_vertical':
        return 'Kamera ganda vertikal';
      case 'dual_diagonal':
        return 'Kamera ganda diagonal';
      case 'triple_vertical':
        return 'Kamera tiga vertikal';
      case 'triple_square':
        return 'Kamera tiga kotak (Pro)';
      default:
        return code;
    }
  }
}
