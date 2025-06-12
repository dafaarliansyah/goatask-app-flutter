import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app_with_firebase/providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String _name = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await Provider.of<AuthProvider>(context, listen: false)
            .loginWithEmail(_email, _password);
      } else {
        await Provider.of<AuthProvider>(context, listen: false)
            .registerWithEmail(_email, _password, _name);
      }
    } catch (err) {
      var message = 'Terjadi kesalahan, silakan coba lagi';
      if (err.toString().contains('weak-password')) {
        message = 'Password terlalu lemah';
      } else if (err.toString().contains('email-already-in-use')) {
        message = 'Email sudah terdaftar';
      } else if (err.toString().contains('user-not-found')) {
        message = 'Email tidak terdaftar';
      } else if (err.toString().contains('wrong-password')) {
        message = 'Password salah';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GOATask',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Atur Harimu, Capai Puncak Terbaikmu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  elevation: 5,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Nama Lengkap',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Harap masukkan nama';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _name = value!.trim();
                                  },
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return 'Harap masukkan email yang valid';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!.trim();
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          SizedBox(height: 20),
                          if (_isLoading)
                            CircularProgressIndicator()
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: Text(
                                  _isLogin ? 'Masuk' : 'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white, // Ganti sesuai warna yang kamu inginkan
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Belum punya akun? Daftar disini'
                                  : 'Sudah punya akun? Masuk disini',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Atau masuk dengan',
                  style: TextStyle(color: Colors.grey[50]),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: const Color.fromARGB(0, 224, 224, 224)!),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                      'Masuk dengan Google',
                      style: TextStyle(
                        color: Colors.black, // Ganti dengan warna yang kamu mau
                        fontSize: 16, // Opsional: ubah ukuran teks juga
                        fontWeight: FontWeight.w400, // Opsional: ubah ketebalan teks
                      ),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}