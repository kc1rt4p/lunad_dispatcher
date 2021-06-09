import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lunad_dispatcher/data/models/completed_request.dart';
import 'package:lunad_dispatcher/data/models/rider.dart';
import 'package:lunad_dispatcher/screens/bloc/rider_bloc.dart';
import 'package:lunad_dispatcher/screens/booking_information_screen.dart';
import 'package:lunad_dispatcher/widgets/history_item.dart';

class RiderInfoScreen extends StatefulWidget {
  final String riderId;
  const RiderInfoScreen({Key key, this.riderId}) : super(key: key);

  @override
  _RiderInfoScreenState createState() => _RiderInfoScreenState();
}

class _RiderInfoScreenState extends State<RiderInfoScreen> {
  String _riderId;
  DateTime _dateSelected = DateTime.now();

  @override
  void initState() {
    setState(() {
      _riderId = widget.riderId;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Rider Details'),
      ),
      body: BlocProvider<RiderBloc>(
        create: (context) =>
            RiderBloc()..add(LoadRiderDetails(_riderId, _dateSelected)),
        child: BlocBuilder<RiderBloc, RiderState>(
          builder: (context, state) {
            return Container(
              height: screenHeight,
              width: double.infinity,
              child: BlocListener<RiderBloc, RiderState>(
                listener: (context, state) {},
                child: BlocBuilder<RiderBloc, RiderState>(
                  builder: (context, state) {
                    if (state is LoadedRiderDetails) {
                      return buildLoadedRiderDetails(
                          context, state.rider, state.completedRequests);
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

  buildLoadedRiderDetails(BuildContext context, Rider rider,
      List<CompletedRequest> completedRequests) {
    var dispatcherFee = 0.0;
    var totalEarned = 0.0;
    var distanceTravelled = 0.0;
    var errandJobs = 0;
    var deliveryJobs = 0;
    var totalJobs = 0;

    for (var cRequest in completedRequests) {
      dispatcherFee += cRequest.dispatcherAmount;
      totalEarned += cRequest.amountCollected;
      distanceTravelled += cRequest.totalDistance;
      totalJobs += 1;
      if (cRequest.type == 'errand')
        errandJobs += 1;
      else
        deliveryJobs += 1;
    }

    return Column(
      children: [
        buildRiderHeader(rider),
        buildSelectDate(context),
        SizedBox(height: 5.0),
        Container(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildInfoItem('Dispatcher Fee',
                        '₱ ${dispatcherFee.toStringAsFixed(2)}'),
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: buildInfoItem(
                        'Total Earned', '₱ ${totalEarned.toStringAsFixed(2)}'),
                  ),
                  SizedBox(width: 5.0),
                  Expanded(
                    child: buildInfoItem('Distance Travelled',
                        '${distanceTravelled.toStringAsFixed(2)} km'),
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: buildInfoItem('Errand Jobs', '$errandJobs'),
                  ),
                  SizedBox(width: 5.0),
                  Expanded(
                    child: buildInfoItem('Delivery Jobs', '$deliveryJobs'),
                  ),
                ],
              ),
              SizedBox(height: 5.0),
              Row(
                children: [
                  Expanded(
                    child: buildInfoItem('Completed Jobs', '$totalJobs'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: Text(
            'Completed Requests for ${DateFormat.yMMMMd().format(_dateSelected)}',
          ),
        ),
        Expanded(
          child: completedRequests.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: completedRequests
                            .map((request) => GestureDetector(
                                  onTap: () =>
                                      _onRequestTapped(context, request),
                                  child: buildHistoryItem(request,
                                      Colors.red.shade400, Colors.white, false),
                                ))
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Tap on a request to view details',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'Rider has no completed requests',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  _onRequestTapped(BuildContext context, CompletedRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingInformationScreen(
          requestId: request.requestId,
          type: request.type,
        ),
      ),
    );
  }

  Container buildRiderHeader(Rider rider) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            '${rider.displayName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            '${rider.firstName} ${rider.lastName}',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            rider.phoneNum,
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

  Container buildSelectDate(BuildContext context) {
    return Container(
      color: Colors.red.shade400,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                DateFormat.yMMMMd().format(
                  _dateSelected,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.chevronDown,
              size: 18.0,
              color: Colors.white,
            ),
            onPressed: () => _onSelectDate(context),
          ),
        ],
      ),
    );
  }

  Container buildInfoItem(String label, String value) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.red.shade400,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _onSelectDate(context) async {
    await DatePicker.showDatePicker(context, showTitleActions: false,
        onChanged: (date) {
      if (date != _dateSelected) {
        setState(() {
          _dateSelected = date;
        });
        BlocProvider.of<RiderBloc>(context)
            .add(LoadRiderDetails(_riderId, _dateSelected));
      }
    });

    print('date selecgted');
  }

  buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.red.shade600,
      ),
    );
  }
}
