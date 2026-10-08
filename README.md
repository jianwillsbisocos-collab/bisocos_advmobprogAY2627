# Jian Wills M. Bisocos

**Course:** INF 233

**Subject:** CTADMOBL Advance Mobile Programming

This Flutter project explores advanced mobile development, including state management, API integration, and Firebase authentication.

## Laboratory Activities

### Lab 1: Theme (Dark/Light Mode)

I learned to use Provider for shared theme state. Changing the theme updates the entire application without calling `setState()` on each screen.

### Lab 2: Bulldog Exchange (Dark/Light Mode)

I integrated Provider into a larger application and kept product cards, navigation, and forms consistent when switching between dark and light themes.

### Lab 3: Cart API Integration with Provider

I connected the Cart API through Provider and separated API services from the UI. This made it easier to retrieve an item by ID and show its details on the appropriate screen.

### Lab 4: API Part III

I explored how the user model, services, and screens work together to render data, and how cart data can be handled by user ID.

### Lab 5: Firebase Authentication

I compared DummyJSON's mock credential validation with Firebase's persistent authentication. The `UserService` centralizes user data and session state, while Firebase supports real accounts and cloud synchronization.

## Local Configuration

The Flutter app expects a local `.env` asset. Keep it in the app folder for local builds and tests; it is intentionally excluded from version control.