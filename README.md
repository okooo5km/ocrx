# OCRX

OCRX 是一个基于 Swift 的命令行工具,用于对图像进行光学字符识别(OCR)处理。它支持多种输出格式,并可以将结果保存到文件或复制到剪贴板。

## 功能特点

- 支持处理多种图像格式
- 可识别中文(简体和繁体)和英文
- 支持多种输出格式:百度格式(JSON)、CSV 和原生格式
- 可将结果保存到文件或复制到剪贴板
- 基于 Apple 的 Vision 框架,提供高精度的 OCR 识别

## 系统要求

- macOS 13.0 或更高版本
- Swift 6.0 或更高版本

## 安装

1. 克隆此仓库:

   ```shell
   git clone https://github.com/yourusername/ocrx.git
   cd ocrx
   ```

2. 构建项目:

   ```shell
   swift build -c release
   ```

3. (可选) 将可执行文件复制到系统路径:

   ```shell
   sudo cp .build/release/ocrx /usr/local/bin/ocrx
   ```

## 使用方法

基本用法:

```shell
ocrx <image-path> [--output <output-path>] [--format <format>]
```

参数:

- `<image-path>`: 要处理的图像文件路径 (必需)
- `--output` 或 `-o`: 指定保存 OCR 结果的文件路径 (可选)
- `--format` 或 `-f`: 指定输出格式,选项为 baidu (默认)、csv 或 native

示例:

1. 使用默认设置处理图像:

   ```shell
   ocrx /path/to/your/image.jpg
   ```

2. 指定输出文件和格式:

   ```shell
   ocrx /path/to/your/image.jpg --output result.json --format baidu
   ```

3. 使用 CSV 格式并将结果复制到剪贴板:

   ```shell
   ocrx /path/to/your/image.jpg --format csv
   ```

## 开发注意事项

1. Swift 版本:
   - 本项目使用 Swift 6.0。确保您的开发环境已安装正确版本的 Swift。

2. 依赖管理:
   - 项目使用 Swift Package Manager 管理依赖。主要依赖包括:
     - ArgumentParser: 用于解析命令行参数
     - Vision: 用于 OCR 处理(系统框架)

3. 文件结构:
   - `Sources/ocrx/main.swift`: 主程序入口和命令行接口
   - `Sources/ocrx/BillOCRResult.swift`: OCR 结果数据模型

4. 错误处理:
   - 确保适当处理文件读取、图像处理和 OCR 识别过程中可能出现的错误。

5. 平台兼容性:
   - 目前仅支持 macOS。如需支持其他平台,需要修改相关平台特定代码。

6. 测试:
   - 建议为主要功能编写单元测试,特别是数据处理和格式转换部分。

7. 性能优化:
   - 对于大型图像,可能需要考虑内存使用和处理时间的优化。

8. 国际化:
   - 如果计划支持多语言,考虑使用本地化字符串。

## 贡献

欢迎提交问题报告和拉取请求。对于重大变更,请先开 issue 讨论您想要改变的内容。

## 许可证

[MIT](https://choosealicense.com/licenses/mit/)
