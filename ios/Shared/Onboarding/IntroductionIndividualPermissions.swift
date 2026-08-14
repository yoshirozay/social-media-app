//
//  IntroductionIndividualPermissions.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/1/22.
//
import SwiftUI

struct IntroductionIndividualPermissions: View {
    let permissonType: PermissonType
    let description: String  
    let image: String
    var isImageInAssets: Bool = false
    @ObservedObject var permissonVM: PermissionVM
    @Environment(\.colorScheme) var colorScheme
    var permissionAccess: Set<PermissonType>{
        permissonVM.permissionAccess
    }
    var body: some View {
        HStack {
            if isImageInAssets {
                Image(image)
                    .resizable()
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: image)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color.black)
            }
            VStack (alignment: .leading) {
                Text(permissonType())
                    .font(.headline)
                Text(description)
                    .font(.caption)
            }
            .foregroundColor(Color.black)
            Spacer()
            Button(action: {
                  permissonVM.askForPermissonOf(permissonType)
            }) {
                Circle() 
                    .fill(Color.speakerPurple.opacity(doHavePermisson ? 1 : 0.1))
                    .frame(width: 30, height: 30)
            }
        }
        .padding(.horizontal, 10)
        .frame(width: screenWidth/1.1, height: 70) // 300
//                            .padding(screenWidth/10.7) // 40
        .background(Color.mainColorInverse.opacity(colorScheme == .light ? 0.4 : 0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
//        .disabled(doHavePermisson)
    }
   var doHavePermisson: Bool {
       permissionAccess.contains(permissonType)
   }
}
