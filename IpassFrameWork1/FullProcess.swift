//
//  FullProcess.swift
//  IpassFrameWork1
//
//  Created by Mobile on 10/04/24.
//

import Foundation
import DocumentReader
import UIKit

public class StartFullProcess {
    public init() {}
 
    private var selectedScenario: String?
    private var sectionsData: [CustomizationSection] = []
    private var delegate:ScanningResultData?
    public var resultData:DocumentReaderResults?
    
    public static func fullProcessScanning(type: Int, controller: UIViewController, userToken:String, appToken:String, completion: @escaping (String?, Error?) -> Void) {
//        DocReader.shared.processParams.doublePageSpread = true
        DocReader.shared.processParams.multipageProcessing = true
        DocReader.shared.processParams.authenticityParams?.livenessParams?.checkHolo = false
        DocReader.shared.processParams.authenticityParams?.livenessParams?.checkOVI = false
        DocReader.shared.processParams.authenticityParams?.livenessParams?.checkMLI = false
        
        let config = DocReader.ScannerConfig()
        
        switch type {
        case 0:
            config.scenario = RGL_SCENARIO_FULL_AUTH
        case 1:
            config.scenario = RGL_SCENARIO_CREDIT_CARD
        case 2:
            config.scenario = RGL_SCENARIO_MRZ
        case 3:
            config.scenario = RGL_SCENARIO_BARCODE
        default:
            config.scenario = RGL_SCENARIO_FULL_AUTH
        }
        DocReader.shared.showScanner(presenter: controller, config: config) { [self] (action, docResults, error) in
            if action == .complete || action == .processTimeout {
//                 print(docResults?.rawResult as Any)
                
    
                    if docResults?.chipPage != 0  {
                        //self.startRFIDReading(res)
                        
                        DocReader.shared.startRFIDReader(fromPresenter: controller, completion: { [] (action, results, error) in
                            switch action {
                            case .complete:
                                guard let results = results else {
                                    return
                                }
//                                completion(results.rawResult, nil)
                                getDocImages(datavalue: docResults ?? DocumentReaderResults(), userToken: userToken, appToken: appToken, completion: {(resuldata, error)in
                                    if let result = resuldata{
                                        completion(result, nil)
                                    }else{
                                        completion(nil, error)
                                    }
                                })
                            case .cancel:
                                guard let results = docResults else {
                                    return
                                }
//                                completion(results.rawResult, nil)
                                getDocImages(datavalue: docResults ?? DocumentReaderResults(), userToken: userToken, appToken: appToken, completion: {(resuldata, error)in
                                    if let result = resuldata{
                                        completion(result, nil)
                                    }else{
                                        completion(nil, error)
                                    }
                                })
                            case .error:
                                print("Error")
                                completion(nil, error)
                            default:
                                break
                            }
                        })

                        
                        
                    } else {
//                        completion(docResults?.rawResult, nil)
                        getDocImages(datavalue: docResults ?? DocumentReaderResults(), userToken: userToken, appToken: appToken, completion: {(resuldata, error)in
                            if let result = resuldata{
                                completion(result, nil)
                            }else{
                                completion(nil, error)
                            }
                        })

                    }
 
            }
            else  if action == .cancel  {
                completion(nil, error)
            }
        }
      
    }
    
    
    
    private static func generateRandomTwoDigitNumber() -> String {
        let lowerBound = 10
        let upperBound = 999999999
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randStr =  String((0..<10).map{ _ in letters.randomElement()! })
        
        
        var randomValue = String(Int(arc4random_uniform(UInt32((upperBound - lowerBound + 1)))) + lowerBound)
        
        return randomValue + randStr
    }

