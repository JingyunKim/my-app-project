import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _appVersion = 'v1.0.0';  // 기본값

  @override
  void initState() {
    super.initState();
    print('스플래시 화면: 초기화 시작');
    
    // 앱 버전 정보 가져오기
    _loadAppVersion();
    
    // 애니메이션 컨트롤러 초기화 (지속 시간을 3초로 증가)
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // 페이드 인 애니메이션
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // 스케일 애니메이션
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // 애니메이션 시작
    _animationController.forward();
    
    // 초기화 완료 후 메인 화면으로 이동
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    print('스플래시 화면: 앱 초기화 시작');
    
    try {
      // 서비스 초기화
      final storageService = StorageService();
      await storageService.init();

      final notificationService = NotificationService();
      await notificationService.init();

      // 앱 설정 로드
      final settings = await storageService.loadSettings();
      
      // Provider 초기화
      final goalProvider = GoalProvider(settings);
      // await goalProvider.loadInitialData();  // 이 줄 제거

      print('스플래시 화면: 앱 초기화 완료');
      
      // 4초 후 메인 화면으로 이동 (지속 시간 증가)
      await Future.delayed(const Duration(seconds: 4));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider<AppSettings>.value(value: settings),
                ChangeNotifierProvider<GoalProvider>.value(value: goalProvider),
              ],
              child: const MainScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      print('스플래시 화면: 초기화 오류 - $e');
      // 오류 발생 시에도 메인 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    }
  }

  Future<void> _loadAppVersion() async {
    // App Store 심사 문제로 고정된 버전 사용
    setState(() {
      _appVersion = 'v1.0.1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 앱 로고 (이모티콘 사용)
                    Container(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'assets/icons/Monthly Focus_2.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Icon(
                                Icons.track_changes,
                                size: 60,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // 앱 이름
                    const Text(
                      'Monthly Focus',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // 앱 설명
                    const Text(
                      '매일의 작은 목표로 큰 변화를',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // 로딩 인디케이터
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 버전 정보
                    Text(
                      'v$_appVersion',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 