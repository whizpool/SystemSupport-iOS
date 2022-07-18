//
//  SLog.swift
//  SystemSupport
//
//  Created by Macbook on 18/07/2022.
//
import Foundation
import UIKit
import SSZipArchive

public class SLog{
    
    // ********************* Variables *********************//
    
    // Instance of Slog file
    public static let shared = SLog()
    
    //Initializer access level change now
        private init(){}
    
    // Zip File Password
    var password = ""
    
    // title
    var titleText:String = ""
    
    // Background Color
    var backgroundColor = UIColor.white
    
    // Text Color
    var textColor = UIColor.black
    
    // border color
    var borderColor = UIColor.black.cgColor
    
    // Tag Variable is Project name this is displayed in console
    var TAG:String = "LogFilePodProj"

    // Days after log files deleted
    private var KEEP_OLD_LOGS_UP_TO_DAYS:Int = 7
    
    // Main Directory Folder name
    private var LOG_FILE_ROOT_DIR_NAME:String = "Logs"
    
    // Zip Folder name
    var LOG_FILE_New_Folder_DIR_NAME:String = "NewZip"
    
    // date Formate
    private var LOG_FILE_DATE_FORMAT:String = "yyyy-MM-dd"
    
    // app version name string
    private var versionName:String = ""
    
    // app Build number variable
    private var buildNo:Int64 = 0
    
    // send by default email of developer
    var sendToEmail: String = "uzair.masood@whizpool.com"
    
    // after combine log file name
    var finalLogFileName_After_Combine = "finalLog"
    
    // zip attach file name
    var zipFileName = "LogFile.zip"
    
    // zip temporary save file name
    var temp_zipFileName = "logFileData.zip"
    
    // json file name
    var jsonFileName = "myJsonFile"
    
    // zip folder path
    var appendZipFolderPath = "/NewZip"
    
    // log folder path
    var appendRootFolderPath = "Logs/"
    
    // Email Subject for mail composer
    var emailSubject = "Email Sends To Developers"
    
    // Textview Placeholder
    var prefilledTextviewText = "Write here about your bug detail"
    
    // ********************* initilization *********************//
    
    // In initilization we can create a Logs Folder
    public func initilization()
        {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            print(path)
            if let pathComponent = url.appendingPathComponent(LOG_FILE_ROOT_DIR_NAME) {
                
                _ = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = LOG_FILE_DATE_FORMAT
                
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                } else {
                    let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                    let DirPath = DocumentDirectory.appendingPathComponent(LOG_FILE_ROOT_DIR_NAME)
                    do
                    {
                        try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch let error as NSError
                    {
                        print("Unable to create directory \(error.debugDescription)")
                    }
                    
                }
            } else {
                print("FILE PATH NOT AVAILABLE")
            }
            
            // Give Values to versionName and buildNo from functions that is in Utils file
            versionName = SLog.getVersionName()
            buildNo = Int64(SLog.buildNumber)!
            
            // calling delete log file function
            _ = deleteOldLogs(forcefullyDelete: false)
        }
    
    // ********************* Functions *********************//
    
   
    // Function to get path of LogZipfile
    public func getLogFilePath (completion: (String) -> ())
    {
        let filePath = SLog.shared.getRootDirPath()
        let url = URL(string: filePath)
        let zipPath = url!.appendingPathComponent(SLog.shared.appendZipFolderPath)
        do {
            self.createPasswordProtectedZipLogFile(at: zipPath.path) { path in
                
                completion(path)
            }
        }
//        catch let error as NSError
//        {
//            print("Unable to create directory \(error.debugDescription)")
//            completion("")
//        }
//
    }
    
