//
//  VerifyPhoneNumber.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 3/7/22.
//

import SwiftUI

struct VerifyPhoneNumber: View { 
      @State var y : CGFloat = 150 
      @State var countryFlag = "🇨🇦"
//    @State var countryCode = ""
    //phoneVM.verificationID.isEmpty
    
    @State var showProgresser : Bool = false
    @State var keyboard = KeyboardOO()
    @StateObject var phoneVM = PhoneVerificationVM()
    @EnvironmentObject var alert : AlertOO
    
    @Binding var showContacts: Bool
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            Color.speakerPurple.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation (.spring()) {
                        self.y = 150
                        hideKeyboard()
                        
                    }
                }
            
            if showProgresser {
                ProgressViewPurpleCircular().scaleEffect(3)
            }
            
            VStack (alignment: .center) {
                HStack (spacing: 16) {
                    Button(action: {
                        showContacts = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(Color.mainColor)
                    }
                    .padding(.leading)
                    .offset(y: 2)
                    Spacer()
                    Text("Verification")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color.mainColor)
                        .padding(.trailing, 60)
   
                    
                    Spacer()
//
                }
                Image(systemName: "arrow.turn.up.forward.iphone")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .offset(x: -50, y: 50)
                ZStack {
                Spacer()
                ZStack {
                    if phoneVM.verificationID.isEmpty {
                         HStack (spacing: 0) {
                             Text(phoneVM.countryCode.isEmpty ? "🇨🇦 +1" : "\(countryFlag) +\(phoneVM.countryCode)")
                                 .frame(width: 80, height: 50)
                                 .background(Color.secondary.opacity(0.2))
                                 .cornerRadius(10)
                                 .foregroundColor(phoneVM.countryCode.isEmpty ? .secondary : .black)
                                 .onTapGesture {
                                     withAnimation (.spring()) {
                                         if self.y != 0 {
                                         self.y = -100
                                         } else {
                                             self.y = 150
                                         }
                                     }
                             }
                             TextField("Phone Number", text: $phoneVM.phoneNumber)
                                 .padding()
                                 .frame(width: 200, height: 50)
                                 .keyboardType(.phonePad)
                         }.padding()
                        .offset(y: -40)
                    } else {
                        TextField("Enter Verification Code", text: $phoneVM.verificationCode)
                            .padding()
                            .frame(width: 270, height: 50)
                            .keyboardType(.numberPad)
                            .offset(x: 27, y: -40)
                    }
                    CountryCodes(countryCode: $phoneVM.countryCode, countryFlag: $countryFlag, y: $y)
                             .offset(y: y)
                         
                         RoundedRectangle(cornerRadius: 10).stroke()
                         .frame(width: 280, height: 50)
                         .offset(y: -40)
                         .opacity(self.y != 150 && keyboard.value > 0 ? 0 : 1)
                    
                    VStack {
                    Text("Verifying your phone number makes it easier to find people you know")
                            .multilineTextAlignment(.center)
                        .frame(width: 290, height: 70)
                        .offset(x: 0, y: 40)
                        .opacity(self.y != 150 && keyboard.value > 0 ? 0 : 1)
                        if phoneVM.verificationID.isEmpty {
                            Button(action: {
                                if showProgresser == false {
                                    showProgresser = true
                                    phoneVM.sendCode { error in
                                        showProgresser = false
                                        if let description = error?.localizedDescription{
                                            alert.alertDetail = description
                                        }
                                    }
                                }
                            }) {
                        ZStack {
                            Text("Send Code")
                                .font(.headline)
                                .foregroundColor(Color.white)
                        }
                        .frame(width: 200, height: 50)
                        .background(Color.speakerPurple)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                        }
                        
                        .opacity(phoneVM.phoneNumber == "" || self.y != 150 ? 0.00 : 1.00)
                        .disabled(phoneVM.phoneNumber == "" || self.y != 150 ? true : false)
                        .animation(.easeIn(duration: 0.3))
                        .offset(x: 0, y: 40)
                        } else {
                            Button(action: {
                                if showProgresser == false {
                                    showProgresser = true
                                    phoneVM.signIn { error in
                                        showProgresser = false
                                        if let description = error?.localizedDescription{
                                            alert.alertDetail = error.descriptionIfAny
                                        }else{
                                            showContacts = false
                                        }
                                    }
                                }
                            }) {
                            ZStack {
                                Text("Confirm")
                                    .font(.headline)
                                    .foregroundColor(Color.white)
                            }
                            .frame(width: 200, height: 50)
                            .background(Color.speakerPurple)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                            }
                            .animation(.easeIn(duration: 0.3))
                            .offset(x: 0, y: 40)
                        }
                     }
                }
             
                Spacer()
            }
            }
        }
    }
}

struct VerifyPhoneNumber_Previews: PreviewProvider {
    static var previews: some View {
        VerifyPhoneNumber(showContacts: .constant(true))
    }
}

struct CountryCodes : View {
    @Binding var countryCode : String
      @Binding var countryFlag : String
      @Binding var y : CGFloat
    
