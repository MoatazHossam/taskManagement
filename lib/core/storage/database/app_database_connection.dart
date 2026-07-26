import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
QueryExecutor openAppDatabaseConnection() => LazyDatabase(() async { final directory=await getApplicationDocumentsDirectory(); return NativeDatabase.createInBackground(File(p.join(directory.path,'organization_tasks.sqlite'))); });
QueryExecutor openInMemoryDatabaseConnection() => NativeDatabase.memory();
