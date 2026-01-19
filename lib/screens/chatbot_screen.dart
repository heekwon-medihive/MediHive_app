import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // 초기 AI 메시지 추가
    _messages.add(
      ChatMessage(
        text: '안녕하세요, 홍길동 님! 😊\n오늘 컨디션은 어떠신가요?\n위에서 궁금한 내용을 선택하거나\n직접 말씀해 주세요.',
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          time: DateTime.now(),
        ),
      );
    });

    _messageController.clear();

    // 스크롤을 맨 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // AI 응답 시뮬레이션
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _getAIResponse(text),
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  String _getAIResponse(String userMessage) {
    if (userMessage.contains('검사') || userMessage.contains('결과')) {
      return '📑 2024.01.13 검사 결과입니다.\n\n● 혈압: 120/80 (정상)\n● 혈당: 95 (정상)\n\n전반적으로 아주 건강한 상태예요!';
    } else if (userMessage.contains('복약') || userMessage.contains('약')) {
      return '💊 오늘의 복약 일정입니다.\n\n● 아침 8시: 혈압약\n● 점심 12시: 소화제\n● 저녁 6시: 비타민\n\n잊지 말고 드세요!';
    } else if (userMessage.contains('진료') || userMessage.contains('예약')) {
      return '📅 예약 가능한 일정입니다.\n\n● 1월 20일 (월) 오전 10시\n● 1월 21일 (화) 오후 2시\n● 1월 23일 (목) 오전 11시\n\n원하시는 일정을 선택해 주세요!';
    }
    return '네, 알겠습니다! 😊\n더 궁금하신 점이 있으시면\n언제든지 말씀해 주세요.';
  }

  void _handleQuickAction(String action) {
    String message = '';
    switch (action) {
      case '복약':
        message = '복약 안내';
        break;
      case '검사':
        message = '검사 결과';
        break;
      case '진료':
        message = '진료 예약';
        break;
    }
    _sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft Gray
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 채팅 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + 1, // +1 for quick action cards
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildQuickActionCards();
                }
                return _buildMessageBubble(_messages[index - 1]);
              },
            ),
          ),

          // 입력 영역
          _buildInputArea(),
        ],
      ),
    );
  }

  // 상단 앱바
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'MediHive AI 상담사',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
          onPressed: () {
            // 메뉴 옵션
          },
        ),
      ],
    );
  }

  // 퀵 액션 카드
  Widget _buildQuickActionCards() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionCard(
            icon: '💊',
            iconAsset: 'assets/icons/medicine-pill.png',
            label: '복약\n안내',
            onTap: () => _handleQuickAction('복약'),
          ),
          _buildQuickActionCard(
            icon: '📑',
            label: '검사\n결과',
            onTap: () => _handleQuickAction('검사'),
          ),
          _buildQuickActionCard(
            icon: '📅',
            iconAsset: 'assets/icons/calendar-appointment.png',
            label: '진료\n예약',
            onTap: () => _handleQuickAction('진료'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String icon,
    required String label,
    required VoidCallback onTap,
    String? iconAsset,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconAsset != null)
              Image.asset(
                iconAsset,
                width: 40,
                height: 40,
              )
            else
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 메시지 말풍선
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2D5AF0),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/icons/medihive_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF2D5AF0) // Medi-Blue for user
                        : Colors.white, // White for AI
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: message.isUser
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // 입력 영역
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: '질문을 입력하세요...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: _sendMessage,
                  onChanged: (text) {
                    setState(() {
                      // 텍스트 변경 시 UI 업데이트
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 전송 버튼
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2D5AF0), // Medi-Blue
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5AF0).withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  _sendMessage(_messageController.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? '오후' : '오전';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }
}

// 채팅 메시지 모델
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

