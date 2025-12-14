import '../services/followup_service.dart';
import '../models/followup_model.dart';

class FollowUpRepository {
  final FollowUpService followUpService;

  FollowUpRepository({required this.followUpService});

  Future<List<FollowUpModel>> getAllFollowUps() async {
    final data = await followUpService.getAllFollowUps();
    return data.map<FollowUpModel>((e) => FollowUpModel.fromJson(e)).toList();
  }

  Future<FollowUpModel> updateFollowUp(FollowUpModel followUp) async {
    final data =
        await followUpService.updateFollowUp(followUp.id, followUp.toJson());
    return FollowUpModel.fromJson(data);
  }

  Future<void> deleteFollowUp(int id) async {
    await followUpService.deleteFollowUp(id);
  }
}
