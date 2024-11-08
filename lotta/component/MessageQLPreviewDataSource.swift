//
//  MessageQLPreviewDataSource.swift
//  lotta
//
//  Created by Alexis Rinaldoni on 08/11/2024.
//

import QuickLook
import LottaCoreAPI

class MessageQLPreviewDataSource: QLPreviewControllerDataSource {
    let files: [GetConversationQuery.Data.Conversation.Message.File]
    let userSession: UserSession
    var localFiles: [URL] = []
    
    var isLoading = false
    
    init(session: UserSession, files: [GetConversationQuery.Data.Conversation.Message.File]) {
        self.userSession = session
        self.files = files
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return localFiles.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        return PreviewItem(url: localFiles[index], title: files[index].filename)
    }
    
    func loadFiles(completion: @escaping () -> Void) -> Void {
        if (isLoading) {
            return
        }
       isLoading = true
        var loadedFilesCount = files.count
        for file in files {
            downloadFileFromRemoteURL(remoteURL: getFileUrl(file: file)!) { url in
                if let url = url {
                    self.localFiles.append(url)
                }
                loadedFilesCount -= 1
                print(loadedFilesCount)
                if loadedFilesCount == 0 {
                    self.isLoading = false
                    completion()
                }
            }
        }
    }
    
    func downloadFileFromRemoteURL(remoteURL: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: remoteURL) { localTempURL, response, error in
            guard let localTempURL = localTempURL, error == nil else {
                print("Failed to download file: \(error!)")
                completion(nil)
                return
            }

            // Move the file to a permanent location in the app's sandbox
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let localURL = documentsURL.appendingPathComponent(remoteURL.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: localURL.path) {
                    try fileManager.removeItem(at: localURL)
                }
                try fileManager.moveItem(at: localTempURL, to: localURL)
                completion(localURL)
            } catch {
                print("Error saving file locally: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    func getFileUrl(file: GetConversationQuery.Data.Conversation.Message.File) -> URL? {
        return file.id?.getUrl(for: userSession.tenant)
    }
    
}

class PreviewItem: NSObject, QLPreviewItem {
    // Required by QLPreviewItem
    var previewItemURL: URL?
    var previewItemTitle: String?

    // Custom initializer
    init(url: URL, title: String? = nil) {
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}
