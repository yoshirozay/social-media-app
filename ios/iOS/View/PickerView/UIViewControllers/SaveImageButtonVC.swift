//
//  SaveImageButtonVC.swift
//  testingSwiftUI
//
//  Created by Ahmad naeem on 4/27/21.
//
    
import YPImagePicker


class SaveImageButtonVC : UIViewController {
   var saveButton : UIButton! = UIButton()
   var originalImage: UIImage!
   override func viewDidLoad() {
       super.viewDidLoad()
       setUpSaveButton()
   }
   
   func setUpSaveButton() {
    saveButton = UIButton (frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Self.size))
       let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)
       let saveImage = UIImage(systemName: "square.and.arrow.down", withConfiguration:configuration)
       ///TODO:- need to change to real speakerPurple color
       let speakerPurple = UIColor(named: "speakerPurple")//UIColor.purple
       saveButton.tintColor  = speakerPurple
       saveButton.setImage(saveImage, for: .normal)
       saveButton.isUserInteractionEnabled = true
       saveButton.addAction(UIAction(handler: {[weak self] (_) in
        if let originalImage = self?.originalImage {
                UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil)
           }
//           print("save image")
           self?.view.isHidden = true 
       }), for: .touchUpInside)
    
       self.view.addSubview(saveButton)
   }
    
   static var topMargin : CGFloat {
    let diff : CGFloat =  screenHeight > 699 ? 15 : 0//(screenHeight - screenWidth - 160 - 44)/2
       return diff
   }
    
    static var size : CGSize = CGSize(width: 40, height: 40)
    static var frame = CGRect(origin: CGPoint(x: screenWidth-size.width-30, y: screenWidth+topMargin), size: size)
    
   deinit {
 
   }
}
