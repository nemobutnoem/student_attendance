import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/University.dart';

class UniversityService {
  final supabase = Supabase.instance.client;

  Future<void> addUniversity(University university) async {
    try {
      await supabase.from('university').insert({
        'name': university.name,
        'address': university.address,
        'contact_info': university.contactInfo,
      });
    } catch (e) {
      throw Exception("Insert failed: $e");
    }
  }

  Future<void> updateUniversity(University university) async {
    if (university.universityId == null) {
      throw Exception("universityId is required to update");
    }

    try {
      await supabase
          .from('university')
          .update({
        'name': university.name,
        'address': university.address,
        'contact_info': university.contactInfo,
      })
          .eq('university_id', university.universityId!);
    } catch (e) {
      throw Exception("Update failed: $e");
    }
  }

  Future<void> deleteUniversity(int id) async {
    try {
      await supabase.from('university').delete().eq('university_id', id);
    } catch (e) {
      throw Exception("Delete failed: $e");
    }
  }

  Future<List<University>> fetchUniversities() async {
    try {
      final data = await supabase.from('university').select();
      return (data as List)
          .map((json) => University.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception("Fetch failed: $e");
    }
  }
}
