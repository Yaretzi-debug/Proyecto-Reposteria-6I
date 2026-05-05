import 'package:flutter/material.dart';
import 'crud_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cake, size: 100, color: Colors.pink),
            Text("Repostería Admin", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.pink[800])),
            const SizedBox(height: 30),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo", filled: true, fillColor: Colors.white)),
            const SizedBox(height: 10),
            TextField(controller: passController, decoration: const InputDecoration(labelText: "Contraseña", filled: true, fillColor: Colors.white), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white),
              onPressed: () {
                // Validación simple para efectos del proyecto
                if (emailController.text == "admin@reposteria.com" && passController.text == "123456") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CRUDPage()));
                }
              },
              child: const Text("Entrar como Administrador"),
            )
          ],
        ),
      ),
    );
  }
}