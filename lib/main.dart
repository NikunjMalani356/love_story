import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:love_story_unicorn/app/constant/app_asset.dart';
import 'package:love_story_unicorn/app/constant/color_constant.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/routes/route_constant.dart';
import 'package:love_story_unicorn/app/widgets/app_text.dart';
import 'package:love_story_unicorn/helper/authentication_helper.dart';
import 'package:love_story_unicorn/helper/cheating_helper.dart';
import 'package:love_story_unicorn/repository/authentication/auth_repository.dart';
import 'package:love_story_unicorn/repository/cheating/cheating_repository.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_helper.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';
import 'package:love_story_unicorn/repository/users/user_helper.dart';
import 'package:love_story_unicorn/repository/users/user_repository.dart';
import 'package:love_story_unicorn/repository/utills/utills_helper.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';
import 'package:love_story_unicorn/service/config_service.dart';
import 'package:love_story_unicorn/service/notification_service.dart';
import 'package:love_story_unicorn/service/remote_config_service.dart';
import 'package:toastification/toastification.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  getIt.registerSingleton<UserRepository>(UserRepositoryImpl());
  getIt.registerSingleton<QueAnsRepository>(QueAnsRepositoryImpl());
  getIt.registerSingleton<CheatingRepository>(CheatingImpl());
  getIt.registerSingleton<UtillsRepository>(UtillsRepositoryImpl());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await init();
  await RemoteConfigService.instance.setUpRemoteConfig();
  await NotificationService.instance.initializeNotification();
  await ConfigService.instance.getRequestTimeFromConfig();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  String contactUsUrl = '';

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async => await getInitialData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    'Current screen --> $runtimeType'.logs();
    return ToastificationWrapper(
      config: const ToastificationConfig(alignment:Alignment.topCenter),
      child: Material(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: GetMaterialApp(
                  title: StringConstant.appName,
                  theme: ThemeData(
                    primaryColor: AppColorConstant.appWhite,
                    useMaterial3: true,
                    splashColor: AppColorConstant.appTransparent,
                    fontFamily: AppAsset.defaultFont,
                    scaffoldBackgroundColor: AppColorConstant.appWhite,
                  ),
                  debugShowCheckedModeBanner: false,
                  locale: Get.deviceLocale,
                  initialRoute: RouteConstant.initial,
                  getPages: GetPageRouteHelper.routes,
                  defaultTransition: Transition.fadeIn,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                      child: child ?? Container(),
                    );
                  },
                ),
              ),
                InkWell(
                  onTap: () => contactUsUrl.launchStoreRating(),
                  child: Container(
                    height: 120,
                    width: 30,
                    decoration: const BoxDecoration(color: AppColorConstant.appBlack),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RotatedBox(
                              quarterTurns: -1,
                              child: AppText(
                                'Feedback',
                                color: AppColorConstant.appWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getInitialData() async {
    final UtillsRepository utillsRepository = getIt<UtillsRepository>();
    final Map<String, dynamic>? utillsData = await utillsRepository.getUtillsData('urls');
    if (utillsData != null && utillsData.containsKey('contact_us')) {
      'utillsData --> ${utillsData['contact_us']}'.logs();
      contactUsUrl = utillsData['contact_us'] ?? '';
      setState(() {});
    }
  }
}
