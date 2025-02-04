import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/job-models.dart';

class JobService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addJob(Job job) async {
    try {
      final Database db = await _dbHelper.database;
      await db.insert(
        'jobs',
        job.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Job added successfully: ${job.title}');
    } catch (e) {
      print('Error adding job: $e');
      throw Exception('Failed to add job: $e');
    }
  }

  Future<List<Job>> getJobs() async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('jobs');
      return List.generate(maps.length, (i) {
        return Job.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error in getJobs: $e');
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      final Database db = await _dbHelper.database;
      await db.delete(
        'jobs',
        where: 'id = ?',
        whereArgs: [jobId],
      );
    } catch (e) {
      print('Error in deleteJob: $e');
      rethrow;
    }
  }

  Future<void> updateJob(Job job) async {
    try {
      final Database db = await _dbHelper.database;
      await db.update(
        'jobs',
        job.toMap(),
        where: 'id = ?',
        whereArgs: [job.id],
      );
    } catch (e) {
      print('Error in updateJob: $e');
      rethrow;
    }
  }
}