    private static func getDocImages(datavalue: DocumentReaderResults, userToken:String, appToken:String, completion: @escaping (String?, Error?) -> Void) {
        
//        let dispatchGroup = DispatchGroup()
//        var ocrResult: String?
//        var saveResult: String?
//
//        var image1 = ""
//        var image2 = ""
//        
//        for i in (0 ..<  datavalue.graphicResult.fields.count) {
//            if(datavalue.graphicResult.fields[i].fieldName.lowercased() == "document image") {
//                if(image1 == "") {
//                    image1 = datavalue.graphicResult.fields[i].value.toBase64() ?? ""
//                }
//                else  if(image2 == "") {
//                    image2 = datavalue.graphicResult.fields[i].value.toBase64() ?? ""
//                }
//            }
//           }
        
        let randomNo = generateRandomTwoDigitNumber()
        
        saveDataPostApi(random: randomNo, results: datavalue, userToken: userToken, appToken: appToken, completion: { (result, error) in
            if let result = result {
                completion(result, nil)
            } else {
                completion(nil, error)
            }
        })

    }

    
   private func randomStringGenerator(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    


    
    private static func saveDataPostApi(random:String,results:DocumentReaderResults, userToken:String, appToken:String,  completion: @escaping (String?, Error?) -> Void){
        guard let apiURL = URL(string: "https://plusapi.ipass-mena.com/api/v1/ipass/sdk/data/save") else { return }
       let jsondata = convertStringToJSON(results.rawResult)
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dict:[String:Any] = [:]
        let parameters: [String: Any] = [
            "email": "ipassmobile@yopmail.com",
            "idvData": jsondata ?? "",
            "livenessdata": dict,
            "randomid": random,
            "userToken" : userToken,
            "appToken" : appToken
        ]
        
//        print("apiURL : ",apiURL)
//        print("parameters : ",parameters)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("Error serializing parameters: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let status = response.statusCode
            print("Response status code: \(status)")

            if status == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Response save data Api-=-=",json)
                        completion("\(json)", nil)
                    } else {
                        print("Failed to parse JSON response")
                    }
                } catch let error {
                    print("Error parsing JSON response: \(error.localizedDescription)")
                    completion(nil, error)
                }
                
            } else {
                print("Unexpected status code: \(status)")
            }
