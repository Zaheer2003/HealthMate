# Health Records App - Architecture & Design System

## 📐 Architecture: MVC Pattern

The project implements **Model-View-Controller (MVC)** architecture with the following structure:

```
lib/
├── features/
│   ├── health_records/
│   │   ├── models/                    # (M) Data Models
│   │   │   └── health_record.dart
│   │   ├── controllers/               # (C) Business Logic Controllers
│   │   │   └── health_record_controller.dart
│   │   ├── services/                  # Data Access Layer
│   │   │   ├── i_database_service.dart
│   │   │   ├── hive_database_service.dart
│   │   │   ├── sqflite_database_service.dart
│   │   │   └── database_service_factory.dart
│   │   └── views/                     # (V) UI Screens & Widgets
│   │       ├── dashboard_page.dart
│   │       ├── home_page.dart
│   │       ├── add_record_page.dart
│   │       ├── manage_records_page.dart
│   │       ├── settings_page.dart
│   │       ├── step_history_page.dart
│   │       ├── calories_history_page.dart
│   │       └── water_history_page.dart
│   └── auth/
│       ├── models/
│       ├── services/
│       │   └── auth_service.dart
│       └── views/
│           ├── login_page.dart
│           ├── register_page.dart
│           └── forgot_password_page.dart
├── services/
│   ├── theme_provider.dart            # Global Theme Management
│   └── database_helper.dart
└── main.dart
```

### **MVC Component Breakdown:**

#### **Model (M) - Data Layer**
- `health_record.dart` - HealthRecord entity (Hive model)
- Contains fields: `id`, `date`, `steps`, `calories`, `water`, `goalSteps`, `goalCalories`, `goalWater`
- Uses Hive for local persistence with `@HiveType` annotations

#### **Controller (C) - Business Logic Layer**
- `health_record_controller.dart` - HealthRecordController (extends ChangeNotifier)
- Singleton pattern for app-wide state
- Handles data loading, CRUD operations, goal management
- Uses Provider package for state management
- Methods: `addHealthRecord()`, `updateHealthRecord()`, `deleteHealthRecord()`, `setGoal*()`

#### **View (V) - Presentation Layer**
- StatelessWidget and StatefulWidget pages
- Consumer widgets for reactive UI updates
- Responsive layout with MediaQuery detection
- Animation controllers for smooth transitions
- Pages communicate with Controller via Provider

#### **Service Layer** (Supporting MVC)
- `IDatabaseService` - Interface for database operations (Dependency Inversion)
- `HiveDatabaseService` - Web database implementation
- `SqfliteDatabaseService` - Mobile database implementation
- `DatabaseServiceFactory` - Factory pattern for DB selection
- `ThemeProvider` - Global theme state management
- `AuthService` - User authentication & profile data

---

## 🎨 Design System

### **Color Palette**

#### **Primary Colors** (Theme-based)
- Primary: Theme's primary color (brand color)
- Surface: Theme's surface color (backgrounds)
- OnSurface: Theme's onSurface color (text)

#### **Accent Colors** (By Feature)

| Feature | Color 1 | Color 2 | Usage |
|---------|---------|---------|-------|
| **Steps** | `#34C759` (Green) | `#30B0A0` (Teal) | Card gradient, chart line |
| **Calories** | `#FF3B30` (Red) | `#FF9500` (Orange) | Card gradient, chart line |
| **Water** | `#00B4DB` (Light Blue) | `#0083B0` (Dark Blue) | Card gradient, chart line |
| **Health Score** | `#9C27B0` (Purple) | `#673AB7` (Deep Purple) | Card gradient |
| **Primary Actions** | Theme Primary | - | Buttons, icons, accents |
| **Errors** | Theme Error Color | - | Error messages, delete actions |

#### **Opacity Levels**
- `withOpacity(0.9)` - Strong, prominent gradients
- `withOpacity(0.8)` - Secondary gradient stops
- `withOpacity(0.3)` - Grid lines, subtle borders
- `withOpacity(0.2)` - Light backgrounds, disabled states
- `withOpacity(0.1)` - Very subtle accents
- `withOpacity(0.05)` - Almost invisible, minimum contrast

---

### **Icons Used**

#### **Navigation Icons** (Material Design - Rounded)
| Icon | Used For | Location |
|------|----------|----------|
| `Icons.dashboard_rounded` | Dashboard | Bottom nav, Drawer |
| `Icons.history_rounded` | Records/History | Bottom nav, Drawer |
| `Icons.add_rounded` | Add Record | Floating Action Button (FAB) |
| `Icons.arrow_forward_rounded` | Navigate/Details | "Detailed History" buttons |
| `Icons.settings_rounded` | Settings | Drawer |
| `Icons.logout_rounded` | Logout | Drawer (Error color) |
| `Icons.help_outline_rounded` | Help | Drawer |

#### **Data Visualization Icons**
| Icon | Used For | Location |
|------|----------|----------|
| `Icons.directions_walk_rounded` | Steps | Summary card, Drawer |
| `Icons.local_fire_department_rounded` | Calories | Summary card, Drawer |
| `Icons.water_drop_rounded` | Water | Summary card |
| `Icons.favorite_rounded` | Health Score | Summary card |

