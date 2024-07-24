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
    @State private var pdfDirectory: URL?

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
                Button(action: {
                    chooseDirectory()
                }) {
                    Text("Choose Directory")
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
        .onAppear(perform: loadPDFs)
    }

    func importPDF() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.allowsMultipleSelection = true
        if panel.runModal() == .OK {
            for url in panel.urls {
                if let document = PDFDocument(url: url) {
                    savePDF(url: url)
                    pdfDocuments.append(document)
                }
            }
        }
    }

    func chooseDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            if let selectedDirectory = panel.url {
                pdfDirectory = selectedDirectory
                UserDefaults.standard.set(selectedDirectory.path, forKey: "pdfDirectory")
                loadPDFs()
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
            deletePDFFile(document: document)
        }
    }

    func savePDF(url: URL) {
        guard let pdfDirectory = pdfDirectory else { return }
        let destinationURL = pdfDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
        } catch {
            print("Error saving PDF: \(error)")
        }
    }

    func loadPDFs() {
        pdfDocuments.removeAll()
        if let savedPath = UserDefaults.standard.string(forKey: "pdfDirectory") {
            pdfDirectory = URL(fileURLWithPath: savedPath)
        }

        guard let pdfDirectory = pdfDirectory else { return }

        do {
            let pdfFiles = try FileManager.default.contentsOfDirectory(at: pdfDirectory, includingPropertiesForKeys: nil, options: [])
            for url in pdfFiles where url.pathExtension.lowercased() == "pdf" {
                if let document = PDFDocument(url: url) {
                    pdfDocuments.append(document)
                }
            }
        } catch {
            print("Error loading PDFs: \(error)")
        }
    }

    func deletePDFFile(document: PDFDocument) {
        guard let documentURL = document.documentURL else { return }
        do {
            try FileManager.default.removeItem(at: documentURL)
        } catch {
            print("Error deleting PDF: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
