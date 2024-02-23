//
//  SearchViews.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/23/24.
//


import Foundation
import SwiftUI




class SearchModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tokens: [FilterTokens] = []
}

enum FilterTokens: String, Identifiable, Hashable, CaseIterable {
    case discovered, favoriteFindings, mammalFindings, avesFindings, amphibiaFindings, reptiliaFindings
    var id: Self { self }
}
