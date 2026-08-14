//
//  ShareableExtensions.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 10/2/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImage.SDImageCache
import Combine
import RealmSwift
import AVFoundation

extension Color {
//    static let oldPrimaryColor = Color(UIColor.systemIndigo)
    static let backgroundColor = Color("backgroundColor")
    static let accent = Color("accent")
    static let softWhite = Color("softWhite")
    static let mainColor = Color("mainColor")
    static let mainColorInverse = Color("mainColorInverse")
    static let supportingColor = Color("secondaryColor")
    static let speakerPurple = Color("speakerPurple")
    static let speakerPink = Color("speakerPink")
    static let speakerBlue = Color("speakerBlue")
    static let aliceBlue = Color("aliceBlue")
    static let alloyOrange = Color("alloyOrange")
    static let arylideYellow = Color("arylideYellow")
    static let babyBlue = Color("babyBlue")
    static let blackCoral = Color("blackCoral")
    static let bleuDeFrance = Color("bleuDeFrance")
    static let blizzardBlue = Color("blizzardBlue")
    static let bloodRed = Color("bloodRed")
    static let blueBell = Color("blueBell")
    static let bluePigment = Color("bluePigment")
    static let brightMaroon = Color("brightMaroon")
    static let brinkPink = Color("brinkPink")
    static let burntSienna = Color("burntSienna")
    static let cafeAuLait = Color("cafeAuLait")
    static let cafeNoir = Color("cafeNoir")
    static let cambridgeBlue = Color("cambridgeBlue")
    static let caribbeanGreen = Color("caribbeanGreen")
    static let celadonGreen = Color("celadonGreen")
    static let charmPink = Color("charmPink")
    static let chinaRose = Color("chinaRose")
    static let chineseRed = Color("chineseRed")
    static let cornflowerBlue = Color("cornflowerBlue")
    static let cottonCandy = Color("cottonCandy")
    static let cyberGrape = Color("cyberGrape")
    static let darkTurqoise = Color("darkTurqoise")
    static let deepPurple = Color("deepPurple")
    static let dodgerBlue = Color("dodgerBlue")
    static let earthYellow = Color("earthYellow")
    static let etonBlue = Color("etonBlue")
    static let fireEngineRed = Color("fireEngineRed")
    static let flourescentBlue = Color("flourescentBlue")
    static let forestGreen = Color("forestGreen")
    static let frenchMauve = Color("frenchMauve")
    static let frenchSkyBlue = Color("frenchSkyBlue")
    static let greenSheen = Color("greenSheen")
    static let indigoDye = Color("indigoDye")
    static let ivory = Color("ivory")
    static let juneBud = Color("juneBud")
    static let khakiWeb = Color("khakiWeb")
    static let laurelGreen = Color("laurelGreen")
    static let lavenderBlue = Color("lavenderBlue")
    static let lavenderFloral = Color("lavenderFloral")
    static let lightCyan = Color("lightCyan")
    static let magentaDye = Color("magentaDye")
    static let magentaHaze = Color("magentaHaze")
    static let magentaProcess = Color("magentaProcess")
    static let mandarin = Color("mandarin")
    static let mangolia = Color("mangolia")
    static let maximumBluePurple = Color("maximumBluePurple")
    static let maximumGreenYellow = Color("maximumGreenYellow")
    static let maximumYellowRed = Color("maximumYellowRed")
    static let mediumPurple = Color("mediumPurple")
    static let mellowApricot = Color("mellowApricot")
    static let middleRed = Color("middleRed")
    static let mintGreen = Color("mintGreen")
    static let oldLavender = Color("oldLavender")
    static let orangePeel = Color("orangePeel")
    static let oxfordBlue = Color("oxfordBlue")
    static let peachPuff = Color("peachPuff")
    static let pearlyPurple = Color("pearlyPurple")
    static let periwinkleCrayola = Color("periwinkleCrayola")
    static let persianGreen = Color("persianGreen")
    static let plumWeb = Color("plumWeb")
    static let raisinBlack = Color("raisinBlack")
    static let rawSienna = Color("rawSienna")
    static let romanSilver = Color("romanSilver")
    static let roseEbony = Color("roseEbony")
    static let rosePink = Color("rosePink")
    static let russianViolet = Color("russianViolet")
    static let safetyYellow = Color("safetyYellow")
    static let sandyBrown = Color("sandyBrown")
    static let sizzlingRed = Color("sizzlingRed")
    static let skyBlueCrayola = Color("skyBlueCrayola")
    static let springGreen = Color("springGreen")
    static let tartOrange = Color("tartOrange")
    static let taupeGray = Color("taupeGray")
    static let tealBlue = Color("tealBlue")
    static let upForestGreen = Color("upForestGreen")
    static let vividSkyBlue = Color("vividSkyBlue")
    
