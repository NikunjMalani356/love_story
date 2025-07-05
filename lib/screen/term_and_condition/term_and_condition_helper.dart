import 'package:love_story_unicorn/main.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';
import 'package:love_story_unicorn/screen/term_and_condition/term_and_condition_screen.dart';
import 'package:love_story_unicorn/serialized/privacy_terms_model.dart';

class TermAndConditionHelper {
  TermAndConditionScreenState state;
  PolicyTermsModel? contentData;
  bool isLoading = true;
  String? contentType;
  UtillsRepository utillsRepository = getIt<UtillsRepository>();

  TermAndConditionHelper(this.state) {
    getTermAndCondition();
  }

  // Future<void> loadContentFromJson() async {
  //   contentType = Get.arguments;
  //   try {
  //     final String jsonString = await rootBundle.loadString(
  //       contentType == 'terms' ? AppAsset.termsJson : AppAsset.privacyJson,
  //     );
  //     final Map<String, dynamic> jsonMap = json.decode(jsonString);
  //     contentData = PolicyTermsModel.fromJson(jsonMap);
  //
  //     "contentData --> ${contentData?.title}".logs();
  //     isLoading = false;
  //     state.termConditionController?.update();
  //   } catch (e) {
  //     isLoading = false;
  //     state.termConditionController?.update();
  //   }
  // }

  Future<void> getTermAndCondition() async {
    updateLoading(true);
    final Map<String, dynamic>? utillsData = await utillsRepository.getUtillsData('term_and_condition');

    if (utillsData != null) contentData = PolicyTermsModel.fromJson(utillsData);
    updateLoading(false);
  }

  void updateState() => state.termConditionController?.update();

  void updateLoading(bool value) {
    isLoading = value;
    updateState();
  }
}
