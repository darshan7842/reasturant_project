import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PopularItem {
  String name;
  double price;
  String image;
  String docId;

  PopularItem({required this.name, required this.price, required this.image, required this.docId});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
    };
  }

  factory PopularItem.fromMap(Map<String, dynamic> map, String docId) {
    return PopularItem(
      name: map['name'],
      price: map['price'],
      image: map['image'],
      docId: docId, // Store document ID
    );
  }
}

class ManagePopularItems extends StatefulWidget {
  @override
  _ManagePopularItemsState createState() => _ManagePopularItemsState();
}

class _ManagePopularItemsState extends State<ManagePopularItems> {
  List<PopularItem> popularItems = [];
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchPopularItems();
  }

  Future<void> _fetchPopularItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('popularItems').get();
    setState(() {
      popularItems = snapshot.docs
          .map((doc) => PopularItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addItemToFirestore(PopularItem item) async {
    DocumentReference docRef = await FirebaseFirestore.instance.collection('popularItems').add(item.toMap());
    String docId = docRef.id; // Get the docId of the newly added document
    item.docId = docId;
  }

  void _addItem() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Item Name"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Price"),
              ),
              _imageFile != null
                  ? Image.file(_imageFile!, width: 200, height: 100)
                  : Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black87, // Background color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text("No image selected")),
              ),
              TextButton(
                onPressed: _pickImage,
                child: Text("Pick Image"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                setState(() {
                  PopularItem newItem = PopularItem(
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    image: _imageFile?.path ?? 'assets/default_image.jpg',
                    docId: '', // Initialize docId as empty
                  );
                  _addItemToFirestore(newItem).then((_) {
                    setState(() {
                      popularItems.add(newItem);
                    });
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete ${popularItems[index].name}?"),
          content: Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                String docId = popularItems[index].docId;
                await FirebaseFirestore.instance
                    .collection('popularItems')
                    .doc(docId)
                    .delete();
                setState(() {
                  popularItems.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Popular Items"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: popularItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: popularItems.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: popularItems[index].image.isNotEmpty
                        ? (popularItems[index].image.startsWith('assets/')
                        ? Image.asset(popularItems[index].image, fit: BoxFit.cover)
                        : Image.file(File(popularItems[index].image), fit: BoxFit.cover))
                        : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey, // Background color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text("No image")),
                    ),
                  ),
                  Text(popularItems[index].name),
                  Text("Rs.${popularItems[index].price}"),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.blueAccent),
                    onPressed: () => _deleteItem(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
