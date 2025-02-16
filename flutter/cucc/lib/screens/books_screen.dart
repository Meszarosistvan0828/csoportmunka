

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'book_detail_screen.dart';

class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final String category;
  final int available;
  final String rating;
  final List reviews;
  final List loans;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.available,
    required this.rating,
    required this.reviews,
    required this.loans,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      available: json['available'] ?? 0,
      rating: json['rating'] ?? 0,
      reviews: json['reviews'] ?? '',
      loans: json['loans'] ?? '',
    );
  }
}

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> books = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('https://pistike.moriczcloud.hu/books'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> booksJson = jsonDecode(response.body);
        setState(() {
          books = booksJson.map((json) => Book.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load books: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      fetchBooks();
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse('https://pistike.moriczcloud.hu/books/search?query=$encodedQuery'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> booksJson = jsonDecode(response.body);
        setState(() {
          books = booksJson.map((json) => Book.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to search books: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error during search: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              setState(() {
                isLoading = true;
                error = null;
              });
              fetchBooks();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or author...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) => searchBooks(value),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => searchBooks(_searchController.text),
                  child: Text('Search'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            Expanded(
              child: Center(child: Text(error!)),
            )
          else if (books.isEmpty)
              Expanded(
                child: Center(
                  child: Text('No books found'),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchBooks,
                  child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.imageUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.book, color: Colors.grey[600]),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            book.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text('${book.author}'),
                              SizedBox(height: 4),
                              Text(
                                book.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),

                              // Star Rating Row
                              Row(
                                children: [

                                  for (int i = 0; i < double.parse(book.rating).floor(); i++)
                                    Icon(Icons.star, color: Colors.amber, size: 20), // Full stars

                                  if (double.parse(book.rating) - double.parse(book.rating).floor() >= 0.5)
                                    Icon(Icons.star_half, color: Colors.amber, size: 20), // Half star

                                  for (int i = 0; i < (5 - double.parse(book.rating).ceil()); i++)
                                    Icon(Icons.star_border, color: Colors.grey, size: 20), // Empty stars

                                  SizedBox(width: 8),
                                  Text(double.parse(book.rating).toStringAsFixed(1)), // Display numeric rating
                                ],
                              ),

                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(book.category),
                                    backgroundColor: Colors.blue[100],
                                  ),
                                  SizedBox(width: 8),
                                  Chip(
                                    label: Text((book.available > 0) ? 'Available' : 'Not Available'),
                                    backgroundColor: (book.available > 0) ? Colors.green[100] : Colors.red[100],
                                  ),
                                ],
                              ),
                            ],
                          ),

                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailScreen(
                                  id: book.id,
                                  title: book.title,
                                  author: book.author,
                                  description: book.description,
                                  imageUrl: book.imageUrl,
                                  category: book.category,
                                  available: book.available,
                                  rating: double.parse(book.rating),
                                  reviews: book.reviews,
                                  loans: book.loans,
                                ),
                              ),
                            );
                          },

                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }
}