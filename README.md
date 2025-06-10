# flutter_app_template

1. 修改文件夹名称 & 删除 .git 目录
2. 补全 Flutter 环境
```sh
flutter create .
```
3. 修改 App名称 和 包名
```sh
flutter pub global activate rename

rename setAppName --targets android, ios, web, windows, macos, linux --value "YourAppName"
rename setBundleId --targets android, ios, web, windows, macos, linux  --value "com.example.bundleId"
```
4. 必要依赖
```sh
flutter pub add hooks_riverpod
flutter pub add flutter_hooks
flutter pub add riverpod_annotation
flutter pub add dev:riverpod_generator
flutter pub add dev:build_runner
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint

flutter pub add dio
flutter pub add shared_preferences
```
### 其他
1. 使用 rust
```sh
cargo install flutter_rust_bridge_codegen
flutter_rust_bridge_codegen integrate

## 修改 flutter_rust_bridge.yaml
rust_input: crate::api
rust_root: rust/
dart_output: lib/core/ffi/rust

# 重新生成代码
flutter_rust_bridge_codegen generate
```
2. 建议依赖
```sh
flutter pub add equatable
flutter pub add dartz
flutter pub add json_annotation
flutter pub add dev:json_serializable
```

### 结构说明
```
├── core             # 业务层不应包含任何 UI 
│   ├── constants
│   ├── error
│   ├── ffi
│   │   └── rust
│   ├── network
│   ├── router
│   ├── theme
│   ├── tools
│   └── un_categorized
├── features
├── presentation
│   ├── pages
│   └── widgets
│
└── main.dart
```