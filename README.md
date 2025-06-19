# Uganda Explore

**Uganda Explore** is a cross-platform Flutter application designed to provide tourists with an immersive and interactive way to discover Uganda’s rich tourism sites. The app offers 3D virtual tours, Augmented Reality (AR) directions, detailed information, multimedia content, and smart location-based suggestions to enhance the travel experience.

---

## Table of Contents

- [Features](#features)   
- [Technology Stack](#technology-stack)  
- [Getting Started](#getting-started)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Project Structure](#project-structure)  
- [Contributing](#contributing)  
- [License](#license)  
- [Contact](#contact)

---

## Features

- **Interactive Map** with Google Maps integration showing Uganda’s tourist sites.
- **Search & Filter** capabilities for easy discovery by type, region, and preferences.
- **360° Virtual Tours** powered by Google Earth or Street View.
- **Augmented Reality (AR) Direction View** to guide users in real-time.
- **Place Details** including images, autoplay video clips, descriptions, and reviews.
- **Location-based Suggestions** for nearby attractions.
- **User Profile** to save favorite places and manage preferences.
- **Multi-language Support** (planned).
- **Offline Mode** (planned).

---

## Technology Stack

- **Flutter** — Cross-platform mobile framework  
- **Google Maps & Places APIs** — Map, location, and places search  
- **Google Earth / Street View APIs** — 3D virtual tours  
- **ARCore (Android)** — Augmented reality directions  
- **Firebase** — Backend services: Firestore, Storage, Authentication  
- **Provider** — State management  
- **Video Player** — For short clips playback  

---

## Getting Started

### Prerequisites

- Flutter SDK (version >= 3.0.0)  
- Android Studio / Xcode (for mobile emulators)  
- Firebase project setup with Firestore, Auth, and Storage enabled  
- Google Maps API key with Maps SDK and Places API enabled  
- ARCore supported device (for AR features)  

---

## Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/uganda_explore.git
cd uganda_explore
Usage
Search or browse tourist attractions on the map or list view.

Tap a place to see detailed info, images, and video clips.

Use the 360° virtual tour feature to explore places remotely.

Enable AR directions for real-time navigation to your destination.

Filter results based on your preferences and location.

Save your favorite places for quick access later.

Project Structure
The project follows a modular structure with clear separation of concerns:

lib/screens/ — UI screens categorized by feature

lib/services/ — External API and platform interaction

lib/models/ — Data models such as Place, User, Review

lib/providers/ — State management providers

lib/widgets/ — Reusable UI components

assets/ — Images, videos, icons

