//
//  QRScannerView.swift
//  QRCodeTest
//
//  Created by Ahmad naeem on 10/28/21.
//

import SwiftUI
import UIKit
import Combine

import AVFoundation

struct QRScannerView : View {
    @Binding var showQRScanner : Bool
    @State private var link : String?
    @EnvironmentObject var sharedPerson : DynamicViewsNavigationOO
    @EnvironmentObject var alert : AlertOO
//    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            Color.blue
            QRScannerViewRepresentable(link : $link)
//                .frame(width: phoneWidth-80, height: phoneHeight-130, alignment: .center)
            VStack{
                HStack{
                    Button {
                        showQRScanner = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.speakerPurple)
                            .contentShape(Circle())
                    }
                    .padding(.leading ,30)
                    .padding(.top , 80)
                    Spacer()
                }
                Spacer()
            }
            
        }
        .frame(width: screenWidth, height: screenHeight, alignment: .center)
        .onChange(of: link) { linkString in
//              print(" onChange(of: link) \(linkString)")
            if let linkString = linkString{
                if let url = URL(string: linkString) {
                    sharedPerson.parseToDeepLink(url: url)
                }else{
                    alert.alertDetail = "Incorrect QR code"
                }
                showQRScanner = false
            }
        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                alert.alertDetail = "Incorrect QR code"
//                showQRScanner = false
////                if let url = URL(string: "https://speakez.cloud/KtPDACuj18yqHjdi6"){
////                    sharedPerson.parseToDeepLink(url: url)
////                    showQRScanner = false
////                }
//            }
//        }
    }
}

struct QRScannerViewRepresentable : UIViewControllerRepresentable{
    @Binding var link : String? 
    func makeUIViewController(context: Context) -> ScannerViewController {
       let scannerVC =  ScannerViewController()
        scannerVC.action = { String in
            link = String
        }
        return scannerVC
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
           print(" updateUIViewController  ")
    }
   
    typealias UIViewControllerType = ScannerViewController
    
 
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let publisher = PassthroughSubject<String,Never>()

    var action : ((String)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
//        action?("")

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
       

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        captureSession.stopRunning()
         print("found(code: String)  \(code)")
         action?(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
