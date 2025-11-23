# Architecture

```mermaid
graph TD
    subgraph App
        A[main.dart]
    end

    subgraph "State Management"
        SM1[Riverpod]
        SM2[Provider]
    end

    subgraph "Services"
        S1[Theme Provider]
    end

    subgraph "Features"
        subgraph "Auth Feature"
            F1V[Views]
            F1W[Widgets]
            F1S[Auth Service]
        end

        subgraph "Health Records Feature"
            F2V[Views]
            F2C[Controllers]
            F2M[Models]
            subgraph "Database Service"
                F2DS[Database Factory]
                F2DSI[IDatabase Service]
                F2DS_SQF[SQFlite Impl]
                F2DS_HIVE[Hive Impl]
            end
        end
    end

    subgraph "Data"
        D1[SQFlite]
        D2[Hive]
        D3[Shared Preferences]
    end

    A --> S1
    A --> SM1
    A --> SM2

    SM1 --> F1V
    SM1 --> F2V
    SM2 --> F1V
    SM2 --> F2V


    F1V --> F1W
    F1V --> F1S

    F2V --> F2C
    F2C --> F2M
    F2C --> F2DS

    F2DS --> F2DSI
    F2DSI -- Implemented by --- F2DS_SQF
    F2DSI -- Implemented by --- F2DS_HIVE

    F2DS_SQF --> D1
    F2DS_HIVE --> D2
    F1S --> D3
```

## Architecture Overview

The application follows a **feature-based architecture**. Each feature is a self-contained unit with its own UI, logic, and data access. This approach promotes modularity and scalability.

### Core Components

*   **`main.dart`**: The entry point of the application. It sets up the initial environment and providers.
*   **State Management**: The application uses both `flutter_riverpod` and `provider` for state management. This is unusual, and it might be beneficial to consolidate to a single state management solution.
*   **Services**:
    *   **`Theme Provider`**: A global service for managing the application's theme.
    *   **`Auth Service`**: A service within the `auth` feature to handle user authentication. It likely uses `shared_preferences` for storing session data.
    *   **`Database Service`**: A service within the `health_records` feature that abstracts the database implementation. It uses a **Factory Pattern** to provide either a `sqflite` or `hive` implementation of the `IDatabaseService` interface.
*   **Features**:
    *   **`Auth`**: Handles user authentication. It's composed of:
        *   **`Views`**: UI screens for authentication (e.g., login, registration).
        *   **`Widgets`**: Reusable UI components for the auth feature.
        *   **`Auth Service`**: The service responsible for authentication logic.
    *   **`Health Records`**: Manages user health records. It's composed of:
        *   **`Views`**: UI screens for displaying and managing health records.
        *   **`Controllers`**: Contains the business logic for the feature.
        *   **`Models`**: Data structures representing health records.
        *   **`Database Service`**: The service for data persistence.
*   **Data Layer**:
    *   **`SQFlite`**: A relational database for structured data.
    *   **`Hive`**: A NoSQL key-value database for semi-structured data.
    *   **`Shared Preferences`**: For storing simple key-value data, like session tokens.

### Data Flow

1.  The UI (`Views`) is built using `Widgets`.
2.  User interactions in the `Views` trigger methods in the `Controllers` (in `health_records`) or `Services` (in `auth`).
3.  The `Controllers`/`Services` execute the business logic.
4.  For data persistence, the `Database Service` in `health_records` uses the `Database Factory` to get the appropriate database implementation (`SQFlite` or `Hive`).
5.  The `Models` define the structure of the data.
6.  The state management solutions (`Riverpod` and `Provider`) are used to update the UI when the data changes.

### Nested `app` Directory

There is a nested `app` directory that contains a default Flutter counter application. This directory seems to be unused and can likely be safely removed to avoid confusion.