    // combine two files into one and set that file name is finalLog and at the end we can call makeJsonFile function which will create json file
    func combineLogFiles(completion: (String) -> ()){
        
        // Delete Zip Folder
        _ = SLog.shared.deleteFile(fileName: SLog.shared.LOG_FILE_New_Folder_DIR_NAME)
        
        let fileManager = FileManager.default
        var files = [String]()
        files.removeAll()
        
        // getting files from Slog Function
        files = SLog.shared.listFilesFromDocumentsFolder()
        
        // arrange Files in orderedAscending
        files = files.sorted(by: { $0.compare($1) == .orderedAscending })
        for file in files{
            //if you get access to the directory
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                //prepare file url
                let fileURL = dir.appendingPathComponent(appendRootFolderPath)
                
                let DirPath = fileURL.appendingPathComponent(SLog.shared.LOG_FILE_New_Folder_DIR_NAME)
                do
                {
                    try FileManager.default.createDirectory(atPath: DirPath.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError
                {
                    print("Unable to create directory \(error.debugDescription)")
                }
                print("Dir Path = \(DirPath)")
                
                let newZipDirURL = fileURL.appendingPathComponent(file)
                let fileCombine = DirPath.appendingPathComponent(SLog.shared.finalLogFileName_After_Combine)
                
                do{
                    var result = ""
                    result = try String(contentsOf: newZipDirURL, encoding: .utf8)
                    print(result)
                    if fileManager.fileExists(atPath: fileCombine.path){
                        
                        do {
                            if fileManager.fileExists(atPath: fileCombine.path) {
                                // File Available
                                if let fileUpdater = try? FileHandle(forUpdating: fileCombine) {
                                    // Function which when called will cause all updates to start from end of the file
                                    fileUpdater.seekToEndOfFile()
                                    
                                    // Which lets the caller move editing to any position within the file by supplying an offset
                                    fileUpdater.write(result.data(using: .utf8)!)
                                    
                                    // Once we convert our new content to data and write it, we close the file and that’s it!
                                    fileUpdater.closeFile()
                                    
                                    completion(fileCombine.path)
                                }
                            }
                        }
//                        catch{
//                            print(error.localizedDescription)
//                            completion("")
//                        }
                    }
                    else{
                        
                        if (FileManager.default.createFile(atPath: fileCombine.path, contents: nil, attributes: nil)) {
                            print("File created successfully.")
                            do{
                                try result.write(to: fileCombine, atomically: true, encoding: String.Encoding.utf8)
    
                                let pathURL = fileCombine // URL
                                let pathString = pathURL.path // String
                        
                                completion(pathString)
                            }
                            catch{
                                print(error.localizedDescription)
                                completion("")
                            }
                        }
                    }
                }catch{
                    print(error.localizedDescription)
                    completion("")
                }
            }
        }
    }
    
    // Function create zip and create password on it
    func createPasswordProtectedZipLogFile(at logfilePath: String, completion: (String) -> ())
    {
        var isZipped:Bool = false
        // calling combine all files into one file
        self.combineLogFiles { filePath in
            //
            self.makeJsonFile { jsonFilePath in
                //
                let contentsPath = logfilePath
                
                // create a json file and call a function of makeJsonFile
                if FileManager.default.fileExists(atPath: contentsPath)
                {
                    let createZipPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(SLog.shared.temp_zipFileName).path
                    if SLog.shared.password.isEmpty{
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath)
                    }
                    else{
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath, keepParentDirectory: true, withPassword: SLog.shared.password)
                    }
                    
                    let zipPath = ((contentsPath as NSString).deletingLastPathComponent as NSString).appendingPathComponent(SLog.shared.zipFileName)
                    
                    do {

                        if isZipped {
                            //
                            if FileManager.default.fileExists(atPath: zipPath)
                            {
                                try FileManager.default.removeItem(atPath: zipPath)
                            }
                            
                            try FileManager.default.copyItem(atPath: createZipPath, toPath: zipPath)
                            
                            completion(zipPath)
                        }
                        else
                        {
                            completion("")
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                        completion("")
                    }
                }
                else
                {
                    completion("")
                }
            }
        }
    }
    
    // Fuction make Json file
    func makeJsonFile(completion: (String) -> ()){
        // -> URL
        
        // create empty dict
        var myDict = [String: String]()
        
        // calling function of manufacture,deviceModel,OSInstalled,appVersion and set that functions value in dict
        let manufacture = SLog.getDeviceManufacture()
        let deviceModel = UIDevice.modelName
        let OSInstalled = SLog.getOSInfo()
        let appVersion = SLog.getVersionName()
        var freeSpace:String = ""
        
        // calculate free space of device
        if let Space = SLog.deviceRemainingFreeSpaceInBytes() {
            print("free space: \(Space)")
            print(Units(bytes: Space).getReadableUnit())
            freeSpace = Units(bytes: Space).getReadableUnit()
        } else {
            print("failed")
        }
        
        // Add Values in Dict
        myDict = ["appVersion":appVersion,"OSInstalled":OSInstalled,"deviceModel":deviceModel,"manufacture":manufacture,"freeSpace":freeSpace]
        do{
//            try  saveJsonFileInDirectory(jsonObject: myDict, toFilename: SLog.shared.jsonFileName)
            try saveJsonFileInDirectory(jsonObject: myDict, toFilename: SLog.shared.jsonFileName, completion: { filePath in
                completion(filePath)
            })
        }catch{
            print(error.localizedDescription)
            completion("")
        }
        
    }
    
