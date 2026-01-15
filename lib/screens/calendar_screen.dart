import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/health_event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _localeInitialized = false;
  
  // 샘플 이벤트 데이터
  final Map<DateTime, List<HealthEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeLocale();
    _loadSampleEvents();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('ko_KR', null);
    setState(() {
      _localeInitialized = true;
    });
  }

  void _loadSampleEvents() {
    // 샘플 데이터 생성
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    
    _events[normalizedToday] = [
      HealthEvent(
        date: normalizedToday,
        title: '혈당 측정',
        type: EventType.vital,
        data: {'value': '120mg/dL', 'status': '정상 범위입니다.'},
        time: const TimeOfDay(hour: 8, minute: 30),
      ),
      HealthEvent(
        date: normalizedToday,
        title: '아침 약 복용',
        type: EventType.medication,
        data: {'medication': '메트포르민 500mg'},
        time: const TimeOfDay(hour: 9, minute: 0),
      ),
    ];

    final tomorrow = normalizedToday.add(const Duration(days: 1));
    _events[tomorrow] = [
      HealthEvent(
        date: tomorrow,
        title: '내과 진료',
        type: EventType.hospital,
        data: {
          'hospital': '서울대학교병원',
          'department': '내분비내과',
          'note': '검사 전 8시간 금식 필요'
        },
        time: const TimeOfDay(hour: 14, minute: 30),
      ),
    ];

    final nextWeek = normalizedToday.add(const Duration(days: 7));
    _events[nextWeek] = [
      HealthEvent(
        date: nextWeek,
        title: '두통 증상',
        type: EventType.symptom,
        data: {'severity': '중간', 'note': '오후부터 두통 시작'},
        time: const TimeOfDay(hour: 15, minute: 0),
      ),
    ];
  }

  List<HealthEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2C4A8C),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Column(
                children: [
                  _buildCalendar(),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildDailyAgenda(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            '건강 캘린더',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.today, color: Color(0xFF2C4A8C)),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        locale: 'ko_KR',
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF2C4A8C)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF2C4A8C)),
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Colors.red),
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF2C4A8C),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF2C4A8C).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildDailyAgenda() {
    final selectedEvents = _selectedDay != null 
        ? _getEventsForDay(_selectedDay!)
        : [];

    if (selectedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '이 날짜에는 기록이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+ 버튼을 눌러 일정을 추가해보세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(HealthEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: event.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showEventDetail(event);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  event.icon,
                  color: event.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (event.formattedTime != null) ...[
                          Text(
                            event.formattedTime!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._buildEventDetails(event),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventDetails(HealthEvent event) {
    List<Widget> widgets = [];

    switch (event.type) {
      case EventType.hospital:
        if (event.data['hospital'] != null) {
          widgets.add(_buildDetailRow(
            Icons.location_on_outlined,
            event.data['hospital'],
          ));
        }
        if (event.data['doctor'] != null) {
          widgets.add(_buildDetailRow(
            Icons.person_outline,
            event.data['doctor'],
          ));
        }
        if (event.data['department'] != null) {
          widgets.add(_buildDetailRow(
            Icons.medical_services_outlined,
            event.data['department'],
          ));
        }
        if (event.data['note'] != null) {
          widgets.add(_buildDetailRow(
            Icons.info_outline,
            event.data['note'],
            color: Colors.orange,
          ));
        }
        break;

      case EventType.vital:
        if (event.data['bloodPressure'] != null) {
          widgets.add(_buildDetailRow(
            Icons.favorite_outline,
            '혈압: ${event.data['bloodPressure']}',
          ));
        }
        if (event.data['bloodSugar'] != null) {
          widgets.add(_buildDetailRow(
            Icons.water_drop_outlined,
            '혈당: ${event.data['bloodSugar']}',
          ));
        }
        if (event.data['value'] != null) {
          widgets.add(_buildDetailRow(
            Icons.show_chart,
            event.data['value'],
          ));
        }
        if (event.data['status'] != null) {
          widgets.add(_buildDetailRow(
            Icons.check_circle_outline,
            event.data['status'],
            color: const Color(0xFF4CAF50),
          ));
        }
        break;

      case EventType.symptom:
        if (event.data['symptom'] != null) {
          widgets.add(_buildDetailRow(
            Icons.note_outlined,
            event.data['symptom'],
          ));
        }
        if (event.data['severity'] != null) {
          widgets.add(_buildDetailRow(
            Icons.trending_up,
            '증상 강도: ${event.data['severity']}',
          ));
        }
        if (event.data['note'] != null) {
          widgets.add(_buildDetailRow(
            Icons.note_outlined,
            event.data['note'],
          ));
        }
        break;

      case EventType.medication:
        if (event.data['times'] != null) {
          widgets.add(_buildDetailRow(
            Icons.access_time,
            event.data['times'],
          ));
        }
        if (event.data['medication'] != null) {
          widgets.add(_buildDetailRow(
            Icons.medication_outlined,
            event.data['medication'],
          ));
        }
        break;
    }

    return widgets;
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: color ?? Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _showAddEventMenu,
      backgroundColor: const Color(0xFF2C4A8C),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showAddEventMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '추가할 기록 유형을 선택하세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuOption(
                icon: Icons.local_hospital,
                title: '병원 일정',
                subtitle: '진료 및 검사 예약',
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEventDialog(EventType.hospital);
                },
              ),
              _buildMenuOption(
                icon: Icons.favorite,
                title: '생체 수치',
                subtitle: '혈당, 혈압 등',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEventDialog(EventType.vital);
                },
              ),
              _buildMenuOption(
                icon: Icons.healing,
                title: '증상 기록',
                subtitle: '통증, 컨디션 메모',
                color: const Color(0xFFF44336),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEventDialog(EventType.symptom);
                },
              ),
              _buildMenuOption(
                icon: Icons.medication,
                title: '복약 기록',
                subtitle: '약 복용 체크',
                color: const Color(0xFF9C27B0),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEventDialog(EventType.medication);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAddEventDialog(EventType type) {
    switch (type) {
      case EventType.hospital:
        _showHospitalDialog();
        break;
      case EventType.vital:
        _showVitalDialog();
        break;
      case EventType.symptom:
        _showSymptomDialog();
        break;
      case EventType.medication:
        _showMedicationDialog();
        break;
    }
  }

  // 병원 일정 팝업
  void _showHospitalDialog() {
    final hospitalController = TextEditingController();
    final doctorController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '병원 일정',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: hospitalController,
                      decoration: InputDecoration(
                        hintText: '병원 이름 (예: 서울대병원)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: doctorController,
                      decoration: InputDecoration(
                        hintText: '담당 의사 성함 (예: 홍길동 교수)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF2196F3),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: selectedTime != null
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime != null
                                  ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : '진료 시간 선택',
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedTime != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (hospitalController.text.isNotEmpty) {
                            _saveHospitalEvent(
                              hospitalController.text,
                              doctorController.text,
                              selectedTime,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C4A8C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 생체 수치 팝업
  void _showVitalDialog() {
    final bloodPressureHighController = TextEditingController();
    final bloodPressureLowController = TextEditingController();
    final bloodSugarController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '생체 수치',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  '혈압',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bloodPressureHighController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '120',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '/',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: bloodPressureLowController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '80',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('mmHg'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '혈당',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bloodSugarController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '110',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('mg/dL'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (bloodPressureHighController.text.isNotEmpty ||
                          bloodSugarController.text.isNotEmpty) {
                        _saveVitalEvent(
                          bloodPressureHighController.text,
                          bloodPressureLowController.text,
                          bloodSugarController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C4A8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 증상 기록 팝업
  void _showSymptomDialog() {
    final symptomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF44336).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.healing,
                        color: Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '증상 기록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: symptomController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '어디가 어떻게 아픈가요?\n(예: 머리가 지끈거림, 갑자기 어지러움)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF44336),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (symptomController.text.isNotEmpty) {
                        _saveSymptomEvent(symptomController.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C4A8C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 복약 기록 팝업
  void _showMedicationDialog() {
    bool morning = false;
    bool afternoon = false;
    bool evening = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medication,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '복약 기록',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '오늘 먹은 시간대를 선택하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilterChip(
                          label: const Text('아침'),
                          selected: morning,
                          onSelected: (value) {
                            setDialogState(() {
                              morning = value;
                            });
                          },
                          selectedColor: const Color(0xFF9C27B0).withOpacity(0.3),
                          checkmarkColor: const Color(0xFF9C27B0),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: morning ? const Color(0xFF9C27B0) : Colors.grey[700],
                            fontWeight: morning ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        FilterChip(
                          label: const Text('점심'),
                          selected: afternoon,
                          onSelected: (value) {
                            setDialogState(() {
                              afternoon = value;
                            });
                          },
                          selectedColor: const Color(0xFF9C27B0).withOpacity(0.3),
                          checkmarkColor: const Color(0xFF9C27B0),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: afternoon ? const Color(0xFF9C27B0) : Colors.grey[700],
                            fontWeight: afternoon ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        FilterChip(
                          label: const Text('저녁'),
                          selected: evening,
                          onSelected: (value) {
                            setDialogState(() {
                              evening = value;
                            });
                          },
                          selectedColor: const Color(0xFF9C27B0).withOpacity(0.3),
                          checkmarkColor: const Color(0xFF9C27B0),
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                            color: evening ? const Color(0xFF9C27B0) : Colors.grey[700],
                            fontWeight: evening ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (morning || afternoon || evening) {
                            _saveMedicationEvent(morning, afternoon, evening);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C4A8C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 데이터 저장 함수들
  void _saveHospitalEvent(String hospital, String doctor, TimeOfDay? time) {
    final normalizedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final event = HealthEvent(
      date: normalizedDay,
      title: '병원 진료',
      type: EventType.hospital,
      data: {
        'hospital': hospital,
        if (doctor.isNotEmpty) 'doctor': doctor,
      },
      time: time ?? TimeOfDay.now(),
    );

    setState(() {
      if (_events[normalizedDay] == null) {
        _events[normalizedDay] = [];
      }
      _events[normalizedDay]!.add(event);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('병원 일정이 추가되었습니다.'),
        backgroundColor: Color(0xFF2C4A8C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveVitalEvent(String bpHigh, String bpLow, String bloodSugar) {
    final normalizedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    String title = '';
    Map<String, dynamic> data = {};

    if (bpHigh.isNotEmpty && bpLow.isNotEmpty) {
      title = '혈압 측정';
      data['bloodPressure'] = '$bpHigh/$bpLow mmHg';
    }
    if (bloodSugar.isNotEmpty) {
      if (title.isEmpty) {
        title = '혈당 측정';
      } else {
        title = '혈압/혈당 측정';
      }
      data['bloodSugar'] = '$bloodSugar mg/dL';
    }

    final event = HealthEvent(
      date: normalizedDay,
      title: title,
      type: EventType.vital,
      data: data,
      time: TimeOfDay.now(),
    );

    setState(() {
      if (_events[normalizedDay] == null) {
        _events[normalizedDay] = [];
      }
      _events[normalizedDay]!.add(event);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('생체 수치가 기록되었습니다.'),
        backgroundColor: Color(0xFF2C4A8C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveSymptomEvent(String symptom) {
    final normalizedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final event = HealthEvent(
      date: normalizedDay,
      title: '증상 기록',
      type: EventType.symptom,
      data: {'symptom': symptom},
      time: TimeOfDay.now(),
    );

    setState(() {
      if (_events[normalizedDay] == null) {
        _events[normalizedDay] = [];
      }
      _events[normalizedDay]!.add(event);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('증상이 기록되었습니다.'),
        backgroundColor: Color(0xFF2C4A8C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveMedicationEvent(bool morning, bool afternoon, bool evening) {
    final normalizedDay = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    List<String> times = [];
    if (morning) times.add('아침');
    if (afternoon) times.add('점심');
    if (evening) times.add('저녁');

    final event = HealthEvent(
      date: normalizedDay,
      title: '복약 기록',
      type: EventType.medication,
      data: {
        'times': times.join(', '),
        'morning': morning,
        'afternoon': afternoon,
        'evening': evening,
      },
      time: TimeOfDay.now(),
    );

    setState(() {
      if (_events[normalizedDay] == null) {
        _events[normalizedDay] = [];
      }
      _events[normalizedDay]!.add(event);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('복약 기록이 추가되었습니다.'),
        backgroundColor: Color(0xFF2C4A8C),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getEventTypeName(EventType type) {
    switch (type) {
      case EventType.hospital:
        return '병원 일정';
      case EventType.vital:
        return '생체 수치';
      case EventType.symptom:
        return '증상 기록';
      case EventType.medication:
        return '복약 기록';
    }
  }

  void _showEventDetail(HealthEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        event.icon,
                        color: event.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (event.formattedTime != null)
                            Text(
                              event.formattedTime!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ..._buildEventDetails(event),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmDialog(event);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      label: const Text(
                        '삭제',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(HealthEvent event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '삭제하시겠습니까?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${event.title} 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteEvent(event);
                Navigator.pop(context);
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(HealthEvent event) {
    final normalizedDay = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );

    setState(() {
      _events[normalizedDay]?.remove(event);
      if (_events[normalizedDay]?.isEmpty ?? false) {
        _events.remove(normalizedDay);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('기록이 삭제되었습니다.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

