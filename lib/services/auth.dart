import "package:meetoplay/global_variables.dart";
class AuthService {
  // creating a new account
  // check whether the user is sign in or not
  static Future<bool> isLoggedIn() async {
    var user = currentUser;
    return user != null;
  }
}
