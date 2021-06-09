import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/data/models/user.dart';
import 'package:lunad_dispatcher/screens/booking_information_screen.dart';

import 'bloc/user_bloc.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;

  const UserInfoScreen({Key key, this.userId}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String _userId;

  @override
  void initState() {
    _userId = widget.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Consumer Details'),
      ),
      body: BlocProvider<UserBloc>(
        create: (context) => UserBloc()..add(LoadUserDetails(_userId)),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return Container(
              height: screenHeight,
              width: double.infinity,
              child: BlocListener<UserBloc, UserState>(
                listener: (context, state) {},
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is LoadedUserDetails) {
                      return buildLoadedUserDetails(
                          context, state.user, state.requests);
                    }

                    return buildLoading(context);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Center buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  Column buildLoadedUserDetails(
      BuildContext context, User user, List<ConsumerRequest> requests) {
    return Column(
      children: [
        buildUserHeader(user),
        buildRequests(requests),
      ],
    );
  }

  Expanded buildRequests(List<ConsumerRequest> requests) {
    var deliveryRequests = 0;
    var errandRequests = 0;
    var totalSpent = 0.0;
    ConsumerRequest currentRequest;

    if (requests.isNotEmpty) {
      for (var request in requests) {
        if (request.type == 'errand')
          errandRequests += 1;
        else
          deliveryRequests += 1;

        totalSpent += request.totalAmount;
      }

      currentRequest =
          requests.lastWhere((request) => request.status != 'complete');
    }

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Colors.red.shade400,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Total Spent',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '₱ ${totalSpent.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Colors.red.shade400,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Errands Requested',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          errandRequests.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Colors.red.shade400,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Deliveries Requested',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          deliveryRequests.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.0),
          Text(
            'Past Transasctions',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              color: Colors.red.shade400,
              child: requests.isNotEmpty
                  ? ListView(
                      children: requests.map((request) {
                        return GestureDetector(
                          onTap: () => _onRequestTapped(
                              context, request.id, request.type),
                          child: buildTransactionItem(request),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                        'User has no transactions yet',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.2,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  _onRequestTapped(BuildContext context, String requestId, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingInformationScreen(
          requestId: requestId,
          type: type,
        ),
      ),
    );
  }

  Card buildTransactionItem(ConsumerRequest request) {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.0),
                topRight: Radius.circular(3.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Text(
                DateFormat.yMMMMd().format(request.dateRequested.toDate()),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.userAlt,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.consumerName,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Customer',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.briefcase,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.type.toUpperCase(),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Type',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.receipt,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₱${(request.totalAmount).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Amount Paid',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.solidClock,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(request.totalDuration ?? 0 / 60).toStringAsFixed(2)} mins',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Total Duration',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildUserHeader(User user) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            '${user.displayName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            '${user.firstName} ${user.lastName}',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            user.phoneNum,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
