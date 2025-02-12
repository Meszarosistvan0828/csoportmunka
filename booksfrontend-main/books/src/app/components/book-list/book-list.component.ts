import { Component, OnInit } from '@angular/core';
import { BookService } from '../../services/book.service';

interface Book {
  id: number;
  title: string;
  author: string;
  description: string | null;
  image_url: string | null;
  category: string;
  available: number;
}

@Component({
  selector: 'app-book-list',
  standalone: false,
  templateUrl: './book-list.component.html',
  styleUrl: './book-list.component.css'
})
export class BookListComponent implements OnInit {
  books: Book[] = [];

  constructor(private bookService: BookService) {}

  ngOnInit(): void {
    this.bookService.getBooks().subscribe((data) => {
      this.books = data;
    });
  }
}
