//
//  ScanService.swift
//  SnapHabit
//
//  Created by Tomas Liivak on 4/22/26.
//

import Foundation
import Alamofire

nonisolated struct UploadResponse: Decodable, Sendable {
    let success: Bool
    let message: String
    let labels: [String]?
}

nonisolated enum UploadError: Error {
    case badURL
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func uploadImageData(_ imageData: Data) async throws -> UploadResponse {
        let urlString = backendUrl // In Secrets.swift file
        print("Logging Data")
        guard let url = URL(string: urlString) else {
            throw UploadError.badURL
        }

        return try await AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(
                    imageData,
                    withName: "image",          // must match upload.single("image") on Express
                    fileName: "photo.jpg",      // keep this
                    mimeType: "image/jpeg"      // change if your data is png
                )
            },
            to: url
        )
        .validate()
        .serializingDecodable(UploadResponse.self)
        .value
    }
}
