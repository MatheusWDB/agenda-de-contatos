import 'dart:io';

import 'package:agenda_contatos/helpers/contacat_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContacatHelper helper = ContacatHelper();
  List<Contact> contacts = [];

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10.0,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      launchUrl(Uri.parse('tel:${contacts[index].phone}'));
                    },
                    child: const Text(
                      'Ligar',
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contacts[index]);
                    },
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      helper.deleteContact(contacts[index].id!);
                      setState(() {
                        contacts.removeAt(index);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _orderList(OrderOptions result) {
    setState(() {
      switch (result) {
        case OrderOptions.orderaz:
          contacts.sort(
            (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()),
          );
          break;
        case OrderOptions.orderza:
          contacts.sort(
            (a, b) => b.name!.toLowerCase().compareTo(a.name!.toLowerCase()),
          );
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            onSelected: _orderList,
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                value: OrderOptions.orderaz,
                child: Text('Ordenar de A-Z'),
              ),
              const PopupMenuItem(
                value: OrderOptions.orderza,
                child: Text('Ordenar de Z-A'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    final contact = contacts[index];

    return GestureDetector(
      onTap: () => _showOptions(context, index),
      child: Card(
        child: Padding(
          padding: const EdgeInsetsGeometry.all(10.0),
          child: Row(
            spacing: 10.0,
            children: [
              Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contact.img != null
                        ? FileImage(File(contact.img!))
                        : const AssetImage('images/person.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name ?? '',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(contact.email ?? '', style: const TextStyle(fontSize: 18.0)),
                  Text(contact.phone ?? '', style: const TextStyle(fontSize: 18.0)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showContactPage([Contact? contact]) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact)),
    );

    if (recContact == null) return;

    contact == null
        ? await helper.saveContact(recContact)
        : await helper.updateContact(recContact);

    _getAllContacts();
  }
}
