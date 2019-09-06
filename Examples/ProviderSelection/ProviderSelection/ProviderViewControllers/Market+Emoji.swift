import TinkLink

extension Market {
    /// Emoji Flag
    ///
    /// - Note: Based on [Swift Tricks: Emoji Flags](https://www.timekl.com/blog/2017/08/31/swift-tricks-emoji-flags/)
    var emojiFlag: String? {
        let uppercasedCode = code.uppercased()
        guard uppercasedCode.count == 2 else { return nil }
        guard uppercasedCode.unicodeScalars.allSatisfy({ $0.isASCII }) else { return nil }

        let regionalIndicatorSymbols = uppercasedCode.unicodeScalars.map { $0.regionalIndicatorSymbol() }
        return String(String.UnicodeScalarView(regionalIndicatorSymbols))
    }
}

extension Unicode.Scalar {
    fileprivate func regionalIndicatorSymbol() -> Unicode.Scalar {
        precondition(isASCII)
        precondition(properties.isUppercase)
        // 0x1F1E6 = REGIONAL INDICATOR SYMBOL LETTER A
        // 0x1F1FF = REGIONAL INDICATOR SYMBOL LETTER Z
        return Unicode.Scalar(value + (0x1F1E6 - Unicode.Scalar("A").value))!
    }
}
