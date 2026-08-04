import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/agora_service.dart';

/// Full-screen in-app voice call screen powered by Agora.
/// No real phone numbers — users are identified by Firebase UID.
class VoiceCallScreen extends StatefulWidget {
  final String requestId; // used as Agora channel name
  final String callerName; // name of the person who initiated
  final String receiverName;
  final bool isIncoming; // true = receiving end, false = caller
  final bool isEmt;

  const VoiceCallScreen({
    super.key,
    required this.requestId,
    required this.callerName,
    required this.receiverName,
    required this.isIncoming,
    required this.isEmt,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  final _agora = AgoraService();
  RtcEngine? _engine;

  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = false;
  bool _remoteJoined = false;
  int _callSeconds = 0;
  Timer? _timer;
  StreamSubscription? _callStateSub;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _listenCallState();
  }

  Future<void> _initAgora() async {
    // Verify this user belongs to the request before joining
    try {
      final doc = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(widget.requestId)
          .get();
      final data = doc.data() ?? {};
      final patientUid = data['uid'] as String? ?? '';
      final emtUid = data['emtUid'] as String? ?? '';
      final isAdminCall = data['isAdminCall'] == true;
      final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (myUid != patientUid && myUid != emtUid && !isAdminCall) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Request microphone permission
    await Permission.microphone.request();

    // Create engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: AgoraService.appId));

    // Set audio profile
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    // Enable speaker by default for emergency calls
    try {
      await _engine!.setEnableSpeakerphone(true);
      setState(() => _speakerOn = true);
    } catch (_) {}

    // Register event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => _joined = true);
          _startTimer();
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() => _remoteJoined = true);
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() => _remoteJoined = false);
          // Other party left — end call
          _endCall();
        },
        onLeaveChannel: (connection, stats) {
          setState(() => _joined = false);
        },
      ),
    );

    // Join the channel — use fixed 'test' channel with temp token during development
    await _engine!.joinChannel(
      token: AgoraService.token,
      channelId: AgoraService.testChannel,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void _listenCallState() {
    _callStateSub = _agora.callStateStream(widget.requestId).listen((state) {
      final callState = state['callState'] as String;
      if (callState == 'ended' && mounted) {
        _leaveAndPop();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callSeconds++);
    });
  }

  String get _durationLabel {
    final m = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    await _engine?.muteLocalAudioStream(_muted);
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _speakerOn = !_speakerOn);
    await _engine?.setEnableSpeakerphone(_speakerOn);
  }

  Future<void> _endCall() async {
    await _agora.endCall(widget.requestId);
    _leaveAndPop();
  }

  bool _isLeaving = false;

  Future<void> _leaveAndPop() async {
    if (_isLeaving) return;
    _isLeaving = true;
    _timer?.cancel();
    _callStateSub?.cancel();
    
    if (mounted) {
      Navigator.of(context).pop();
    }

    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    _engine = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _callStateSub?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherName = widget.isIncoming
        ? widget.callerName
        : widget.receiverName;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // ── Status label ──────────────────────────────────
            Text(
              _joined && _remoteJoined
                  ? _durationLabel
                  : _joined
                  ? 'Waiting for other party…'
                  : 'Connecting…',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            // ── Avatar ────────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2D3A8C),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3A8C).withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Name ──────────────────────────────────────────
            Text(
              otherName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.isEmt ? 'Patient' : 'Your EMT',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),

            // ── Live indicator ────────────────────────────────
            if (_joined && _remoteJoined) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Connected',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 13),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // ── Controls ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute
                  _CallControl(
                    icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _muted ? 'Unmute' : 'Mute',
                    color: _muted
                        ? Colors.red.shade400
                        : Colors.white.withValues(alpha: 0.15),
                    onTap: _toggleMute,
                  ),

                  // End call
                  _CallControl(
                    icon: Icons.call_end_rounded,
                    label: 'End',
                    color: Colors.red,
                    size: 72,
                    onTap: _endCall,
                  ),

                  // Speaker
                  _CallControl(
                    icon: _speakerOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    label: _speakerOn ? 'Speaker' : 'Earpiece',
                    color: _speakerOn
                        ? const Color(0xFF2D3A8C)
                        : Colors.white.withValues(alpha: 0.15),
                    onTap: _toggleSpeaker,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ── Incoming call screen ──────────────────────────────────────────────────────

class IncomingCallScreen extends StatelessWidget {
  final String requestId;
  final String callerName;
  final bool callerIsEmt;
  final String myName;

  const IncomingCallScreen({
    super.key,
    required this.requestId,
    required this.callerName,
    required this.callerIsEmt,
    required this.myName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            Text(
              'Incoming Call',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2D3A8C),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3A8C).withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              callerIsEmt ? 'EMT' : 'Patient',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),

            const Spacer(),

            // Accept / Decline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  _CallControl(
                    icon: Icons.call_end_rounded,
                    label: 'Decline',
                    color: Colors.red,
                    size: 68,
                    onTap: () {
                      AgoraService().endCall(requestId); // Fire and forget
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),

                  // Accept
                  _CallControl(
                    icon: Icons.call_rounded,
                    label: 'Accept',
                    color: Colors.green,
                    size: 68,
                    onTap: () {
                      AgoraService().acceptCall(requestId); // Fire and forget for instant UI response
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => VoiceCallScreen(
                              requestId: requestId,
                              callerName: callerName,
                              receiverName: myName,
                              isIncoming: true,
                              isEmt: !callerIsEmt,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// ── Call control button ───────────────────────────────────────────────────────

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: size * 0.45),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
