# Uganda Explore

Uganda Explore is a Flutter application designed to help users discover popular places and relevant locations in Uganda. The app features a user-friendly interface with a search bar, sections for popular places, and the ability to view images and clips stored in Supabase.

## Features

- **Home Screen**: Displays a header with location and weather information, a search bar, and sections for popular and relevant places.
- **Image and Clip Storage**: Utilizes Supabase for storing and retrieving images and video clips, allowing users to view media content seamlessly.
- **Responsive Design**: The app is designed to work well on various screen sizes, providing a consistent user experience.

## Project Structure

```
uganda_explore
├── lib
│   ├── main.dart
│   ├── screens
│   │   └── home
│   │       └── home_screen.dart
│   ├── services
│   │   └── supabase_storage_service.dart
│   └── widgets
│       └── image_clip_widget.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd uganda_explore
   ```

2. **Install Dependencies**:
   Make sure you have Flutter installed on your machine. Run the following command to install the necessary packages:
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**:
   - Create a Supabase account and set up a new project.
   - Obtain your Supabase URL and API key.
   - Update the `supabase_storage_service.dart` file with your Supabase credentials.

4. **Run the Application**:
   Use the following command to run the app on your device or emulator:
   ```bash
   flutter run
   ```

## Usage

- Launch the app to view the home screen.
- Use the search bar to find specific places.
- Explore the popular places and relevant locations displayed on the screen.
- Images and clips will be fetched from Supabase and displayed in the app.

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.