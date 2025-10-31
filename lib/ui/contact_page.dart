import 'dart:io';

import 'package:agenda_contatos/helpers/contacat_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({this.contact, super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  late Contact _editedContact;
  bool _userEdited = false;

  Future<bool> _requestPop() async {
    if (!_userEdited) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Descartar Alterações?'),
          content: const Text('Se sair, as alaterações serão perdidas.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      _editedContact = Contact.fromMap(widget.contact!.toMap());
      _nameController.text = _editedContact.name!;
      _emailController.text = _editedContact.email!;
      _phoneController.text = _editedContact.phone!;
      return;
    }

    _editedContact = Contact();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _requestPop();

        if (!shouldPop) return;
        if (mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editedContact.name ?? 'Novo Contato'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name == null || _editedContact.name!.isEmpty) {
              FocusScope.of(context).requestFocus(_nameFocus);
              return;
            }
            if (_editedContact.phone == null || _editedContact.phone!.isEmpty) {
              FocusScope.of(context).requestFocus(_phoneFocus);
              return;
            }
            Navigator.pop(context, _editedContact);
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  final picker = ImagePicker();
                  picker.pickImage(source: ImageSource.camera).then((value) {
                    if (value == null) return;
                    setState(() {
                      _editedContact.img = value.path;
                    });
                  });
                },
                child: Container(
                  height: 140.0,
                  width: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.img != null
                          ? FileImage(File(_editedContact.img!))
                          : const AssetImage('images/person.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = value;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  _userEdited = true;
                  _editedContact.email = value;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (value) {
                  _userEdited = true;
                  _editedContact.phone = value;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
