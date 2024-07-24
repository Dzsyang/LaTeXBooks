//
//  ContentView.swift
//  LaTeXBooks
//
//  Created by Zixiang Lin on 2024/7/24.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var pdfDocuments: [PDFDocument] = []

    var body: some View {
        VStack {
            HStack {
                Text("LaTeXBooks")
                    .font(.largeTitle)
                    .padding()
                Spacer()
                Button(action: {
                    importPDF()
                }) {
                    Text("Import PDF")
                }
                .padding()
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(pdfDocuments, id: \.self) { document in
                        VStack {
                            if let coverImage = getCoverImage(from: document) {
                                Image(nsImage: coverImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            }
                            Button(action: {
                                deletePDF(document: document)
                            }) {
                                Text("Delete")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    func importPDF() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.allowsMultipleSelection = true
        if panel.runModal() == .OK {
            for url in panel.urls {
                if let document = PDFDocument(url: url) {
                    pdfDocuments.append(document)
                }
            }
        }
    }

    func getCoverImage(from document: PDFDocument) -> NSImage? {
        guard let page = document.page(at: 0) else { return nil }
        // Increase the thumbnail size to improve resolution
        let thumbnailSize = CGSize(width: 300, height: 400)
        return page.thumbnail(of: thumbnailSize, for: .mediaBox)
    }

    func deletePDF(document: PDFDocument) {
        if let index = pdfDocuments.firstIndex(of: document) {
            pdfDocuments.remove(at: index)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
