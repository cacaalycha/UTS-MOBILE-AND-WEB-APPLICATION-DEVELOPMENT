import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../data/data_simulasi.dart';
import '../../data/mock/mock_iphones.dart';
import '../../services/layanan_data.dart';

/// Form Pesanan — padanan `FormReservasiPage` pada modul Minggu 10.
///
/// Dropdown case **diambil langsung dari stream `cases`**, tombol Kirim
/// dinonaktifkan saat menyimpan, dan jadwal bentrok ditolak lewat SnackBar
/// tanpa menutup form. Validasi lokal memakai pola `Form` + `GlobalKey`.
class FormPesananPage extends StatefulWidget {
  const FormPesananPage({
    super.key,
    this.layanan,
    this.pesananAwal,
  });

  /// Injeksi `LayananMemori()` untuk widget test.
  final LayananData? layanan;

  /// Null = mode tambah (Minggu 10). Diisi = mode ubah (Minggu 11):
  /// isian form terisi data lama dan tombol menjadi "Simpan Perubahan".
  final PesananFirestore? pesananAwal;

  @override
  State<FormPesananPage> createState() => _FormPesananPageState();
}

class _FormPesananPageState extends State<FormPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();

  String? _idCaseTerpilih;
  String _namaModelTerpilih = mockIphones.first.displayName;
  String _jamTerpilih = daftarJamPengambilan.first;
  late DateTime _tanggalTerpilih;
  bool _sedangProses = false;

  @override
  void initState() {
    super.initState();
    final sekarang = DateTime.now();
    _tanggalTerpilih = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day,
    );

    final awal = widget.pesananAwal;
    if (awal != null) {
      _idCaseTerpilih = awal.idCase;
      _namaModelTerpilih = awal.namaModelIphone;
      _jamTerpilih = awal.jam;
      _jumlah = awal.jumlah.toString();
      _catatanController.text = awal.catatan;
      _tanggalTerpilih = DateTime.tryParse(awal.tanggal) ?? _tanggalTerpilih;
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  bool get _modeUbah => widget.pesananAwal != null;

  String get _tanggal => formatTanggal(_tanggalTerpilih);

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalTerpilih,
      firstDate: DateTime(sekarang.year, sekarang.month, sekarang.day),
      lastDate: DateTime(sekarang.year + 1),
    );
    if (hasil != null && mounted) {
      setState(() => _tanggalTerpilih = hasil);
    }
  }

  Future<void> _kirim(
    List<CaseKatalog> daftarCase,
    String idCaseTerpilih,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final caseItem = daftarCase.firstWhere(
      (item) => item.idCase == idCaseTerpilih,
      orElse: () => const CaseKatalog(
        idCase: '',
        namaCase: '',
        brand: '',
        harga: 0,
        stok: 0,
        material: '',
        fitur: <String>[],
        modelKompatibel: <String>[],
        kategori: '',
      ),
    );
    if (caseItem.idCase.isEmpty) return;

    final pesan = ScaffoldMessenger.of(context);
    pesan.hideCurrentSnackBar();
    setState(() => _sedangProses = true);

    final service = widget.layanan ?? context.read<LayananData>();
    try {
      if (_modeUbah) {
        await service.ubahPesanan(
          idPesanan: widget.pesananAwal!.idPesanan,
          caseItem: caseItem,
          namaModelIphone: _namaModelTerpilih,
          jumlah: int.parse(_jumlah),
          tanggal: _tanggal,
          jam: _jamTerpilih,
          catatan: _catatanController.text.trim(),
        );
      } else {
        await service.tambahPesanan(
          caseItem: caseItem,
          namaModelIphone: _namaModelTerpilih,
          jumlah: int.parse(_jumlah),
          tanggal: _tanggal,
          jam: _jamTerpilih,
          catatan: _catatanController.text.trim(),
        );
      }
      if (!mounted) return;
      pesan.showSnackBar(
        SnackBar(
          content: Text(
            _modeUbah
                ? 'Perubahan pesanan berhasil disimpan.'
                : 'Pesanan berhasil disimpan ke collection orders.',
          ),
        ),
      );
      context.go('/firestore/pesanan');
    } on PesananBentrokException catch (e) {
      // Jangan tutup form: tampilkan penolakan sesuai modul.
      pesan.showSnackBar(
        SnackBar(
          content: Text(e.pesan),
          backgroundColor: AppColors.error,
        ),
      );
    } on OperasiDitolakException catch (e) {
      pesan.showSnackBar(
        SnackBar(
          content: Text(e.pesan),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      pesan.showSnackBar(
        SnackBar(
          content: Text(
            _modeUbah
                ? 'Gagal mengubah pesanan. Periksa Rules dan koneksi.'
                : 'Gagal menyimpan pesanan. Periksa Rules dan koneksi.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangProses = false);
    }
  }

  /// Jumlah disimpan sebagai string agar bisa divalidasi Form.
  String _jumlah = '1';

  @override
  Widget build(BuildContext context) {
    final service = widget.layanan ?? context.read<LayananData>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _modeUbah
              ? 'Ubah Pesanan · collection orders'
              : 'Form Pesanan · collection orders',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/firestore'),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<CaseKatalog>>(
          stream: service.streamDaftarCase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Gagal memuat daftar case. Periksa Security Rules Firestore.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final daftar = snapshot.data ?? const <CaseKatalog>[];
            if (daftar.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Collection cases masih kosong. Kembali ke Beranda Firestore '
                    'agar auto-seed dijalankan.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Jaga nilai dropdown tetap valid bila stream berubah.
            final idValid = daftar.any(
              (item) => item.idCase == _idCaseTerpilih,
            );
            final String idTerpilih =
                idValid ? _idCaseTerpilih! : daftar.first.idCase;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _modeUbah
                              ? 'Ubah data pemesanan'
                              : 'Isi data pemesanan',
                          style:
                              AppTypography.subtitle.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _modeUbah
                              ? 'Isian terisi data lama. Field audit dibuat_pada '
                                  'dan id_pengguna tidak berubah.'
                              : 'Pilihan case dibaca real-time dari collection cases.',
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          key: const Key('dropdown_case'),
                          initialValue: idTerpilih,
                          // Item teks panjang harus dipotong, kalau tidak
                          // RenderFlex di dalam dropdown akan overflow.
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Case iPhone',
                            prefixIcon: Icon(Icons.phone_iphone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final item in daftar)
                              DropdownMenuItem<String>(
                                value: item.idCase,
                                child: Text(
                                  '${item.namaCase} · ${formatRupiah(item.harga)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: _sedangProses
                              ? null
                              : (nilai) =>
                                  setState(() => _idCaseTerpilih = nilai),
                          validator: (nilai) => (nilai == null || nilai.isEmpty)
                              ? 'Case wajib dipilih'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<String>(
                          initialValue: _namaModelTerpilih,
                          decoration: const InputDecoration(
                            labelText: 'Model iPhone',
                            prefixIcon: Icon(Icons.smartphone_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final model in mockIphones)
                              DropdownMenuItem<String>(
                                value: model.displayName,
                                child: Text(model.displayName),
                              ),
                          ],
                          onChanged: _sedangProses
                              ? null
                              : (nilai) => setState(
                                    () => _namaModelTerpilih =
                                        nilai ?? _namaModelTerpilih,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          key: const Key('field_jumlah'),
                          initialValue: _jumlah,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                            prefixIcon: Icon(Icons.numbers_outlined),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (nilai) => _jumlah = nilai.trim(),
                          validator: (nilai) {
                            final angka = int.tryParse(nilai?.trim() ?? '');
                            if (angka == null || angka < 1) {
                              return 'Jumlah minimal 1';
                            }
                            if (angka > 10) return 'Jumlah maksimal 10';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed:
                                    _sedangProses ? null : _pilihTanggal,
                                icon: const Icon(Icons.calendar_today_outlined),
                                label: Text('Tanggal $_tanggal'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _jamTerpilih,
                                decoration: const InputDecoration(
                                  labelText: 'Jam ambil',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 14,
                                  ),
                                ),
                                items: [
                                  for (final jam in daftarJamPengambilan)
                                    DropdownMenuItem<String>(
                                      value: jam,
                                      child: Text(jam),
                                    ),
                                ],
                                onChanged: _sedangProses
                                    ? null
                                    : (nilai) => setState(
                                          () => _jamTerpilih =
                                              nilai ?? _jamTerpilih,
                                        ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _catatanController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Catatan (opsional)',
                            prefixIcon: Icon(Icons.notes_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: AppSpacing.buttonHeight,
                          child: FilledButton(
                            key: const Key('tombol_kirim_pesanan'),
                            onPressed: _sedangProses
                                ? null
                                : () => _kirim(daftar, idTerpilih),
                            child: _sedangProses
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _modeUbah
                                        ? 'Simpan Perubahan'
                                        : 'Kirim Pesanan',
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Aturan bisnis: case + tanggal + jam yang sama tidak '
                          'boleh dipesan dua kali (SnackBar penolakan).',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
