import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Shield Configuration Extension for customizing blocked app appearance
class ShieldConfigurationDataSource: NSObject, ManagedSettingsUI.ShieldConfigurationDataSource {
    
    // MARK: - Application Shield Configuration
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
            icon: UIImage(systemName: "leaf.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Touch Grass!",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\(application.localizedDisplayName ?? "This app") is blocked. Go outside and enjoy nature to unlock.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGreen,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Learn More",
                color: .systemGreen
            )
        )
    }
    
    // MARK: - Application Category Shield Configuration
    override func configuration(shielding applicationCategory: ActivityCategory, in set: ActivityCategorySet) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
            icon: UIImage(systemName: "leaf.fill"),
            title: ShieldConfiguration.Label(
                text: "Category Blocked",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Apps in this category are blocked. Take a break and touch some grass!",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGreen
        )
    }
    
    // MARK: - Web Domain Shield Configuration
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
            icon: UIImage(systemName: "leaf.fill"),
            title: ShieldConfiguration.Label(
                text: "Website Blocked",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\(webDomain.domain ?? "This website") is blocked. Time for a nature break!",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGreen
        )
    }
    
    // MARK: - Web Domain Category Shield Configuration
    override func configuration(shielding webDomainCategory: ActivityCategory, in set: ActivityCategorySet) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2),
            icon: UIImage(systemName: "leaf.fill"),
            title: ShieldConfiguration.Label(
                text: "Website Category Blocked",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Websites in this category are blocked. Go touch grass!",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGreen
        )
    }
}