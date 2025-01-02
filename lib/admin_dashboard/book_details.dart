import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final dynamic book; // Data buku yang diterima

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.judul_buku),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${book.judul_buku}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Category: ${book.kategori_buku}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Author: ${book.pengarang}', style: TextStyle(fontSize: 16)),
            // Tambahkan detail lain sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}
