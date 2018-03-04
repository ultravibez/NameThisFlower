//
//  ViewController.swift
//  NameThisFlower
//
//  Created by Matan Dahan on 04/03/2018.
//  Copyright © 2018 Matan Dahan. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker : UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            //imagePicker.allowsEditing = true
        } else {
            imagePicker.sourceType = .savedPhotosAlbum
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage : UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciImage : CIImage = CIImage(image: userPickedImage) else { fatalError("Cannot convert UIImage to CIImage") }
            
            detect(image: ciImage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("Loading CoreML Model Failed") }
        
        let request : VNCoreMLRequest = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let firstResult = request.results?.first as? VNClassificationObservation else { fatalError("Model Failed Classifying image") }
            
            self.navigationItem.title = firstResult.identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}
