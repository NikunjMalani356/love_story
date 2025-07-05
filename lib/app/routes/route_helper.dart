import 'package:get/get.dart';
import 'package:love_story_unicorn/app/routes/route_constant.dart';
import 'package:love_story_unicorn/serialized/user_model.dart';

class RouteHelper {
  static final RouteHelper instance = RouteHelper._internal();

  factory RouteHelper() => instance;

  RouteHelper._internal();
  void goToBack() => Get.back();
  void goToOnBoarding() => Get.toNamed(RouteConstant.onBoarding);
  void goToSignUp() => Get.toNamed(RouteConstant.signUp);
  void goToSignIn() => Get.toNamed(RouteConstant.signIn);
  void goToForgot() => Get.toNamed(RouteConstant.forgotPassword);
  void offAllSignIn() => Get.offAllNamed(RouteConstant.signIn);
  void goToBasicInformation() => Get.offAllNamed(RouteConstant.basicInformation);
  Future<dynamic> goToCameraScreen() async => await Get.toNamed(RouteConstant.cameraScreen);
  void goToSubscription() => Get.offAllNamed(RouteConstant.subscription);
  void goToMatchMakingScreen() => Get.toNamed(RouteConstant.matchMaking);
  void gotoDashboard({int? index}) => Get.offAllNamed(RouteConstant.dashboard, arguments: {'index': 0});
  void gotoMandatory({UserModel? currentUser, bool? isEdit}) => Get.toNamed(RouteConstant.mandatoryQuestion, arguments: {'currentUser': currentUser, 'isEdit': false});
  void gotoPerfectMatch() => Get.toNamed(RouteConstant.perfectMatch);
  void gotoPartnerProfile({UserModel? currentUser, bool? isDragonShow=true}) => Get.toNamed(RouteConstant.partnerProfile,arguments:{'currentUser':currentUser,'isDragonShow':isDragonShow});
  void gotoFilter() => Get.toNamed(RouteConstant.filter);
  void gotoPartnerImages({UserModel? currentUser}) => Get.toNamed(RouteConstant.partnerImages,arguments: currentUser);
  void gotoPartnerOffPartnerImages({UserModel? currentUser}) => Get.offNamed(RouteConstant.partnerImages,arguments: currentUser);
  void gotoIntroMessage({required String userid}) => Get.toNamed(RouteConstant.introMessage,arguments: userid);
  void gotoChat({required String introMessage, required bool isfollowBack}) => Get.toNamed(RouteConstant.chatScreen, arguments: {'introMessage':introMessage,'isFollowBack':isfollowBack});
  void gotoTermCondition(String contentType) => Get.toNamed(RouteConstant.termsCondition,arguments: contentType);
  void gotoWebView(String url) => Get.toNamed(RouteConstant.webView,arguments: {'url':url});
  void gotoPhotoPreview(String url) => Get.toNamed(RouteConstant.photoPreview,arguments: {'url':url});

}
