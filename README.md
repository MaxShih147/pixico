# Pixico

Pixico is a simple cross-platform image utility app built with Flutter. It allows you to import any image, resize it into a pixelated version at a custom resolution, and (soon) apply custom color replacements. Designed for ease of use and quick deployment on desktop and web.

## Features

* 🖼 Import any image file (JPG, PNG, etc.)
* 🔲 Pixelate the image to target resolutions (e.g., 16x16, 32x32)
* 📐 Adjustable pixel dimensions
* 🔍 Enlarged output with visible pixel grid effect
* 💾 Save pixelated result to gallery (mobile) or download (web, coming soon)

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/pixico.git
   cd pixico
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   * On mobile or emulator:

     ```bash
     flutter run
     ```
   * On Chrome (web):

     ```bash
     flutter run -d chrome
     ```

## Roadmap

* [x] Image import and pixelation
* [ ] Web-compatible image download
* [ ] Custom color replacement mapping
* [ ] Multi-image batch processing
* [ ] Export color map data (e.g., JSON or CSV)

## License

MIT License