import re

with open("lib/screens/dashboards/emt_dashboard.dart", "r") as f:
    content = f.read()

target = """                Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Active Case: ${data['caseId'] ?? 'N/A'}\\n${data['status'] == 'transporting' ? 'To Hospital' : 'Patient: ${data['patientName'] ?? 'Patient'}'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),"""

replacement = """                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [const Color(0xFF1E2F26), const Color(0xFF141F18)] 
                        : [Colors.green.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black38 : Colors.green.withValues(alpha: 0.15),
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
                      color: isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade100,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(Icons.emergency_share_rounded, color: isDark ? Colors.green.shade400 : Colors.green.shade700, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ACTIVE EMERGENCY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.black26 : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                                      ),
                                      child: Text(
                                        'Case: ${data['caseId'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.green.shade300 : Colors.green.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  data['status'] == 'transporting' ? 'En route to Hospital' : 'Attending to Patient',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    letterSpacing: -0.5,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person_rounded, size: 14, color: isDark ? Colors.white60 : Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${data['patientName'] ?? 'Unknown Patient'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                      ),"""

if target in content:
    with open("lib/screens/dashboards/emt_dashboard.dart", "w") as f:
        f.write(content.replace(target, replacement))
    print("Replaced successfully")
else:
    print("Target not found")
