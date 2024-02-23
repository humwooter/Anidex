//
//  StatsView.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import SwiftUI
import CoreData

struct StatsView: View {
    @ObservedObject var species: Species
    @State var tabs : [Bool] = [true, true, true, true, true]
    var body : some View {
        NavigationStack {
            List {
                Section(header: Text("Species")) {
                    Text(species.commonLabel ?? "unknown species")
                }
                Section {
                    if tabs[0] {
                        VStack(alignment: .leading) {
                            Text(" \(species.scientificLabel ?? "NA")")
                        }
                    }
                    
                } header: {
                    HStack {
                        Text("Scientific Name")
                        Spacer()
                        Label("", systemImage: tabs[0] ? "chevron.up" : "chevron.down").foregroundColor(.green)
                            .onTapGesture {
                                tabs[0].toggle()
                            }
                    }
                }
                Section {
                    if tabs[1] {
                        Text("\(species.phylumLabel ?? "NA")")
                    }
                } header: {
                    HStack {
                        Text("Phylum")
                        Spacer()
                        Label("", systemImage: tabs[1] ? "chevron.up" : "chevron.down").foregroundColor(.green)
                            .onTapGesture {
                                tabs[1].toggle()
                            }
                    }
                }
                Section {
                    if tabs[2] {
                        Text("\(species.classLabel ?? "NA")")
                    }
                } header: {
                    HStack {
                        Text("Class")
                        Spacer()
                        Label("", systemImage: tabs[2] ? "chevron.up" : "chevron.down").foregroundColor(.green)
                            .onTapGesture {
                                tabs[2].toggle()
                            }
                    }
                }
                
                Section {
                    if tabs[3] {
                        Text("\(species.familyLabel ?? "NA")")
                    }
                } header: {
                    HStack {
                        Text("Family")
                        Spacer()
                        Label("", systemImage: tabs[3] ? "chevron.up" : "chevron.down").foregroundColor(.green)
                            .onTapGesture {
                                tabs[3].toggle()
                            }
                    }
                }
            }
        }
    }

}
