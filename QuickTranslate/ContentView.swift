//
//  ContentView.swift
//  QuickTranslate
//
//  Created by Никита Евдокимов on 7.04.25.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var sourceLanguage: String = "en"
    @State private var targetLanguage: String = "es"
    @State private var interfaceLanguage: String = "en"
    @State private var isTranslating: Bool = false
    @State private var errorMessage: String = ""
    @State private var isHorizontalLayout: Bool = true
    @State private var debounceTimer: Timer?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale
    
    private let languageCodes = ["en", "es", "fr", "de", "it", "pt", "ru", "zh", "ar", "hi"]
    
    private func localizedLanguageName(for code: String) -> String {
        // Create a locale based on the interface language
        let locale = Locale(identifier: interfaceLanguage)
        
        // Try to get the localized name in the interface language
        if let localizedName = locale.localizedString(forLanguageCode: code) {
            return localizedName
        }
        
        // Fallback to English if localization fails
        let englishLocale = Locale(identifier: "en")
        if let englishName = englishLocale.localizedString(forLanguageCode: code) {
            return englishName
        }
        
        // If all else fails, return the language code
        return code
    }
    
    private let translations: [String: [String: String]] = [
        "en": [
            "enter_text": "Enter text to translate:",
            "translation": "Translation:",
            "translate": "Translate",
            "swap": "Swap languages",
            "from": "From",
            "to": "To"
        ],
        "es": [
            "enter_text": "Ingrese el texto a traducir:",
            "translation": "Traducción:",
            "translate": "Traducir",
            "swap": "Intercambiar idiomas",
            "from": "De",
            "to": "A"
        ],
        "fr": [
            "enter_text": "Entrez le texte à traduire:",
            "translation": "Traduction:",
            "translate": "Traduire",
            "swap": "Échanger les langues",
            "from": "De",
            "to": "À"
        ],
        "de": [
            "enter_text": "Text zum Übersetzen eingeben:",
            "translation": "Übersetzung:",
            "translate": "Übersetzen",
            "swap": "Sprachen tauschen",
            "from": "Von",
            "to": "Nach"
        ],
        "it": [
            "enter_text": "Inserisci il testo da tradurre:",
            "translation": "Traduzione:",
            "translate": "Tradurre",
            "swap": "Scambia lingue",
            "from": "Da",
            "to": "A"
        ],
        "pt": [
            "enter_text": "Digite o texto para traduzir:",
            "translation": "Tradução:",
            "translate": "Traduzir",
            "swap": "Trocar idiomas",
            "from": "De",
            "to": "Para"
        ],
        "ru": [
            "enter_text": "Введите текст для перевода:",
            "translation": "Перевод:",
            "translate": "Перевести",
            "swap": "Поменять языки",
            "from": "Из",
            "to": "В"
        ],
        "zh": [
            "enter_text": "输入要翻译的文本：",
            "translation": "翻译：",
            "translate": "翻译",
            "swap": "交换语言",
            "from": "从",
            "to": "到"
        ],
        "ar": [
            "enter_text": "أدخل النص للترجمة:",
            "translation": "الترجمة:",
            "translate": "ترجمة",
            "swap": "تبديل اللغات",
            "from": "من",
            "to": "إلى"
        ],
        "hi": [
            "enter_text": "अनुवाद के लिए पाठ दर्ज करें:",
            "translation": "अनुवाद:",
            "translate": "अनुवाद करें",
            "swap": "भाषाएँ बदलें",
            "from": "से",
            "to": "में"
        ]
    ]
    
    private func localizedString(_ key: String) -> String {
        return translations[interfaceLanguage]?[key] ?? translations["en"]![key]!
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(NSColor.windowBackgroundColor).opacity(0.95) : Color.white.opacity(0.95)
    }
    
    private var textFieldBackground: Color {
        colorScheme == .dark ? Color(NSColor.textBackgroundColor).opacity(0.7) : Color.white.opacity(0.7)
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? .gray.opacity(0.8) : .gray
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Menu {
                    ForEach(languageCodes.sorted(), id: \.self) { code in
                        Button(action: { interfaceLanguage = code }) {
                            HStack {
                                Text(localizedLanguageName(for: code))
                                if interfaceLanguage == code {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "globe")
                        .foregroundColor(secondaryTextColor)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)
                
                Picker(localizedString("from"), selection: $sourceLanguage) {
                    ForEach(languageCodes.sorted(), id: \.self) { code in
                        Text(localizedLanguageName(for: code)).tag(code)
                    }
                }
                .frame(width: 150)
                .environment(\.layoutDirection, sourceLanguage == "ar" ? .rightToLeft : .leftToRight)
                
                Button(action: swapLanguages) {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help(localizedString("swap"))
                
                Picker(localizedString("to"), selection: $targetLanguage) {
                    ForEach(languageCodes.sorted(), id: \.self) { code in
                        Text(localizedLanguageName(for: code)).tag(code)
                    }
                }
                .frame(width: 150)
                .environment(\.layoutDirection, targetLanguage == "ar" ? .rightToLeft : .leftToRight)
                .onChange(of: targetLanguage) { _ in
                    if !inputText.isEmpty {
                        translate()
                    }
                }
                
                Button(action: { isHorizontalLayout.toggle() }) {
                    Image(systemName: isHorizontalLayout ? "rectangle.split.2x1" : "rectangle.split.1x2")
                        .foregroundColor(secondaryTextColor)
                }
                .buttonStyle(.plain)
                .help(isHorizontalLayout ? "Switch to vertical layout" : "Switch to horizontal layout")
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(secondaryTextColor)
                }
                .buttonStyle(.plain)
            }
            
            if isHorizontalLayout {
                HStack(spacing: 20) {
                    textFields
                }
                .environment(\.layoutDirection, sourceLanguage == "ar" ? .rightToLeft : .leftToRight)
            } else {
                VStack(spacing: 20) {
                    textFields
                }
                .environment(\.layoutDirection, sourceLanguage == "ar" ? .rightToLeft : .leftToRight)
            }
            
            Button(action: translate) {
                if isTranslating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text(localizedString("translate"))
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.isEmpty || isTranslating)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .environment(\.layoutDirection, sourceLanguage == "ar" ? .rightToLeft : .leftToRight)
        .padding()
        .frame(width: isHorizontalLayout ? 600 : 400, height: isHorizontalLayout ? 300 : 450)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .shadow(radius: 10)
        )
    }
    
    private var textFields: some View {
        Group {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(localizedString("enter_text"))
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                    
                    Spacer()
                    
                    Button(action: pasteFromClipboard) {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(secondaryTextColor)
                    }
                    .buttonStyle(.plain)
                    .help("Paste from clipboard")
                }
                
                TextEditor(text: $inputText)
                    .frame(height: 120)
                    .padding(4)
                    .background(textFieldBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .foregroundColor(textColor)
                    .onChange(of: inputText) { _ in
                        debounceTranslation()
                    }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(localizedString("translation"))
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                    
                    Spacer()
                    
                    Button(action: copyToClipboard) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(secondaryTextColor)
                    }
                    .buttonStyle(.plain)
                    .help("Copy translation to clipboard")
                    .disabled(outputText.isEmpty)
                }
                
                TextEditor(text: $outputText)
                    .frame(height: 120)
                    .padding(4)
                    .background(textFieldBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .disabled(true)
                    .foregroundColor(textColor)
            }
        }
    }
    
    private func pasteFromClipboard() {
        if let clipboardString = NSPasteboard.general.string(forType: .string) {
            inputText = clipboardString
        }
    }
    
    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputText, forType: .string)
    }
    
    private func debounceTranslation() {
        // Cancel any existing timer
        debounceTimer?.invalidate()
        
        // Start a new timer
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            if !inputText.isEmpty {
                translate()
            } else {
                outputText = ""
            }
        }
    }
    
    private func swapLanguages() {
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        
        // Also swap the text if there's any
        if !inputText.isEmpty || !outputText.isEmpty {
            let tempText = inputText
            inputText = outputText
            outputText = tempText
        }
    }
    
    private func translate() {
        guard !inputText.isEmpty else { return }
        isTranslating = true
        errorMessage = ""
        
        // Create the request with proper encoding
        let urlString = "https://api.mymemory.translated.net/get"
        guard var components = URLComponents(string: urlString) else {
            isTranslating = false
            errorMessage = "Invalid URL"
            return
        }
        
        components.queryItems = [
            URLQueryItem(name: "q", value: inputText),
            URLQueryItem(name: "langpair", value: "\(sourceLanguage)|\(targetLanguage)")
        ]
        
        guard let url = components.url else {
            isTranslating = false
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isTranslating = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "No data received"
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TranslationResponse.self, from: data)
                    if let translation = result.responseData.translatedText {
                        outputText = translation
                    } else {
                        errorMessage = "Translation failed"
                    }
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
    }
}

struct TranslationResponse: Codable {
    let responseData: ResponseData
    
    struct ResponseData: Codable {
        let translatedText: String?
    }
}

#Preview {
    ContentView()
}
