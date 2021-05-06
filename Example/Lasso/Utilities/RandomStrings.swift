//
// ==----------------------------------------------------------------------== //
//
//  Utilities.swift
//
//  Created by Steven Grosmark on 5/9/19.
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2020 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import Foundation

extension String {
    
    static func loremIpsum(paragraphs count: Int) -> String {
        var paragraphs = [String]()
        for _ in 0..<count {
            paragraphs.append(.loremIpsum(sentences: Int.random(in: 1...4)))
        }
        return paragraphs.map({ $0.sentenceCased }).joined(separator: "\n")
    }
    
    static func loremIpsum(sentences count: Int) -> String {
        var sentences = [String]()
        for _ in 0..<count {
            sentences.append(.loremIpsum(words: Int.random(in: 3...11)))
        }
        return sentences.map({ $0.sentenceCased }).joined(separator: ". ") + "."
    }
    
    static func loremIpsum(words count: Int) -> String {
        let words = ["fusce", "nam", "mollis", "ultrices", "vehicula", "congue", "nunc", "condimentum", "sapien", "porttitor", "risus", "id", "donec", "feugiat", "fames", "fringilla", "ipsum", "quis", "at", "dictum", "adipiscing", "faucibus", "lacinia", "facilisis", "magna", "vitae", "leo", "porta", "tortor", "dignissim", "est", "suspendisse", "egestas", "augue", "pulvinar", "venenatis", "iaculis", "suscipit", "velit", "eget", "volutpat", "vivamus", "posuere", "pellentesque", "arcu", "cras", "enim", "sollicitudin", "consequat", "mattis", "vestibulum", "sed", "nisi", "ante", "rhoncus", "ut", "ligula", "dapibus", "lobortis", "odio", "ultricies", "elementum", "molestie", "mi", "lorem", "viverra", "a", "tellus", "euismod", "dui", "massa", "aliquet", "lectus", "diam", "neque", "sem", "sagittis", "pharetra", "efficitur", "aliquam", "nullam", "vulputate", "mauris", "cursus", "ac", "interdum", "maecenas", "facilisi", "ex", "malesuada", "sit", "felis", "varius", "turpis", "hendrerit", "accumsan", "tempus", "auctor", "integer", "proin", "convallis", "libero", "tincidunt", "sodales", "morbi", "gravida", "orci", "elit", "non", "nibh", "nulla", "placerat", "praesent", "dolor", "vel", "lacus", "amet", "et", "urna", "fermentum", "eros", "erat", "purus", "aenean", "finibus", "consectetur", "laoreet", "primis", "in", "tristique", "ornare", "etiam", "maximus", "nec", "quam"].shuffled()
        return words[0..<Swift.min(count, words.count)].joined(separator: " ")
    }
    
    static func randomWord() -> String {
        let consonants = "bcdfghjklmnprstvwz"
        let vowels = "aeiou"
        var s = ""
        for _ in 0..<Int.random(in: 2...4) {
            s += "\(consonants.randomCharacter())\(vowels.randomCharacter())"
        }
        return s
    }
    
    func randomCharacter() -> Character {
        return randomElement() ?? "a"
    }
    
    var firstLetter: String {
        guard !isEmpty else { return "" }
        return String(self[startIndex..<index(after: startIndex)])
    }
    var sentenceCased: String { return self.firstLetter.uppercased() + self.dropFirst() }
}