#### **UI Element Icons**
| Icon | Used For | Location |
|------|----------|----------|
| `Icons.person_rounded` | User Avatar | Header, Profile |
| `Icons.notifications_rounded` | Notifications | Dashboard header |
| `Icons.search_rounded` | Search | Dashboard search bar |
| `Icons.tune_rounded` | Filter | Dashboard search bar |
| `Icons.calendar_today_rounded` | Date | Dashboard header |
| `Icons.dark_mode_rounded` | Dark Theme Toggle | Drawer |
| `Icons.light_mode_rounded` | Light Theme Toggle | Drawer |
| `Icons.edit_rounded` | Edit/Pencil | Forms |
| `Icons.delete_rounded` | Delete/Remove | Record items |

#### **Theme Toggle Icons**
```dart
// In Drawer SwitchListTile:
themeProvider.themeMode == ThemeMode.dark
    ? Icons.dark_mode_rounded
    : Icons.light_mode_rounded
```

---

### **Typography**

#### **Font Sizes**
- **Headlines**: `headlineSmall` (w700) - Section titles
- **Titles**: `titleMedium` (w700) - Card values
- **Body Large**: `bodyLarge` (w600) - Primary text
- **Body Small**: `bodySmall` (w500) - Secondary text
- **Label Small**: 11-12 px (w600) - Badges, labels

#### **Font Weights**
- `FontWeight.w700` - Bold headings, numbers
- `FontWeight.w600` - Section labels, secondary titles
- `FontWeight.w500` - Body text, hints

---

### **Spacing & Layout**

#### **Padding/Margins**
- **Cards**: 16.0 px padding
- **Page content**: 20.0 px horizontal padding
- **Section spacing**: 32.0 px (major), 16.0 px (minor)
- **Item spacing**: 12.0 px between related items

#### **Border Radius**
- **Cards/Containers**: 20.0 radius (rounded corners)
- **Input fields**: 16.0 radius
- **Icons**: 12.0 radius (icon backgrounds)
- **Progress bars**: 8.0 radius

#### **Shadows**
- **Card shadows**: `BlurRadius: 12, Offset: (0,4), opacity: 0.1`
- **Chart shadows**: `BlurRadius: 12, spreadRadius: 2, opacity: 0.1`
- **Header shadows**: `BlurRadius: 12, opacity: 0.3` (stronger)

---

### **Responsive Design**

#### **Small Screens (<400px width)**
- X-axis labels show only day numbers (e.g., "14")
- Font size reduced (10px vs 11px)
- Reserved label space: 24px (vs 30px on larger screens)
- Chart interval: Show every 2nd label (fewer crowded labels)

#### **Regular Screens (≥400px)**
- Full date format displayed (e.g., "11/14")
- Standard font sizes
- Reserved label space: 30-40px

---

### **Chart Styling**

#### **Line Charts**
- **Curve Type**: `isCurved: true` (smooth spline interpolation)
- **Line Width**: 3.0 px
- **Area Fill**: Gradient with opacity transition
- **Dots**: Hidden (`FlDotData(show: false)`)
- **Grid**: Visible, light opacity (0.2)
- **Legend**: False (clean look)

#### **Colors per Chart**
- **Steps**: Green to Teal gradient
- **Calories**: Red to Orange gradient
- **Water**: Light Blue to Dark Blue gradient

---

### **State Management & Provider Pattern**

#### **Global Providers**
```dart
// In Consumer widgets:
Consumer<HealthRecordController>(
  builder: (context, controller, child) {
    final records = controller.healthRecords;
    final goals = controller.defaultGoalSteps;
    // ...
  }
)

Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    // ...
  }
)
```

---

## 📱 App Structure Summary

```
Entry Point: main.dart
    ↓
MultiProvider (Provider setup)
    ├─ HealthRecordController (Singleton)
    ├─ ThemeProvider
    └─ Other services
    ↓
MaterialApp (Theme support)
    ↓
HomePage (Shell/Navigation)
    ├─ AppBar (Title)
    ├─ Drawer (Navigation menu)
    ├─ BottomAppBar (Quick nav)
    ├─ FloatingActionButton (Add record)
    └─ Body
        ├─ DashboardPage
        ├─ ManageRecordsPage
        └─ [Other pages via Navigator]
```

---

## 🔧 Key Design Decisions

1. **Singleton Pattern** for `HealthRecordController` - Ensures single app-wide instance
2. **Factory Pattern** for Database Service - Supports Web (Hive) and Mobile (SQLite)
3. **Provider Package** for State Management - Clean, reactive UI updates
4. **Theme Inheritance** - Uses Material 3 theme for consistency
5. **Responsive Typography** - Dynamic font sizes based on screen width
6. **Gradient Cards** - Modern, visually appealing metric displays
7. **Smooth Animations** - Fade-in transitions for page load
8. **Dark Mode Support** - Full theme toggle with persistence (SharedPreferences)

---

## ✨ Design Consistency Rules

1. ✅ All major sections have gradient backgrounds
2. ✅ All cards have rounded corners (≥16 radius)
3. ✅ All text colors respect opacity hierarchy
4. ✅ All navigation uses Material icons (rounded variants)
5. ✅ All buttons have consistent styling (TextButton.icon)
6. ✅ All charts share common styling (line curves, gradients)
7. ✅ All pages follow safe area constraints
8. ✅ All interactive elements provide visual feedback

