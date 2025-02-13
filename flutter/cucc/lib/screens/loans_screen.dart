

import 'package:cucc/screens/loan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'book_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

class LoansScreen extends StatefulWidget {
  @override
  _LoansScreenState createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  List<Book> books = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();
int? userint;

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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final  user_id = prefs.getString('user_id');
       userint = int.parse(user_id!);





      final response = await http.get(
        Uri.parse('https://pistike.moriczcloud.hu/loans/user/${userint}/books'),
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your loans'),
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
                              Text(book.author),
                              SizedBox(height: 4),
                              Text(
                                book.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoanDetailScreen(
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
                                  user: userint,
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