    //MARK: DEFAULT LIGHT
        static let defaultLightAccent = Color("defaultLightAccent")
        static let defaultLightPrimary = Color("defaultLightPrimary")
        static let defaultLightSecondary = Color("defaultLightSecondary")
    //MARK: DEFAULT DARK
        static let defaultDarkAccent = Color("defaultDarkAccent")
        static let defaultDarkPrimary = Color("defaultDarkPrimary")
        static let defaultDarkSecondary = Color("defaultDarkSecondary")
    
    //MARK: BLUE
    //MARK: ROYAL BLUE
        static let royalBlueAccent = Color("royalBlueAccent")
        static let royalBluePrimary = Color("royalBluePrimary")
        static let royalBlueSecondary = Color("royalBlueSecondary")
    //MARK: BIG STONE
        static let bigStoneAccent = Color("bigStoneAccent")
        static let bigStonePrimary = Color("bigStonePrimary")
        static let bigStoneSecondary = Color("bigStoneSecondary")
    //MARK: CORNFLOWER BLUE
        static let cornflowerBlueAccent = Color("cornflowerBlueAccent")
        static let cornflowerBluePrimary = Color("cornflowerBluePrimary")
        static let cornflowerBlueSecondary = Color("cornflowerBlueSecondary")
    //MARK: DANUBE
        static let danubeAccent = Color("danubeAccent")
        static let danubePrimary = Color("danubePrimary")
        static let danubeSecondary = Color("danubeSecondary")
    //MARK: ICY BLUE
        static let icyBlueAccent = Color("icyBlueAccent")
        static let icyBluePrimary = Color("icyBluePrimary")
        static let icyBlueSecondary = Color("icyBlueSecondary")
    
    //MARK: PINK
    //MARK: HELIOTROPE
        static let heliotropeAccent = Color("heliotropeAccent")
        static let heliotropePrimary = Color("heliotropePrimary")
        static let heliotropeSecondary = Color("heliotropeSecondary")
    //MARK: MEDIUM PURPLE
        static let mediumPurpleAccent = Color("mediumPurpleAccent")
        static let mediumPurplePrimary = Color("mediumPurplePrimary")
        static let mediumPurpleSecondary = Color("mediumPurpleSecondary")
    //MARK: MUAVE
        static let muaveAccent = Color("muaveAccent")
        static let muavePrimary = Color("muavePrimary")
        static let muaveSecondary = Color("muaveSecondary")
    //MARK: SEANCE
        static let seanceAccent = Color("seanceAccent")
        static let seancePrimary = Color("seancePrimary")
        static let seanceSecondary = Color("seanceSecondary")
    
