import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.titleTextStyle});

  final String title;
  final TextStyle titleTextStyle;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final server = "http://localhost/";
  List<Map<String, dynamic>> books = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final response = await http.get(Uri.parse('$server/book/content/dashboardPage.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  Future<void> insertData({
    required String title,
    required String description,
    required String author,
    required String category,
  }) async {
    final url = '$server/book/content/dashboardPage.php';

    Map<String, dynamic> bookData = {
      "title": title,
      "description": description,
      "author": author,
      "category": category,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(bookData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Book added successfully');
        _titleController.text = '';
        _descriptionController.text = '';
        _authorController.text = '';
        _categoryController.text = '';
        await _fetchBooks();
      } else {
        print('Failed to add book');
        // Handle failure, maybe show an error message to the user
      }
    } catch (e) {
      print('Error adding book: $e');
      // Handle any exceptions that occur during the HTTP request
    }
  }

  Future<void> _deleteBook(int id) async {
    final url = '$server/book/content/dashboardPage.php?id=$id';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Book deleted successfully');
        await _fetchBooks(); // Load updated data
      } else {
        print('Failed to delete book');
        // Handle failure, maybe show an error message to the user
      }
    } catch (e) {
      print('Error deleting book: $e');
      // Handle any exceptions that occur during the HTTP request
    }
  }


  Future<void> _editBook(int id) async {
    // Implement your edit book logic here
    // For example, show a modal bottom sheet with editing fields
    // Retrieve the book data by ID from the list of books
    Map<String, dynamic>? selectedBook;
    for (var book in books) {
      if (book['id'] == id) {
        selectedBook = book;
        break;
      }
    }

    if (selectedBook != null) {
      // Show a modal bottom sheet with editing fields
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Edit Book',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: selectedBook?['title'] ?? ''),
                      onChanged: (value) {
                        setState(() {
                          selectedBook?['title'] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: selectedBook?['description'] ?? ''),
                      onChanged: (value) {
                        setState(() {
                          selectedBook?['description'] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: selectedBook?['author'].toString() ?? ''),
                      onChanged: (value) {
                        setState(() {
                          selectedBook?['author'] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Author',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: TextEditingController(text: selectedBook?['category'] ?? ''),
                      onChanged: (value) {
                        setState(() {
                          selectedBook?['category'] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Call updateData function to update the book
                        updateData(
                          id: id,
                          title: selectedBook?['title'] ?? '',
                          description: selectedBook?['description'] ?? '',
                          author: selectedBook?['author'] ?? '',
                          category: selectedBook?['category'] ?? '',
                        );
                        Navigator.pop(context); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
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
  }

  Future<void> updateData({
    required int id,
    required String title,
    required String description,
    required String author,
    required String category,
  }) async {
    final url = '$server/book/content/dashboardPage.php';

    try {
      final response = await http.put(
        Uri.parse(url),
        body: jsonEncode({
          'id': id,
          'title': title,
          'description': description,
          'author': author,
          'category': category,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Book updated successfully');
        await _fetchBooks(); // Load updated data
      } else {
        print('Failed to update book');
        // Handle failure, maybe show an error message to the user
      }
    } catch (e) {
      print('Error updating book: $e');
      // Handle any exceptions that occur during the HTTP request
    }
  }
  Future<void> _performSearch(String query) async {
    final url = '$server/book/content/dashboardPage.php?search=$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to perform search');
      }
    } catch (e) {
      print('Error performing search: $e');
    }
  }


  void _showAddBookModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Add Book',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Call insertData function when the "Add" button is pressed
                  insertData(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    author: _authorController.text,
                    category: _categoryController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteBook(id); // Call the delete function
              },
              child: Text('Delete'),
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
        backgroundColor: const Color(0xFF039C60),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.network(
              'https://i.postimg.cc/yxkLtVq3/removal-ai-a828ce7f-c776-4499-8024-01fce6fcff2a-grey-and-white-simple-product-inventory-planner.png',
              width: 60,
              height: 70,
            ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: widget.titleTextStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          AppBar(
            backgroundColor: const Color(0xFF555555),
            title: const Text('Second AppBar'),
            centerTitle: true,
            actions: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 9.3),
                  child: TextField(
                    onChanged: (value) {
                      _performSearch(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black45),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.all(8),
            color: Colors.lightGreen,
            child: Table(
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Center(
                        child: Text(
                          'Title',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Author',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Action',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(2),
            child: Table(
              border: TableBorder.all(color: Colors.black),
              children: [
                for (var book in books)
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                          child: Text(book['title'] ?? ''),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(book['description'] ?? ''),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(book['author'].toString() ?? ''),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(book['category'] ?? ''),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editBook(book['id']); // Call edit function
                                },
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(book['id']);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookModal,
        backgroundColor: const Color(0xFF039C60),
        tooltip: 'Add Book',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
