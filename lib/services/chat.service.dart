import 'package:firestore_chat/models/chat_entity.dart';
import 'package:chaskiy/requests/chat.request.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ChatService {
  //
  static sendChatMessage(String message, ChatEntity chatEntity) async {
    //notify the involved party
    final otherPeerKey = chatEntity.peers.keys.firstWhere(
      (peerKey) => chatEntity.mainUser.id != peerKey,
    );
    //
    final otherPeer = chatEntity.peers[otherPeerKey];
    await ChatRequest().sendNotification(
      title: "Nuevo mensaje de".tr() + " ${chatEntity.mainUser.name}",
      body: message,
      topic: otherPeer!.id,
      path: chatEntity.path,
      user: chatEntity.mainUser,
      otherUser: otherPeer,
    );
  }
}
