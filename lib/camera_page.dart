

//C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS
//C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS
//C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS
//C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS
//C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS  //C'EST LE GROS BROUILLONS



import 'dart:io';
// import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



void main() async {
  runApp(const MyApp());
  } 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  late final List<CameraDescription> _cameras;
  bool _isRecording = false;
  List<FileSystemEntity>? _folderContents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    // Initialize the camera with the first camera in the list
    await onNewCameraSelected(_cameras.first);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
     return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  Future<String> createFolder(String cow) async {
    final dir = Directory('${(Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory())!.path}/$cow');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if (await dir.exists()) {
      return dir.path;
    } else {
      await dir.create();
      return dir.path;
    }
  }

  internalFolder() async {
    final abc = (await getExternalStorageDirectories())!.first;
    final path = Directory('${abc.path}/MyAppStore/');
    String res = "";

    if (await path.exists()) {
      res = path.path;
    } else {
      final Directory appDocDirNewFolder = await path.create(recursive: true);
      res = appDocDirNewFolder.path;
    }
    final File file = File('${res}tips21.dart');
    await file.writeAsString('data');

  }

  // Méthode pour déplacer un fichier depuis le cache vers un dossier spécifique
  Future<void> moveFileFromCache(String sourceFilePath, String destinationFolderPath) async {
    try {
      // Créer le dossier de destination s'il n'existe pas
      Directory destinationDir = Directory(destinationFolderPath);
      if (!destinationDir.existsSync()) {
        destinationDir.createSync(recursive: true);
      }

      // Récupérer le nom du fichier à partir du chemin source
      String fileName = path.basename(sourceFilePath);

      // Créer les chemins complets pour la source et la destination
      String sourcePath = path.join(Directory.systemTemp.path, fileName);
      String destinationPath = path.join(destinationFolderPath, fileName);

      // Déplacer le fichier
      File(sourcePath).renameSync(destinationPath);
      
      // Si vous souhaitez supprimer le fichier source après le déplacement, décommentez la ligne suivante
      // File(sourceFilePath).deleteSync();
      
      debugPrint('Le fichier a été déplacé avec succès vers : $destinationPath');
    } catch (e) {
      debugPrint('Une erreur s\'est produite lors du déplacement du fichier : $e');
    }
  }

  // Utilisation de la méthode
  void main() {
    String cacheFilePath = '/data/user/0/com.example.streaming/cache/CAP7919332425586637872.jpg';
    String destinationFolderPath = '/data/user/0/com.example.streamiAppFolder';
    
    moveFileFromCache(cacheFilePath, destinationFolderPath);
  }

  Future<XFile?> capturePhoto() async {
    String folderName = "MyAppFolder";
    String folderPath = await createFolder(folderName);
    final CameraController? cameraController = _controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await cameraController.setFlashMode(FlashMode.off);
      XFile file = await cameraController.takePicture();

      file.saveTo(folderPath);
      // return file;
      moveFileFromCache(file.path, folderPath);


      // Obtenez le répertoire d'enregistrement
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String storageDirectoryPath = path.join(appDirectory.path, 'my_app_directory');
      // Créez le répertoire s'il n'existe pas
      Directory storageDirectory = Directory(storageDirectoryPath);
      if (!storageDirectory.existsSync()) {
        storageDirectory.createSync(recursive: true);
      }

      // Déplacez le fichier vers le répertoire d'enregistrement
      // String fileName = path.basename(file.path);
      // String newFilePath = path.join(folderPath, fileName);
      // File newFile = File(newFilePath);
      // await file.rename(newFilePath);

      String fileName = path.basename(file.path);
    String newFilePath = path.join(storageDirectory.path, fileName);
    // File(file.path).rename(newFilePath);

      // debugPrint(newFile.path);

      // void savePhoto(String filePath) {
        // Implémentez votre logique d'enregistrement de la photo ici
        // Utilisez le chemin du fichier (filePath) pour enregistrer la photo où vous le souhaitez
        // Par exemple :
        // File file = File(filePath);
        // Déplacez/copiez le fichier vers l'emplacement souhaité
        // file.copySync('chemin_de_destination');
      // }

      return XFile(newFilePath);
      
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<XFile?> captureVideo() async {
    final CameraController? cameraController = _controller;
    try {
      setState(() {
        _isRecording = true;
      });
      await cameraController?.startVideoRecording();
      await Future.delayed(const Duration(seconds: 5));
      final video = await cameraController?.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      // return video;
      // Obtenez le répertoire d'enregistrement
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String storageDirectoryPath = path.join(appDirectory.path, 'my_app_directory');

      // Créez le répertoire s'il n'existe pas
      Directory storageDirectory = Directory(storageDirectoryPath);
      if (!storageDirectory.existsSync()) {
        storageDirectory.createSync(recursive: true);
      }

      // Déplacez la vidéo vers le répertoire d'enregistrement
      String fileName = path.basename(video!.path);
      String newFilePath = path.join(storageDirectory.path, fileName);
      File newFile = File(newFilePath);
      // await video.rename(newFilePath);

      return XFile(newFile.path);      
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  // void _onTakePhotoPressed() async {
  //   final navigator = Navigator.of(context);
  //   final xFile = await capturePhoto();
  //   if (xFile != null) {
      
  //     if (xFile.path.isNotEmpty) {
  //       navigator.push(
  //         MaterialPageRoute(
  //           builder: (context) => PreviewPage(
  //             imagePath: xFile.path,
  //           ),
  //         ),
  //       );
  //     }
  //   }
  // }

  void _onRecordVideoPressed() async {
    final navigator = Navigator.of(context);
    final xFile = await captureVideo();
    if (xFile != null) {
      if (xFile.path.isNotEmpty) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              videoPath: xFile.path,
            ),
          ),
        );
      }
    }
  }

  void openFilePicker(BuildContext context) async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      Directory directory = Directory(directoryPath);
      setState(() {
        _folderContents = directory.listSync();
      });
    } else {
      // L'utilisateur a annulé la sélection
      // print('Aucun dossier sélectionné');
    }
    ListView.builder(
      itemCount: _folderContents!.length,
      itemBuilder: (BuildContext context, int index) {
        FileSystemEntity entity = _folderContents![index];
        return ListTile(
          title: Text(entity.path),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _onDeleteFilePressed(entity.path);
            },
          ),
        );
      },
    );
  }

  void deleteFiles(List<String> filePaths) {
    for (String filePath in filePaths) {
      File file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
        // print('Fichier supprimé : $filePath');
      } else {
        // print('Le fichier n\'existe pas : $filePath');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraInitialized) {
      return SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
          child: CameraPreview(_controller!),),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRecording)
                    ElevatedButton(
                      onPressed: capturePhoto,
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(70, 70),
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  if (!_isRecording) const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed:_isRecording? null: _onRecordVideoPressed,
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(70, 70),
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.videocam,
                        color: Colors.red,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {                  
                      openFilePicker(context);
                    },
                    child: const Text('Sélectionner un dossier'),
                  ),
                  const SizedBox(height: 20),
                  if (_folderContents != null)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _folderContents!.length,
                        itemBuilder: (BuildContext context, int index) {
                          FileSystemEntity entity = _folderContents![index];
                          return ListTile(
                            title: Text(entity.path),
                          );
                        },
                      ),
                    ),
                  
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    // Directory appDirectory = await getApplicationDocumentsDirectory();
    // String storageDirectoryPath = '${appDirectory.path}/my_app_directory';

    // Directory storageDirectory = Directory(storageDirectoryPath);
    // if (!storageDirectory.existsSync()) {
    //   storageDirectory.createSync(recursive: true);
    // }

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    }
  }
  void _onDeleteFilePressed(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le fichier'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce fichier ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFile(filePath);
              },
              child: const Text('Supprimer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(String filePath) {
    File file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
      setState(() {
        _folderContents!.removeWhere((entity) => entity.path == filePath);
      });
      debugPrint('Fichier supprimé : $filePath');
    } else {
      debugPrint('Le fichier n\'existe pas : $filePath');
    }
  }

}

