
class RoomData {
List<dynamic> members  ; 
String roomName ; 


  RoomData(this.members , this.roomName );
  toJson() {
    return {
      "members" : this.members,
    };
  }
}