A very simple way to test the status of the secondaries running in the Virtual Environment.
 Using the [at_server_status](https://pub.dev/packages/at_server_status) package.

running at_ve_doctor.dart will run through the secondaries and report out the status of each of them.

The result as you start up the Virtual Environment should look like this after giving the VE a minute or two to start everything up:- 

````
@alice🛠 status: AtSignStatus.teapot
@ashish🛠 status: AtSignStatus.teapot
@barbara🛠 status: AtSignStatus.teapot
@bob🛠 status: AtSignStatus.teapot
@colin🛠 status: AtSignStatus.teapot
@egbiometric🛠 status: AtSignStatus.teapot
@egcovidlab🛠 status: AtSignStatus.teapot
@egcreditbureau🛠 status: AtSignStatus.teapot
@eggovagency🛠 status: AtSignStatus.teapot
@emoji🦄🛠 status: AtSignStatus.teapot
@eve🛠 status: AtSignStatus.teapot
@jagan🛠 status: AtSignStatus.teapot
@kevin🛠 status: AtSignStatus.teapot
@murali🛠 status: AtSignStatus.teapot
@naresh🛠 status: AtSignStatus.teapot
@purnima🛠 status: AtSignStatus.teapot
@sameeraja🛠 status: AtSignStatus.teapot
@sitaram🛠 status: AtSignStatus.teapot
````
In the "teapot" state the secondaries are ready to pair using the CRAM keys in the [demo data](https://github.com/atsign-foundation/at_demos/tree/master/at_demo_data)

As you use the @signs the at_client will create keys and place them on the secondary and "activate" them, and you will be asked to store the keyFile containing the privateKeys.

The suggested way to do that is using the [at_onboarding_flutter](https://pub.dev/packages/at_onboarding_flutter)
 package.
If you want to load the secondaries with known PKAM values then goto localhost:9001 and run the pkamLoad job. This will load each of the secondaries with PKAM publicKeys and your code can use know values from [demo data] (https://github.com/atsign-foundation/at_demos/tree/master/at_demo_data), to authenticate manually.

If you get stuck or lose keys you can restart the Virtual Environment and all the secondaries will be reset to a "teapot" status.

You can re-run this at_ve_doctor at anytime to see the individual status of all the secondaries. 