  var body: some View {
      GeometryReader { geo in
                 List(self.countryDictionary.sorted(by: <), id: \.key) { key , value in
                     HStack {
                         Text("\(self.flag(country: key))")
                         Text("\(self.countryName(countryCode: key) ?? key)")
                         Spacer()
                         Text("+\(value)").foregroundColor(.secondary)
                     }.background(Color.white)
                         .font(.system(size: 20))
                         .onTapGesture {
                             self.countryCode = value
                             self.countryFlag = self.flag(country: key)
                             withAnimation(.spring()) {
                                 self.y = 150
                             }
                     }
                 }
                 .padding(.horizontal, iOS15 ? -20 : 0)
                 .padding(.bottom)
                 .frame(width: geo.size.width, height: 300)
                 .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).maxY - 150)
                 
             }
  }
  let countryDictionary  = ["AF":"93","AL":"355","DZ":"213","US":"1",
                              "AD":"376","AO":"244","AI":"1","AG":"1","AR":"54",
                              "AM":"374","AW":"297","AU":"61","AT":"43","AZ":"994",
                              "BS":"1","BH":"973","BD":"880","BB":"1","BY":"375",
                              "BE":"32","BZ":"501","BJ":"229","BM":"1","BT":"975",
                              "BA":"387","BW":"267","BR":"55","IO":"246","BG":"359",
                              "BF":"226","BI":"257","KH":"855","CM":"237","CA":"1",
                              "CV":"238","KY":"345","CF":"236","TD":"235","CL":"56","CN":"86",
                              "CX":"61","CO":"57","KM":"269","CG":"242","CK":"682","CR":"506",
                              "HR":"385","CU":"53","CY":"537","CZ":"420","DK":"45","DJ":"253",
                              "DM":"1","DO":"1","EC":"593","EG":"20","SV":"503","GQ":"240",
                              "ER":"291","EE":"372","ET":"251","FO":"298","FJ":"679","FI":"358",
                              "FR":"33","GF":"594","PF":"689","GA":"241","GM":"220","GE":"995",
                              "DE":"49","GH":"233","GI":"350","GR":"30","GL":"299","GD":"1",
                              "GP":"590","GU":"1","GT":"502","GN":"224","GW":"245","GY":"595","HT":"509",
                              "HN":"504","HU":"36","IS":"354","IN":"91","ID":"62","IQ":"964",
                              "IE":"353","IL":"972","IT":"39","JM":"1","JP":"81","JO":"962",
                              "KZ":"77","KE":"254","KI":"686","KW":"965","KG":"996","LV":"371",
                              "LB":"961","LS":"266","LR":"231","LI":"423","LT":"370","LU":"352",
                              "MG":"261","MW":"265","MY":"60","MV":"960","ML":"223",
                              "MT":"356","MH":"692","MQ":"596","MR":"222","MU":"230","YT":"262",
                              "MX":"52","MC":"377","MN":"976", "ME":"382","MS":"1","MA":"212",
                              "MM":"95","NA":"264","NR":"674","NP":"977","NL":"31","NC":"687",
                              "NZ":"64","NI":"505","NE":"227","NG":"234","NU":"683",
                              "NF":"672","MP":"1","NO":"47","OM":"968","PK":"92","PW":"680",
                              "PA":"507","PG":"675","PY":"595","PE":"51","PH":"63","PL":"48",
                              "PT":"351","PR":"1","QA":"974","RO":"40","RW":"250","WS":"685",
                              "SM":"378","SA":"966","SN":"221","RS":"381","SC":"248",
                              "SL":"232","SG":"65","SK":"421","SI":"386","SB":"677",
                              "ZA":"27","GS":"500","ES":"34","LK":"94","SD":"249","SR":"597",
                              "SZ":"268","SE":"46","CH":"41","TJ":"992","TH":"66","TG":"228",
                              "TK":"690","TO":"676","TT":"1","TN":"216","TR":"90",
                              "TM":"993","TC":"1","TV":"688","UG":"256","UA":"380",
                              "AE":"971","GB":"44","AS":"1","UY":"598","UZ":"998",
                              "VU":"678","WF":"681","YE":"967","ZM":"260",
                              "ZW":"263","BO":"591","BN":"673","CC":"61",
                              "CD":"243","CI":"225","FK":"500","GG":"44",
                              "VA":"379","HK":"852","IR":"98","IM":"44",
                              "JE":"44","KP":"850","KR":"82","LA":"856",
                              "LY":"218","MO":"853","MK":"389","FM":"691",
                              "MD":"373","MZ":"258","PS":"970","PN":"872",
                              "RE":"262","RU":"7","BL":"590","SH":"290","KN":"1",
                              "LC":"1","MF":"590","PM":"508","VC":"1","ST":"239",
                              "SO":"252","SJ":"47","SY":"963","TW":"886","TZ":"255",
                              "TL":"670","VE":"58","VN":"84","VG":"284","VI":"340"]
    func countryName(countryCode: String) -> String? {
            let current = Locale(identifier: "en_US")
            return current.localizedString(forRegionCode: countryCode)
        }
    
    func flag(country:String) -> String {
            let base : UInt32 = 127397
            var flag = ""
            for v in country.unicodeScalars {
                flag.unicodeScalars.append(UnicodeScalar(base + v.value)!)
            }
            return flag
        }
}

