//
//  Typography.swift
//  Cloudyyy_App
//
//  Created by user@10 on 11/12/25.
//

import UIKit

enum AppFont {

    // MARK: - Headers (Apple Health Style)
    static let largeTitleBold: UIFont = {
        let base = UIFont.preferredFont(forTextStyle: .largeTitle)
        let boldDescriptor = base.fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: boldDescriptor ?? base.fontDescriptor, size: 0)
    }()

    static let title1Bold: UIFont = {
        let base = UIFont.preferredFont(forTextStyle: .title1)
        let boldDescriptor = base.fontDescriptor.withSymbolicTraits(.traitBold)
        return UIFont(descriptor: boldDescriptor ?? base.fontDescriptor, size: 0)
    }()

    // MARK: - Subtitles
    static let subtitle = UIFont.preferredFont(forTextStyle: .subheadline)

    // MARK: - Body
    static let body = UIFont.preferredFont(forTextStyle: .body)

    // MARK: - Secondary text
    static let footnote = UIFont.preferredFont(forTextStyle: .footnote)
    static let caption = UIFont.preferredFont(forTextStyle: .caption1)
}


