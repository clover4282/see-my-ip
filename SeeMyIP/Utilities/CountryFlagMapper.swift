import Foundation

enum CountryFlagMapper {
    static func flag(for countryCode: String) -> String {
        let code = countryCode.uppercased()
        guard code.count == 2 else { return "" }
        let base: UInt32 = 127397
        var flag = ""
        for scalar in code.unicodeScalars {
            guard let flagScalar = Unicode.Scalar(base + scalar.value) else { return "" }
            flag.append(Character(flagScalar))
        }
        return flag
    }

    static func displayText(for countryCode: String?) -> String? {
        guard let countryCode else { return nil }
        let emojiFlag = flag(for: countryCode)
        return emojiFlag.isEmpty ? countryCode.uppercased() : emojiFlag
    }
}
