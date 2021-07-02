
class UsersData {
String email  ; 


  UsersData(this.email);
  toJson() {
    return {
      "email" : this.email,
    };
  }
}