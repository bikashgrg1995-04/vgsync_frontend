import '../models/followup_model.dart';
import '../services/followup_service.dart';

class FollowUpRepository {
  final FollowUpService followUpService;

  FollowUpRepository({required this.followUpService});

  // ---------------- FETCH ----------------
  Future<List<FollowUpModel>> getFollowUps({
    int page = 1,
    int pageSize = 10,
  }) {
    return followUpService.fetchFollowUps(
      page: page,
      pageSize: pageSize,
    );
  }

  // ---------------- TERMINATE ----------------
  Future<void> terminate(
    int id, {
    String? reason,
  }) {
    return followUpService.terminateFollowUp(
      id,
      reason: reason,
    );
  }
}
