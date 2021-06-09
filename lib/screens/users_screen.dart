import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lunad_dispatcher/data/models/user.dart';
import 'package:lunad_dispatcher/screens/bloc/user_bloc.dart';
import 'package:lunad_dispatcher/screens/user_info_screen.dart';
import 'package:lunad_dispatcher/widgets/filled_text_field.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: BlocProvider<UserBloc>(
        create: (context) => UserBloc()
          ..add(
            SearchUsers(
              searchTextController.text.trim(),
            ),
          ),
        child: Container(
          height: screenHeight,
          padding: EdgeInsets.all(8.0),
          width: double.infinity,
          child: Column(
            children: [
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return FilledTextField(
                    controller: searchTextController,
                    labelText: 'Search Consumers',
                    hintText: 'Enter consumer name...',
                    textInputType: TextInputType.text,
                    maxLines: 1,
                    onEditingComplete: () => _onSearchTapped(context),
                  );
                },
              ),
              SizedBox(height: 12.0),
              Expanded(
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is SearchedUsers) {
                      return buildSearchedUsers(context, state.users);
                    }
                    return buildLoading(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onSearchTapped(BuildContext context) {
    final query = searchTextController.text.trim();
    BlocProvider.of<UserBloc>(context).add(SearchUsers(query));
  }

  buildSearchedUsers(BuildContext context, List<User> users) {
    return ListView(
      children: users.map<Widget>((rider) {
        return buildUserItem(context, rider);
      }).toList(),
    );
  }

  buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  _onUserTapped(BuildContext context, String userId) {
    //user tapped
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          userId: userId,
        ),
      ),
    );
  }

  Card buildUserItem(BuildContext context, User user) {
    return Card(
      color: Colors.red.shade400,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    user.phoneNum,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: () => _onUserTapped(context, user.id),
            ),
          ],
        ),
      ),
    );
  }
}
