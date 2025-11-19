# Project Structure & Architecture

## Clean Architecture Implementation

The project follows Clean Architecture principles with clear separation of concerns across three main layers:

```
lib/
├── main.dart                    # App entry point
└── src/
    ├── core/                    # Shared utilities and base classes
    ├── data/                    # Data layer (external concerns)
    ├── domain/                  # Business logic layer (pure Dart)
    └── presentation/            # UI layer (Flutter widgets)
```

## Layer Dependencies
- **Presentation** → **Domain** (UI depends on business logic)
- **Data** → **Domain** (Data implementations depend on domain contracts)
- **Domain** → **Core** (Business logic uses shared utilities)
- **Core** is independent (no dependencies)

## Detailed Structure

### Core Layer (`lib/src/core/`)
```
core/
├── di/
│   └── injection_container.dart # GetIt service locator setup
├── error/
│   └── failures.dart          # Error handling abstractions
└── usecases/
    └── usecase.dart           # Base UseCase interface
```

### Domain Layer (`lib/src/domain/`)
```
domain/
├── entities/                   # Business objects (pure Dart)
│   ├── question_entity.dart
│   └── user_entity.dart
├── repositories/              # Repository contracts
│   ├── auth_repository.dart
│   └── quiz_repository.dart
└── usecases/                  # Business logic operations
    ├── auth/
    │   ├── get_user_status.dart
    │   ├── sign_in_with_google.dart
    │   └── sign_out.dart
    └── quiz/
        └── fetch_questions.dart
```

### Data Layer (`lib/src/data/`)
```
data/
├── datasources/               # External data sources
│   ├── auth_remote_datasource.dart
│   └── quiz_remote_datasource.dart
├── models/                    # Data transfer objects
│   ├── question_model.dart    # Extends QuestionEntity
│   └── user_model.dart        # Extends UserEntity
└── repositories/              # Repository implementations
    ├── auth_repository_impl.dart
    └── quiz_repository_impl.dart
```

### Presentation Layer (`lib/src/presentation/`)
```
presentation/
├── blocs/                     # BLoC state management
│   ├── auth/
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   └── quiz/
│       ├── quiz_bloc.dart
│       ├── quiz_event.dart
│       └── quiz_state.dart
└── pages/                     # UI screens
    ├── home_page.dart
    ├── quiz_page.dart
    ├── sign_in_page.dart
    └── splash_page.dart
```

## Assets Structure
```
assets/
├── audio/                     # Sound effects
│   ├── correct.mp3
│   └── wrong.mp3
└── lottie/                    # Animation files
    ├── correct_answer.json
    └── wrong_answer.json
```

## Naming Conventions

### Files & Directories
- Use `snake_case` for all file and directory names
- Suffix files with their type: `_bloc.dart`, `_event.dart`, `_state.dart`, `_model.dart`, `_entity.dart`
- Repository implementations end with `_impl.dart`
- Pages end with `_page.dart`

### Classes & Methods
- Use `PascalCase` for class names
- Use `camelCase` for method and variable names
- Abstract classes/interfaces have no special prefix
- Implementations can have `Impl` suffix when needed

### BLoC Pattern
- Events: `AuthEvent`, `QuizEvent` (abstract base classes)
- States: `AuthState`, `QuizState` (abstract base classes)
- BLoCs: `AuthBloc`, `QuizBloc`
- Event names: `AuthCheckRequested`, `SignInRequested`
- State names: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`

## Key Architectural Rules

1. **Domain Independence**: Domain layer contains no Flutter/external dependencies
2. **Repository Pattern**: All external data access goes through repository interfaces
3. **UseCase Pattern**: Each business operation is a separate UseCase class
4. **BLoC State Management**: UI state managed through BLoC pattern
5. **Dependency Injection**: All dependencies registered in `injection_container.dart`
6. **Error Handling**: Use `Either<Failure, Success>` pattern from dartz
7. **Equatable**: All entities, events, and states extend Equatable for value comparison

## Import Organization
```dart
// Flutter/Dart imports first
import 'package:flutter/material.dart';

// External package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// Internal imports (relative paths)
import '../domain/entities/user_entity.dart';
import '../core/error/failures.dart';
```