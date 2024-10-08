# OCRX

OCRX 是一个基于 Swift 的命令行工具，用于对图像进行光学字符识别(OCR)处理。它支持多种输出格式，并可以将结果保存到文件或复制到剪贴板。

## 功能特点

- 支持处理多种图像格式（jpg、jpeg、png）
- 可识别中文（简体和繁体）和英文
- 支持多种输出格式：百度格式（JSON）、CSV 和原生格式
- 可将结果保存到文件或复制到剪贴板
- 支持批量处理图像目录
- 支持紧凑输出模式
- 基于 Apple 的 Vision 框架，提供高精度的 OCR 识别

## 系统要求

- macOS 13.0 或更高版本
- Swift 6.0 或更高版本

## 安装

1. 克隆此仓库：

   ```shell
   git clone https://github.com/yourusername/ocrx.git
   cd ocrx
   ```

2. 构建项目：

   ```shell
   swift build -c release
   ```

3. （可选）将可执行文件复制到系统路径：

   ```shell
   sudo cp .build/release/ocrx /usr/local/bin/ocrx
   ```

## 使用方法

基本用法：

```shell
ocrx <image-path> [--output <output>] [--format <format>]
```

参数说明：

- `<image-path>`: 要处理的图像文件路径
- `--output <output>`: 指定输出文件路径（可选）
- `--format <format>`: 指定输出格式，可选值为 baidu、csv 或 native（默认为 baidu）

### 示例

1. 处理单个图像并将结果输出到控制台：

   ```shell
   ocrx /path/to/image.jpg
   ```

2. 处理图像并将结果保存到文件：

   ```shell
   ocrx /path/to/image.jpg --output result.json
   ```

3. 使用 CSV 格式输出结果：

   ```shell
   ocrx /path/to/image.jpg --format csv
   ```

4. 批量处理目录中的所有图像：

   ```shell
   ocrx /path/to/image/directory --output results.json
   ```

## 输出格式

1. 百度格式（默认）：

   ```json
   {
     "words_result": [
       {
         "words": "识别的文本",
         "location": {
           "top": 100,
           "left": 50,
           "width": 200,
           "height": 30
         }
       }
     ],
     "words_result_num": 1
   }
   ```

2. CSV 格式：

   ```csv
   文本,左,上,宽,高
   "识别的文本",50,100,200,30
   ```

3. 原生格式：

   ```native
   识别的文本 (50, 100, 200, 30)
   ```

## 注意事项

- 确保您有足够的权限访问和处理目标图像文件。
- 对于大量图像的批处理，请考虑使用更强大的硬件以提高处理速度。
- 识别结果的准确性可能受图像质量、文字清晰度等因素影响。

## 贡献

欢迎提交问题报告和改进建议。如果您想贡献代码，请遵循以下步骤：

1. Fork 本仓库
2. 创建您的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 许可证

本项目采用 MIT 许可证。详情请参见 [LICENSE](LICENSE) 文件。

## 联系方式

如有任何问题或建议，请通过以下方式联系我们：

- 电子邮件：<your.email@example.com>
- GitHub Issues：<https://github.com/yourusername/ocrx/issues>

感谢您使用 OCRX！
