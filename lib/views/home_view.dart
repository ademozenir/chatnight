import 'package:chatnight/api/apis.dart';
import 'package:chatnight/main.dart';
import 'package:chatnight/models/chat_user.dart';
import 'package:chatnight/widget/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  final bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text("Chat Night"),
        actions: [
          //search user button
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

          //more features button
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
      ),

      //floating button to add new user
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Icon(Icons.add_comment_rounded)),
      ),

      body: StreamBuilder(
        stream: APIs.getMyUsersId(),

        //get id of only known users
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
          //if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

          //if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              return StreamBuilder(
                stream: APIs.getAllUsers(
                    snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                //get only those user, who's ids are provided
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                  //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                    // return const Center(
                    //     child: CircularProgressIndicator());

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list = data
                          ?.map((e) => ChatUser.fromJson(e.data()))
                          .toList() ??
                          [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _isSearching
                                ? _searchList.length
                                : _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index]);
                            });
                      } else {
                        return const Center(
                          child: Text('No Connections Found!',
                              style: TextStyle(fontSize: 20)),
                        );
                      }
                  }
                },
              );
          }
        },
      ),
    );

  }
}
