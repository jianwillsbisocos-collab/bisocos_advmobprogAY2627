# surname_advmobprogAY2627

A Flutter product browser that fetches items from the [Fake Store API](https://fakestoreapi.com/products). It includes live title search, product details, and a Provider-powered dark mode setting.

## Run the application

```bash
flutter pub get
flutter run
```

## Laboratory discussion

### How the layers interact

`ProductModel` represents the product data structure. `ProductService` fetches REST data and converts each JSON item into a `ProductModel`. The screens use that data to build the user interface and handle navigation. `ThemeProvider` manages the app-wide light or dark theme state and notifies listening widgets when it changes.

Data flow: **API → Service → Model → Screen → User Interface**.

### Design pattern used

The app follows a layered architecture similar to MVVM and Clean Architecture. Keeping model, service, presentation, and state management responsibilities separate provides separation of concerns, reusable code, easier maintenance and debugging, and room to scale the app.