    //MARK: GREEN
    //MARK: CELTIC
        static let celticAccent = Color("celticAccent")
        static let celticPrimary = Color("celticPrimary")
        static let celticSecondary = Color("celticSecondary")
    //MARK: EVERGLADE
        static let evergladeAccent = Color("evergladeAccent")
        static let evergladePrimary = Color("evergladePrimary")
        static let evergladeSecondary = Color("evergladeSecondary")
    //MARK: KILLARNEY
        static let killarneyAccent = Color("killarneyAccent")
        static let killarneyPrimary = Color("killarneyPrimary")
        static let killarneySecondary = Color("killarneySecondary")
    //MARK: LAUREL
        static let laurelAccent = Color("laurelAccent")
        static let laurelPrimary = Color("laurelPrimary")
        static let laurelSecondary = Color("laurelSecondary")
    //MARK: PALE LEAF
        static let paleLeafAccent = Color("paleLeafAccent")
        static let paleLeafPrimary = Color("paleLeafPrimary")
        static let paleLeafSecondary = Color("paleLeafSecondary")
    
    //MARK: RED
    //MARK: ZINNWALDITE
        static let zinnwalditeAccent = Color("zinnwalditeAccent")
        static let zinnwalditePrimary = Color("zinnwalditePrimary")
        static let zinnwalditeSecondary = Color("zinnwalditeSecondary")
    //MARK: CORNFLOWER LILAC
        static let cornflowerLilacAccent = Color("cornflowerLilacAccent")
        static let cornflowerLilacPrimary = Color("cornflowerLilacPrimary")
        static let cornflowerLilacSecondary = Color("cornflowerLilacSecondary")
    //MARK: ROSE GOLD
        static let roseGoldAccent = Color("roseGoldAccent")
        static let roseGoldPrimary = Color("roseGoldPrimary")
        static let roseGoldSecondary = Color("roseGoldSecondary")
    //MARK: CHESTNUT ROSE
        static let chestnutRoseAccent = Color("chestnutRoseAccent")
        static let chestnutRosePrimary = Color("chestnutRosePrimary")
        static let chestnutRoseSecondary = Color("chestnutRoseSecondary")
    //MARK: TALL POPPY
        static let tallPoppyAccent = Color("tallPoppyAccent")
        static let tallPoppyPrimary = Color("tallPoppyPrimary")
        static let tallPoppySecondary = Color("tallPoppySecondary")
    //MARK: DARK TAN
        static let darkTanAccent = Color("darkTanAccent")
        static let darkTanPrimary = Color("darkTanPrimary")
        static let darkTanSecondary = Color("darkTanSecondary")
    //MARK: BURNT MAROON
        static let burntMaroonAccent = Color("burntMaroonAccent")
        static let burntMaroonPrimary = Color("burntMaroonPrimary")
        static let burntMaroonSecondary = Color("burntMaroonSecondary")
    
    //MARK: TAN
    //MARK: ALTO
        static let altoAccent = Color("altoAccent")
        static let altoPrimary = Color("altoPrimary")
        static let altoSecondary = Color("altoSecondary")
    //MARK: TRUE GRAY
        static let trueGrayAccent = Color("trueGrayAccent")
        static let trueGrayPrimary = Color("trueGrayPrimary")
        static let trueGraySecondary = Color("trueGraySecondary")
    //MARK: MERLIN
        static let merlinAccent = Color("merlinAccent")
        static let merlinPrimary = Color("merlinPrimary")
        static let merlinSecondary = Color("merlinSecondary")
    //MARK: KABUL
        static let kabulAccent = Color("kabulAccent")
        static let kabulPrimary = Color("kabulPrimary")
        static let kabulSecondary = Color("kabulSecondary")
    //MARK: CORK BROWN
        static let corkBrownAccent = Color("corkBrownAccent")
        static let corkBrownPrimary = Color("corkBrownPrimary")
        static let corkBrownSecondary = Color("corkBrownSecondary")
}

extension UIColor {
    static let speakerPurpleUI = UIColor(named: "speakerPurple")!
    static let speakerPinkUI = UIColor(named: "speakerPink")!
    static let accent = UIColor(named: "accent")!
}

extension UIColor {
    static let speakerPurple : UIColor? = UIColor(named: "speakerPurple")
    static let speakerPink : UIColor? = UIColor(named: "speakerPink")
}


