
import 'dart:io';

void main() async {
  // 1. Preguntar por el link del nuevo repositorio
  print('Por favor, ingresa el link del nuevo repositorio de GitHub:');
  String repoUrl = stdin.readLineSync() ?? '';

  if (repoUrl.isEmpty) {
    print('No se ingresó un link de repositorio. Abortando.');
    return;
  }

  // 2. Preguntar por el commit
  print('Por favor, ingresa el mensaje para el commit:');
  String commitMessage = stdin.readLineSync() ?? '';

  if (commitMessage.isEmpty) {
    print('No se ingresó un mensaje de commit. Abortando.');
    return;
  }

  // 3. Preguntar por el nombre de la rama
  print('Ingresa el nombre de la rama (o presiona Enter para usar "main"):');
  String branchName = stdin.readLineSync() ?? '';

  if (branchName.isEmpty) {
    branchName = 'main';
  }

  // Ejecutar comandos de Git
  try {
    // Inicializar repositorio si no existe
    if (!await Directory('.git').exists()) {
      await runProcess('git', ['init']);
    }

    // Agregar remote
    await runProcess('git', ['remote', 'add', 'origin', repoUrl]);

    // Agregar todos los archivos
    await runProcess('git', ['add', '.']);

    // Realizar commit
    await runProcess('git', ['commit', '-m', commitMessage]);

    // Renombrar la rama a la seleccionada
    await runProcess('git', ['branch', '-M', branchName]);

    // Enviar a GitHub
    await runProcess('git', ['push', '-u', 'origin', branchName]);

    print('\n¡Repositorio enviado a GitHub exitosamente!');
  } catch (e) {
    print('\nOcurrió un error: $e');
  }
}

Future<void> runProcess(String command, List<String> arguments) async {
  final result = await Process.run(command, arguments);
  if (result.exitCode != 0) {
    throw Exception('Error ejecutando el comando: ${result.stderr}');
  }
  print(result.stdout);
}
