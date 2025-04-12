import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class MultipleImageInput extends StatefulWidget {
  final Function(List<File>) onPickImages;
  List<String>? images;

  MultipleImageInput({
    required this.onPickImages,
    this.images,
  });

  @override
  _MultipleImageInputState createState() => _MultipleImageInputState();
}

class _MultipleImageInputState extends State<MultipleImageInput> {
  List<File?> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.images != null) {
      for (var imagePath in widget.images!) {
        final file = File(imagePath);

        _selectedImages.add(file);
      }
    }
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)).toList());
      });

      widget.onPickImages(_selectedImages.whereType<File>().toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 40,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                  Colors.purple[100]!,
                )),
                onPressed: _pickImage,
                child: const Text(
                  'Pick Images',
                )),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            if (_selectedImages[index] != null) {
              return Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.black,
                        Colors.white,
                      ],
                      stops: [
                        0.0,
                        0.4,
                      ],
                    ).createShader(bounds),
                    child: Image.file(
                      _selectedImages[index]!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => setState(() {
                        _selectedImages.removeAt(index);
                        widget.onPickImages(
                            _selectedImages.whereType<File>().toList());
                      }),
                    ),
                  ),
                ],
              );
            }
            return SizedBox(); // Return an empty widget if the image is null
          },
        ),
      ],
    );
  }
}
