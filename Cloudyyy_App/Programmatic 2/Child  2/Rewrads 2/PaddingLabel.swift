////
////  PaddingLabel.swift.swift
////  Cloudyyy_App
////
////  Created by user@5 on 16/11/25.
////
//
////
////  PaddingLabel.swift
////  Cloudyyy_App
////
////  Created by Gemini
////
//import UIKit
//
//final class PaddingLabel: UILabel {
//    
//    // ... (All the code for PaddingLabel from your original file) ...
//    
//    private let topInset: CGFloat
//    private let leftInset: CGFloat
//    private let bottomInset: CGFloat
//    private let rightInset: CGFloat
//
//    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
//        self.topInset = top
//        self.leftInset = left
//        self.bottomInset = bottom
//        self.rightInset = right
//        super.init(frame: .zero)
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    override func drawText(in rect: CGRect) {
//        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
//        super.drawText(in: rect.inset(by: insets))
//    }
//
//    override var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
//    }
//}
