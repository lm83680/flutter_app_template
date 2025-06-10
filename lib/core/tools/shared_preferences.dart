import 'dart:async' show StreamController;
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static SharedPrefsHelper? _instance;
  static SharedPreferences? _prefs;
  final StreamController<String> _streamController =
      StreamController<String>.broadcast();

  SharedPrefsHelper._internal();

  /// 可信的同步访问
  static SharedPrefsHelper get i {
    assert(
      _instance != null,
      'SharedPrefsHelper has not been initialized yet. need run  `SharedPrefsHelper.getInstance()`',
    );
    return _instance!;
  }

  /// 初始化
  static Future<SharedPrefsHelper> getInstance() async {
    _instance ??= SharedPrefsHelper._internal();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// 监听指定 key 的变化（可过滤特定 key）
  Stream<T> watch<T>({String? key}) {
    return _streamController.stream
        .where((eventKey) => key == null || eventKey == key)
        .asyncMap((eventKey) => get<T>(eventKey))
        .where((value) => value != null)
        .cast<T>();
  }

  /// 增强版存储方法（触发事件通知）存储自定义类型
  Future<bool> saveObject<T>(String key, T object) async {
    if (object == null) return false;
    if (object is Map || object is List) {
      return save(key, object);
    } else if (object is String || object is num || object is bool) {
      return save(key, object);
    } else {
      // 调用对象的 toJson 方法
      final json = (object as dynamic).toJson();
      return save(key, json);
    }
  }

  /// （触发事件通知）存储普通类型
  Future<bool> save<T>(String key, T value) async {
    try {
      bool success;
      if (value is int) {
        success = await _prefs!.setInt(key, value);
      } else if (value is double) {
        success = await _prefs!.setDouble(key, value);
      } else if (value is bool) {
        success = await _prefs!.setBool(key, value);
      } else if (value is String) {
        success = await _prefs!.setString(key, value);
      } else if (value is List<String>) {
        success = await _prefs!.setStringList(key, value);
      } else if (value is Map || value is List) {
        success = await _prefs!.setString(key, jsonEncode(value));
      } else {
        throw UnsupportedError('Unsupported type: ${value.runtimeType}');
      }

      if (success) _streamController.add(key);
      return success;
    } catch (e) {
      debugPrint('SharedPrefsHelper save error: $e');
      return false;
    }
  }

  /// 读取对象（自动反序列化）
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final json = get<Map<String, dynamic>>(key);
    return json != null ? fromJson(json) : null;
  }

  /// 读取对象列表（自动反序列化）
  List<T>? getListObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = get<List<dynamic>>(key);
    return list?.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 通用读取方法
  ///
  /// 如果 key 不存在，则返回 [defaultValue]（默认值为 null）。
  T? get<T>(String key, {T? defaultValue}) {
    try {
      final value = _prefs!.get(key);
      if (value == null) return defaultValue;

      if (T == int) {
        return value as T;
      } else if (T == double) {
        return value as T;
      } else if (T == bool) {
        return value as T;
      } else if (T == String) {
        return value as T;
      } else if (T == List<String>) {
        return value as T;
      } else if (T.toString() == 'Map<String, dynamic>') {
        return jsonDecode(value.toString()) as T;
      } else if (T.toString() == 'List<dynamic>') {
        return jsonDecode(value.toString()) as T;
      } else {
        throw UnsupportedError('Type $T is not supported');
      }
    } catch (e) {
      debugPrint('SharedPrefsHelper get error: $e');
      return defaultValue;
    }
  }

  /// 删除数据并触发通知
  Future<bool> remove(String key) async {
    try {
      final success = await _prefs!.remove(key);
      if (success) _streamController.add(key);
      return success;
    } catch (e) {
      debugPrint('SharedPrefsHelper remove error: $e');
      return false;
    }
  }

  /// 清空数据并触发所有 key 通知
  Future<bool> clear() async {
    try {
      final keys = _prefs!.getKeys();
      final success = await _prefs!.clear();
      if (success) keys.forEach(_streamController.add);
      return success;
    } catch (e) {
      debugPrint('SharedPrefsHelper clear error: $e');
      return false;
    }
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
}

// 初始化（在 App 启动时）
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SharedPrefsHelper.getInstance();
//   runApp(MyApp());
// }
//

// 存储数据
// await SharedPrefsHelper.i.save('username', 'John');
// await SharedPrefsHelper.i.save('age', 25);

// 读取数据
// String? name = SharedPrefsHelper.i.get<String>('username');
// int age = SharedPrefsHelper.i.get<int>('age', defaultValue: 0)!;

// 存储对象（Map）
// Map<String, dynamic> user = {'name': 'Alice', 'email': 'alice@example.com'};
// await SharedPrefsHelper.i.save('user', user);

// 读取对象
// Map<String, dynamic>? userData = SharedPrefsHelper.i.get<Map>('user');

// 删除数据
// await SharedPrefsHelper.i.remove('token');

// 在 BLoC 或 StatefulWidget 中
// 监听单个 key 的变化
// StreamSubscription<String>? _subscription;

// void initListener() {
//   _subscription = SharedPrefsHelper.i.watch<String>(key: 'theme').listen((theme) {
//     print('主题变更: $theme');
//     // 更新UI或状态
//   });
// }

// @override
// void dispose() {
//   _subscription?.cancel();
//   super.dispose();
// }

// 复杂类型
// User user = User('Alice', 30);
// 存储 User 对象
// await SharedPrefsHelper.i.saveObject('user_info', user);
// 读取 User 对象
// User? user = SharedPrefsHelper.i.getObject<User>('user_info', User.fromJson);
