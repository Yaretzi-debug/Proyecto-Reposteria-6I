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
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.pink,
        // Forzamos que los iconos se rendericen con Material Design
        iconTheme: const IconThemeData(color: Colors.pink),
      ),
      home: const LoginPage(),
    );
  }
}

// --- LOGIN CORREGIDO PARA ESCRITURA EN MÓVIL ---
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
      // Esta línea es vital para que el teclado no tape los campos
      resizeToAvoidBottomInset: true, 
      body: Container(
        color: const Color(0xFFFCE4EC),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cake_rounded, size: 80, color: Colors.pink),
                    const SizedBox(height: 10),
                    const Text("Reposteria Pro", 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pink)),
                    const SizedBox(height: 30),
                    TextField(
                      controller: user,
                      decoration: const InputDecoration(
                        labelText: "Correo Admin",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pass,
                      obscureText: true,
                      // Configuraciones para forzar la activación del teclado en Web móvil
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      onPressed: () {
                        if (user.text.trim() == "admin@reposteria.com" && pass.text.trim() == "123456") {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                        }
                      },
                      child: const Text("INGRESAR"),
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

// --- PÁGINA PRINCIPAL ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final List<Widget> _paginas = [const PostresPage(), const UsuariosPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.icecream_rounded), label: 'Postres'),
          NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'Usuarios'),
        ],
      ),
    );
  }
}

// --- CRUD DE POSTRES (EDITAR Y BORRAR) ---
class PostresPage extends StatelessWidget {
  const PostresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postres = FirebaseFirestore.instance.collection('postres');
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Postres"), centerTitle: true),
      body: StreamBuilder(
        stream: postres.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(doc['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Sabor: ${doc['sabor']} | \$${doc['precio']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _dialogoPostre(context, doc)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogoPostre(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _dialogoPostre(BuildContext context, DocumentSnapshot? doc) {
    final nombre = TextEditingController(text: doc != null ? doc['nombre'] : "");
    final sabor = TextEditingController(text: doc != null ? doc['sabor'] : "");
    final precio = TextEditingController(text: doc != null ? doc['precio'] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Agregar Postre" : "Editar Postre"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombre, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: sabor, decoration: const InputDecoration(labelText: "Sabor")),
            TextField(controller: precio, decoration: const InputDecoration(labelText: "Precio")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ElevatedButton(
            onPressed: () {
              final data = {'nombre': nombre.text, 'sabor': sabor.text, 'precio': precio.text};
              if (doc == null) {
                FirebaseFirestore.instance.collection('postres').add(data);
              } else {
                doc.reference.update(data);
              }
              Navigator.pop(context);
            }, 
            child: const Text("Guardar")
          ),
        ],
      ),
    );
  }
}

// --- CRUD DE USUARIOS (NUEVO MÓDULO) ---
class UsuariosPage extends StatelessWidget {
  const UsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarios = FirebaseFirestore.instance.collection('usuarios');
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Usuarios")),
      body: StreamBuilder(
        stream: usuarios.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(doc['nombre']),
                subtitle: Text("Rol: ${doc['rol']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _dialogoUser(context, doc)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _dialogoUser(context, null),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  void _dialogoUser(BuildContext context, DocumentSnapshot? doc) {
    final nombre = TextEditingController(text: doc != null ? doc['nombre'] : "");
    final rol = TextEditingController(text: doc != null ? doc['rol'] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Nuevo Usuario" : "Editar Usuario"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombre, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: rol, decoration: const InputDecoration(labelText: "Rol")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ElevatedButton(
            onPressed: () {
              final data = {'nombre': nombre.text, 'rol': rol.text};
              if (doc == null) {
                FirebaseFirestore.instance.collection('usuarios').add(data);
              } else {
                doc.reference.update(data);
              }
              Navigator.pop(context);
            }, 
            child: const Text("Registrar")
          ),
        ],
      ),
    );
  }
}