extension Bundle {
    func decode<T: Codable>(_ file: String) -> T {
        // 1. Locate the JSON file in the app Bundle
        
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        // 2. Create a property for the data
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) in bundle.")
        }
        // 3. Create a JSON decoder
        let decoder = JSONDecoder()
        
        // 4. Decode the data and collect the information with a new property
         // a. decoder requests information on type that we are trying to decode, in this case it is Cover Image
         // b. the source data
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) in bundle.")
        }
        // 5. Return the ready-to-use data
        return loaded

    }
}


extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
 
extension UIColor {
    static let speakerBlue : UIColor? = UIColor(named: "speakerBlue")
}

extension Date {
    //time interval in milliseconds since 1970
    var jsGetTimeEquivalent:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    func jsToSwiftTime() -> Double {
        return Double(jsGetTimeEquivalent/1000)
    }
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

extension Timestamp {
    ///do need to test that and need to use this instead
    static let timeStringFormatter :  DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
     func getTimeString() -> String {
        let createdAt = self.dateValue()
        var timeString = ""
        if Calendar.current.isDateInToday(createdAt) == true {
            //need to make this formatter a static var instead
            let format = DateFormatter()
            format.dateFormat = "h:mm a"
//            let format = Self.timeStringFormatter
            timeString = format.string(from: createdAt )
        }
        if Calendar.current.isDateInYesterday(createdAt ) == true {
            
            timeString = "Yesterday"
        }
        if Calendar.current.isDateInToday(createdAt ) == false &&  Calendar.current.isDateInYesterday(createdAt ) == false {
            //            let newDate = Calendar.current.date(byAdding: .day, value: -7, to: createdAt.dateValue())
            let startOfNow = Calendar.current.startOfDay(for: Date())
            let startOfTimeStamp = Calendar.current.startOfDay(for: createdAt )
            let components = Calendar.current.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            if let day = components.day,
               day < 1 {
                timeString = "\(-day) days ago"
            }
        }
        return timeString
    }
    
    static func <(lhs: Timestamp, rhs: Timestamp) -> Bool{
        return lhs.dateValue().timeIntervalSinceNow < rhs.dateValue().timeIntervalSinceNow
    }
    static func >(lhs: Timestamp, rhs: Timestamp) -> Bool{
        return lhs.dateValue().timeIntervalSinceNow > rhs.dateValue().timeIntervalSinceNow
    }
    static func >=(lhs: Timestamp, rhs: Timestamp) -> Bool{
        return lhs.dateValue().timeIntervalSinceNow >= rhs.dateValue().timeIntervalSinceNow
    }
    static func <=(lhs: Timestamp, rhs: Timestamp) -> Bool{
        return lhs.dateValue().timeIntervalSinceNow <= rhs.dateValue().timeIntervalSinceNow
    }
    func isTimeEqual (_ time: Timestamp) -> Bool{
        return self.dateValue().timeIntervalSinceNow == time.dateValue().timeIntervalSinceNow
    }

}

extension SDImageCache {
   
   func add(image : UIImage, url : URL,callback : @escaping () -> Void = { }) {
       add(image : image, key : url.absoluteString){ callback() }
   }
   
   func add(image : UIImage, key : String,callback : @escaping () -> Void = { }) {
       SDImageCache.shared.diskImageExists(withKey: key) { isInCache in
           if !isInCache {
               SDImageCache.shared.store(image, forKey: key) { callback() }
           }else{
               callback()
           }
       }
   }
}

extension Collection {
    var isNotEmpty : Bool {
        !isEmpty
    }
}

extension Set {
    func getArray() -> [Element] {
      return Array(self)
    }
    
}

extension Set where Element == AnyCancellable{
   func cancelAll(){
       self.forEach({$0.cancel()})
   }
}

extension Array where Element: Hashable {
    func getSet() -> Set<Element> {
        return Set.init(self)
    }
}

extension RawRepresentable where RawValue == String {
 func callAsFunction() -> String{
     self.rawValue
 }
}
extension String {
    
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var possibleURL : URL?{
        return  URL(string: self)
    }
    
