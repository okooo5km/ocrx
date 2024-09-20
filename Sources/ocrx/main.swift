import Foundation
import ArgumentParser
import Vision
import AppKit

struct OCRX: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ocrx",
        abstract: "A command-line tool for OCR processing"
    )

    @Argument(help: "Path to the image file to be processed")
    var imagePath: String

    @Option(name: [.short, .long], help: "Specify the file path to save the OCR result")
    var output: String?

    @Option(name: [.short, .long], help: "Specify the output format (baidu, csv, or native)")
    var format: String = "baidu" 

    mutating func run() throws {
        let imageURL: URL
        if imagePath.hasPrefix("/") {
            // Absolute path
            guard let url = URL(string: imagePath) else {
                throw ValidationError("Invalid image path")
            }
            imageURL = url
        } else {
            // Relative path
            imageURL = URL(fileURLWithPath: imagePath)
        }

        let result = try processImage(url: imageURL)

        let formattedResult: String
        switch format.lowercased() {
        case "baidu":
            formattedResult = result.json
        case "csv":
            formattedResult = result.csv
        case "native":
            formattedResult = result.raw
        default:
            throw ValidationError("Invalid format. Please use 'baidu', 'csv', or 'native'.")
        }

        if let outputPath = output {
            try formattedResult.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("Result saved to \(outputPath)")
        } else {
            copyToClipboard(formattedResult)
            print("Result copied to clipboard")
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
