import 'package:get/get.dart';
import 'package:love_story_unicorn/app/utills/app_web_view_screen.dart';
import 'package:love_story_unicorn/app/widgets/app_camera_screen.dart';
import 'package:love_story_unicorn/screen/authentication/forgot_password/forgot_password.dart';
import 'package:love_story_unicorn/screen/authentication/sign_in/sign_in_screen.dart';
import 'package:love_story_unicorn/screen/authentication/sign_up/sign_up_screen.dart';
import 'package:love_story_unicorn/screen/basic_information/basic_information_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/chat_screen/chat_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/chat_screen/photo_preview_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/dashboard_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/intro_message/intro_message_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/matches/partner_images/partner_images_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/partner_profile/partner_profile_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/perfetct_match/perfect_match_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/profile/profile_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/swipe/filter/filter_screen.dart';
import 'package:love_story_unicorn/screen/dashboard_module/swipe/swipe_screen.dart';
import 'package:love_story_unicorn/screen/mandatory_question/mandatory_question_screen.dart';
import 'package:love_story_unicorn/screen/onboarding/onboarding_screen.dart';
import 'package:love_story_unicorn/screen/payment/subscription_screen.dart';
import 'package:love_story_unicorn/screen/splash/splash_screen.dart';
import 'package:love_story_unicorn/screen/term_and_condition/term_and_condition_screen.dart';

class RouteConstant {
  static const String initial = '/';
  static const String onBoarding = '/onBoarding';
  static const String signUp = '/signUp';
  static const String signIn = '/signIn';
  static const String forgotPassword = '/forgotPassword';
  static const String cameraScreen = '/cameraScreen';
  static const String basicInformation = '/basicInformation';
  static const String subscription = '/subscription';
  static const String matchMaking = '/match-making';
  static const String dashboard = '/dashboard';
  static const String swipe = '/swipe';
  static const String mandatoryQuestion = '/mandatoryQuestion';
  static const String perfectMatch = '/perfectMatch';
  static const String partnerProfile = '/partnerProfile';
  static const String filter = '/filter';
  static const String partnerImages = '/partnerImages';
  static const String introMessage = '/introMessage';
  static const String chatScreen = '/chatScreen';
  static const String termsCondition = '/termsCondition';
  static const String webView = '/webView';
  static const String photoPreview = '/photoPreview';

}

class GetPageRouteHelper {
  static List<GetPage> routes = [
    GetPage(name: RouteConstant.initial, page: () => const SplashScreen()),
    GetPage(name: RouteConstant.onBoarding, page: () => const OnboardingScreen()),
    GetPage(name: RouteConstant.signUp, page: () => const SignUpScreen()),
    GetPage(name: RouteConstant.forgotPassword, page: () => const ForgotPassword()),
    GetPage(name: RouteConstant.signIn, page: () => const SignInScreen()),
    GetPage(name: RouteConstant.cameraScreen, page: () => const AppCameraScreen()),
    GetPage(name: RouteConstant.basicInformation, page: () => const BasicInformationScreen()),
    GetPage(name: RouteConstant.subscription, page: () => const SubscriptionScreen()),
    GetPage(name: RouteConstant.matchMaking, page: () => const ProfileScreen()),
    GetPage(name: RouteConstant.dashboard, page: () => const DashboardScreen()),
    GetPage(name: RouteConstant.swipe, page: () => const SwipeScreen()),
    GetPage(name: RouteConstant.mandatoryQuestion, page: () => const MandatoryQuestionScreen()),
    GetPage(name: RouteConstant.perfectMatch, page: () => const PerfectMatchScreen()),
    GetPage(name: RouteConstant.partnerProfile, page: () => const PartnerProfileScreen()),
    GetPage(name: RouteConstant.filter, page: () => const FilterScreen()),
    GetPage(name: RouteConstant.partnerImages, page: () => const PartnerImagesScreen()),
    GetPage(name: RouteConstant.introMessage, page: () => const IntroMessageScreen()),
    GetPage(name: RouteConstant.chatScreen, page: () => const ChatScreen()),
    GetPage(name: RouteConstant.termsCondition, page: () => const TermAndConditionScreen()),
    GetPage(name: RouteConstant.webView, page: () => const AppWebViewScreen()),
    GetPage(name: RouteConstant.photoPreview, page: () => const PhotoPreviewScreen()),
  ];
}
