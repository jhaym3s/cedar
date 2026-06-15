

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

Okay let me explain what I understand 
From the home screen when you click on the set up button the enroll function is triggered 
the enrollmentstarted event is triggered and there is a navigation to the Enrollmentscreen 
During enrollmentstarted event we make a call to startenrollment from the repository 
the repository is implementing the datasource 
the data source is being implemented by the mock data source class 
The startenrollment in the mock data source 
we have the secret in the generate secret function 
a secure random range is generated with Random.Secure() because the normal Random() function can be predicted by an external body
We then generate 20 byte of secret which is 160 bits. 
we return base32.encode string which 32 random characters
in the base 32 encode function we pass in the the 20 bytes(160 bits) we generated then seperate the bits in groups of 5 we use that to make a letter, from 160 bits we would have 32 letter we then use string buffer to join this characters 
this secrets of 32 charaters is passed into the uri, the issuer, period algorithm and digits are passed in the uri 
the uri and the secret is passed through the bloc state management
on code submission we pass the code from the repository to the data source 
this triggers confirmEnrollment the secret is gotten from the pendingsecret saved from the start enrollment function and then trigger the totp verify function 
in the totp verify function we pass the secret, the code entered, and the duration when the verification started.
the code that is being passed in is now converted into a bytes. the counter which is an int is also converted to byte 
then this is used with the decode bytes to generate a code and then verify the code entered


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


 Verification was left out because I saw the task at a wrong time but didnt want to exceed time 



https://github.com/user-attachments/assets/de62872a-f24d-48a9-9149-41b732b2627c


# with err 

https://github.com/user-attachments/assets/bda898c3-6a1d-4b0c-94ae-2510a09f6bb3






