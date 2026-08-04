import re

with open("lib/screens/dashboards/patient_dashboard.dart", "r") as f:
    content = f.read()

# We want to replace the `body: SafeArea(...)` part
# We will just do a regex replace to insert the StreamBuilder

target = """      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Welcome text ──────────────────────────────────"""

replacement = """      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('emergency_requests')
              .where('uid', isEqualTo: user?.uid)
              .where('status', whereIn: ['pending', 'assigned', 'accepted', 'transporting', 'arrived', 'admin_call'])
              .snapshots(),
          builder: (context, snapshot) {
            final hasActiveCase = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
            final activeCaseDoc = hasActiveCase ? snapshot.data!.docs.first : null;
            final activeCaseData = activeCaseDoc?.data() as Map<String, dynamic>?;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  if (hasActiveCase) ...[
                    GestureDetector(
                      onTap: () {
                        // Navigate to tracking screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmergencyScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [const Color(0xFF1E2F26), const Color(0xFF141F18)] 
                              : [Colors.red.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : Colors.red.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade100,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.emergency_share_rounded, color: isDark ? Colors.red.shade400 : Colors.red.shade700, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACTIVE EMERGENCY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.red.shade400 : Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeCaseData?['status'] == 'transporting' ? 'Ambulance is arriving' : 'Waiting for ambulance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: -0.5,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to track your request',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white54 : Colors.grey.shade500, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Welcome text ──────────────────────────────────"""

if target in content:
    with open("lib/screens/dashboards/patient_dashboard.dart", "w") as f:
        f.write(content.replace(target, replacement))
    print("Replaced successfully")
else:
    print("Target not found")
