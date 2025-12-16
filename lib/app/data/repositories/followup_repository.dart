import '../services/followup_service.dart';
import '../models/followup_model.dart';
import '../../modules/dashboard/dashboard_controller.dart'; // For FollowupItem

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

  Future<int> getCount() async {
    final followups = await getAllFollowUps();
    return followups.length;
  }

  // ------------------------
  // Dashboard helper: upcoming follow-ups
  // ------------------------
  Future<List<FollowupItem>> getUpcoming() async {
    final followups = await getAllFollowUps();
    final now = DateTime.now();

    // Filter follow-ups that are today or later
    final upcoming = followups.where((f) {
      final date = DateTime.tryParse(f.followUpDate) ?? now;
      return date.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();

    return upcoming
        .map((f) => FollowupItem(
              customerName: f.id.toString(),
              date: f.followUpDate,
              priority: f.remarks,
            ))
        .toList();
  }
}
