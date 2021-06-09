import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lunad_dispatcher/data/models/user.dart';
import 'package:lunad_dispatcher/widgets/filled_text_field.dart';
import 'package:lunad_dispatcher/screens/bloc/login_bloc.dart';

class RiderAddScreen extends StatefulWidget {
  const RiderAddScreen({Key key}) : super(key: key);

  @override
  _RiderAddScreenState createState() => _RiderAddScreenState();
}

class _RiderAddScreenState extends State<RiderAddScreen> {
  TextEditingController phoneNumberTextController = TextEditingController();
  TextEditingController verificationCodeTextController =
      TextEditingController();
  TextEditingController firstNameTextController = TextEditingController();
  TextEditingController lastNameTextController = TextEditingController();
  TextEditingController displayNameTextController = TextEditingController();

  var _currentStep = 0;
  User _newUser;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final steps = [
      buildInputPhoneNumber(),
      buildVerifyPhoneNumber(),
      buildRiderDetails(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('NEW RIDER'),
      ),
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(),
        child: Container(
          height: screenHeight,
          width: double.infinity,
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is CodeSentState) {
                _currentStep += 1;
              }

              if (state is RiderCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'New rider added',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    backgroundColor: Colors.white,
                  ),
                );

                Navigator.pop(context);
              }

              if (state is PhoneNumberExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Phone number already exists',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
              }

              if (state is CreateUserError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error creating rider',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    backgroundColor: Colors.white,
                  ),
                );

                setState(() {
                  _currentStep = 0;
                });
              }

              if (state is VerifyingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invalid verification code',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    backgroundColor: Colors.white,
                  ),
                );
              }

              if (state is PhoneVerified) {
                _currentStep += 1;
                _newUser = state.user;
              }
            },
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return Stepper(
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    setState(() {
                      _currentStep = step;
                    });
                  },
                  onStepContinue: () => onStepContinue(context, steps.length),
                  onStepCancel: () {
                    setState(() {
                      if (_currentStep > 0) {
                        _currentStep = _currentStep - 1;
                      } else {
                        _currentStep = 0;
                        Navigator.pop(context);
                      }
                    });
                  },
                  steps: steps,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  onStepContinue(BuildContext context, int stepsCount) {
    if (_currentStep == 0) {
      //verify phone number
      final phoneNumber = phoneNumberTextController.text.trim();
      if (phoneNumber.isEmpty) return;
      BlocProvider.of<LoginBloc>(context).add(
        SendCode(phoneNumber),
      );
    }

    if (_currentStep == 1) {
      //send sms code
      final smsCode = verificationCodeTextController.text.trim();
      if (smsCode.isEmpty) return;
      BlocProvider.of<LoginBloc>(context).add(
        VerifyPhoneNumber(smsCode, 'rider'),
      );
    }

    if (_currentStep == 2) {
      final firstName = firstNameTextController.text.trim();
      final lastName = lastNameTextController.text.trim();
      final displayName = displayNameTextController.text.trim();

      var userMap = _newUser.toMap();
      userMap.addAll({
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
      });

      var user = User(
        id: _newUser.id,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName,
        phoneNum: _newUser.phoneNum,
      );

      BlocProvider.of<LoginBloc>(context).add(CreateRider(user));
    }
  }

  Step buildInputPhoneNumber() {
    return Step(
      isActive: _currentStep == 0,
      title: Text('Phone Number'),
      subtitle: Text('Ask rider for his phone number'),
      content: Container(
        padding: EdgeInsets.all(8.0),
        child: FilledTextField(
          controller: phoneNumberTextController,
          isPhone: true,
          textInputType: TextInputType.phone,
          validator: (val) {
            if (val.isNotEmpty) {
              if (val.length != 10) {
                return 'Enter valid phone number';
              }
            }

            return null;
          },
        ),
      ),
    );
  }

  Step buildVerifyPhoneNumber() {
    return Step(
      isActive: _currentStep == 1,
      title: Text('Verification Code'),
      subtitle: Text('Get verification code sent to rider'),
      content: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: FilledTextField(
                controller: verificationCodeTextController,
                textInputType: TextInputType.number,
                hintText: 'Enter 6-digit code',
                validator: (val) {
                  if (val.isNotEmpty) {
                    if (val.length != 6) {
                      return 'Enter verification code';
                    }
                  }

                  return null;
                },
              ),
            ),
            IconButton(
              tooltip: 'Resend Code',
              onPressed: () {},
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Step buildRiderDetails() {
    return Step(
      isActive: _currentStep == 2,
      title: Text('Rider Information'),
      subtitle: Text('Enter rider name'),
      content: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            FilledTextField(
              controller: displayNameTextController,
              textInputType: TextInputType.text,
              hintText: 'Display Name',
              maxLines: 1,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Enter display name';
                }

                return null;
              },
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: FilledTextField(
                    controller: firstNameTextController,
                    textInputType: TextInputType.text,
                    hintText: 'First Name',
                    maxLines: 1,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter first name';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(width: 5.0),
                Expanded(
                  child: FilledTextField(
                    controller: lastNameTextController,
                    textInputType: TextInputType.text,
                    hintText: 'Last Name',
                    maxLines: 1,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter last name';
                      }

                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
