

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../models/user/data_model/user_model.dart';



class UserProvider extends ChangeNotifier {

  List<UserModel> _usersList = [];

  List<UserModel> get usersList => _usersList;

  bool _usersLoading = false, _hasMoreUsers = false;

  DocumentSnapshot<Map<String, dynamic>>? _lastdocument;

  void setUsersList(List<UserModel> value,{bool isNotify = true}) {
    _usersList.clear();
    _usersList = value;
    if(isNotify) {
      notifyListeners();
    }
  }

  void updateTestListSingleElement(UserModel usersFeedModel,int index,{bool isNotify = true}) {

    if(index < _usersList.length){
      _usersList[index] = usersFeedModel;
    }

    if(isNotify) {
      notifyListeners();
    }
  }

  void addAllUsersList(List<UserModel> value,{bool isNotify = true}) {
    _usersList.addAll(value);
    if(isNotify) {
      notifyListeners();
    }
  }

  int get usersListLength => _usersList.length;

  bool get getHasMoreUsers => _hasMoreUsers;
  set setHasMoreUsers(bool hasMoreUser) => _hasMoreUsers = hasMoreUser;

  DocumentSnapshot<Map<String, dynamic>>? get getLastDocument => _lastdocument;
  set setLastDocument(DocumentSnapshot<Map<String, dynamic>>? documentSnapshot) => _lastdocument = documentSnapshot;


  void addUsersModelInTestList(UserModel value,{bool isNotify = true}) {
    _usersList.add(value);
    if(isNotify) {
      notifyListeners();
    }
  }

  bool get getIsUsersLoading => _usersLoading;
  void setIsUsersLoading(bool isUserLoading, {bool isNotify = true}) {
    _usersLoading = isUserLoading;
    if(isNotify) {
      notifyListeners();
    }
  }

  void updateUsersListSingleElement(UserModel userModel,int index,{bool isNotify = true}) {

    if(index < _usersList.length){
      _usersList[index] = userModel;
    }

    if(isNotify) {
      notifyListeners();
    }
  }


  void removeUsersFromList(int index,{bool isNotify = true}) {
    _usersList.removeAt(index);
    if(isNotify) {
      notifyListeners();
    }
  }

  // void updateEnableDisableOfList(bool value,int index,{bool isNotify = true}) {
  //   if(index < _usersList.length){
  //     _usersList[index].adminEnabled = value;
  //   }
  //
  //   if(isNotify) {
  //     notifyListeners();
  //   }
  // }


}