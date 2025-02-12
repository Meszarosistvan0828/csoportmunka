# API docs

## User auth
POST `/register` name, email, password
GET `/login` email, password

## Books
GET `/books` -> összes könyv JSON
GET `/books/search?query=Harry Potter` keresi a könyvet NÉV és SZERZŐ alapján -> találatok JSON
GET `/books/search?category=horror` listázza a kategória könyveit -> találatok JSON
! A `query` és a `category` egyszerre is használható

## Borrows
GET `/loans` -> összes kölcsönzés JSON
GET `/loans/return/{id}` törli a kölcsönzést id alapján

POST `loans/add` Új kölcsönzés hozzáadása
paraméterek:
- `user` felhasználó ID
- `book` könyv ID
- `date` lejárat dátuma

