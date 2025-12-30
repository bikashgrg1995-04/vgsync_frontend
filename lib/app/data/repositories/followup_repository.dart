import '../models/followup_model.dart';
import '../services/followup_service.dart';

class FollowUpRepository {
  final FollowUpService followUpService;

  FollowUpRepository({required this.followUpService});

  Future<List<FollowUpModel>> getFollowUps() =>
      followUpService.fetchFollowUps();

  Future<void> terminate(int id) => followUpService.terminateFollowUp(id);
}
