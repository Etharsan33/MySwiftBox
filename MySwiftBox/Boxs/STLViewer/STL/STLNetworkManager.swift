//
//  STLNetworkManager.swift
//  MySwiftBox
//
//  Created by Elankumaran Tharsan on 07/10/2020.
//  Copyright © 2020 Elankumaran Tharsan. All rights reserved.
//

import Foundation
import Alamofire

class STLNetworkManager {
    
    /// download STL
    ///
    /// - Parameters:
    ///   - url
    ///   - completion: callback
    static func downloadSTL(url: URL, filename: String, completion: @escaping ((Result<URL, Error>) -> Void)) {
        
        func downloadToServer() {
            self.downloadToFileLocal(url: url.absoluteString, filename: filename, progressHandler: nil) { result in
                switch result {
                case .success(let url):
                    completion(.success(url))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderSTLURL = documentsURL.appendingPathComponent("STL")
        let pathFileUrl = folderSTLURL.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: pathFileUrl.path) {
            print(pathFileUrl)
            completion(.success(pathFileUrl))
            return
        }
        
        downloadToServer()
    }
    
    private static func downloadToFileLocal(url: String, filename: String, progressHandler: ((_ progress : Double) -> Void)?, completion: @escaping ((Result<URL, Error>) -> Void)) {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var folderSTLURL = documentsURL.appendingPathComponent("STL")
        
        // Create folder if not exist
        if !FileManager.default.fileExists(atPath: folderSTLURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderSTLURL, withIntermediateDirectories: false, attributes: nil)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        // Check if files on directory STL is up to 10 and remove it
        do {
            let contentsInDirectory = try FileManager.default.contentsOfDirectory(atPath: folderSTLURL.path).sorted(by: { (path, path1) -> Bool in
                if let date = self.getFileCreatedDate(folderSTLURL.path + "/" + path), let date1 = self.getFileCreatedDate(folderSTLURL.path + "/" + path1) {
                    return date < date1
                }
                return false
            }).filter({ $0.contains("stl") })
            
            if contentsInDirectory.count >= 10, let firstFilePath = contentsInDirectory.first {
                do {
                    try FileManager.default.removeItem(atPath: folderSTLURL.path + "/" + firstFilePath)
                } catch {
                    completion(.failure(error))
                    return
                }
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        let destination: DownloadRequest.Destination? = { _, _ in
            folderSTLURL.appendPathComponent(filename)
            return (folderSTLURL, [.removePreviousFile])
        }
        
        let request = AF.download(url, to: destination).response { response in
            
            switch response.result {
            case .success(let url):
                guard let url = url else {
                    let unknownError = NSError(domain:"", code:409, userInfo:[NSLocalizedDescriptionKey: "URL not valid"])
                    completion(.failure(unknownError))
                    return
                }
                completion(.success(url))
            case .failure(let afError):
                completion(.failure(afError))
            }
        }
        
        request.resume()
    }
    
    private static func getFileCreatedDate(_ theFile: String) -> Date? {
        do {
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: theFile) as [FileAttributeKey:Any]
            return aFileAttributes[FileAttributeKey.creationDate] as? Date
        } catch {
            return nil
        }
    }
    
}
