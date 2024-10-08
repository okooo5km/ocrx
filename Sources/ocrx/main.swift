import Foundation
import ArgumentParser
import Vision
import AppKit

struct OCRX: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "OCR工具，用于从图像中提取文本",
        version: "0.1.2"
    )

    @Argument(help: "要处理的图像文件路径")
    var imagePath: String?

    @Option(name: [.short, .long], help: "指定保存OCR结果的文件路径")
    var output: String?

    @Option(name: [.short, .long], help: "指定输出格式（baidu、csv或native）")
    var format: String = "baidu" 

    @Flag(name: [.short, .long], help: "输出紧凑的BillOCRResult")
    var compact: Bool = false

    @Option(name: [.short, .long], help: "指定要批处理的图像目录")
    var batch: String?

    mutating func run() throws {
        if let batchPath = batch {
            try processBatch(batchPath: batchPath)
        } else if let imagePath = imagePath {
            try processSingleImage(imagePath: imagePath)
        } else {
            throw ValidationError("请指定图像路径或批处理目录")
        }
    }

    func processBatch(batchPath: String) throws {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: batchPath)
        var batchResults: [String: String] = [:]

        while let filePath = enumerator?.nextObject() as? String {
            let fullPath = (batchPath as NSString).appendingPathComponent(filePath)
            let ext = (filePath as NSString).pathExtension.lowercased()
            if ["jpg", "jpeg", "png"].contains(ext) {
                let result = try processImage(url: URL(fileURLWithPath: fullPath))
                let formattedResult = formatResult(result)
                batchResults[filePath] = formattedResult
            }
        }

        let jsonData = try JSONSerialization.data(withJSONObject: batchResults, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        if let outputPath = output {
            try jsonString.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("批处理结果已保存到 \(outputPath)")
        } else {
            copyToClipboard(jsonString)
            print("批处理结果已复制到剪贴板")
        }
    }

    func processSingleImage(imagePath: String) throws {
        let imageURL = URL(fileURLWithPath: imagePath)
        let result = try processImage(url: imageURL)
        let formattedResult = formatResult(result)

        if let outputPath = output {
            try formattedResult.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("结果已保存到 \(outputPath)")
        } else {
            copyToClipboard(formattedResult)
            print("结果已复制到剪贴板")
        }
    }

    func formatResult(_ result: BillOCRResult) -> String {
        switch format.lowercased() {
        case "baidu":
            return compact ? result.compact.json : result.json
        case "csv":
            return compact ? result.compact.csv : result.csv
        case "native":
            return compact ? result.compact.raw : result.raw
        default:
            return "错误：无效的格式。请使用 'baidu'、'csv' 或 'native'。"
        }
    }

    func processImage(url: URL) throws -> BillOCRResult {
        guard let img = NSImage(contentsOf: url) else {
            throw ValidationError("Unable to load image: \(url)")
        }
        print("Image loaded: \(url)")

        guard let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ValidationError("Unable to create CGImage")
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        let imageWidth = Int(cgImage.width)
        let imageHeight = Int(cgImage.height)
        
        let request = VNRecognizeTextRequest()
        request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en_US"]
        
        do {
            try requestHandler.perform([request])
        } catch {
            throw ValidationError("Unable to perform request: \(error)")
        }
        
        guard let observations = request.results else {
            throw ValidationError("Unable to get recognition results")
        }
        
        let ocrWords = observations.compactMap { observation -> BillOCRResult.Words? in
            guard let candidate = observation.topCandidates(1).first else {
                return nil
            }
            
            let words = candidate.string
            let boundingBox = try? candidate.boundingBox(for: words.startIndex..<words.endIndex)
            let rect = VNImageRectForNormalizedRect(boundingBox?.boundingBox ?? .zero, Int(CGFloat(imageWidth)), Int(CGFloat(imageHeight)))
            
            return BillOCRResult.Words(
                words: words,
                location: .init(
                    top: Int(rect.origin.y),
                    left: Int(rect.origin.x),
                    width: Int(rect.size.width),
                    height: Int(rect.size.height)
                )
            )
        }
        
        let ocrResultSorted = ocrWords.sorted { $0.location.top > $1.location.top }
        return BillOCRResult(words: ocrResultSorted, count: ocrResultSorted.count)
    }

    func copyToClipboard(_ string: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
        #else
        print("Clipboard functionality not implemented on this platform")
        #endif
    }
}

OCRX.main()
