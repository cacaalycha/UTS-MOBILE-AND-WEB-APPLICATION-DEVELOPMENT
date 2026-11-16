#!/usr/bin/env python3
"""Mengubah `firebaseConfig` dari Firebase Console menjadi firebase-config.json.

Praktikum Minggu 9 — Case iPhone Caca.

Cara pakai (paling cepat):
  1. Di Firebase Console, salin seluruh blok `const firebaseConfig = { ... };`
  2. Di folder project jalankan:
         python tools/isi_firebase_config.py
  3. Jalankan aplikasi:
         flutter run -d chrome --dart-define-from-file=firebase-config.json

Sumber teks juga bisa dari berkas atau argumen:
     python tools/isi_firebase_config.py --file konfigurasi.txt
     python tools/isi_firebase_config.py --text '{"apiKey":"...","projectId":"..."}'

Berkas keluaran firebase-config.json sudah masuk .gitignore, jadi tidak akan
terkirim ke GitHub. Isinya pengenal project, bukan password.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

# Kunci pada firebaseConfig (Console) -> nama dart-define yang dipakai
# lib/firebase_options.dart
PETA_KUNCI: dict[str, str] = {
    "apiKey": "FIREBASE_API_KEY",
    "appId": "FIREBASE_APP_ID",
    "messagingSenderId": "FIREBASE_MESSAGING_SENDER_ID",
    "projectId": "FIREBASE_PROJECT_ID",
    "authDomain": "FIREBASE_AUTH_DOMAIN",
    "storageBucket": "FIREBASE_STORAGE_BUCKET",
    "measurementId": "FIREBASE_MEASUREMENT_ID",
}

WAJIB: tuple[str, ...] = (
    "FIREBASE_API_KEY",
    "FIREBASE_APP_ID",
    "FIREBASE_MESSAGING_SENDER_ID",
    "FIREBASE_PROJECT_ID",
    "FIREBASE_AUTH_DOMAIN",
)

PENANDA_TEMPLATE = ("NILAI_DARI_CONSOLE", "AIzaSy...", "000000000000", "G-XXXX")


def baca_clipboard() -> str:
    """Baca clipboard Windows lewat PowerShell (tanpa interaksi pengguna)."""
    try:
        hasil = subprocess.run(
            [
                "powershell",
                "-NoProfile",
                "-NonInteractive",
                "-Command",
                "Get-Clipboard -Raw",
            ],
            capture_output=True,
            text=True,
            timeout=25,
            check=True,
        )
        return hasil.stdout
    except Exception as galat:  # noqa: BLE001 - pesan ditujukan ke mahasiswa
        raise RuntimeError(
            "Gagal membaca clipboard. Gunakan --file atau --text. "
            f"Detail: {galat}"
        ) from galat


def parse_firebase_config(teks: str) -> dict[str, str]:
    """Ambil pasangan kunci:nilai, toleran terhadap format JS maupun JSON.

    Mendukung:
      const firebaseConfig = { apiKey: "AIza...", projectId: "..." };
      { "apiKey": "AIza...", "projectId": "..." }
      apiKey: 'AIza...'   (kutip satu)
    """
    hasil: dict[str, str] = {}
    for kunci_console, nama_define in PETA_KUNCI.items():
        pola = (
            r"""["']?"""
            + re.escape(kunci_console)
            + r"""["']?\s*:\s*["']([^"']+)["']"""
        )
        cocok = re.search(pola, teks)
        if cocok:
            hasil[nama_define] = cocok.group(1).strip()
    return hasil


def validasi(nilai: dict[str, str]) -> list[str]:
    """Kembalikan daftar masalah; list kosong berarti siap dipakai."""
    masalah: list[str] = []

    for nama in WAJIB:
        if not nilai.get(nama):
            masalah.append(f"Nilai {nama} tidak ditemukan pada firebaseConfig.")

    for nama, isi in nilai.items():
        if any(tanda in isi for tanda in PENANDA_TEMPLATE):
            masalah.append(f"{nama} masih berisi nilai contoh: {isi!r}")

    api_key = nilai.get("FIREBASE_API_KEY", "")
    if api_key and not api_key.startswith("AIza"):
        masalah.append(
            "FIREBASE_API_KEY biasanya diawali 'AIza'. "
            "Pastikan Anda menyalin firebaseConfig, bukan yang lain."
        )

    return masalah


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Ubah firebaseConfig menjadi firebase-config.json"
    )
    sumber = parser.add_mutually_exclusive_group()
    sumber.add_argument("--file", help="Berkas berisi salinan firebaseConfig")
    sumber.add_argument("--text", help="Teks firebaseConfig langsung")
    parser.add_argument(
        "--output",
        default="firebase-config.json",
        help="Berkas keluaran (default: firebase-config.json)",
    )
    arg = parser.parse_args()

    if arg.file:
        teks = Path(arg.file).read_text(encoding="utf-8", errors="replace")
        asal = f"berkas {arg.file}"
    elif arg.text:
        teks = arg.text
        asal = "argumen --text"
    else:
        teks = baca_clipboard()
        asal = "clipboard"

    if not teks.strip():
        print("Sumber kosong: salin firebaseConfig dari Console lalu coba lagi.")
        return 1

    nilai = parse_firebase_config(teks)
    if not nilai:
        print(
            "Tidak ada kunci firebaseConfig yang dikenali.\n"
            "Pastikan yang disalin adalah blok seperti:\n"
            "  const firebaseConfig = { apiKey: \"...\", authDomain: \"...\" };\n"
            "Lalu jalankan ulang, atau pakai --file / --text."
        )
        return 1

    masalah = validasi(nilai)
    if masalah:
        print("Konfigurasi belum lengkap/ragu:")
        for m in masalah:
            print("  -", m)
        print("\nDitemukan:", ", ".join(sorted(nilai)))
        return 1

    keluaran = Path(arg.output)
    keluaran.write_text(
        json.dumps(nilai, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    print(f"Sumber  : {asal}")
    print(f"Tersimpan: {keluaran.resolve()}")
    print(f"Project : {nilai['FIREBASE_PROJECT_ID']}")
    print(f"Kunci   : {len(nilai)} nilai ({', '.join(sorted(nilai))})")
    print("\nLangkah berikutnya:")
    print("  flutter run -d chrome --dart-define-from-file=firebase-config.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
