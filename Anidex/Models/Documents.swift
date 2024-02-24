//
//  Documents.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/24/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SpeciesDocument: FileDocument {
    var speciesData: Data

    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }

    init(speciesData: Data) {
        self.speciesData = speciesData
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.speciesData = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: speciesData)
    }
}
