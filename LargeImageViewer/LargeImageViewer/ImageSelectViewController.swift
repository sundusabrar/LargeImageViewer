//
//  ImageSelectViewController.swift
//  LargeImageHandler
//
//  Created by Sundus Abrar on 26/07/2019.
//  Copyright © 2019 Cinemo. All rights reserved.
//

import Foundation
import UIKit
import arek
import ALCameraViewController

class ImageSelectViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var imageName: URL?
    var delegate: ImageSelectedProtocol?
    
    lazy var actionSheet : UIAlertController = {
        let actionSheet = UIAlertController(title: "", message: "Select Source", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.requestCameraPermission()
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
                self.requestPhotoLibraryPermission()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))
        
        return actionSheet
    }()
    
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.tintColor = UIColor.darkText
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.finishAddingImage))
        
        //Present menu for image selection
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: Custom Methods
    
    @objc func finishAddingImage() {
        if let d = delegate {
            d.didFinishPickingImage(withPath: imageName!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //Check if camera permission is granted
    
    func checkCameraPermission() -> ArekPermissionStatus {
        
        let permission = ArekPhoto()
        var stat = ArekPermissionStatus.notDetermined
        
        permission.status { (status) in
            stat = status
        }
        return stat
    }
    
    //MARK: Permissions
    
    func requestCameraPermission() {
    
        let tmp = ArekCamera()
        let conf = ArekConfiguration(frequency: .OnceAWeek, presentInitialPopup: true, presentReEnablePopup: true)
      
        let initialPopupData = ArekPopupData(title: "Camera Access Required",
                                              message: "Image Viewer would like to access your Camera",
                                              image: "\(tmp.identifier)_image",
            allowButtonTitle: "allow",
            denyButtonTitle: "deny",
            styling: nil)
        
        let reEnablePopupData = ArekPopupData(title: "Camera Access Required",
                                             message: "Image Viewer would like to access your Camera",
                                             image: "\(tmp.identifier)_image",
                                             allowButtonTitle: "allow",
                                             denyButtonTitle: "deny",
                                             styling: nil)
        
        let cam_permission = ArekCamera(configuration: conf, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
        
        cam_permission.manage { (status) in
            switch status {
            case .authorized:
                //launch camera view
                self.launchPicker(media: .Camera)
                break
            case .denied:
                self.navigationController?.popViewController(animated: true)
            case .notDetermined: break
            case .notAvailable: break
            }
        }
    }
    
    func requestPhotoLibraryPermission() {
        let photos = ArekPhoto()
        print(photos.identifier)
        
        let conf = ArekConfiguration(frequency: .OnceAWeek, presentInitialPopup: true, presentReEnablePopup: true)
        let p_initialPopupData = ArekPopupData(title: "Photo Library Access Required",
                                               message: "Image Viewer would like to access your Photos",
                                               image: "\(photos.identifier)_image",
            allowButtonTitle: "allow",
            denyButtonTitle: "deny",
            styling: nil)
        
        let p_reEnablePopupData = ArekPopupData(title: "Photo Library Access Required",
                                                message: "Image Viewer would like to access your Photos",
                                                image: "\(photos.identifier)_image",
            allowButtonTitle: "allow",
            denyButtonTitle: "deny",
            styling: nil)
        
        
        let photo_permission = ArekPhoto(configuration: conf, initialPopupData: p_initialPopupData, reEnablePopupData: p_reEnablePopupData)
        
        photo_permission.manage { (status) in
            switch status {
            case .authorized:
                //launch library view
                self.launchPicker(media: .PhotoLibrary)
                break
            case .denied:
                self.navigationController?.popViewController(animated: true)
                break
            case .notDetermined: break
            case .notAvailable: break
            }
        }
    }
    
    func launchPicker(media: MediaType) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if media == .Camera {
            imagePicker.sourceType = .camera
        }
        else if media == .PhotoLibrary {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: UIImagePickerControllerDelegate Implementation

extension ImageSelectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true)
        var resizedImage : UIImage = UIImage()
        var availableKey = ""
        
        if #available(iOS 11.0, *) {
            availableKey = UIImagePickerControllerImageURL
        }
         else {
            availableKey = UIImagePickerControllerOriginalImage
        }
        
        guard let imageURL = info[availableKey] as? NSURL else {
            print("Unable to resolve image path --  Image captured using camera")
            
            let imgName = "image_" + String(format: "%f", NSDate().timeIntervalSince1970)
            resizedImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
            resizedImage = IVUtilities.shared.imageOrientation(resizedImage)
            self.imageView.image = resizedImage
            imageName = IVUtilities.shared.saveThumbnail(forImage: resizedImage, withName: imgName)
            return
        }
        
        resizedImage = IVUtilities.shared.downsample(imageAt: imageURL as URL, to: self.imageView.frame.size, scale: 1.0)
        let imgName = "image_" + String(format: "%f", NSDate().timeIntervalSince1970)
        self.imageView.image = resizedImage
        imageName = IVUtilities.shared.saveThumbnail(forImage: resizedImage, withName: imgName)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //handle cancel selection
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
