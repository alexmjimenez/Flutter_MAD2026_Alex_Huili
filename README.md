# Workspace

Github:
* Repository: [https://github.com/alexmjimenez/HelloWorldMAD26.git](https://github.com/alexmjimenez/Flutter_MAD2026_Alex_Huili)
* Releases: [https://github.com/alexmjimenez/HelloWorldMAD26/releases](https://github.com/alexmjimenez/Flutter_MAD2026_Alex_Huili/releases)

Workspace: https://upm365.sharepoint.com/:u:/s/MobileAPPDevelopmentGroup/IQCpZIwIHHZUQYlnT6Hqz18QAfoaPzNKJiFzHrLOmGAjLPk?e=FPQX9R (Address to flutter folder)

## Description
"Bin Collector" is an app that allows citizens to track their routes, checks the local weather, view public bins, and report maintenance issues in real time. The cizitens and city ​​hall administrator can add news bins with marked coordinates and catalog reports issue status to promote a cleaner environment, providing real-time database. The​​ hall administrator, exclusively, allows to erase reports when it's done; and bins. Additionally, it enhances the experience within its scope by rewarding users with score for reports issue and new bins added; and the leaderboard to compete with users for highest score possible. Ideally, this app creates an environmental community and unifies a swift response through map-marked reports to address landfill issues.

### Note: In settings menu, to change the role to hall city administrator, type in the token input: "AYUNTAMIENTO2026"

## Screenshots and navigation
| Home | Map | Weather |
| :---: | :---: | :---: |
| <img width="250" alt="1" src="https://github.com/user-attachments/assets/c535f5a4-f69b-4849-87e3-47a542b169d4" /><br>Displaying the Score System for reports and bins added, location tracking and app info. | <img width="250" alt="2" src="https://github.com/user-attachments/assets/eb540de5-03d9-41b2-8d7f-9be093f21165" /><br>Icons for bins and report issues status. | <img width="250" alt="3" src="https://github.com/user-attachments/assets/fefb51ce-4984-464e-926d-1e666de0ea06" /><br>Local weather in current location. |

| Report | Places | Records |
| :---: | :---: | :---: |
| <img width="250" alt="4" src="https://github.com/user-attachments/assets/6f69655e-be3f-478a-a194-3c39965354b8" /><br>Reports issues with status options and info account. | <img width="250" alt="5" src="https://github.com/user-attachments/assets/ff29f199-b549-4d24-9f30-fc4de04b8374" /><br>Adds bins with current or custom coordinates and displays all actives user reports. | <img width="250" alt="6" src="https://github.com/user-attachments/assets/a360ba38-eb98-4de1-9e7a-b9449f998bdc" /><br>Displays all records location updates. |

| Leaderboard | Settings |
| :---: | :---: |
| <img width="250" alt="7" src="https://github.com/user-attachments/assets/b8d45feb-0442-4f99-a414-dabc0b9cf5f5" /><br>Display all user scores, which is called Leaderboard Score. | <img width="250" alt="8" src="https://github.com/user-attachments/assets/2e4d79d6-b7da-497e-bb11-4a92ef458baa" /><br>Displays the username and token to change the role to city ​​hall administrator. |

## Demo video
https://upm365.sharepoint.com/sites/MobileAPPDevelopmentGroup/_layouts/15/stream.aspx?id=%2Fsites%2FMobileAPPDevelopmentGroup%2FShared%20Documents%2FFlutter%2FFlutter%5Fvideo%2Emp4&referrer=StreamWebApp%2EWeb&referrerScenario=AddressBarCopied%2Eview%2E0a548bc4%2De2cf%2D458d%2D9dde%2Dea03b97383e9&isDarkMode=true

## Features
### Functional features
* Track reports and bin on a interactive map.
* For all users, add new bins and report issues (Full, Dirty, Broken for status) to keep the city clean.
* For hall city administrator, exclusively, remove bins and report issues.
* **Scoring system:** Earn 5 points for every new reports and 10 points for bins.
* Leaderboard score system to compete with the highest score possible.
* View real-time database for bins and reports and real-time location for local weather.
* Records all locations history.

### Technical features
* **Maps:** flutter_map for interactive map.
* **Weather:** Local Weather API integrated using Retrofit and dio.
* **Location updates:** GPS coordinates (Latitude, Longitude, Altitude) utilizing geolocator.
* **Persistence in csv/text file:** Stores data location saved in csv files (csv).
* **Persistence in shared preferences:** User ID and API Key management (shared_preferences).
* **Firebase Realtime database:** Real-time data storage and community sync for reports and bins.
* **Firebase authentication:** Secure user login via Email and Google Auth UI.

## How to use to add or remove reports and bins
1. Open the app and log in using your Email Account.
2. Optionally in settings menu, to change the role to hall city administrator, type in the token input: "AYUNTAMIENTO2026".
3. Check your Score on the main screen.
4. Add the report issues and bins with current or custom coordinates.
5. If the user has a role as hall city administrator, it grants to remove reports and bins.
6. Navigate to the Map to check all reports and bins.

## Additional section: Development History
### Week 3-5 (v1)
* **Advanced Navigation**: Implementation of a 3-level navigation flow (MainActivity ↔ SecondActivity ↔ ThirdActivity)
* **GPS Location and location updates**: The app requests runtime permissions and displays the device's latitude and longitude and GPS coordinates (Latitude, Longitude, Altitude) utilizing geolocator
* **System Logging**: Integrated logger library messaging with different levels of verbosity (Debug and Info) to monitor the activity lifecycle.
* **Custom Styling**: UI components have been customized
* **Persistence in csv/text file:** Stores data location saved in csv files (csv).
* **Records location history**: Records all locations history.
* **Persistence in shared preferences:** User ID and API Key management (shared_preferences).

### Week 6
* **Weather:** Local Weather API integrated using Retrofit and dio.
* **Map:** For an interactive map, using the library flutter_map.
* **Snackbar notification**

### Week 7-8 (v2)
* **Firebase Realtime database:** Real-time data storage and community sync for reports and bins.
* **Firebase authentication:** Secure user login via Email and Google Auth UI.
* **Scoring system:** Earn 5 points for every new reports and 10 points for bins.
* **Leaderboard scoring system:** Users compete with the highest score possible, displaying list of users from highest score.
* **Add/remove reports and bins system**: Users can now add or remove reports and bin and updates icons to the map in real-time database.
* **Token added for role as hall city administrator**: This role allows to remove reports and bins.

## Participants
List of MAD developers:
* Huili Chen (huili.chen@alumnos.upm.es)
* Lozano Martín Alex (alex.mjimenez@alumnos.upm.es)

Workload distribution between members: (60% Huili / 40% Alex).
* *Alex focused on base app structure, navigation, GPS sensors integration, persistence in csv/text file and in shared preferences, and Firebase Setup.*
* *Huili was in charge of the external API connections (Retrofit for weather and flutter_map for map), Gamification Score System and Leaderboard System, sharedPreferences focused to change roles by tokens, functions for reports and bins, and Firebase Realtime Database cloud sync.*
