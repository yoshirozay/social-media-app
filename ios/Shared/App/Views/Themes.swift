//
//  Themes.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 11/15/22.
//

import SwiftUI

enum Theme {
    case defaultLight
    case defaultDark
    case royalBlue
    case bigStone
    case cornflowerBlue
    case danube
    case icyBlue
    case muave
    case heliotrope
    case mediumPurple
    case seance
    case paleLeaf
    case laurel
    case killarney
    case everglade
    case celtic
    case zinnwaldite
    case cornflowerLilac
    case roseGold
    case chestnutRose
    case tallPoppy
    case darkTan
    case burntMaroon
    case alto
    case trueGray
    case merlin
    case kabul
    case corkBrown
    case none
}

struct ThemeModel: Hashable {
    let id = UUID()
    let theme: Theme
    let name: String
    let primary: Color
    let accent: Color
    let secondary: Color
    let text: Color
    let messageList: Color
    let strokeOutline: Color
    let leftMessage: Color
    let rightMessage: Color
}

class ThemeController: ObservableObject {
    @Published var theme: ThemeModel = ThemeModel(theme: .defaultLight, name: "114Default Light", primary: .defaultLightPrimary, accent: .defaultLightAccent, secondary: .defaultLightSecondary, text: .black, messageList: .softWhite, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6))
    @Published var lightTheme: ThemeModel = ThemeModel(theme: .defaultLight, name: "114Default Light", primary: .defaultLightPrimary, accent: .defaultLightAccent, secondary: .defaultLightSecondary, text: .black, messageList: .softWhite, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6))
    @Published var darkTheme: ThemeModel = ThemeModel(theme: .defaultDark, name: "113Default Dark", primary: .defaultDarkPrimary, accent: .defaultDarkAccent, secondary: .defaultDarkSecondary, text: .black, messageList: .defaultDarkSecondary, strokeOutline: .black, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6))
    @Published var allThemes: [Theme : ThemeModel] = [
        .defaultLight : ThemeModel(theme: .defaultLight,name: "114Default Light", primary: .defaultLightPrimary, accent: .defaultLightAccent, secondary: .defaultLightSecondary, text: .black, messageList: .defaultLightSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .defaultDark : ThemeModel(theme: .defaultDark, name: "113Default Dark", primary: .defaultDarkPrimary, accent: .defaultDarkAccent, secondary: .defaultDarkSecondary, text: .black, messageList: .defaultDarkSecondary, strokeOutline: .black, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .cornflowerBlue : ThemeModel(theme: .cornflowerBlue, name: "100Cornflower Blue", primary: .cornflowerBluePrimary, accent: .cornflowerBlueAccent, secondary: .cornflowerBlueSecondary, text: .black, messageList: .cornflowerBlueSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .danube : ThemeModel(theme: .danube, name: "103Danube Blue", primary: .danubePrimary, accent: .danubeAccent, secondary: .danubeSecondary, text: .black, messageList: .danubeSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .icyBlue : ThemeModel(theme: .icyBlue, name: "106Icy Blue", primary: .icyBluePrimary, accent: .icyBlueAccent, secondary: .icyBlueSecondary, text: .black, messageList: .icyBlueSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .royalBlue : ThemeModel(theme: .royalBlue, name: "109Royal Blue", primary: .royalBluePrimary, accent: .royalBlueAccent, secondary: .royalBlueSecondary, text: .black, messageList: .royalBlueSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .bigStone : ThemeModel(theme: .bigStone, name: "112Big Stone", primary: .bigStonePrimary, accent: .bigStoneAccent, secondary: .bigStoneSecondary, text: .black, messageList: .bigStoneSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .muave : ThemeModel(theme: .muave, name: "115Muave", primary: .muavePrimary, accent: .muaveAccent, secondary: .muaveSecondary, text: .black, messageList: .muaveSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .heliotrope : ThemeModel(theme: .heliotrope, name: "118Heliotrope", primary: .heliotropePrimary, accent: .heliotropeAccent, secondary: .heliotropeSecondary, text: .black, messageList: .heliotropeSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .mediumPurple : ThemeModel(theme: .mediumPurple, name: "121Medium Purple", primary: .mediumPurplePrimary, accent: .mediumPurpleAccent, secondary: .mediumPurpleSecondary, text: .black, messageList: .mediumPurpleSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .seance : ThemeModel(theme: .seance, name: "124Seance", primary: .seancePrimary, accent: .seanceAccent, secondary: .seanceSecondary, text: .black, messageList: .seanceSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .paleLeaf : ThemeModel(theme: .paleLeaf, name: "127Pale Leaf", primary: .paleLeafPrimary, accent: .paleLeafAccent, secondary: .paleLeafSecondary, text: .black, messageList: .paleLeafSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .laurel : ThemeModel(theme: .laurel, name: "130Laurel", primary: .laurelPrimary, accent: .laurelAccent, secondary: .laurelSecondary, text: .black, messageList: .laurelSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .killarney : ThemeModel(theme: .killarney, name: "133Killarney", primary: .killarneyPrimary, accent: .killarneyAccent, secondary: .killarneySecondary, text: .black, messageList: .killarneySecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .everglade : ThemeModel(theme: .everglade, name: "136Everglade", primary: .evergladePrimary, accent: .evergladeAccent, secondary: .evergladeSecondary, text: .black, messageList: .evergladeSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .celtic : ThemeModel(theme: .celtic, name: "139Celtic", primary: .celticPrimary, accent: .celticAccent, secondary: .celticSecondary, text: .black, messageList: .celticSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .zinnwaldite : ThemeModel(theme: .zinnwaldite, name: "142Zinnwaldite", primary: .zinnwalditePrimary, accent: .zinnwalditeAccent, secondary: .zinnwalditeSecondary, text: .black, messageList: .zinnwalditeSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .cornflowerLilac : ThemeModel(theme: .cornflowerLilac, name: "145Cornflower Lilac", primary: .cornflowerLilacPrimary, accent: .cornflowerLilacAccent, secondary: .cornflowerLilacSecondary, text: .black, messageList: .cornflowerLilacSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .roseGold : ThemeModel(theme: .roseGold, name: "148Rose Gold", primary: .roseGoldPrimary, accent: .roseGoldAccent, secondary: .roseGoldSecondary, text: .black, messageList: .roseGoldSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .chestnutRose : ThemeModel(theme: .chestnutRose, name: "151Chestnut Rose", primary: .chestnutRosePrimary, accent: .chestnutRoseAccent, secondary: .chestnutRoseSecondary, text: .black, messageList: .chestnutRoseSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .tallPoppy : ThemeModel(theme: .tallPoppy, name: "154Tall Poppy", primary: .tallPoppyPrimary, accent: .tallPoppyAccent, secondary: .tallPoppySecondary, text: .black, messageList: .tallPoppySecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .darkTan : ThemeModel(theme: .darkTan, name: "157Dark Tan", primary: .darkTanPrimary, accent: .darkTanAccent, secondary: .darkTanSecondary, text: .black, messageList: .darkTanSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .burntMaroon : ThemeModel(theme: .burntMaroon, name: "160Burnt Maroon", primary: .burntMaroonPrimary, accent: .burntMaroonAccent, secondary: .burntMaroonSecondary, text: .black, messageList: .burntMaroonSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .alto : ThemeModel(theme: .alto, name: "163Alto", primary: .altoPrimary, accent: .altoAccent, secondary: .altoSecondary, text: .black, messageList: .altoSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .trueGray : ThemeModel(theme: .trueGray, name: "166True Gray", primary: .trueGrayPrimary, accent: .trueGrayAccent, secondary: .trueGraySecondary, text: .black, messageList: .trueGraySecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .merlin : ThemeModel(theme: .merlin, name: "169Merlin", primary: .merlinPrimary, accent: .merlinAccent, secondary: .merlinSecondary, text: .black, messageList: .merlinSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .kabul : ThemeModel(theme: .kabul, name: "172Kabul", primary: .kabulPrimary, accent: .kabulAccent, secondary: .kabulSecondary, text: .black, messageList: .kabulSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6)),
        .corkBrown : ThemeModel(theme: .corkBrown, name: "175Cork Brown", primary: .corkBrownPrimary, accent: .corkBrownAccent, secondary: .corkBrownSecondary, text: .black, messageList: .corkBrownSecondary, strokeOutline: .white, leftMessage: .white.opacity(0.6), rightMessage: .white.opacity(0.6))
    ]

    var booly = false

    init() {
        let savedLightTheme = UserDefaults.standard.value(forKey: "lightTheme") ?? "defaultLight"
        self.lightTheme = self.allThemes[convertStringToTheme(theme: savedLightTheme as? String ?? "defaultLight")]!
        let savedDarkTheme = UserDefaults.standard.value(forKey: "darkTheme") ?? "defaultDark"
        self.darkTheme = allThemes[convertStringToTheme(theme: savedDarkTheme as? String ?? "defaultDark")]!

        lightOrDark(light: colorScheme() == .light ? true : false)
    }
    func changeTheme(theme: Theme, light: Bool) {
        if light {
            self.lightTheme = allThemes[theme]!
            if colorScheme() == .light {
                self.theme = lightTheme
            }
            UserDefaults.standard.setValue(convertThemeToString(theme: theme), forKey: "lightTheme")
        } else {
            self.darkTheme = allThemes[theme]!
            if colorScheme() == .dark {
                self.theme = darkTheme
            }
            UserDefaults.standard.setValue(convertThemeToString(theme: theme), forKey: "darkTheme")
        }
    }
    func lightOrDark(light: Bool) {
        if light {
            theme = lightTheme
        } else {
            theme = darkTheme
        }
    }
    func colorScheme() -> ColorScheme {
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        if userInterfaceStyle == .light {
            return .light
        }else if userInterfaceStyle == .dark {
            return .dark
        }
        return .light
    }
}


extension ThemeController {
    func convertStringToTheme(theme: String) -> Theme {
        switch theme {
        case "defaultLight":
            return .defaultLight
        case "defaultDark":
            return .defaultDark
        case "royalBlue":
            return .royalBlue
        case "bigStone":
            return .bigStone
        case "cornflowerBlue":
            return .cornflowerBlue
        case "danube":
            return .danube
        case "icyBlue":
            return .icyBlue
        case "muave":
            return .muave
        case "heliotrope":
            return .heliotrope
        case "mediumPurple":
            return .mediumPurple
        case "seance":
            return .seance
        case "paleLeaf":
            return .paleLeaf
        case "laurel":
            return .laurel
        case "killarney":
            return .killarney
        case "everglade":
            return .everglade
        case "celtic":
            return .celtic
        case "zinnwaldite":
            return .zinnwaldite
        case "cornflowerLilac":
            return .cornflowerLilac
        case "roseGold":
            return .roseGold
        case "chestnutRose":
            return .chestnutRose
        case "tallPoppy":
            return .tallPoppy
        case "darkTan":
            return .darkTan
        case "burntMaroon":
            return .burntMaroon
        case "alto":
            return .alto
        case "trueGray":
            return .trueGray
        case "merlin":
            return .merlin
        case "kabul":
            return .kabul
        case "corkBrown":
            return .corkBrown
        default:
            return .defaultLight
        }
    }
    func convertThemeToString(theme: Theme) -> String {
        switch theme {
        case .defaultLight:
            return "defaultLight"
        case .defaultDark:
            return "defaultDark"
        case .royalBlue:
            return "royalBlue"
        case .bigStone:
            return "bigStone"
        case .cornflowerBlue:
            return "cornflowerBlue"
        case .danube:
            return "danube"
        case .icyBlue:
            return "icyBlue"
        case .muave:
            return "muave"
        case .heliotrope:
            return "heliotrope"
        case .mediumPurple:
            return "mediumPurple"
        case .seance:
            return "seance"
        case .paleLeaf:
            return "paleLeaf"
        case .laurel:
            return "laurel"
        case .killarney:
            return "killarney"
        case .everglade:
            return "everglade"
        case .celtic:
            return "celtic"
        case .zinnwaldite:
            return "zinnwaldite"
        case .cornflowerLilac:
            return "cornflowerLilac"
        case .roseGold:
            return "roseGold"
        case .chestnutRose:
            return "chestnutRose"
        case .tallPoppy:
            return "tallPoppy"
        case .darkTan:
            return "darkTan"
        case .burntMaroon:
            return "burntMaroon"
        case .alto:
            return "alto"
        case .trueGray:
            return "trueGray"
        case .merlin:
            return "merlin"
        case .kabul:
            return "kabul"
        case .corkBrown:
            return "corkBrown"
        default:
            return "defaultLight"
        }
    }
}
