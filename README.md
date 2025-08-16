# Modex Delivery App

A comprehensive Flutter delivery partner application built for managing order deliveries
efficiently. This app provides delivery personnel with tools to authenticate, view orders, track
deliveries, and manage their delivery workflow through an intuitive interface.

The application follows clean architecture principles with BLoC pattern for state management,
ensuring scalable and maintainable code structure.

## Folder Structure

```
lib/
├── main.dart                    # Application entry point with providers setup
├── bloc/                        # State management using BLoC pattern
│   ├── auth/                    # Authentication related business logic
│   │   ├── delivery_auth_bloc.dart
│   │   ├── delivery_auth_event.dart
│   │   └── delivery_auth_state.dart
│   └── order/                   # Order management business logic
│       ├── order_bloc.dart
│       ├── order_event.dart
│       └── order_state.dart
├── data/                        # Data layer containing models and repositories
│   ├── models/                  # Data models
│   │   └── order_model.dart     # Order entity model
│   └── repositories/            # Data access layer
│       ├── delivery_auth_repository.dart
│       └── delivery_repository.dart
├── presentation/                # UI layer
│   └── screen/                  # Application screens
│       ├── auth/                # Authentication screens
│       │   └── delivery_login_screen.dart
│       ├── home/                # Main dashboard
│       │   └── home_screen.dart
│       ├── new_orders/          # New order listings
│       │   └── new_orders_screen.dart
│       ├── assigned_orders/     # Assigned orders management
│       │   └── assigned_orders_screen.dart
│       ├── active_orders/       # Currently active deliveries
│       │   └── active_orders_screen.dart
│       └── past_orders/         # Delivery history
│           └── past_orders_screen.dart
└── services/                    # External services integration
    └── notification_service.dart
```

## Screens Overview

### Authentication

- **Login Screen** (`delivery_login_screen.dart`): Secure authentication interface for delivery
  partners to access the app

### Dashboard

- **Home Screen** (`home_screen.dart`): Main dashboard providing overview of delivery statistics and
  quick navigation

### Order Management

- **New Orders Screen** (`new_orders_screen.dart`): Display available orders that can be accepted by
  delivery partners
- **Assigned Orders Screen** (`assigned_orders_screen.dart`): Shows orders assigned to the current
  delivery partner
- **Active Orders Screen** (`active_orders_screen.dart`): Real-time tracking and management of
  ongoing deliveries
- **Past Orders Screen** (`past_orders_screen.dart`): Historical record of completed deliveries with
  details and earnings

## BLoC State Management

The application uses the BLoC (Business Logic Component) pattern for predictable state management:

### Authentication BLoC

- **Purpose**: Manages user authentication state, login/logout processes
- **Events**: Login requests, logout actions, authentication status checks
- **States**: Authenticated, unauthenticated, loading states
- **Repository**: `DeliveryAuthRepository` for handling authentication API calls

### Order BLoC

- **Purpose**: Handles all order-related operations and state management
- **Events**: Fetch orders, accept orders, update delivery status, complete deliveries
- **States**: Order loading, loaded, error states with different order categories
- **Repository**: `DeliveryRepository` for order data operations

## Data Handling

### Repository Pattern

The app implements the repository pattern for clean data access:

- **DeliveryAuthRepository**: Handles authentication API calls, token management, and user session
  persistence
- **DeliveryRepository**: Manages order data operations including fetching, updating, and status
  changes

### Data Models

- **OrderModel**: Comprehensive order entity containing delivery details, customer information,
  pickup/drop locations, and status tracking

### Services

- **NotificationService**: Manages push notifications for new order alerts, delivery updates, and
  important announcements

## Key Features

- **Secure Authentication**: Role-based access for delivery partners
- **Real-time Order Updates**: Live synchronization of order status changes
- **Order Categories**: Organized workflow from new orders to completion
- **Notification System**: Push notifications for important delivery updates
- **Clean Architecture**: Separation of concerns with BLoC pattern and repository design
- **Responsive UI**: Modern interface built with Google Fonts (Poppins) and Material Design
