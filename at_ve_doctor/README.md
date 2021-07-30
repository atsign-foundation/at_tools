# at_ve_doctor

at_ve_doctor is a simple utility than can check the state of the secondaries running in the 
virtual environment (VE) . 
The virtual environment provides the full @platform stack including a @root server and a number of 
preconfigured @signs.

Once the virtual environment is up and running the at_ve_doctor can be run and it will report back the 
state of each of the preconfigured @signs.

Before the @signs are paired with a device they will report as being in a "teapot" once paired and a 
pkam key is in place they will report as "activated".

Activation can be done via the onboarding widget or if you prefer to activate all the @signs 
with predefined pkam keys the pkamLoad script can be run on the supervisor Ui found at 
localhost:9001 when running the VE.

```
cconstab$ dart bin/at_ve_doctor.dart
@alice🛠 status: AtSignStatus.teapot
outbound finish handler called
@ashish🛠 status: AtSignStatus.teapot
outbound finish handler called
@barbara🛠 status: AtSignStatus.teapot
outbound finish handler called
@bob🛠 status: AtSignStatus.teapot
outbound finish handler called
@colin🛠 status: AtSignStatus.teapot
outbound finish handler called
@egbiometric🛠 status: AtSignStatus.teapot
outbound finish handler called
@egcovidlab🛠 status: AtSignStatus.teapot
outbound finish handler called
@egcreditbureau🛠 status: AtSignStatus.teapot
outbound finish handler called
@eggovagency🛠 status: AtSignStatus.teapot
outbound finish handler called
@emoji🦄🛠 status: AtSignStatus.teapot
outbound finish handler called
@eve🛠 status: AtSignStatus.teapot
outbound finish handler called
@jagan🛠 status: AtSignStatus.teapot
outbound finish handler called
@kevin🛠 status: AtSignStatus.teapot
outbound finish handler called
@murali🛠 status: AtSignStatus.teapot
outbound finish handler called
@naresh🛠 status: AtSignStatus.teapot
outbound finish handler called
@purnima🛠 status: AtSignStatus.teapot
outbound finish handler called
@sameeraja🛠 status: AtSignStatus.teapot
outbound finish handler called
@sitaram🛠 status: AtSignStatus.teapot
cconstab$
```

Once pkamLoad has been run
```
cconstab$ dart bin/at_ve_doctor.dart
@alice🛠 status: AtSignStatus.activated
outbound finish handler called
@ashish🛠 status: AtSignStatus.activated
outbound finish handler called
@barbara🛠 status: AtSignStatus.activated
outbound finish handler called
@bob🛠 status: AtSignStatus.activated
outbound finish handler called
@colin🛠 status: AtSignStatus.activated
outbound finish handler called
@egbiometric🛠 status: AtSignStatus.activated
outbound finish handler called
@egcovidlab🛠 status: AtSignStatus.activated
outbound finish handler called
@egcreditbureau🛠 status: AtSignStatus.activated
outbound finish handler called
@eggovagency🛠 status: AtSignStatus.activated
outbound finish handler called
@emoji🦄🛠 status: AtSignStatus.activated
outbound finish handler called
@eve🛠 status: AtSignStatus.activated
outbound finish handler called
@jagan🛠 status: AtSignStatus.activated
outbound finish handler called
@kevin🛠 status: AtSignStatus.activated
outbound finish handler called
@murali🛠 status: AtSignStatus.activated
outbound finish handler called
@naresh🛠 status: AtSignStatus.activated
outbound finish handler called
@purnima🛠 status: AtSignStatus.activated
outbound finish handler called
@sameeraja🛠 status: AtSignStatus.activated
outbound finish handler called
@sitaram🛠 status: AtSignStatus.activated
cconstab$
```
