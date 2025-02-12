import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'https://pistike.moriczcloud.hu';
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
}

