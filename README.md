# SwA

SwA 是一个小而完整的 SwiftUI iOS 应用骨架：业务逻辑放在 Swift Package（`SwACore`）里，可以在 Linux 或 macOS 上直接用 `swift test` 测试；SwiftUI 界面代码只由 Xcode 编译。

## 目录结构

```text
.
├── Package.swift          # Swift Package "SwA"，库产物 SwACore（iOS 17 / macOS 13）
├── Sources/SwACore/       # 业务核心，只依赖 Foundation
├── Tests/SwACoreTests/    # SwACore 的 swift-testing 测试
├── App/                   # @main 入口、组合根、根视图（只由 Xcode 编译）
├── Features/Home/         # Home 功能：HomeView + HomeViewModel（只由 Xcode 编译）
└── project.yml            # XcodeGen 工程描述，用来生成 SwA.xcodeproj
```

## 架构

依赖只有一个方向：`App → Features → SwACore → Foundation`。

**SwACore**（Swift Package 库；不导入 SwiftUI / UIKit，不使用 URLSession，没有第三方依赖）

| 类型 | 作用 |
| --- | --- |
| `DateProvider` | “当前时间”依赖。`SystemDateProvider` 返回系统时间，`FixedDateProvider` 返回固定时间，用于测试和预览。 |
| `Item` | 列表条目：`id`、`title`、`createdAt`。 |
| `ItemStore` / `InMemoryItemStore` | 条目存储协议（`async throws`）和基于 actor 的内存实现。 |
| `HomeModel` / `HomeState` | Home 用例。`load()` 没有条目时返回 `.empty`，否则按创建时间倒序返回 `.items`；`addItem(title:)` 去掉标题首尾空白，空标题抛出 `HomeModelError.emptyTitle`，并用 `DateProvider` 记录创建时间。 |

**App**（`App/`）

- `SwAApp`：`@main` 入口，持有 `AppDependencies`。
- `AppDependencies`：组合根，创建 `InMemoryItemStore` 和 `SystemDateProvider`，组装 `HomeModel` 与 `HomeViewModel`。
- `RootView`：在 `NavigationStack` 中显示 Home。

**Features/Home**

- `HomeViewModel`：`@MainActor` + `@Observable`，只调用 SwACore 的 `HomeModel`。
- `HomeView`：加载中、空状态、列表三种界面，底部输入框用于添加条目。

要把内存存储换成持久化存储，只需要在 SwACore 中实现一个新的 `ItemStore`，再在 `AppDependencies.live()` 中替换，用例和界面代码都不用改。

## 运行测试

需要 Swift 6.0 或更高版本的工具链（macOS 上装 Xcode 16 或更新版本；Linux 参见 [swift.org/install](https://www.swift.org/install/linux/)，可以用 swiftly 安装）。在仓库根目录执行：

```bash
swift test
```

测试使用 swift-testing，覆盖内存存储（初始为空、添加、列表顺序）和 Home 用例（空状态、添加、按时间倒序列出、空标题校验）。

## 生成并打开 Xcode 工程（macOS）

```bash
brew install xcodegen
xcodegen generate
open SwA.xcodeproj
```

选择 `SwA` scheme 和 iOS 17 或更高版本的模拟器，⌘R 运行。scheme 的 Test 动作包含 Swift Package 中的 `SwACoreTests`，⌘U 会在模拟器上运行这些测试。

`SwA.xcodeproj` 由 `project.yml` 生成，已加入 `.gitignore`，不要手动修改。需要改 target、build settings 或 scheme 时编辑 `project.yml`，然后重新执行 `xcodegen generate`；在 `App/` 或 `Features/` 下增删文件后也要重新生成。

模拟器运行不需要签名。真机运行时，在 `project.yml` 中 `SwA` target 的 `settings.base` 里加上 `DEVELOPMENT_TEAM: <你的 Team ID>` 再重新生成；直接在 Xcode 里选的 Team 会在下次生成时被覆盖。

## 新增一个功能

1. 在 `Sources/SwACore/` 中添加用例和需要的协议，在 `Tests/SwACoreTests/` 中添加测试。
2. 在 `Features/<功能名>/` 中添加 View 和 ViewModel，ViewModel 只调用 SwACore。
3. 在 `AppDependencies` 中组装依赖，从 `RootView` 或导航进入新功能。
4. 执行 `xcodegen generate` 刷新工程。
