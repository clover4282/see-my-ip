import SwiftUI

struct GeoLocationView: View {
    let location: GeoLocation

    var body: some View {
        if let countryText = CountryFlagMapper.displayText(for: location.countryCode) {
            HStack(spacing: 4) {
                Text(countryText)
                    .help(location.country)
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
