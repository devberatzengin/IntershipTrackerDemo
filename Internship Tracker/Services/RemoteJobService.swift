import Foundation

enum RemoteJobServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "API adresi oluşturulamadı."
        case .invalidResponse:
            return "Sunucudan geçerli yanıt alınamadı."
        case .badStatusCode(let code):
            return "API hata kodu döndürdü: \(code)"
        }
    }
}

struct RemoteJobService {
    func fetchJobs(searchText: String = "internship") async throws -> [RemoteJob] {
        var components = URLComponents(string: "https://remotive.com/api/remote-jobs")
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedSearch.isEmpty {
            components?.queryItems = [
                URLQueryItem(name: "search", value: trimmedSearch)
            ]
        }

        guard let url = components?.url else {
            throw RemoteJobServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteJobServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RemoteJobServiceError.badStatusCode(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(RemoteJobResponse.self, from: data).jobs
    }
}
