//
//  ViewController.swift
//  ImageViewer
//
//  Created by Sundus Abrar on 28/07/2019.
//  Copyright © 2019 Cinemo. All rights reserved.
//

import UIKit

protocol ImageSelectedProtocol {
    func didFinishPickingImage(withPath path: URL)
}

class ImageListViewController: UIViewController {
    
    var imageDataSource = Array<URL>() {
        didSet {
            selectedIndex = imageDataSource.count - 1
            self.imageCollectionView.reloadData()
        }
    }
    
    var displayedImage = URL.init(string: "") {
        didSet {
            self.imageCollectionView.reloadData()
        }
    }
    
    var selectedIndex = 0
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "Large Image Viewer"
        self.navigationController?.navigationBar.tintColor = UIColor.darkText
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.add))
        
      self.imageCollectionView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        
        populateDataSource()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Custom Methods
    
    @objc func add() {
        let vc = IVUtilities.mainStoryboard().instantiateViewController(withIdentifier: SBIdentifiers.kImageSelectView) as! ImageSelectViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)        
    }
    
    func populateDataSource() {
        if let savedData = IVUtilities.shared.fetchSavedImages() as? [URL] {
            if savedData.count > 0 {
                self.imageDataSource = savedData
            }
        }
    }
}

//MARK: Receive new image

extension ImageListViewController: ImageSelectedProtocol {
    func didFinishPickingImage(withPath path: URL) {
        self.imageDataSource.append(path)
    }
}

//MARK: UICollectionView Cell Classes

class DisplayImageCell: UICollectionViewCell {              //display image cell
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 2
    }
}

class ThumbImageCell: UICollectionViewCell {                //thumbnail image cell
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 10
    }
    
}

//MARK: UICollectionView Implementation

extension ImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tWidth = self.view.frame.width
        
        if indexPath.section == 0 {
            return CGSize(width: tWidth, height: tWidth)
        }
        
        let thumbWidth = tWidth / 5 - 2
        return CGSize(width: thumbWidth, height: thumbWidth )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        else {
            return 0.5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return self.imageDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //switch display image to tapped image
        
        if indexPath.section == 1 {
            self.selectedIndex = indexPath.row
            self.imageCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayImage", for: indexPath) as! DisplayImageCell
            
            if imageDataSource.count > 0 {
                let data = try! Data.init(contentsOf: imageDataSource[selectedIndex])
                cell.imageView.image = UIImage.init(data: data)
            }
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbImage", for: indexPath) as! ThumbImageCell
            let data = try! Data.init(contentsOf: imageDataSource[indexPath.row])
            cell.imageView.image = UIImage.init(data: data)
            return cell
        }
        
    }
}