    var isNotEmpty : Bool{
        return !isEmpty
    }
    /// Returns a condensed string, with no extra whitespaces and no new lines.
    var condensed: String {
        return replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    }
    
    /// Returns a condensed string, with no whitespaces at all and no new lines.
    var extraCondensed: String {
        return replacingOccurrences(of: "[\\s\n]+", with: "", options: .regularExpression, range: nil)
    }
    
    func trimWhitespacesAndNewlines() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var asError : Error{
        NSError.getWith(description: self)
    }
    ///we use this in firebase query so app does not crash in case the ids are ""
    var nonEmpty : String{
        self.isEmpty ? " " : self
    }
    
    func removePrefix(possibleExtraString str: String) -> String  { 
        if let firstRange = self.range(of: str){
            let key =  String(self[firstRange.upperBound...])
            return key
        }
        return self
    } 
}
 

extension Error {
    var errorCode : Int? {
        (self as NSError?)?.code
    }
}

extension NSError {
    static func getWith(description : String) -> Error {
        let error = NSError(domain: "speakEZ local error", code: 00000, userInfo: [NSLocalizedDescriptionKey: description])
        return error
    }
}

extension Optional where Wrapped ==  Error{
    var descriptionIfAny : String {
        self?.localizedDescription ?? ""
    }
}
extension Bool {
    var falseIsNil : Bool? {
        self ? true : nil
    }
}

protocol RealmFailAble : Object {
}
extension RealmFailAble {
    static func getAllFailedObjectsResult()  -> Results<Self>? {
        guard let realm = try? Realm() else { return  nil }
        let realmPosts = realm.objects(Self.self).filter("isFailed == YES")
        return realmPosts
    }
}
extension Array where Element == String {
    
    @discardableResult mutating func removeFisrIfExist(_ string : String) -> String? {
         if let index = self.firstIndex(of: string){
            return self.remove(at: index)
         }
        return nil
     }
     
}

extension Sequence {
   func sorted<T: Comparable>(
       by keyPath: KeyPath<Element, T>,
       using comparator: (T, T) -> Bool = (<)
   ) -> [Element] {
       sorted { a, b in
           comparator(a[keyPath: keyPath], b[keyPath: keyPath])
       }
   }
}

extension Array  {
   var secondLast : Element? {
       if  count >= 2 {
           return self[count-2]
       }
       return nil
   }
   /// original orde will not be changed O(n) complexity
   func unique(selector:(Element,Element)->Bool) -> Array<Element> {
       return reduce(Array<Element>()){
           if let last = $0.last {
               return selector(last,$1) ? $0 : $0 + [$1]
           } else {
               return [$1]
           }
       }
   }
}
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
 
extension FileManager {
    func clearTmpDirectory(tmpDirURL: URL) {
        do { 
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
           //catch the error somehow
        }
    }
}
  
extension URL {
    
    var secondLastComponentWithMov : String? {
        if let secondLastComponent = secondLastComponent{
            return secondLastComponent+".mov"
        }
        return nil
    }
    var secondLastComponentAudioTypem4a : String? {
        if let secondLastComponent = secondLastComponent{
            return secondLastComponent+".m4a"
        }
        return nil
    }
    
    var secondLastComponent : String?{
        let count = self.pathComponents.count
        if  count >= 2 {
            return  self.pathComponents[count-2]
        }
        return nil
    }
    //we use this for firestore storage token
    var token : String?{
         URLComponents(url: self, resolvingAgainstBaseURL: true)?
            .queryItems?
            .first(where: {$0.name == "token"})?.value
    }
    ///In app directory
    var doesExist: Bool{
        FileManager.default.fileExists(atPath: self.path)
    }
    ///In app directory
    var doesNotExist: Bool{
        !doesExist
    }
 
