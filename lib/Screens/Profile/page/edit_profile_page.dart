import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../model/user.dart';
import '../widget/appbar_widget.dart';
import '../widget/profile_widget.dart';
import '../widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  final User user;
  final String imageUrl;

  const EditProfilePage({Key? key, required this.user, required this.imageUrl}) : super(key: key);
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late User user;
  File? _image;
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: buildAppBar(context),
      body: user != null ? buildProfileEditor() : buildLoading(),
    );

  Widget buildProfileEditor() => ListView(
    padding: EdgeInsets.symmetric(horizontal: 32),
    physics: BouncingScrollPhysics(),
    children: [
      ProfileWidget(
        imagePath: _image != null ? _image!.path : widget.imageUrl,
        isEdit: true,
        onClicked: () async {
          _showUploadOptions(context);
        },
      ),
      const SizedBox(height: 24),
      TextFieldWidget(
        label: 'Full Name',
        text: user.name,
        onChanged: (name) {},
      ),
      const SizedBox(height: 24),
      TextFieldWidget(
        label: 'Email',
        text: user.email,
        onChanged: (email) {},
      ),
      const SizedBox(height: 24),
      TextFieldWidget(
        label: 'About',
        text: user.about??'fshi',
        maxLines: 5,
        onChanged: (about) {},
      ),
    ],
  );

  Widget buildLoading() => Center(child: CircularProgressIndicator());

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                _getImageFromCamera(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                _getImageFromGallery(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImageFromCamera(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _getImageFromGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }
}
