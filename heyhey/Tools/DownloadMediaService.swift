//
//  DownloadMediaService.swift
//  heyhey
//
//  Created by Vlad Tretiak on 06.12.2020.
//

import Foundation

final class DownloadMediaService: NSObject {
    static let shared = DownloadMediaService()
    
    private let queue = DispatchQueue(label: "image.download.queue")
    private var urlSession: URLSession!
    private let fileManager: FileManager
    
    private var downloadTasks = [URL: DownloadTaskInfo]()
    private var taskListeners = [URL: [String: Listener]]()
    
    var backgroundCompletionHandler: (() -> ())?
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        
        super.init()
        
        self.urlSession = URLSession.init(configuration: .background(withIdentifier: "background"), delegate: self, delegateQueue: nil)
    }
    
    func fetchMedia(with path: String,
                    progressBlock: @escaping (Float) -> Void,
                    completionBlock: @escaping (Error?, URL?) -> Void) -> Dispossable? {
        
        guard let url = URL(string: "https://smktesting.herokuapp.com/static/\(path)") else { return nil }
        let localFilePath = localCacheMediaPath(by: url)
        let mediaIdentifier = url
        let disposable: Dispossable?
        
        if fileManager.fileExists(atPath: localFilePath.path) {
            queue.async { completionBlock(nil, localFilePath) }
            disposable = nil
        } else {
            let callbackId = UUID().uuidString
            
            if var listeners = taskListeners[mediaIdentifier] {
                listeners[callbackId] = (progressBlock, completionBlock)
                taskListeners[mediaIdentifier] = listeners
            } else {
                taskListeners[mediaIdentifier] = [callbackId: (progressBlock, completionBlock)]
            }
            
            if let taskInfo = downloadTasks[mediaIdentifier] {
                let task: URLSessionDownloadTask
                if let tsk = taskInfo.sessionTask {
                    task = tsk
                } else {
                    if let resumeData = taskInfo.resumeData {
                        task = urlSession.downloadTask(withResumeData: resumeData)
                        taskInfo.resumeData = nil
                    } else {
                        var request = URLRequest(url: url)
                        request.httpMethod = "GET"
                        task = urlSession.downloadTask(with: request)
                    }
                    
                    downloadTasks[mediaIdentifier] = DownloadTaskInfo(sessionTask: task)
                    resumeTask(task, mediaIdentifier: mediaIdentifier, destinationFilePath: localFilePath)
                }
                
                progressBlock(Float(task.progress.fractionCompleted))
            } else {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = urlSession.downloadTask(with: request)
                downloadTasks[mediaIdentifier] = DownloadTaskInfo(sessionTask: task)
                
                resumeTask(task, mediaIdentifier: mediaIdentifier, destinationFilePath: localFilePath)
            }
            
            disposable = DispossableBlock {
                self.taskListeners[mediaIdentifier]?[callbackId] = nil
                
                if self.taskListeners[mediaIdentifier]?.keys.count == 0 {
                    let taksInfo = self.downloadTasks[mediaIdentifier]
                    taksInfo?.sessionTask?.cancel(byProducingResumeData: { data in
                        taksInfo?.resumeData = data
                    })
                    taksInfo?.sessionTask = nil
                }
            }
        }
        return disposable
    }
    
    private func  handleResponse(error: Error?,
                                 tempFilePath: URL?,
                                 mediaIdentifier: URL,
                                 destinationFilePath: URL?) {
        let listeners = taskListeners.first { key, _ in
            key == mediaIdentifier
        }?.value.values
        
        if let url = tempFilePath, let dest = destinationFilePath {
            try? fileManager.copyItem(at: url, to: dest)
        }
        
        listeners?.forEach {
            $0.completionBlock(error, (tempFilePath != nil ? destinationFilePath : nil))
        }
        
        taskListeners[mediaIdentifier] = nil
        
        if let error = error as NSError?, error.code == NSURLErrorCancelled {
            
        } else {
            downloadTasks[mediaIdentifier] = nil
        }
    }
    
    private func resumeTask(_ task: URLSessionDownloadTask,
                            mediaIdentifier: URL,
                            destinationFilePath: URL) {
        task.resume()
    }
    
    func cancelAllTasks() {
        urlSession.invalidateAndCancel()
    }
    
    func localCacheMediaPath(by remoteUrl: URL) -> URL {
        var fileURL = FileManager.default.temporaryDirectory
        fileURL.appendPathComponent(remoteUrl.lastPathComponent)
        return fileURL
    }
    
}

private extension DownloadMediaService {
    
    func localMediaIdentifier(by remoteUrl: URL) -> String {
        remoteUrl.lastPathComponent
    }
    
}

private extension DownloadMediaService {
    typealias Listener = (progressBlock: (Float) -> Void, completionBlock: (Error?, URL?) -> Void)
    
    class DownloadTaskInfo {
        var sessionTask: URLSessionDownloadTask?
        var resumeData: Data? = nil
        
        init(sessionTask: URLSessionDownloadTask) {
            self.sessionTask = sessionTask
        }
    }
}

extension DownloadMediaService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, let url = task.response?.url {
            handleResponse(error: error, tempFilePath: nil, mediaIdentifier: url, destinationFilePath: nil)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.response?.url else {
            return
        }
        
        var fileUrl = fileManager.temporaryDirectory
        fileUrl.appendPathComponent(UUID().uuidString)
        fileUrl.appendPathExtension((downloadTask.response?.suggestedFilename as NSString?)?.pathExtension ?? "")
        
        do {
            try fileManager.copyItem(at: location, to: fileUrl)
            let localFilePath = localCacheMediaPath(by: url)
            handleResponse(error: nil, tempFilePath: fileUrl, mediaIdentifier: url, destinationFilePath: localFilePath)
        } catch {
            handleResponse(error: error, tempFilePath: nil, mediaIdentifier: url, destinationFilePath: nil)
        }
    }
}