    var delete: Error? {
        do {
            try FileManager.default.removeItem(at: self)
            return nil
        } catch let error {
            return error
        }
    }
}

extension Date {
    ///firebase Timestamp
    var timestamp : Timestamp{
        Timestamp(date: self)
    }
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

///for publisher didset use
extension Published.Publisher {
     //FIXME: - need to check all other publisher using this and need to update
    var didSet: AnyPublisher<Value, Never> {
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
    var didSetOnMain: AnyPublisher<Value, Never> { 
        self.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}
 
extension View {
    @ViewBuilder
    func `if`<CustomTransform: View>(_ condition: Bool, transform: (Self) -> CustomTransform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
#if os(iOS)
    func onCustomTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> some View{
        self.onTapGesture(count: count,perform: action)
    }
#endif
    
#if os(macOS)
    ///we use it when macOS tapGesture is not working
    func onCustomTapGesture(perform action: @escaping () -> Void) -> some View {
        self.overlay(
            Button(action: action) {
                Color.black.opacity(0.000000001)
            }.buttonStyle(.borderless)
        ) 
    }
#endif
    var leftInHStack : some View {
        HStack{
            self
            Spacer()
        }
     }
    var rightInHStack : some View {
        HStack{
            Spacer()
            self
        }
     }
    
    var centerInHStack : some View {
        HStack{
            Spacer()
            self
            Spacer()
        }
     }
    
    var topInVStack : some View {
        VStack{
            self
            Spacer()
        }
     }
    var bottomInVStack : some View {
        VStack{
            Spacer()
            self 
        }
     }
    
} 
extension Color {
    static let lightGray = Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1))
}

class TextBindingManager: ObservableObject {
    @Published var text = "" {
        didSet {
            if text.count > characterLimit && oldValue.count <= characterLimit {
                text = oldValue
            }
        }
    }
    let characterLimit: Int

    init(limit: Int = 420){
        characterLimit = limit
    }
    func clearText() {
        text = ""
    }
}
 
extension UserDefaults {
    func keyExists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
//MARK: - UIImage extensions
// SDImageCache cache funcs
extension UIImage {

    func saveInCache(forKey key : String, callback: @escaping () -> Void = { }) {
        SDImageCache.shared.add(image: self, key: key){ callback() }
    }
    
    func saveInCache(forURL Url : URL) {
        saveInCache(forKey : Url.absoluteString)
    }
    
    class func getFromCacheWith(key : String) -> UIImage? {
        SDImageCache.shared.imageFromCache(forKey: key)
    }
}
//image compression funcs
extension UIImage {
 
    var highestQualityJPEGNSData: Data? { return self.jpegData(compressionQuality: 1.00) }
    
    enum Quality : CGFloat {
        case highest = 1.0
        case high = 0.75
        case medium = 0.50
        case low = 0.25
        case lowest = 0.0
    }
    
    func getJpegDataOf(_ quality : Quality) -> Data? {
        jpegData(compressionQuality: quality.rawValue)
    }
    
    func getJpegImageOf(_ quality : Quality) -> UIImage? {
        if let data = jpegData(compressionQuality: quality.rawValue){
            return UIImage(data: data)
        }
        return nil
    }
    
    class func resizeByByte(image : UIImage,maxByte: Int  , completion: @escaping (UIImage,Error?) -> Void) {
        var compressQuality: CGFloat = 1
        let nsError : Error = {NSError.getWith(description: "Image was not able to be compressed ")}()
        guard var imageData = image.jpegData(compressionQuality: 1) else {
            completion(image ,nsError)
            return
        }
 //        var image = image
        
        while  compressQuality >= 0 {
     
            guard let compressedImageData = image.jpegData(compressionQuality: compressQuality) else {
                completion(image ,nsError)
                return
            }
            
            imageData = compressedImageData
            compressQuality -= 0.1
            
            if imageData.count <= maxByte,
               let newImageDataCount = UIImage(data: compressedImageData)?.getJpegDataOf(.highest)?.count,
               newImageDataCount <= maxByte {
                    break
                }
           
        }
        
        if maxByte >  imageData.count {
           let compressedImage = UIImage(data: imageData) ?? image
            completion(compressedImage,nil)
        } else {
            completion(image ,nil)
        }
    }
    