//            APIHandler.fetchData(token: UserLocalStore.shared.token, sessId: UserLocalStore.shared.sessionId) {status, statusString in
//                if status == true {
//                    print(statusString)
//                    print("Received JSON data:", statusString)
//                    
//                } else {
//                    print(statusString)
//                }
//            }
            let datatoken = "eyJhbGciOiJIUzI1NiJ9.eW9wbWFpbDEyM0BnbWFpbC5jb21hZnNkIHNkZmEgICA2ODlmMDJhYy1iZGMwLTQ1YzAtOWVlNC04NDRmOGMzMGQ0YzU.LiGjDJwSjOAMBU-ssBA0DbYPlz_sPLexErz70hGCP6A"
            APIHandler.getDataFromAPI(token: datatoken, sessId: UserLocalStore.shared.sessionId) { (data, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let data = data {
                    if let dataString = String(data: data, encoding: .utf8) {
                                print(dataString)
                            } else {
                                print("Error converting data to string.")
                            }
                    APIHandler.fetchDataliveness(token: datatoken, sessId: UserLocalStore.shared.sessionId) { (data, error) in
                        if let error = error {
                            print("Error: \(error)")
                            return
                        }
                        
                        if let data = data {
                            if let dataString = String(data: data, encoding: .utf8) {
                                        print(dataString)
                                    } else {
                                        print("Error converting data to string.")
                                    }
                    }
                }
                    
                    
                    
                    
                }
            }
            
        }

        task.resume()
    }

    
   private static func convertStringToJSON(_ jsonString: String) -> Any? {
        // Convert the string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        
        // Use JSONSerialization to parse the data into a JSON object (Dictionary or Array)
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return jsonObject
        } catch {
            print("Error converting JSON data: \(error)")
            return nil
        }
    }

    
    lazy var onlineProcessing: CustomizationItem = {
        let item = CustomizationItem("Online Processing") { [weak self] in
            guard let self = self else { return }
//            let container = UINavigationController(rootViewController: OnlineProcessingViewController())
//            container.modalPresentationStyle = .fullScreen
//            self.present(container, animated: true, completion: nil)
        }
        return item
    }()
    
    private func initSections() {
        // 1. Default
        let defaultScanner = CustomizationItem("Default (showScanner)") {
            DocReader.shared.functionality = ApplicationSetting.shared.functionality
        }
        
        defaultScanner.resetFunctionality = false
        let stillImage = CustomizationItem("Gallery (recognizeImages)")
        stillImage.actionType = .gallery
        let recognizeImageInput = CustomizationItem("Recognize images with light type") { [weak self] in
            guard let self = self else { return }
            self.recognizeImagesWithImageInput()
        }
        
        recognizeImageInput.actionType = .custom
        let defaultSection = CustomizationSection("Default", [defaultScanner, stillImage, recognizeImageInput])
        sectionsData.append(defaultSection)
        
        // 2. Custom modes
        let childModeScanner = CustomizationItem("Child mode") { [weak self] in
            guard let self = self else { return }
            
        }
        childModeScanner.actionType = .custom
        let manualMultipageMode = CustomizationItem("Manual multipage mode") { [weak self] in
            guard let self = self else { return }
            // Set default copy of functionality
            DocReader.shared.functionality = ApplicationSetting.shared.functionality
            // Manual multipage mode
            DocReader.shared.functionality.manualMultipageMode = true
            DocReader.shared.startNewSession()
            self.showScannerForManualMultipage(controller: UIViewController())
        }
        manualMultipageMode.resetFunctionality = false
       // manualMultipageMode.actionType = .custom
        let customModedSection = CustomizationSection("Custom", [childModeScanner, manualMultipageMode, onlineProcessing])
        sectionsData.append(customModedSection)
        
        // 3. Custom camera frame
        let customBorderWidth = CustomizationItem("Custom border width") { () -> (Void) in
            DocReader.shared.customization.cameraFrameBorderWidth = 10
        }
        let customBorderColor = CustomizationItem("Custom border color") { () -> (Void) in
            DocReader.shared.customization.cameraFrameDefaultColor = .red
            DocReader.shared.customization.cameraFrameActiveColor = .purple
        }
        let customShape = CustomizationItem("Custom shape") { () -> (Void) in
            DocReader.shared.customization.cameraFrameShapeType = .corners
            DocReader.shared.customization.cameraFrameLineLength = 40
            DocReader.shared.customization.cameraFrameCornerRadius = 10
            DocReader.shared.customization.cameraFrameLineCap = .round
        }
        let customOffset = CustomizationItem("Custom offset") { () -> (Void) in
            DocReader.shared.customization.cameraFrameOffsetWidth = 50
        }
        let customAspectRatio = CustomizationItem("Custom aspect ratio") { () -> (Void) in
            DocReader.shared.customization.cameraFramePortraitAspectRatio = 1.0
            DocReader.shared.customization.cameraFrameLandscapeAspectRatio = 1.0
        }
        let customFramePosition = CustomizationItem("Custom position") { () -> (Void) in
            DocReader.shared.customization.cameraFrameVerticalPositionMultiplier = 0.5
        }
        
        let customCameraFrameItems = [customBorderWidth, customBorderColor, customShape, customOffset, customAspectRatio, customFramePosition]
        let customCameraFrameSection = CustomizationSection("Custom camera frame", customCameraFrameItems)
        sectionsData.append(customCameraFrameSection)
        
        // 4. Custom toolbar
        let customTorchButton = CustomizationItem("Custom torch button") { () -> (Void) in
            DocReader.shared.functionality.showTorchButton = true
            DocReader.shared.customization.torchButtonOnImage = UIImage(named: "light-on")
            DocReader.shared.customization.torchButtonOffImage = UIImage(named: "light-off")
        }
        let customCameraSwitch = CustomizationItem("Custom camera switch button") { () -> (Void) in
            DocReader.shared.functionality.showCameraSwitchButton = true
            DocReader.shared.customization.cameraSwitchButtonImage = UIImage(named: "camera")
        }
        let customCaptureButton = CustomizationItem("Custom capture button") { () -> (Void) in
            DocReader.shared.functionality.showCaptureButton = true
            DocReader.shared.functionality.showCaptureButtonDelayFromStart = 0
            DocReader.shared.functionality.showCaptureButtonDelayFromDetect = 0
            DocReader.shared.customization.captureButtonImage = UIImage(named: "palette")
        }
        let customChangeFrameButton = CustomizationItem("Custom change frame button") { () -> (Void) in
            DocReader.shared.functionality.showChangeFrameButton = true
            DocReader.shared.customization.changeFrameButtonExpandImage = UIImage(named: "expand")
            DocReader.shared.customization.changeFrameButtonCollapseImage = UIImage(named: "collapse")
        }
        let customCloseButton = CustomizationItem("Custom close button") { () -> (Void) in
            DocReader.shared.functionality.showCloseButton = true
            DocReader.shared.customization.closeButtonImage = UIImage(named: "close")
        }
        let customSizeOfToolbar = CustomizationItem("Custom size of the toolbar") { () -> (Void) in
            DocReader.shared.customization.toolbarSize = 120
            DocReader.shared.customization.torchButtonOnImage = UIImage(named: "light-on")
            DocReader.shared.customization.torchButtonOffImage = UIImage(named: "light-off")
            DocReader.shared.customization.closeButtonImage = UIImage(named: "big_close")
            //DocReader.shared.customization.
        }
        
        let customToolbarItems = [customTorchButton, customCameraSwitch, customCaptureButton, customChangeFrameButton, customCloseButton, customSizeOfToolbar]
        let customToolbarSection = CustomizationSection("Custom toolbar", customToolbarItems)
        sectionsData.append(customToolbarSection)
        
        // 5. Custom status messages
        let customText = CustomizationItem("Custom text") { () -> (Void) in
            DocReader.shared.customization.showStatusMessages = true
            DocReader.shared.customization.status = "Custom status"
        }
        
        let customTextFont = CustomizationItem("Custom text font") { () -> (Void) in
            DocReader.shared.customization.showStatusMessages = true
            DocReader.shared.customization.statusTextFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        }
        
        let customTextColor = CustomizationItem("Custom text color") { () -> (Void) in
            DocReader.shared.customization.showStatusMessages = true
            DocReader.shared.customization.statusTextColor = .blue
        }
        let customStatusPosition = CustomizationItem("Custom position") { () -> (Void) in
            DocReader.shared.customization.showStatusMessages = true
            DocReader.shared.customization.statusPositionMultiplier = 0.5
        }
        
        let customStatusItems = [customText, customTextFont, customTextColor, customStatusPosition]
        let customStatusSection = CustomizationSection("Custom status messages", customStatusItems)
        sectionsData.append(customStatusSection)
        
        // 6. Custom result status messages
        let customResultStatusText = CustomizationItem("Custom text") { () -> (Void) in
            DocReader.shared.customization.showResultStatusMessages = true
            DocReader.shared.customization.resultStatus = "Custom result status"
        }
        let customResultStatusFont = CustomizationItem("Custom text font") { () -> (Void) in
            DocReader.shared.customization.showResultStatusMessages = true
            DocReader.shared.customization.resultStatusTextFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        }
        let customResultStatusColor = CustomizationItem("Custom text color") { () -> (Void) in
            DocReader.shared.customization.showResultStatusMessages = true
            DocReader.shared.customization.resultStatusTextColor = .blue
        }
        let customResultStatusBackColor = CustomizationItem("Custom background color") { () -> (Void) in
            DocReader.shared.customization.showResultStatusMessages = true
            DocReader.shared.customization.resultStatusBackgroundColor = .blue
        }
        let customResultStatusPosition = CustomizationItem("Custom position") { () -> (Void) in
            DocReader.shared.customization.showResultStatusMessages = true
            DocReader.shared.customization.resultStatusPositionMultiplier = 0.5
        }
        
        let customResultStatusItems = [customResultStatusText, customResultStatusFont, customResultStatusColor, customResultStatusBackColor, customResultStatusPosition]
        let customResultStatusSection = CustomizationSection("Custom result status messages", customResultStatusItems)
        sectionsData.append(customResultStatusSection)
        
        // 7. Free custom status
        let freeCustomTextAndPostion = CustomizationItem("Free text + position") { () -> (Void) in
            let fontAttributes =  [NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 18)]
            DocReader.shared.customization.customLabelStatus = NSAttributedString(string: "Hello, world!", attributes: fontAttributes)
            DocReader.shared.customization.customStatusPositionMultiplier = 0.5
        }
        
        let customUILayerModeStatic = CustomizationItem("Custom Status & Images & Buttons") { [weak self] in
            guard let self = self else { return }
            self.setupCustomUIFromFile()
        }
        let customUILayerButtons = CustomizationItem("Custom Buttons") { [weak self] in
            guard let self = self else { return }
            self.setupCustomUIButtonsFromFile()
        }
        
        let customUILayerModeAnimated = CustomizationItem("Custom Status Animated") { [weak self] in
            guard let self = self else { return }

        }
        
        let freeCustomStatusItems = [freeCustomTextAndPostion, customUILayerModeStatic, customUILayerButtons, customUILayerModeAnimated]
        let freeCustomStatusSection = CustomizationSection("Free custom status", freeCustomStatusItems)
        sectionsData.append(freeCustomStatusSection)
        
        // 8. Custom animations
        let customAnimationHelpImage = CustomizationItem("Help animation image") { () -> (Void) in
            DocReader.shared.customization.showHelpAnimation = true
            DocReader.shared.customization.helpAnimationImage = UIImage(named: "credit-card")
        }
        let customAnimationNextPageImage = CustomizationItem("Custom the next page animation") { () -> (Void) in
            DocReader.shared.customization.showNextPageAnimation = true
            DocReader.shared.customization.multipageAnimationFrontImage = UIImage(named: "1")
            DocReader.shared.customization.multipageAnimationBackImage = UIImage(named: "2")
        }
        
        let customAnimationItems = [customAnimationHelpImage, customAnimationNextPageImage]
        let customAnimationSection = CustomizationSection("Custom animations", customAnimationItems)
        sectionsData.append(customAnimationSection)
        
        // 9. Custon tint color
        let customTintColor = CustomizationItem("Activity indicator") { () -> (Void) in
            DocReader.shared.customization.activityIndicatorColor = .red
        }
        let custonNextPageButton = CustomizationItem("Next page button") { () -> (Void) in
            DocReader.shared.functionality.showSkipNextPageButton = true
            DocReader.shared.customization.multipageButtonBackgroundColor = .red
        }
        let customAllVisualElements = CustomizationItem("All visual elements") { () -> (Void) in
            DocReader.shared.customization.tintColor = .blue
        }
        
        let customTintColorItems = [customTintColor, custonNextPageButton, customAllVisualElements]
        let customTintColorSection = CustomizationSection("Custom tint color", customTintColorItems)
        sectionsData.append(customTintColorSection)
        
        // 10. Custom background
        let noBackgroundMask = CustomizationItem("No background mask") { () -> (Void) in
            DocReader.shared.customization.showBackgroundMask = false
        }
        let customBackgroundAlpha = CustomizationItem("Custom alpha") { () -> (Void) in
            DocReader.shared.customization.backgroundMaskAlpha = 0.8
        }
        let customBackgroundImage = CustomizationItem("Custom background image") { () -> (Void) in
            DocReader.shared.customization.borderBackgroundImage = UIImage(named: "viewfinder")
        }
        
        let customBackgroundItems = [noBackgroundMask, customBackgroundAlpha, customBackgroundImage]
        let customBackgroundSection = CustomizationSection("Custom background", customBackgroundItems)
        sectionsData.append(customBackgroundSection)
    }
    
    
    @objc func fireTimer() {

    }

    
    
    
    private func setupCustomUIFromFile() {
        if let path = Bundle.main.path(forResource: "layer", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
//                DocReader.shared.customization.actionDelegate = self
                DocReader.shared.customization.customUILayerJSON = jsonDict
            } catch {
                
            }
        }
    }
    
    
    private func setupCustomUIButtonsFromFile() {
        if let path = Bundle.main.path(forResource: "buttons", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                
                DocReader.shared.functionality.showTorchButton = false
                DocReader.shared.functionality.showCloseButton = false
                
                //DocReader.shared.customization.actionDelegate = self
                DocReader.shared.customization.customUILayerJSON = jsonDict
            } catch {
                
            }
        }
    }
    
    private func showScannerForManualMultipage(controller:UIViewController) {
        let config = DocReader.ScannerConfig()
        config.scenario = selectedScenario
        
        DocReader.shared.showScanner(presenter: controller, config:config) { [weak self] (action, result, error) in
            guard let self = self else { return }
            switch action {
            case .cancel:
                print("Cancelled by user")
                DocReader.shared.functionality.manualMultipageMode = false
            case .complete, .processTimeout:
                guard let results = result else {
                    return
                }
                if results.morePagesAvailable != 0 {
                    // Scan next page in manual mode
                    DocReader.shared.startNewPage()
                    self.showScannerForManualMultipage(controller: UIViewController())
                } else if !results.isResultsEmpty() {
                    self.showResultScreen(results)
                    DocReader.shared.functionality.manualMultipageMode = false
                }
            case .error:
                print("Error")
                guard let error = error else { return }
                print("Error string: \(error)")
            case .process:
                guard let result = result else { return }
                print("Scaning not finished. Result: \(result)")
            default:
                break
            }
        }
    }

    
    private func recognizeImagesWithImageInput() {
        let whiteImage = UIImage(named: "white.bmp")
        let uvImage = UIImage(named: "uv.bmp")
        let irImage = UIImage(named: "ir.bmp")
        
        let whiteInput = DocReader.ImageInput(image: whiteImage!, light: .white, pageIndex: 0)
        let uvInput = DocReader.ImageInput(image: uvImage!, light: .UV, pageIndex: 0)
        let irInput = DocReader.ImageInput(image: irImage!, light: .infrared, pageIndex: 0)
        let imageInputs = [whiteInput, irInput, uvInput]
        
        let config = DocReader.RecognizeConfig(imageInputs: imageInputs)
        config.scenario = selectedScenario
        DocReader.shared.recognize(config:config) { action, results, error in
            switch action {
            case .cancel:
                self.stopCustomUIChanges()
              //  print("Cancelled by user")
            case .complete, .processTimeout:
                self.stopCustomUIChanges()
                guard let opticalResults = results else {
                    return
                }
                self.showResultScreen(opticalResults)
            case .error:
                self.stopCustomUIChanges()
                print("Error")
                guard let error = error else { return }
                print("Error string: \(error)")
            case .process:
                guard let result = results else { return }
                print("Scaning not finished. Result: \(result)")
            case .morePagesAvailable:
                print("This status couldn't be here, it uses for -recognizeImage function")
            default:
                break
            }
        }
    }

    
    private func stopCustomUIChanges() {
        DocReader.shared.customization.customUILayerJSON = nil
    }
    
    private func enableUserInterfaceOnSuccess() {
        if let scenario = DocReader.shared.availableScenarios.first {
            selectedScenario = scenario.identifier
        }
    }
    
    
    private func startRFIDReading(presenterClass: UIViewController, opticalResults: DocumentReaderResults?, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        if ApplicationSetting.shared.useCustomRfidController {

        } else {
            DocReader.shared.startRFIDReader(fromPresenter: presenterClass, completion: { [weak self] (action, results, error) in
                var scannResultData: [[String: Any]] = []
                guard let self = self else { return }
                switch action {
                case .complete:
                    guard let results = results else {
                        return
                    }
                  
                    for field in results.textResult.fields {
                        let fieldName = field.fieldName
                        let value = field.value
                        let dict = [fieldName: value]
                        scannResultData.append(dict)
                    }
                    completion(scannResultData, nil)
                    
                    self.showResultScreen(results)
                case .cancel:
                    guard let results = opticalResults else {
                        return
                    }
                  
                    for field in results.textResult.fields {
                        let fieldName = field.fieldName
                        let value = field.value
                        let dict = [fieldName: value]
                        scannResultData.append(dict)
                    }
                    completion(scannResultData, nil)
                    self.showResultScreen(results)
                case .error:
                    print("Error")
                    completion(nil,error)
                default:
                    break
                }
            })
        }
    }
    
    
    private func showResultScreen(_ results: DocumentReaderResults) {
        if ApplicationSetting.shared.isDataEncryptionEnabled {
            StartFullProcess.processEncryptedResults(results) { decryptedResult in
                DispatchQueue.main.async {
                    guard let results = decryptedResult else {
                        print("Can't decrypt result")
                        return
                    }
                    StartFullProcess.presentResults(results)
                }
            }
        } else {
            StartFullProcess.presentResults(results)
        }
    }
    
    public static func presentResults(_ results: DocumentReaderResults) {
        var dict = [String:Any]()
        for i in 0 ..< results.textResult.fields.count {

            print("Title-=-=",results.textResult.fields[i].fieldName)
            let fileds = results.textResult.fields[i].fieldName
//            print("Title",results.textResult.fields[i].fieldType)
            print("data-=-=",results.textResult.fields[i].value)
            let value = results.textResult.fields[i].value
            dict = [fileds:value]
//            delegate?.getScanningData(result: dict)
            
    }

        }
    

    
    
    var audioPlayer: AVAudioPlayer?
    func handleDataForNavigation(_ results: DocumentReaderResults)  {
        
    }
    
    
    // MARK: - Encrypted processing
    public static func processEncryptedResults(_ encrypted: DocumentReaderResults, completion: ((DocumentReaderResults?) -> (Void))?) {
        let json = encrypted.rawResult
        
        let data = Data(json.utf8)

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let containers = json["ContainerList"] as? [String: Any] else {
                    completion?(nil)
                    return
                }
                guard let list = containers["List"] as? [[String: Any]] else {
                    completion?(nil)
                    return
                }
                
                let processParam:[String: Any] = [
                    "scenario": RGL_SCENARIO_FULL_PROCESS,
                    "alreadyCropped": true
                ]
                let params:[String: Any] = [
                    "List": list,
                    "processParam": processParam
                ]
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                    completion?(nil)
                    return
                }
                sendDecryptionRequest(jsonData) { result in
                    completion?(result)
                }
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            
        }
    }
    
    public static func sendDecryptionRequest(_ jsonData: Data, _ completion: ((DocumentReaderResults?) -> (Void))? ) {
        guard let url = URL(string: "") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            guard let jsonData = data else {
                completion?(nil)
                return
            }
            
            let decryptedResult = String(data: jsonData, encoding: .utf8)
                .flatMap { DocumentReaderResults.initWithRawString($0) }
            completion?(decryptedResult)
        })

        task.resume()
    }
    
    
    
    public static func getRfidCertificates(bundleName: String) -> [PKDCertificate] {
        var certificates: [PKDCertificate] = []
        let masterListURL = Bundle.main.bundleURL.appendingPathComponent(bundleName)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: masterListURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            
            for content in contents {
//                if let cert = try? Data(contentsOf: content)  {
//                    certificates.append(PKDCertificate.init(binaryData: cert, resourceType: PKDCertificate.findResourceType(typeName: content.pathExtension), privateKey: nil))
//                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return certificates
    }
    
   
    
public static func showCameraViewControllerForMrz(controller:UIViewController) {
        let config = DocReader.ScannerConfig()
       config.scenario = RGL_SCENARIO_FULL_AUTH
        
        DocReader.shared.showScanner(presenter: controller , config:config) {  (action, result, error) in
           // guard let self = self else { return }
            
            switch action {
            case .cancel:
              //  self.stopCustomUIChanges()
                print("Cancelled by user")
            case .complete, .processTimeout:
              //  self.stopCustomUIChanges()
                guard let opticalResults = result else {
                    return
                }
//                if opticalResults.chipPage != 0 && UserLocalStore.shared.RFIDChipProcessing == true {
//                    self.startRFIDReading(opticalResults)
//                } else {
              // showResultScreen(opticalResults)
               // }
            case .error:
               // self.stopCustomUIChanges()
                print("Error")
                guard let error = error else { return }
                print("Error string: \(error)")
            case .process:
                guard let result = result else { return }
                print("Scaning not finished. Result: \(result)")
                print(result.rawResult)
            case .morePagesAvailable:
                print("This status couldn't be here, it uses for -recognizeImage function")
            default:
                break
            }
        }
    }
    public static func getRfidTACertificates() -> [PKDCertificate] {
        var paCertificates: [PKDCertificate] = []
        let masterListURL = Bundle.main.bundleURL.appendingPathComponent("CertificatesTA.bundle")
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: masterListURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            
            var filesCertMap: [String: [URL]] = [:]
            
            for content in contents {
                let fileName = content.deletingPathExtension().lastPathComponent
                if filesCertMap[fileName] == nil {
                    filesCertMap[fileName] = []
                }
                filesCertMap[fileName]?.append(content.absoluteURL)
            }
            
            for (_, certificates) in filesCertMap {
                var binaryData: Data?
                var privateKey: Data?
                for cert in certificates {
                    if let data = try? Data(contentsOf: cert) {
                        if cert.pathExtension.elementsEqual("cvCert") {
                            binaryData = data
                        } else {
                            privateKey = data
                        }
                    }
                }
                if let data = binaryData {
                    paCertificates.append(PKDCertificate.init(binaryData: data, resourceType: .certificate_TA, privateKey: privateKey))
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return paCertificates
    }
    
}

public protocol ScanningResultData:AnyObject{
    func getScanningData(result:[String:Any])
}


private class ImageRequest {
    var image1: String = ""
    var image2: String = ""
    
    func isEmpty() -> Bool {
        return image1.isEmpty
    }
}
extension UIImage {
    func toBase64() -> String? {
        // Convert UIImage to Data
        guard let imageData = self.pngData() else {
            return nil
        }
        
        // Convert Data to base64 string
        let base64String = imageData.base64EncodedString(options: [])
        return base64String
    }
}







 
//    private static func faceMatchingApi(frontImg: String,backImg:String) {
//         guard let apiURL = URL(string: "https://plusapi.ipass-mena.com/api/v1/ipass/plus/ocr/data?token=eyJhbGciOiJIUzI1NiJ9.aXBhc3Ntb2JpbGVAeW9wbWFpbC5jb21pcGFzcyBpcGFzcw.y66dMZJUkzYrRZoczlkNum8unLc910zIuGUVaQW5lUI") else {
//             return
//         }
//
//         var parameters: [String: Any] = [:]
//
//         parameters["email"] = "ipassmobile@yopmail.com"
//         parameters["auth_token"] = UserLocalStore.shared.token
//         parameters["image1"] = frontImg
//         parameters["image2"] = backImg
//         parameters["custEmail"] = "anshul12@gmail.com"
//         parameters["workflow"] = "10032"
//         parameters["sid"] = "47"
//
//        print("dictData", parameters)
//         // Create JSON data from parameters
//         guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
//             print("Error converting parameters to JSON")
//             return
//         }
//
//         var request = URLRequest(url: apiURL)
//         request.httpMethod = "POST"
//         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//         request.httpBody = jsonData
//
//         let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//             DispatchQueue.main.async {
//                 // Handle response
//                 if let error = error {
//                     print("Error: \(error.localizedDescription)")
//
//                     return
//                 }
//
//                 guard let httpResponse = response as? HTTPURLResponse else {
//                     print("Invalid response")
//
//                     return
//                 }
//
//                 let statusCode = httpResponse.statusCode
//                 print("Status code: \(statusCode)")
//
//                 if statusCode == 201 {
//                     if let responseData = data {
//                         do {
//                             if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
//                                 print("Response JSON: \(json)")
//
//
//                             }
//                         } catch {
//                             print("Error decoding JSON: \(error.localizedDescription)")
//
//                         }
//                     }
//                 } else {
//                     print("Invalid status code: \(statusCode)")
//                     print("error", error?.localizedDescription)
//                 }
//             }
//         }
//
//         task.resume()
//     }
//
//


