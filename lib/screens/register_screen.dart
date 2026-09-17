import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _berat = TextEditingController();
  final _tinggi = TextEditingController();
  DateTime? _tglLahir;

  Future<void> _daftar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tglLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal lahir')),
      );
      return;
    }
    try {
      await DBHelper().registerUser({
        'nama': _nama.text.trim(),
        'username': _username.text.trim(),
        'password': _password.text.trim(),
        'berat': double.tryParse(_berat.text) ?? 0,
        'tinggi': double.tryParse(_tinggi.text) ?? 0,
        'tanggalLahir': _tglLahir!.toIso8601String(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil daftar, silakan login')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal daftar: username mungkin sudah dipakai')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _berat,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Berat Badan (kg)'),
              ),
              TextFormField(
                controller: _tinggi,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_tglLahir == null
                    ? 'Pilih Tanggal Lahir'
                    : 'Lahir: ${_tglLahir!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _tglLahir = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _daftar, child: const Text('Daftar')),
            ],
          ),
        ),
      ),
    );
  }
}
