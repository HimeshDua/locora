// ignore_for_file: avoid_print
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryConfig {
  static const String cloudName = 'deedj7iii';
  static const String uploadPreset = 'locora_places';
  static late CloudinaryPublic cloudinary;

  static void initialize() {
    try {
      cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
      print('✅ Cloudinary initialized successfully');
    } catch (e) {
      print('❌ Error initializing Cloudinary: $e');
      print(
        'Make sure to set your CLOUD_NAME in lib/utils/cloudinary_config.dart',
      );
    }
  }
}

/*
  SETUP INSTRUCTIONS:

  1. Create a Cloudinary account at https://cloudinary.com (free tier available)

  2. Get your Cloud Name from: https://cloudinary.com/console/settings/api-keys

  3. Create an unsigned upload preset:
     - Go to https://cloudinary.com/console/settings/upload
     - Click "Add upload preset"
     - Set "Signing Mode" to "Unsigned"
     - Enter a name (e.g., "locora_places")
     - Click "Save"

  4. Update this file with:
     - Your Cloud Name
     - Your Upload Preset name

  5. Call CloudinaryConfig.initialize() in your main.dart before runApp()

  Example in main.dart:
  ```
  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    CloudinaryConfig.initialize();  // Add this line
    runApp(const MyApp());
  }
  ```
*/
