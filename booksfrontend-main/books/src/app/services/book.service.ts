import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

interface Book {
  id: number;
  title: string;
  author: string;
  description: string | null;
  image_url: string | null;
  category: string;
  available: number;
}

@Injectable({
  providedIn: 'root'
})
export class BookService {
  private apiUrl = 'https://pistike.moriczcloud.hu/books';

  constructor(private http: HttpClient) {}

  getBooks(): Observable<Book[]> {
    return this.http.get<Book[]>(this.apiUrl);
  }
}
