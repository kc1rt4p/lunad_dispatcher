import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lunad_dispatcher/data/models/consumer_request.dart';
import 'package:lunad_dispatcher/screens/bloc/request_bloc.dart';
import 'package:lunad_dispatcher/screens/booking_information_screen.dart';
import 'package:lunad_dispatcher/widgets/request_item.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key key}) : super(key: key);

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Consumer Requests'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: BlocProvider<RequestBloc>(
        create: (context) => RequestBloc()..add(GetAllRequests()),
        child: Container(
          padding: EdgeInsets.all(8.0),
          height: screenHeight,
          width: double.infinity,
          child: BlocBuilder<RequestBloc, RequestState>(
            builder: (context, state) {
              if (state is LoadedAllRequests) {
                return buildLoadedAllRequests(context, state.requests);
              }
              return buildLoading(context);
            },
          ),
        ),
      ),
    );
  }

  buildLoadedAllRequests(BuildContext context, List<ConsumerRequest> requests) {
    return requests.isNotEmpty
        ? ListView(
            children: requests.map((request) {
              return GestureDetector(
                onTap: () => onRequestTapped(context, request.id, request.type),
                child: buildRequestItem(request),
              );
            }).toList(),
          )
        : Center(
            child: Text(
              'No requests found',
              style: TextStyle(
                color: Colors.red.shade600,
                letterSpacing: 1.2,
                fontSize: 18.0,
              ),
            ),
          );
  }

  onRequestTapped(BuildContext context, String requestId, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BookingInformationScreen(
                requestId: requestId,
                type: type,
              )),
    );
  }

  buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.red.shade600,
      ),
    );
  }
}
