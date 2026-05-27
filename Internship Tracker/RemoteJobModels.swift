import Foundation

struct RemoteJobResponse: Decodable {
    let jobs: [RemoteJob]
}

struct RemoteJob: Identifiable, Decodable, Equatable {
    let id: Int
    let url: String
    let title: String
    let companyName: String
    let category: String?
    let jobType: String?
    let publicationDate: String?
    let candidateRequiredLocation: String?
    let salary: String?
    let description: String?
    let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case companyName = "company_name"
        case category
        case jobType = "job_type"
        case publicationDate = "publication_date"
        case candidateRequiredLocation = "candidate_required_location"
        case salary
        case description
        case tags
    }

    var applyURL: URL? {
        URL(string: url)
    }

    var locationText: String {
        let value = candidateRequiredLocation?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? "Remote / Konum belirtilmemiş" : value
    }

    var sourceText: String {
        "Remotive"
    }

    var cleanedDescription: String {
        (description ?? "")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
