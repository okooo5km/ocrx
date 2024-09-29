import Foundation

struct BillOCRResult: Codable {
    var words: [Words]
    var count: Int
    
    struct Words: Codable {
        var words: String
        var location: Location
        
        struct Location: Codable {
            var top: Int
            var left: Int
            var width: Int
            var height: Int
        }
    }

    var compact: BillOCRResult {
        var mergedWords: [Words] = []
        var currentLine: [Words] = []
        
        for word in words {
            if let lastWord = currentLine.last {
                if abs(lastWord.location.top - word.location.top) < 10 { // 判断 top 是否比较接近
                    currentLine.append(word)
                } else {
                    if !currentLine.isEmpty {
                        let mergedWord = mergeWords(currentLine)
                        mergedWords.append(mergedWord)
                    }
                    currentLine = [word]
                }
            } else {
                currentLine.append(word)
            }
        }
        
        if !currentLine.isEmpty {
            let mergedWord = mergeWords(currentLine)
            mergedWords.append(mergedWord)
        }
        
        return BillOCRResult(words: mergedWords, count: mergedWords.count)
    }
    
    private func mergeWords(_ words: [Words]) -> Words {
        let mergedText = words.map { $0.words }.joined(separator: " ")
        let top = words.map { $0.location.top }.min() ?? 0
        let left = words.map { $0.location.left }.min() ?? 0
        let width = (words.map { $0.location.left + $0.location.width }.max() ?? 0) - left
        let height = (words.map { $0.location.top + $0.location.height }.max() ?? 0) - top
        
        let mergedLocation = Words.Location(top: top, left: left, width: width, height: height)
        return Words(words: mergedText, location: mergedLocation)
    }
    
    var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let data = try! encoder.encode(self)
        if let str = String(data: data, encoding: .utf8) {
            return str
        } else {
            return "Error: Unable to create JSON string."
        }
    }
    
    var raw: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        let data = try! encoder.encode(self)
        if let str = String(data: data, encoding: .utf8) {
            return str
        } else {
            return "Error: Unable to create JSON string."
        }
    }
    
    var csv: String {
        var result = "text,left,top,width,height\n"
        for word in words {
            let text = word.words.replacingOccurrences(of: ",", with: "，")
            result.append("\(text),\(word.location.left),\(word.location.top),\(word.location.width),\(word.location.height)\n")
        }
        return result
    }
}