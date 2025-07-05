abstract class UtillsRepository {
  Future<Map<String, dynamic>?>? getUtillsData(String collectionName);
  Future<String?> getPolicyUrl();
}
