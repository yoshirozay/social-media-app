//
//  QRCodeView.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/10/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase


struct QRCodeView: View {
@Binding var qrCodeImageData: Data?
    var body: some View {
        ZStack {
            VStack {
                HStack{
                Button {
                    qrCodeImageData = nil
                } label: {
                     Image(systemName: "xmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.speakerPurple)
                }.buttonStyle(.borderless)
                .padding(.leading,10)
                    Spacer()
                }
                if let data = qrCodeImageData,
                    let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: screenWidth-80, height: screenWidth-80, alignment: .center)
                }
            }
            .padding(.bottom,40)
            .padding(.top,20)
            .background(Color.gray
                            .opacity(0.5).cornerRadius(30))
        }.onAppear{
            
        }
    }
}
