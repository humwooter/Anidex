//
//  CustomTextField.swift
//  Anidex
//
//  Created by Katyayani G. Raman on 2/22/24.
//

import Foundation
import UIKit
import Combine
import SwiftUI

struct GrowingTextField: UIViewRepresentable {
    @Binding var text: String
    let fontSize: CGFloat
    let fontColor: UIColor
    let cursorColor: UIColor
    var initialText: String?
    
    
//    @Binding var cursorPosition: NSRange?
//    @ObservedObject var viewModel: TextEditorViewModel
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        context.coordinator.textView = textView
        textView.backgroundColor = UIColor(Color(fontColor).opacity(0.05))
        textView.tintColor = cursorColor
        textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.textColor = fontColor
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        print("makeUIView called for GrowingTextField")
        
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        print("updateUIView called for GrowingTextField with text: \(text)")
        if uiView.text != text {
                uiView.text = text
            }
    }
    
    func makeCoordinator() -> Coordinator {
        print("makeCoordinator called for GrowingTextField")
        return Coordinator(self)
        
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextField
//        var viewModel: TextEditorViewModel
        var textView: UITextView?
        private var cancellables = Set<AnyCancellable>() // To hold the subscription

        init(_ parent: GrowingTextField) {
            self.parent = parent
//            self.viewModel = viewModel
            super.init()

            // Observe changes to textToInsert
//            viewModel.$textToInsert
//                .compactMap { $0 } // Filter out nil values
//                .receive(on: DispatchQueue.main) // Ensure UI updates are on the main thread
//                .sink { [weak self] textToInsert in
//                    self?.insertTextAtCursor(text: textToInsert)
//                }
//                .store(in: &cancellables)
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            self.textView = textView // Keep a reference to the textView
        }

  
//        private func insertTextAtCursor(text: String) {
//            print("entered insertTextAtCursor from inside the Coordinator class with text: \(text)")
////            DispatchQueue.main.async {
//                guard let textView = self.textView else { return }
//                
//                let currentText = textView.text as NSString
//                var range = textView.selectedRange
//                let updatedText = currentText.replacingCharacters(in: range, with: text)
//                textView.text = updatedText as String
//                range.location += text.utf16.count
//                range.length = 0
//                textView.selectedRange = range
//                self.parent.text = updatedText as String
////            }
//        }

    }
}
