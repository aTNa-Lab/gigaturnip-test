import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gigaturnip_api/gigaturnip_api.dart' as api;
import 'package:gigaturnip_repository/gigaturnip_repository.dart';
import 'package:local_database/local_database.dart' as db;

class TaskDetailRepository {
  final api.GigaTurnipApiClient _gigaTurnipApiClient;

  TaskDetailRepository({
    required api.GigaTurnipApiClient gigaTurnipApiClient,
  }) : _gigaTurnipApiClient = gigaTurnipApiClient;

  Future<TaskDetail> fetchData(int id) async {
    try {
      final data = await db.LocalDatabase.getSingleTask(id);
      final stage = await db.LocalDatabase.getSingleTaskStage(data.stage);
      return TaskDetail.fromDB(data, stage);
    } catch (e) {
      final task = await _gigaTurnipApiClient.getTaskById(id);
      return TaskDetail.fromApiModel(task);
    }
  }

  Future<List<TaskDetail>> fetchPreviousTaskData(int id) async {
    try {
      final tasks = await _gigaTurnipApiClient.getDisplayedPreviousTasks(id);
      return tasks.results.map(TaskDetail.fromApiModel).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<TaskResponse> saveData(int id, Map<String, dynamic> data) async {
    final task = await db.LocalDatabase.getSingleTask(id);
    db.LocalDatabase.updateTask(
      task.copyWith(
        responses: Value(jsonEncode(data['responses'])),
        complete: data['complete'],
      ),
    );
    try {
      return _gigaTurnipApiClient.saveTaskById(id, data);
    } catch (e) {
      return TaskResponse(id: id, nextDirectId: null, notifications: []);
    }
  }

  Future<TaskResponse> submitTask(int id, Map<String, dynamic> data) async {
    int? newId;
    int? newCachedId;
    final task = await db.LocalDatabase.getSingleTask(id);
    if (task.createdOffline) {
      try {
        final response = await _gigaTurnipApiClient
            .createTaskFromStageId(task.stage, data: {'responses': data['responses']});
        newId = response.id;
        db.LocalDatabase.deleteTask(task.id);
        final parsed = TaskDetail.fromApiModel(response)..copyWith(complete: data['complete']);
        newCachedId = await db.LocalDatabase.insertTask(parsed.toDB());
      } catch (e) {
        newId = id;
        db.LocalDatabase.updateTask(
          task.copyWith(
            responses: Value(jsonEncode(data['responses'])),
            complete: data['complete'],
          ),
        );
      }
    } else {
      newId = id;
      db.LocalDatabase.updateTask(
        task.copyWith(
          responses: Value(jsonEncode(data['responses'])),
          complete: data['complete'],
        ),
      );
    }

    final response = await _gigaTurnipApiClient.saveTaskById(newId, data);

    if (response.nextDirectId == response.id && newCachedId != null) {
      final task = await db.LocalDatabase.getSingleTask(newCachedId);

      db.LocalDatabase.updateTask(
        task.copyWith(
          responses: Value(jsonEncode(data['responses'])),
          complete: false,
        ),
      );

      return api.TaskResponse(id: newId, nextDirectId: newId);
    }

    return response;
  }

  Future<Map<String, dynamic>> triggerWebhook(int id) async {
    try {
      final response = await _gigaTurnipApiClient.triggerTaskWebhook(id);
      return response.responses;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getDynamicSchema({
    required int taskId,
    required int stageId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final dynamicSchema = await _gigaTurnipApiClient.getDynamicSchema(
        stageId,
        query: {
          'current_task': taskId,
          'responses': data,
        },
      );
      return dynamicSchema.schema;
    } catch (e) {
      return {};
    }
  }

  Future<void> releaseTask(int id) async {
    await _gigaTurnipApiClient.releaseTask(id);
  }

  Future<int> openPreviousTask(int id) async {
    final response = await _gigaTurnipApiClient.openPreviousTask(id);
    return response.data['id'] as int;
  }
}
