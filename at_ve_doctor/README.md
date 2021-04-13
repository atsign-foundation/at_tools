A very simple way to test the status of the secondaries running in the Virtual Environment.
 Using the [at_server_status](https://pub.dev/packages/at_server_status) package.

running at_ve_doctor.dart will run through the secondaries and report out the status of each of them.

The result as you start up the Virtual Environment should look like:- 

````
@alice🛠 status: AtSignStatus.activated
@ashish🛠 status: AtSignStatus.activated
@barbara🛠 status: AtSignStatus.activated
@bob🛠 status: AtSignStatus.activated
@colin🛠 status: AtSignStatus.activated
@egbiometric🛠 status: AtSignStatus.activated
@egcovidlab🛠 status: AtSignStatus.activated
@egcreditbureau🛠 status: AtSignStatus.activated
@eggovagency🛠 status: AtSignStatus.activated
@emoji🦄🛠 status: AtSignStatus.activated
@eve🛠 status: AtSignStatus.activated
@jagan🛠 status: AtSignStatus.activated
@kevin🛠 status: AtSignStatus.activated
@murali🛠 status: AtSignStatus.activated
@naresh🛠 status: AtSignStatus.activated
@purnima🛠 status: AtSignStatus.activated
@sameeraja🛠 status: AtSignStatus.activated
@sitaram🛠 status: AtSignStatus.activated
````

If all the secondaries are not activated the go to localhost:9001 and restart the pkamLoad process.
Then re-run at_ve_doctor to test again.

