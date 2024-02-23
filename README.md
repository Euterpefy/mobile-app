# Euterpefy: Music Recommender

Euterpefy is a music recommender mobile application developed for CS4750, designed to create
personalized playlists for users based on their current mood and taste. The app leverages the
Spotify API to fetch data and utilize its recommendation system, providing users with music that
suits their preferences.

## Inspiration

Named after Euterpe, one of the nine Muses in Greek mythology known as the muse of music and lyric
poetry, Euterpefy aims to bring harmony and inspiration to your daily life. The suffix "fy,"
inspired by Spotify, reflects the app's use of the Spotify API for underlying data fetching and
recommendation mechanisms.

## Project Objective

This class project aims to provide hands-on experience in mobile app development, from conception to
deployment. Through Euterpefy, students learn to build a mobile application from scratch,
integrating third-party APIs and implementing user interface design principles to enhance user
experience.

## Technical Stack

Euterpefy is built using Flutter for the frontend, providing a seamless and responsive user
interface across multiple platforms. The backend logic, including interactions with the Spotify API,
is powered by Rust through the [`rustyspoty`](https://github.com/bluesimp1102/rustyspoty) crate.
This combination ensures an efficient performance, leveraging Rust's safety and
concurrency features.

## Features

- **Mood-Based Playlists:** Generate playlists based on your current mood, ensuring the music
  matches how you feel.
- **Personalized Recommendations:** Utilize your music taste to recommend songs and artists that
  align with your preferences.
- **Advanced Playlist Customization:** Adjust settings such as track popularity, dance-ability,
  valence, loudness, and more to refine your playlists.
- **Spotify Integration:** Seamlessly integrates with Spotify, allowing users to explore a vast
  library of music and add recommendations directly to their Spotify account.

## App Wireframe

![euterpefy](https://github.com/Euterpefy/mobile-app/assets/88558991/6187d469-bf07-4c8f-80f0-5da19d38b16d)

## Getting Started

To get started with Euterpefy, clone the repository and ensure you have Flutter installed on your
system. Follow these steps:

1. **Clone the repository:**

    ```sh
    git clone https://github.com/Euterpefy/mobile-app.git
    ```

2. **Navigate to the project directory:**

    ```sh
    cd mobile_app
    ```

3. **Install dependencies:**

    ```sh
    flutter pub get
    ```

4. **Run the app:**

    ```sh
    flutter run
    ```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/): Explore Flutter's comprehensive documentation
  for tutorials, samples, and a full API reference.
- [Rust Documentation](https://www.rust-lang.org/learn): Get started with Rust to understand the
  backend crate `rustyspoty`.
- [Spotify API Documentation](https://developer.spotify.com/documentation/web-api/): Learn more
  about the Spotify Web API and how to integrate it into your projects.

Thank you for exploring Euterpefy. Let the music inspire you!
