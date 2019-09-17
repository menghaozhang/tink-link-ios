import Foundation

extension Locale: TinkCompatible { }

/// Availabl locales for Tink link
extension Tink where Base == Locale {
    public static var availableLocalesGroupedByRegionCode: [String: Locale] {
        let locales = [
            "DK": Locale(identifier: "da_DK"),
            "DE": Locale(identifier: "de_DE"),
            "GB": Locale(identifier: "en_GB"),
            "US": Locale(identifier: "en_US"),
            "FR": Locale(identifier: "fr_FR"),
            "NL": Locale(identifier: "nl_NL"),
            "NO": Locale(identifier: "no_NO"),
            "SE": Locale(identifier: "sv_SE"),
            "PT": Locale(identifier: "pt_PT")
        ]
        return locales
    }
}
