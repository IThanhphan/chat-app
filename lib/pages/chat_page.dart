import 'dart:convert';
import 'dart:io';
import 'package:chat_app/components/custom_avatar.dart';
import 'package:chat_app/helper/utils/convert_image_to_base64.dart';
import 'package:chat_app/pages/receiver_info_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/components/emoji_picker_sheet.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/theme_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> receiver;

  const ChatPage({required this.receiver, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  int _prevMessageCount = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiver['uid'],
        _messageController.text,
        isImage: false,
      );
      _messageController.clear();

      _scrollToBottom();
    }
  }

  Future<void> _sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final base64Image = await convertImageToBase64(imageFile);

      if (base64Image != null) {
        await _chatService.sendMessage(
          widget.receiver['uid'],
          base64Image,
          isImage: true,
        );

        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return Scaffold(
          backgroundColor: dark ? Colors.black : Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0099FF),
            title: Row(
              children: [
                Stack(
                  children: [
                    CustomAvatar(
                      imageBase64: widget.receiver['avatar'] ?? "",
                      radius: 16,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receiver['username'] ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đang hoạt động',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ReceiverInfoPage(receiver: widget.receiver),
                    ),
                  );
                  // xử lý mở info
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(child: _messageList(dark)),
              _messageInput(dark),
            ],
          ),
        );
      },
    );
  }

  Widget _messageList(dark) {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiver['uid'], senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error');
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Text('Loading...');

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không có tin nhắn'));
        }

        final messages = snapshot.data!.docs;

        // So sánh số lượng tin nhắn để scroll
        if (messages.length != _prevMessageCount) {
          _prevMessageCount = messages.length;
          _scrollToBottom();
        }

        return ListView(
          controller: _scrollController,
          children: messages.map((doc) => _messageItem(doc, dark)).toList(),
        );
      },
    );
  }

  Widget _messageItem(DocumentSnapshot doc, bool dark) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    String messageID = doc.id;

    final timestamp = data['timestamp'] as Timestamp;
    final timeString = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(timestamp.toDate());

    if (isCurrentUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onLongPress: () {
                _showMessageOptions(context, messageID);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB0DAFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    data['isImage'] == true
                        ? Image.memory(
                          base64Decode(data['message']),
                          width: 200,
                        )
                        : Text(
                          data['message'],
                          style: TextStyle(color: Colors.black),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 4),
              child: Text(
                timeString,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomAvatar(
                imageBase64: widget.receiver['avatar'] ?? "",
                radius: 14,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dark ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      data['isImage'] == true
                          ? Image.memory(
                            base64Decode(data['message']),
                            width: 200,
                          )
                          : Text(data['message']),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Text(
                    timeString,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _messageInput(dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: dark ? Colors.grey[900] : Colors.grey[100],
      child: Row(
        children: [
          GestureDetector(
            onTap: _sendImageMessage,
            child: Icon(Icons.image, color: dark ? Colors.white : Colors.grey),
          ),
          const SizedBox(width: 10),
          // Ô nhập có icon emoji bên trong
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: dark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: dark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Nhắn tin',
                  hintStyle: TextStyle(
                    color: dark ? Colors.grey[400] : Colors.grey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 24),
                    color: Colors.grey[400],
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            (context) => EmojiPickerSheet(
                              dark: dark,
                              onSelect: (emoji) {
                                setState(() {
                                  _messageController.text += emoji;
                                  _messageController
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _messageController.text.length,
                                    ),
                                  );
                                });
                              },
                            ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              Icons.send,
              color: dark ? Colors.blue[200] : Colors.blue,
            ),
            onPressed: _sendMessage,
          ),
          IconButton(
            icon: Icon(
              Icons.thumb_up_alt_outlined,
              color: dark ? Colors.white : Colors.grey,
            ),
            onPressed: () async {
              await _chatService.sendMessage(widget.receiver['uid'], "👍");

              // Scroll xuống cuối sau khi gửi
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, String messageID) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.undo),
                title: const Text('Thu hồi tin nhắn'),
                onTap: () async {
                  String userID = _authService.getCurrentUser()!.uid;
                  await _chatService.deleteMessage(
                    userID,
                    widget.receiver['uid'],
                    messageID,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Hủy'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
