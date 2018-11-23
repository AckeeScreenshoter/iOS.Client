//
//  URLRequestExtensions.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import Foundation

func myImageUploadRequest(image: UIImage, appInfo: AppInfo)
{
    
    let myUrl =  URL(string: "http://requestbin.fullcontact.com/1aoiaq11");
    //let myUrl = NSURL(string: "http://www.boredwear.com/utils/postImage.php");
    
    var request = URLRequest(url:myUrl!);
    request.httpMethod = "POST";
    
    let encoder = JSONEncoder()
    let paramData = try! encoder.encode(appInfo)
    
    let boundary = "-----abc"//generateBoundaryString()
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    
    let imageData = image.jpegData(compressionQuality: 1)
    
    if(imageData==nil)  { return; }
    
    request.httpBody = createBodyWithParameters(parameters: paramData, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
    
    let task = URLSession.shared.dataTask(with: request) {
        data, response, error in
        
        if error != nil {
            print("error=\(error)")
            return
        }
        
        // You can print out response object
        print("******* response = \(response)")
        
        // Print out reponse body
        let responseString = String(data: data!, encoding: .utf8)
        print("****** response data = \(responseString!)")
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            
            print(json)
            
        }catch
        {
            print(error)
        }
        
    }
    
    task.resume()
}


func createBodyWithParameters(parameters: Data?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
    var body = Data()
    
    if let parameters = parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"metadata\"\r\n\r\n")
            body.append(parameters)
            body.appendString("\r\n")
    }
    
    let filename = "screenshot.jpg"
    let mimetype = "image/jpg"
    
    body.appendString("--\(boundary)\r\n")
    body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
    body.append(imageDataKey)
    body.appendString("\r\n")
    
    
    
    body.appendString("--\(boundary)--\r\n")
    
    return body
}


extension Data {
    mutating func appendString(_ str: String) {
        append(str.data(using: .utf8)!)
    }
}
