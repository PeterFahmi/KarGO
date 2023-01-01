class ChatUser{
  final String id;
  final String? name;
  final String? messageText;
  final String? imageUrl;
  final String? time;

  ChatUser({required this.id, this.name, required this.messageText, this.imageUrl, required this.time});
}