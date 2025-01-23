import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/job-models.dart';

class JobService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addJob(Job job) async {
    final Database db = await _dbHelper.database;
    await db.insert(
      'jobs',
      job.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Job>> getJobs() async {
    final Database db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('jobs');

    return List.generate(maps.length, (i) {
      return Job.fromJson(maps[i]);
    });
  }
}
