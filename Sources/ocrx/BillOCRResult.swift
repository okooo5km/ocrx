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
        var result = "text,left,top,width,height\n\n"
        for word in words {
            result.append("\(word.words),\(word.location.left),\(word.location.top),\(word.location.width),\(word.location.height)\n\n")
        }
        return result
    }
}