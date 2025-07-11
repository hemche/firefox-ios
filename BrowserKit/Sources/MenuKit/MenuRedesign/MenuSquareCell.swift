// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit

final class MenuSquareView: UIView, ThemeApplicable {
    private struct UX {
        static let iconSize: CGFloat = 24
        static let backgroundViewCornerRadius: CGFloat = 12
        static let horizontalMargin: CGFloat = 6
        static let contentViewSpacing: CGFloat = 4
        static let contentViewTopMargin: CGFloat = 12
        static let contentViewBottomMargin: CGFloat = 8
        static let contentViewHorizontalMargin: CGFloat = 4
        static let cornerRadius: CGFloat = 16
        static let backgroundAlpha: CGFloat = 0.8
        static let hyphenationFactor: Float = 1.0
    }

    // MARK: - UI Elements
    private var backgroundContentView: UIView = .build()

    private var contentStackView: UIStackView = .build { stack in
        stack.axis = .vertical
        stack.spacing = UX.contentViewSpacing
        stack.distribution = .fill
    }

    private var icon: UIImageView = .build { view in
        view.contentMode = .scaleAspectFit
    }

    private var titleLabel: UILabel = .build { label in
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
    }

    // MARK: - Properties
    var model: MenuElement?
    var cellTapCallback: (() -> Void)?

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not yet supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = UX.cornerRadius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                    .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.clipsToBounds = true
    }

    func configureCellWith(model: MenuElement) {
        self.model = model
        self.setTitle(with: model.title)
        self.icon.image = UIImage(named: model.iconName)?.withRenderingMode(.alwaysTemplate)
        self.backgroundContentView.layer.cornerRadius = UX.backgroundViewCornerRadius
        self.isAccessibilityElement = true
        self.isUserInteractionEnabled = !model.isEnabled ? false : true
        self.accessibilityIdentifier = model.a11yId
        self.accessibilityLabel = model.a11yLabel
        self.accessibilityHint = model.a11yHint
        self.accessibilityTraits = .button
    }

    private func setupView() {
        self.addSubview(backgroundContentView)
        backgroundContentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(icon)
        contentStackView.addArrangedSubview(titleLabel)
        NSLayoutConstraint.activate([
            backgroundContentView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            contentStackView.topAnchor.constraint(
                equalTo: backgroundContentView.topAnchor,
                constant: UX.contentViewTopMargin
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: backgroundContentView.leadingAnchor,
                constant: UX.contentViewHorizontalMargin
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: backgroundContentView.trailingAnchor,
                constant: -UX.contentViewHorizontalMargin
            ),
            contentStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: backgroundContentView.bottomAnchor,
                constant: -UX.contentViewBottomMargin
            ),
            icon.heightAnchor.constraint(equalToConstant: UX.iconSize)
        ])
    }

    private func setTitle(with title: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = UX.hyphenationFactor
        paragraphStyle.alignment = .center

        let attributedText = NSAttributedString(
            string: title,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: FXFontStyles.Regular.caption2.scaledFont()
            ]
        )
        titleLabel.attributedText = attributedText
    }

    @objc
    private func handleTap() {
        cellTapCallback?()
    }

    // MARK: - Theme Applicable
    func applyTheme(theme: Theme) {
        backgroundColor = .clear
        contentStackView.backgroundColor = .clear
        backgroundContentView.backgroundColor = theme.colors.layer2.withAlphaComponent(UX.backgroundAlpha)
        icon.tintColor = theme.colors.iconPrimary
        titleLabel.textColor = theme.colors.textSecondary
    }
}
