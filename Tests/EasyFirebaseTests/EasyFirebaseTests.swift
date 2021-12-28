import XCTest
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

@testable import EasyFirebase

final class EasyFirebaseTests: XCTestCase {
  
  override func setUp() {
    let appOptions = FirebaseOptions(
      googleAppID: "1:308133207168:ios:3eb613d3a5ec91ee545a65",
      gcmSenderID: "308133207168"
    )
    appOptions.apiKey = "AIzaSyACn2tBLSoPMGhOQqYONFsUjNbXUxOwqbI"
    appOptions.projectID = "easy-firebase"
    EasyFirebase.configure(options: appOptions)
  }
  
  func test() throws {
    
    EasyFirebase.logLevel = .all
    EasyFirebase.log("Easy Firebase Tests are active!")
    
    let testDoc = TestDocument()
    
    testDoc.set()
  }
}
