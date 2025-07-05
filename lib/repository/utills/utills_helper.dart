import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/repository/utills/utills_repository.dart';

class UtillsRepositoryImpl extends UtillsRepository {
  CollectionReference utillsCollection = FirebaseFirestore.instance.collection(AppCollectionConstants.utills);

  @override
  Future<Map<String, dynamic>?>? getUtillsData(String collectionName) async {
    try {
      final DocumentSnapshot snapshot = await utillsCollection.doc(collectionName).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()! as Map<String, dynamic>;
      }
    } on FirebaseException catch (e) {
      'Catch FirebaseException in getUserData --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return null;
  }

  @override
  Future<String?> getPolicyUrl() async {
    final Map<String, dynamic>? utillsData = await getUtillsData('urls');
    if (utillsData != null && utillsData.containsKey('privacy_policy')) {
      'utillsData --> ${utillsData['privacy_policy']}'.logs();
      final String privacyPolicy = utillsData['privacy_policy'] ?? '';
      'privacyPolicy --> $privacyPolicy'.logs();
      return privacyPolicy;
    }
    return null;
  }
}
