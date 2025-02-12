import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'https://fasirtguy.moriczcloud.hu';
  private userId: number | null = null;

  constructor(private http: HttpClient) { }

  register(name: string, email: string, password: string): Observable<any> {
    return this.http.get(`${this.apiUrl}/register?name=${name}&email=${email}&password=${password}`, 
      { observe: 'response' }
    );
  }

  login(email: string, password: string): Observable<any> {
    return this.http.get(`${this.apiUrl}/login?email=${email}&password=${password}`)
      .pipe(
        tap((response: any) => {
          if (response.user_id) {
            this.userId = response.user_id;
            localStorage.setItem('userId', response.user_id.toString());
          }
        })
      );
  }

  logout(): void {
    this.userId = null;
    localStorage.removeItem('userId');
  }

  getUserId(): number | null {
    if (!this.userId) {
      const storedUserId = localStorage.getItem('userId');
      if (storedUserId) {
        this.userId = parseInt(storedUserId, 10);
      }
    }
    return this.userId;
  }

  isLoggedIn(): boolean {
    return this.getUserId() !== null;
  }
}