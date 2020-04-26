//
//  ResumeViewModal.swift
//  Resume
//
//  Created by Navneet Singh on 4/13/20.
//  Copyright © 2020 Navneet Singh. All rights reserved.
//

import Foundation
import Combine

class ResumeViewModal: ObservableObject, Identifiable {

    private let headers: [String] = ["","Summary",
                                     "Experience", "Technical Skills",
                                     "Education","Languages"]

    @Published var sectionsHeaders : [String] = []
    @Published var profile : [Resume.Profile] = []
    @Published var summary : [String] = []
    @Published var skills : [Resume.Skill] = []

    @Published var experience : [Resume.Experience] = []
    @Published var education : [Resume.Education] = []
    @Published var languages : [Resume.Language] = []

    @Published var sections : [Any] = []

    private var disposables = Set<AnyCancellable>()

    private var resumeDetails: Resume?{
        didSet{
            sectionsHeaders = headers
            guard let details = resumeDetails else{ return }

            profile = [details.profile]
            summary = details.summary
            experience = details.experience
            skills = details.skills
            education = details.education
            languages = details.languages
        }

    }

    private var networkManager : NetworkManager
    init(session: URLSession = .shared ) {
        networkManager = NetworkManager(session: session)
        fetchResume()
    }

    private func fetchResume(){
        // Publisher
        networkManager.fetchDataFromServer()
            .receive(on: DispatchQueue.main)

            //        Subscrber
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .failure(let error):
                        print(error.description)
                        self.sectionsHeaders.removeAll()
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] data in
                    guard let self = self else { return }
                    self.resumeDetails = data
            })
            .store(in: &disposables)

    }
}

