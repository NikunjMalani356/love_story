abstract class QueAnsRepository {
  Future<void> saveQuestionAns(Map<String, dynamic> questions) ;

  Future<bool> checkQuestionExist();

  Future<Map<String, dynamic>?> getQuestion({String? userId});

  Future<bool> updateQuestion({String? userId, Map<String, dynamic>? updatedData});
}
