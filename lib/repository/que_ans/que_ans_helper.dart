import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_story_unicorn/app/constant/string_constant.dart';
import 'package:love_story_unicorn/app/helper/extension_helper.dart';
import 'package:love_story_unicorn/app/widgets/app_toast.dart';
import 'package:love_story_unicorn/repository/que_ans/que_ans_repository.dart';

class QueAnsRepositoryImpl extends QueAnsRepository {
  CollectionReference queAnsCollection = FirebaseFirestore.instance.collection(AppCollectionConstants.queAnsCollection);

  @override
  Future<void> saveQuestionAns(Map<String, dynamic> questions) async {
    try {
      await queAnsCollection.doc(FirebaseAuth.instance.currentUser?.uid).set(questions);
    } on FirebaseException catch (e) {
      'Catch FirebaseException in saveQuestionAns --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
  }

  @override
  Future<bool> checkQuestionExist() async {
    try {
      final DocumentSnapshot snapshot = await queAnsCollection.doc(FirebaseAuth.instance.currentUser?.uid).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('mandatory')) {
          final List<dynamic> questionAnswer = data['mandatory'];
          return validateMandatoryQuestions(questionAnswer);
        }
      }
    } on FirebaseException catch (e) {
      'Catch FirebaseException in checkQuestionExist --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return false;
  }

  bool validateMandatoryQuestions(List<dynamic> questionsList) {
    final bool isValidate = questionsList.every((model) => model['answer'] != null && (model['answer']?.isNotEmpty == true));
    'isValidate --> $isValidate'.logs();
    return isValidate;
  }

  @override
  Future<Map<String, dynamic>?> getQuestion({String? userId}) async {
    final String? user = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (user == null) {
      return null;
    }

    try {
      final DocumentSnapshot snapshot = await queAnsCollection.doc(user).get();

      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()! as Map<String, dynamic>;
      }
    } on FirebaseException catch (e) {
      'Catch FirebaseException in getQuestions --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
    }
    return null;
  }

  @override
  Future<bool> updateQuestion({String? userId, Map<String, dynamic>? updatedData}) async {
    final String? user = userId ?? FirebaseAuth.instance.currentUser?.uid;
    try {
      final userRef = queAnsCollection.doc(user);
      await userRef.update(updatedData ?? {});
      return true;
    } on FirebaseException catch (e) {
      'Catch FirebaseException in updateQuestion --> ${e.message}'.errorLogs();
      e.message?.showErrorToast();
      return false;
    }
  }
}
