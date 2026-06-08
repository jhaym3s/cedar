

# cedar


# Prerequisites
Make sure you have the following installed before cloning the project
- Flutter
- X-CODE
- Android Studio

# Set up 
git clone the repo https://github.com/jhaym3s/cedar.git

install flutter dependencies using `flutter pub get`

then run `flutter run`


## Security Precautions
I did not log any secrets; they are in the block state 
I made sure to clear the bloc state when I was done with the secrets (_onReceived)
I added the lockout feature(replay protection) that prevents the user from staying logged in for 30 seeconds especially since it is TOPT 


# Packages used
I used crypto for HMAC-SHA1

Bloc/flutterbloc for state management

qr_flutter 

Validation happens inside the mock data source, not in the UI. That mirrors
a live server. The verifying party holds the secret, and the client only ever sends a
6-digit code. The MockTOPTDataSource therefore plays the role of the
server — it stores the secret and runs Totp.verify.
 The UI never sees the secret after enrollment(explained in security precautions above).



https://github.com/user-attachments/assets/de62872a-f24d-48a9-9149-41b732b2627c


# with err 

https://github.com/user-attachments/assets/bda898c3-6a1d-4b0c-94ae-2510a09f6bb3






