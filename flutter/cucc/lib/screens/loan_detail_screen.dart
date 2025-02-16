import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

class LoanDetailScreen extends StatelessWidget {
  final int id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final String category;
  final int available;
  final double rating;
  final List reviews;
  final List loans;
  final int? user;


  const LoanDetailScreen({
    super.key,
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
    this.user,
  });


  Future<void> loanBook(BuildContext context) async {
    final url = Uri.parse('https://pistike.moriczcloud.hu/loans/search/return?user=${user}&book=${id}');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final  user_id = prefs.getString('user_id');
    final userint = int.parse(user_id!);


    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'book': id, 'user':userint}), // Adjust according to API requirements
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book loaned successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to loan book: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.book, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('by $author', style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),


            SizedBox(height: 8),
            Text('Category: $category', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),

            Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),

            // Loan Book Button
            Center(
              child: ElevatedButton(
                onPressed: available > 0 ? () => loanBook(context) : null, // Disable if not available
                child: Text('Return Book'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}