class PreviewPage extends StatefulWidget {
  final String? imagePath;
  final String? videoPath;

  const PreviewPage({Key? key, this.imagePath, this.videoPath})
      : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  VideoPlayerController? controller;

  Future<void> _startVideoPlayer() async {
    if (widget.videoPath != null) {
      controller = VideoPlayerController.file(File(widget.videoPath!));
      await controller!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await controller!.setLooping(true);
      await controller!.play();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _startVideoPlayer();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.imagePath != null
            ? Image.file(
                File(widget.imagePath ?? ""),
                fit: BoxFit.cover,
              )
            : AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
      ),
    );
  }
}



// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// List<CameraDescription>? cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   cameras = await availableCameras();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   MyHomePageState createState() => MyHomePageState();
// }

// class MyHomePageState extends State<MyHomePage> {
//   CameraController? controller;
//   String imagePath = "";

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(cameras![1], ResolutionPreset.max);

//     controller?.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!controller!.value.isInitialized) {
//       return Container();
//     }
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             children: [
//               const SizedBox(
//                 height: 50,
//               ),
//               SizedBox(
//                 width: 200,
//                 height: 200,
//                 child: AspectRatio(
//                   aspectRatio: controller!.value.aspectRatio,
//                   child: CameraPreview(controller!),
//                 ),
//               ),
//               TextButton(
//                   onPressed: () async {
//                     try {
//                       final image = await controller!.takePicture();
//                       setState(() {
//                         imagePath = image.path;
//                       });
//                     } catch (e) {
//                       // debugPrint(e);
//                     }
//                   },
//                   child: const Text("Take Photo")),
//               if (imagePath != "")
//                 SizedBox(
//                     width: 300,
//                     height: 300,
//                     child: Image.file(
//                       File(imagePath),
//                     ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }