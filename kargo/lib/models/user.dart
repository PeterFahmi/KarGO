class User {
  String? imagePath;
  String name;
  String email;
  List<dynamic> myAds;
  List<dynamic> myBids;

  User(
      {required this.name,
      required this.email,
      this.imagePath,
      required this.myAds,
      required this.myBids});
}
