//
//  .swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/4/21.
//

 
import SwiftUI
//MARK:- tutorial number  11
struct CanAttachMultipleKeysTutorialView  : View {
     
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    let detail = "You can attach multiple keys to any moment"
    var body : some View {
        ZStack{
            CenteredTextWithNexButtonView(detail: detail, width : 270)
        }
        .highPriorityGesture( DragGesture()  )
    }
}
