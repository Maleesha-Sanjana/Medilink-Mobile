import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/agora_service.dart';
import 'voice_call_screen.dart';

/// In-app chat between patient and EMT for a specific emergency request.
/// Messages are stored in Firestore:
///   emergency_requests/{requestId}/messages/{messageId}
class ChatScreen extends StatefulWidget {
  final String requestId;
  final String myName;
  final bool isEmt; // true = EMT side, false = patient side

  const ChatScreen({
    super.key,
    required this.requestId,
    required this.myName,
    required this.isEmt,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _agoraService = AgoraService();
  bool _callScreenShown = false;

  CollectionReference get _messages => FirebaseFirestore.instance
      .collection('emergency_requests')
      .doc(widget.requestId)
      .collection('messages');

  DocumentReference get _requestRef => FirebaseFirestore.instance
      .collection('emergency_requests')
      .doc(widget.requestId);

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    await _messages.add({
      'text': text,
      'senderUid': _uid,
      'senderName': widget.myName,
      'isEmt': widget.isEmt,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startCall(String otherName) async {
    // Write call state to Firestore — other party will see it and show incoming screen
    await _agoraService.initiateCall(
      requestId: widget.requestId,
      callerName: widget.myName,
      callerIsEmt: widget.isEmt,
    );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceCallScreen(
          requestId: widget.requestId,
          callerName: widget.myName,
          receiverName: otherName,
          isIncoming: false,
          isEmt: widget.isEmt,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: _requestRef.snapshots(),
      builder: (context, reqSnap) {
        final reqData = reqSnap.data?.data() as Map<String, dynamic>? ?? {};

        final otherName = widget.isEmt
            ? (reqData['patientName'] ?? 'Patient')
            : (reqData['emtName'] ?? 'EMT');

        // ── Access guard — only the matched patient & EMT can use this chat ──
        final patientUid = reqData['uid'] as String? ?? '';
        final emtUid = reqData['emtUid'] as String? ?? '';
        final isAuthorized = _uid == patientUid || _uid == emtUid;

        if (reqSnap.hasData && !isAuthorized) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D3A8C),
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You can only message the EMT assigned to your request.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Incoming call detection ───────────────────────────
        final callState = reqData['callState'] as String? ?? 'idle';
        final callInitiatedBy = reqData['callInitiatedBy'] as String? ?? '';
        final callerName = reqData['callerName'] as String? ?? '';
        final callerIsEmt = reqData['callerIsEmt'] as bool? ?? false;

        // Show incoming call screen if someone else is calling us
        if (callState == 'ringing' &&
            callInitiatedBy != _uid &&
            !_callScreenShown) {
          _callScreenShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => IncomingCallScreen(
                    requestId: widget.requestId,
                    callerName: callerName,
                    callerIsEmt: callerIsEmt,
                    myName: widget.myName,
                  ),
                ),
              ).then((_) => _callScreenShown = false);
            }
          });
        }
        if (callState != 'ringing') _callScreenShown = false;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2D3A8C),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.isEmt ? 'Patient' : 'Your EMT',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // In-app voice call button
              IconButton(
                icon: const Icon(Icons.call_rounded),
                tooltip: 'Voice Call',
                onPressed: () => _startCall(otherName),
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Messages list ───────────────────────────────
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messages
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No messages yet.\nSay hello!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Auto-scroll on new message
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollCtrl.hasClients) {
                        _scrollCtrl.animateTo(
                          _scrollCtrl.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        final isMine = d['senderUid'] == _uid;
                        final ts = d['createdAt'] as Timestamp?;
                        final time = ts != null ? _formatTime(ts.toDate()) : '';
                        return _MessageBubble(
                          text: d['text'] ?? '',
                          senderName: d['senderName'] ?? '',
                          isMine: isMine,
                          time: time,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                ),
              ),

              // ── Input bar ───────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  MediaQuery.of(context).padding.bottom + 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message…',
                          hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF0F0F0),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D3A8C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final String senderName;
  final bool isMine;
  final String time;
  final bool isDark;

  const _MessageBubble({
    required this.text,
    required this.senderName,
    required this.isMine,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF2D3A8C).withValues(alpha: 0.15),
              child: Text(
                senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3A8C),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine
                    ? const Color(0xFF2D3A8C)
                    : isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMine)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        senderName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3A8C),
                        ),
                      ),
                    ),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMine ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.white60 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 6),
        ],
      ),
    );
  }
}
