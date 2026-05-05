import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ReposteriaApp());
}

class ReposteriaApp extends StatelessWidget {
  const ReposteriaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.pink),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cake, size: 80, color: Colors.pink),
              const Text("Reposteria Admin", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink)),
              const SizedBox(height: 20),
              TextField(controller: user, decoration: const InputDecoration(labelText: "Usuario")),
              TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña")),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                onPressed: () {
                  if (user.text == "admin@reposteria.com" && pass.text == "123456") {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CRUDPage()));
                  }
                }, 
                child: const Text("ENTRAR"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CRUDPage extends StatelessWidget {
  const CRUDPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference postres = FirebaseFirestore.instance.collection('postres');
    final nombre = TextEditingController();
    final precio = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Postres"), backgroundColor: Colors.pink, foregroundColor: Colors.white),
      body: StreamBuilder(
        stream: postres.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                color: Colors.pink[50],
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(doc['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("\$${doc['precio']} - ${doc['sabor']}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () {
          showDialog(context: context, builder: (context) => AlertDialog(
            title: const Text("Nuevo Postre"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nombre, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: precio, decoration: const InputDecoration(labelText: "Precio")),
            ]),
            actions: [
              TextButton(onPressed: () {
                postres.add({'nombre': nombre.text, 'precio': precio.text, 'sabor': 'Especial'});
                Navigator.pop(context);
              }, child: const Text("Agregar"))
            ],
          ));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}