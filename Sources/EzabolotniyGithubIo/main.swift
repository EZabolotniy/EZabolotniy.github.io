import Foundation
import Publish
import Plot
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct EzabolotniyGithubIo: Website {
  enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:
//    case camera
    case blog
//    case structures
//    case interview
    case about
  }

  struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
  }

  // Update these properties to configure your website:
  var url = URL(string: "https://ezabolotniy.github.io")!
  var name = "iOS Developer Notes"
  var description = "Articles about Swift and iOS Development"
  var language: Language { .english }
  var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
try EzabolotniyGithubIo().publish(
  withTheme: .blog,
  deployedUsing: .gitHub("EZabolotniy/ezabolotniy.github.io", useSSH: false),
  additionalSteps: [
    
  ],
  plugins: [.splash(withClassPrefix: "")]
)