      func getCompressedImage(imageMaxBytes: Int = 1_000_000, callback : @escaping (_ processedImage : UIImage? ) -> Void){
     
        if let imageByteCount = self.getJpegDataOf(.highest)?.count,
           imageByteCount <= imageMaxBytes {
            callback(self)
        }else{
            UIImage.compress(image:  self,imageMaxBytes : imageMaxBytes) {  compressedImage in
               callback(compressedImage)
            }
        }
    }
    
  class func compress(image : UIImage, sideArea : CGFloat = 1280, imageMaxBytes: Int = 1_000_000,callback : @escaping (_ processedImage : UIImage? ) -> Void){
    var compImage : UIImage = image
       if image.size.width > sideArea || image.size.height > sideArea {
           compImage = image.scalePreservingAspectRatio(targetSize: CGSize(width: sideArea, height: sideArea))
       }
        
       guard let data = compImage.getJpegDataOf(.highest) else{
        callback(nil)
           return
       }
       
    if data.count <=  imageMaxBytes {
        if let processedImage = UIImage(data: data) {
            callback(processedImage)
        }else{
            callback(nil)
        }
    }else{
           Self.resizeByByte(image: compImage,maxByte :  imageMaxBytes) { (compressedImage, _) in
               if  let dataCount =  compImage.getJpegDataOf(.highest)?.count,
                   dataCount <=  imageMaxBytes {
                   callback(compressedImage)
               }else{
                   Self.compress(image: compressedImage, sideArea : sideArea-200) { image in
                       callback(image ?? compressedImage)
                   }
               }
           }
           /*
            now we will lower the size of image and then check for the lowest qlty . until we get 1mb size image
            */
       }
   }
  
}
extension Thread {
    var threadName: String {
        if isMainThread {
            return "main"
        } else if let threadName = Thread.current.name, !threadName.isEmpty {
            return threadName
        } else {
            return description
        }
    }
    
    var queueName: String {
        if let queueName = String(validatingUTF8: __dispatch_queue_get_label(nil)) {
            return queueName
        } else if let operationQueueName = OperationQueue.current?.name, !operationQueueName.isEmpty {
            return operationQueueName
        } else if let dispatchQueueName = OperationQueue.current?.underlyingQueue?.label, !dispatchQueueName.isEmpty {
            return dispatchQueueName
        } else {
            return "n/a"
        }
    }
}

extension Dictionary where Key == String {
    var arrayKeys: [String] {
          [String](keys)
    }
    var setKeys: Set<String> {
          Set<String>(keys)
    }
}
//extension Any{
////    (dict["audioUrl"] as?  String)?.possibleURL
//}
extension Optional where Wrapped == Any{
    var possibleURL : URL? {
        (self as? String)?.possibleURL
    }
//    var possibleString : String? {
//         self as? String
//    }
}
extension FileManager {
    func removefileIfExist(path : String) -> Error? {
        guard fileExists(atPath: path) else {  return nil }
        do {
            try removeItem(atPath: path)
            return nil
        } catch {
            print("fileManager.removeItem ",error.localizedDescription)
            return error
        }
    }
}
extension Foundation.Notification.Name {
    static let unHiddenPM = Foundation.Notification.Name(rawValue: "unHiddenPM")
}

extension AVPlayer {
    
    var isAudioAvailable: Bool? {
        currentItem?.asset.tracks.contains(where: {$0.mediaType == .audio})
    }
    var isVideoAvailable: Bool? {
        currentItem?.asset.tracks.contains(where: {$0.mediaType == .video})
    }
    var isPlayingVideo : Bool{
        timeControlStatus == .playing && (isVideoAvailable == true)
    }
    var isPlayingAudioOnly : Bool{
        timeControlStatus == .playing && (isVideoAvailable == false) && (isAudioAvailable == true)
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ListBackgroundModifier: ViewModifier {

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
//                .listStyle(.insetGrouped)
        } else {
            content
        }
    }
}
//                        .modifier(ListBackgroundModifier())