    // create json file in directory with specific information of device
   
    func saveJsonFileInDirectory(jsonObject: Any, toFilename filename: String, completion: (String) -> ()) throws{
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            var fileURL = url.appendingPathComponent(appendRootFolderPath)
            let zipFolder = fileURL.appendingPathComponent("NewZip/")
            let zipFolderUrl = zipFolder.appendingPathComponent(filename)
            fileURL = zipFolderUrl.appendingPathExtension("json")
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            
            do {
                try data.write(to: fileURL, options: [.atomicWrite])
             
                completion(fileURL.path)
            }
            catch {
                completion("")
            }
       }
       else
       {
           completion("")
       }
    }
    // ********************* Functions *********************//
    
    // this function is used for writing logs in log file
   public func log(text: String?)
        {
            log(tag: TAG, text: text, exception: nil)
        }
    
    // this function is call from above log function
    func log(tag: String?, text: String?)
        {
            log(tag: TAG, text: text, exception: nil)
        }
    
    // this function is call from above log function
    func log(tag: String?, text: String?, exception: NSException?)
       {
           var tagToLog:String = ""
           if (tag == nil || tag == ""){
               tagToLog = "Null Tag"
           }
           else{
               tagToLog = tag!
           }
           
           var textToLog:String = ""
           if (text == nil || text == ""){
               textToLog = "Null Message"
           }
           else{
               textToLog = text!
           }
           
           if (exception == nil){
               print("tag: \(tagToLog)::: \(textToLog)")
               
           }
           else{
               print("tag: \(tagToLog)::: \(textToLog). Exception: \(String(describing: exception))")
           }
           
           // this function is call for writing logs in log file
           writeLogInFile(message: text!)
       }
    
    // Function For checking files are greater than (KEEP_OLD_LOGS_UP_TO_DAYS) or not and call function for deleting files
    public func deleteOldLogs(forcefullyDelete: Bool) -> Bool
        {
            let fileManager:FileManager = FileManager.default
            let fileList = listFilesFromDocumentsFolder()
            
            let fileCounts = fileList.count
            
            for fileCount in 0..<fileCounts
            {
                if fileManager.fileExists(atPath: fileList[fileCount]) != true
                {
                    print("File is \(fileList[fileCount])")
                }
            }
            
            let totalDirectories = fileList.count
            
            // If there is only one log directory then don't delete anything and return.
            if (totalDirectories <= 1)
            {
                return false
            }
            
            // If total directories are less than 7, then don't delete any thing. But if requested to forcefully delete,
            // then skip this check and proceed forward.
            if (totalDirectories <= KEEP_OLD_LOGS_UP_TO_DAYS && !forcefullyDelete)
            {
                return false
            }
            
            // Sort the directories in alphabetical order (in ascending dates)
            
            let sortArray = fileList.sorted(by: { $0.compare($1) == .orderedAscending })
            
            
            
            
            for (index, file) in sortArray.enumerated()
            {
                // Delete file
                _ = deleteFile(fileName: file)
                
                
                // After deleting it, check how many drafts are left. If they are less than or equal to 7 then return.
                if (totalDirectories - (index + 1) <= KEEP_OLD_LOGS_UP_TO_DAYS)
                {
                    break
                }
            }
            
            return true
        }
    
    // Function For Writing Logs in Log File
    private func writeLogInFile(message:String){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(LOG_FILE_ROOT_DIR_NAME) {
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = LOG_FILE_DATE_FORMAT
            let currentDate = dateFormatter.string(from: date)
            
            let LongDate = getCurrentDate()
            let updatedMessage = "\n\(LongDate)" + " " + "\(message)\n"
            
            let filename = pathComponent.appendingPathComponent(currentDate)
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: filePath) {
                print("Folder AVAILABLE")
                
                if fileManager.fileExists(atPath: filename.path) {
                    print("FILE AVAILABLE")
                    do {
                        if let fileUpdater = try? FileHandle(forUpdating: filename) {
                            // Function which when called will cause all updates to start from end of the file
                            fileUpdater.seekToEndOfFile()
                            
                            // Which lets the caller move editing to any position within the file by supplying an offset
                            fileUpdater.write(updatedMessage.data(using: .utf8)!)
                            
                            // Once we convert our new content to data and write it, we close the file and that’s it!
                            fileUpdater.closeFile()
                            print(updatedMessage)
                        }
                        
                    }
                } else {
                    print("FILE NOT AVAILABLE")
                    do{
                        try updatedMessage.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                        print(updatedMessage)
                        
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                    
                }
                
                
                
            } else {
                print("Folder NOT AVAILABLE")
                let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let DirPath = DocumentDirectory.appendingPathComponent(LOG_FILE_ROOT_DIR_NAME)
                do
                {
                    try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError
                {
                    print("Unable to create directory \(error.debugDescription)")
                }
                print("Dir Path = \(DirPath!)")
                
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    // Function For Checking App is in Debug mode or not
    public func isInDebugMode() -> Bool
        {
#if DEBUG
            print("In Debug Mode")
            return true
#else
            print("Not In Debug Mode")
            return false
#endif
        }
    
    // function for getting App Version Number
    class func getVersionName() -> String{
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        return version
    }
    
    // function for getting App Build Number
    static var buildNumber:String
        {
            if let buildNum = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
            {
                return "\(buildNum)"
            }
            return ""
        }
    
    // function for getting Os Version
   class func getOSInfo()->String {
       let os = ProcessInfo.processInfo.operatingSystemVersion
       return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    // function for getting device manufacture
    class func getDeviceManufacture()->String {
         let os = "iPhone"
         return os
     }
    
    
    
    // Function For getting logs files from Directory and return Files List
    func listFilesFromDocumentsFolder() -> [String]
    {
        var fileListLogFile = [String]()
        fileListLogFile.removeAll()
        let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if dirs != [] {
            let dir = dirs[0]
            let fileList = try! FileManager.default.contentsOfDirectory(atPath: dir + "/Logs")
            for list in fileList{
                if list == ".DS_Store" || list == LOG_FILE_New_Folder_DIR_NAME{
                    continue
                }
                else{
                    fileListLogFile.append(list)
                }
            }
            return fileListLogFile
        }else{
            fileListLogFile = [""]
            return fileListLogFile
        }
    }
    
    // Function For Deleting Files From Directory when we can give this function file name
    func deleteFile(fileName : String) -> Bool{
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("Logs" + "/" + fileName) {
            do {
                try fileManager.removeItem(at: pathComponent)
                print("File deleted")
                return true
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return false
    }
    
    func logException(tag: String?, text: String?, map: [String:Any], exception: NSException?)
       {
           log(tag: tag, text: text, exception: exception)
       }
    
    // Function For Getting Current Time
    func getCurrentTime() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let DateTime = formatter.string(from: date)
        let strOfDateTime = String(DateTime)
        return strOfDateTime
    }
    
    // Function For Getting Current Date
    func getCurrentDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd kk:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let DateTime = formatter.string(from: date)
        let strOfDateTime = String(DateTime)
        return strOfDateTime
    }
    
    
    
    // Function For Getting root Directory folder path
    func getRootDirPath() -> String{
        var PATH = ""
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(LOG_FILE_ROOT_DIR_NAME) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = LOG_FILE_DATE_FORMAT
            
            let filePath = pathComponent.path
            PATH = filePath
            return PATH
        }
        return PATH
    }
    
    // converting Bytes into Mb,Gb etc
    class func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else {
            // something failed
            return nil
        }
        return freeSize.int64Value
     }
    
    // function to get tag value
    public func setDefaultTag (tagName: String) {
            TAG = tagName
        }
    
    // function to get log days value
    public func setDaysForLog (numberOfDays: Int) {
            KEEP_OLD_LOGS_UP_TO_DAYS = numberOfDays
        }
    
    // function to get password
    public func setpassword(password:String){
        self.password = password
    }
    public func setTittle(title:String){
        self.titleText = title
    }
    
}

// ********************* Extensions *********************//


// getting Device model Extension
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
#if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                                return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
#elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

// Struct For Calculating Free Space in Device
public struct Units {
  
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(bytes) bytes"
        }
    }
}
