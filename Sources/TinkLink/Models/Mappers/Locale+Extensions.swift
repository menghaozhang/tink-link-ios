import Foundation

extension Locale: TinkCompatible { }

/// Availabl locales for Tink link
extension Tink where Base == Locale {
    public static var availableLocales: [Locale] {
        let locales = [
            Locale(identifier: "da_DK"),
            Locale(identifier: "de_DE"),
            Locale(identifier: "en_GB"),
            Locale(identifier: "en_US"),
            Locale(identifier: "fr_FR"),
            Locale(identifier: "nl_NL"),
            Locale(identifier: "no_NO"),
            Locale(identifier: "sv_SE"),
            Locale(identifier: "pt_PT")
        ]
        return locales
    }
    
    public static func availableLocaleWith(languageCode: String) -> Locale? {
        return availableLocales.first { $0.languageCode == languageCode }
    }
    
    public static func availableLocaleWith(regionCode: String) -> Locale? {
        return availableLocales.first { $0.regionCode == regionCode }
    }
    
    /// Fallback locales if no other locale is available
    public static var fallBackLocale: Locale {
        return Locale(identifier: "en_US")
    }
    
    /// Default available locale that will be used based on the current locale
    public static var defaultLocale: Locale {
        if let languageCode = Locale.current.languageCode, let locale = Locale.tink.availableLocaleWith(languageCode: languageCode) {
            return locale
        } else if let regionCode = Locale.current.regionCode, let locale = Locale.tink.availableLocaleWith(regionCode: regionCode) {
            return  locale
        } else {
            return fallBackLocale
        }
    }
}
