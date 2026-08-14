//
//  YPPhotoFiltersVC+Extension.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/7/21.
//
  
import YPImagePicker

extension YPPhotoFiltersVC {
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = UIImage.SymbolConfiguration(pointSize: 22)
        var image = UIImage(systemName: "chevron.backward", withConfiguration:configuration)?.withTintColor(.black)
        image = image?.withAlignmentRectInsets(.init(top: 9, left: 0, bottom: 0, right: 0))
        self.navigationItem.leftBarButtonItem?.setBackgroundImage(image, for: .normal, barMetrics: UIBarMetrics.default)
        
        if self.inputPhoto.fromCamera {
        let buttonVC = SaveImageButtonVC()
           buttonVC.view.frame = SaveImageButtonVC.frame
          buttonVC.originalImage = self.inputPhoto.originalImage
           self.addChild(buttonVC)
           self.view.addSubview(buttonVC.view)
            buttonVC.didMove(toParent: self)
        }
    }
}

