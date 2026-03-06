import SwiftUI

struct GeoLocationView: View {
    @AppStorage(Constants.UserDefaultsKeys.countryFormat) private var countryFormat = "emojiFlag"
    let location: GeoLocation

    var body: some View {
        let style = CountryDisplayFormat(rawValue: countryFormat) ?? .emojiFlag

        if let countryText = CountryFlagMapper.formattedCountry(
            country: location.country,
            countryCode: location.countryCode,
            style: style
        ) {
            HStack(spacing: 4) {
                Text(countryText)
                if !location.city.isEmpty {
                    Text("\u{00B7}")
                    Text(location.city)
                }
                if !location.isp.isEmpty {
                    Text("\u{00B7}")
                    Text(location.isp)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
