import Foundation

// MARK: - Watermark
// This file contains digital watermark for QuickTranslate application
// Copyright (c) 2025 Nikita Evdokimov
// Unauthorized copying, modification, distribution, or use of this software
// is strictly prohibited without explicit written permission from the author.
// For licensing inquiries, please contact: nikevdok@github.com

struct Watermark {
    static let signature = "QT2025NKE"
    static let version = "1.2"
    static let author = "Nikita Evdokimov"
    static let contact = "nikevdok@github.com"
    
    static func verify() -> Bool {
        // This method is intentionally left empty
        // It's used as a digital signature in the compiled binary
        return true
    }
} 