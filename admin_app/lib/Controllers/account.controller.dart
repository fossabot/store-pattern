import 'dart:convert';
import 'dart:io';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:image_picker/image_picker.dart';

import './../Models/account.model.dart';

class Controller {
  static Controller _instance;

  static Controller get instance {
    if (_instance == null) _instance = new Controller();
    return _instance;
  }

  Future<List<Account>> _accounts;

  Future<List<Account>> get listAccount {
    if (_accounts == null) _accounts = Model.instance.getAccounts();
    return _accounts;
  }

  Future<bool> insertAcc(String username, String password, String displayName, int sex, String idCard,
      String address, String phoneNumber, DateTime birthday, int idAccountType, String image) {
    return Model.instance.insertAcc(username, new DBCrypt().hashpw(password, new DBCrypt().gensalt()),
        displayName, sex, idCard, address, phoneNumber, birthday, idAccountType, image);
  }

  Future<bool> updateAcc(String username, String displayName, int sex, String idCard, String address,
      String phoneNumber, DateTime birthday, int idAccountType, String image) {
    return Model.instance
        .updateAcc(username, displayName, sex, idCard, address, phoneNumber, birthday, idAccountType, image);
  }

  Future<bool> deleteAcc(String username) {
    return Model.instance.deleteAcc(username);
  }

  Future<bool> isAccExists(String username) {
    return Model.instance.isAccExists(username);
  }

  Future<bool> resetAcc(String username, String defaultPass) {
    return Model.instance.resetAcc(username, new DBCrypt().hashpw(username, new DBCrypt().gensalt()));
  }

  Future<bool> isUsernameExists(String username) async {
    List<Account> accounts = await listAccount;
    for (var account in accounts) {
      if (account.username == username) return true;
    }
    return false;
  }

  Future<List<Account>> searchAccs(String keyword) async {
    List<Account> items = await listAccount;
    if (keyword.trim() == '') return items;
    return items.where((item) => item.username.toUpperCase().indexOf(keyword.toUpperCase()) != -1).toList();
  }

  Future<File> getImage() async {
    return await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void insertAccountToLocal(String username, String displayName, int sex, String idCard, String address,
      String phoneNumber, DateTime birthday, int idAccountType, String image) async {
    Account acc = new Account(username, displayName, sex, idCard, address, phoneNumber, birthday,
        idAccountType, base64.decode(image));
    (await listAccount).add(acc);
  }

  void updateAccountToLocal(String username, String displayName, int sex, String idCard, String address,
      String phoneNumber, DateTime birthday, int idAccountType, String image) async {
    int index = await findIndex(username);
    (await listAccount)[index].displayName = displayName;
    (await listAccount)[index].sex = sex;
    (await listAccount)[index].idCard = idCard;
    (await listAccount)[index].address = address;
    (await listAccount)[index].phone = phoneNumber;
    (await listAccount)[index].birthday = birthday;
    (await listAccount)[index].idAccountType = idAccountType;
    (await listAccount)[index].image = base64.decode(image);
  }

  void deleteAccountToLocal(String username) async {
    int index = await findIndex(username);
    (await listAccount).removeAt(index);
  }

  Future<int> findIndex(String username) async {
    for (var i = 0; i < (await listAccount).length; i++) {
      if ((await listAccount)[i].username == username) return i;
    }
    return -1;
  }
}
