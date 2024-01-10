import 'dart:developer';
import 'dart:io';

import 'package:apng_resize/app_module_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _expectedWidthController = TextEditingController();
  final TextEditingController _expectedHeightController = TextEditingController();

  final _selectedImagesProvider = StateProvider<List<XFile>>((ref) => []);

  void _onPickImages() async {
    final selectedImages = await ref.read(imagePickerProvider).pickMultiImage();
    ref.read(_selectedImagesProvider.notifier).state = selectedImages;
  }

  void _onSubmit() async {
    final selectedImages = ref.read(_selectedImagesProvider);
    final widthText = _expectedWidthController.value.text;
    final heightText = _expectedHeightController.value.text;
    final expectedWidth = int.tryParse(widthText);
    final expectedHeight = int.tryParse(heightText);
    if (expectedWidth == null || expectedHeight == null || selectedImages.isEmpty) return;

    final downloadDirectory = await getDownloadsDirectory();

    if (downloadDirectory == null) {
      log('no download directory found');
      return;
    }

    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    final savedDirectory = Directory('${downloadDirectory.path}/$nowMillis');
    await savedDirectory.create();

    for (int index = 0; index < selectedImages.length; index++) {
      final image = selectedImages[index];
      final cmd = img.Command()
        ..decodeImageFile(image.path)
        ..copyResize(width: expectedWidth, height: expectedHeight)
        ..writeToFile('${savedDirectory.path}/${image.name}');
      await cmd.executeThread();
    }

    showSuccessDialog();
  }

  void _onClear() {
    ref.read(_selectedImagesProvider.notifier).state = [];
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text('Successful'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;
    // final screenWidth = screenSize.width;
    // final screenHeight = screenSize.height;
    // final isVerticalScreen = screenHeight > screenWidth;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              child: Consumer(
                builder: (
                  BuildContext context,
                  WidgetRef ref,
                  Widget? child,
                ) {
                  final images = ref.watch(_selectedImagesProvider);
                  if (images.isEmpty) return _buildNoSelectedImageView();
                  return _buildImageListView(images);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expectedWidthController,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(hintText: 'width'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _expectedHeightController,
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(hintText: 'height'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _onClear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSelectedImageView() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No image. Please select.'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _onPickImages,
          child: const Text('Pick images'),
        ),
      ],
    );
  }

  Widget _buildImageListView(List<XFile> images) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          crossAxisCount: 4,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];
          return Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Center(
              child: Text(image.name),
            ),
          );
        });
    /*return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Column(
          children: [
            Image.memory(image),
            const Divider(),
          ],
        );
      },
    );*/
  }
}
