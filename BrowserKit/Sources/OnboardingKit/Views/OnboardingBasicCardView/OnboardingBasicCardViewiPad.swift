// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Common
import ComponentLibrary

public struct OnboardingBasicCardViewiPad<VM: OnboardingCardInfoModelProtocol>: View {
    @State private var textColor: Color = .clear
    @State private var secondaryTextColor: Color = .clear
    @State private var cardBackgroundColor: Color = .clear
    @State private var primaryActionColor: Color = .clear

    let windowUUID: WindowUUID
    var themeManager: ThemeManager
    public let viewModel: VM
    public let onBottomButtonAction: (VM.OnboardingActionType, String) -> Void
    public let onLinkTap: (String) -> Void

    public init(
        viewModel: VM,
        windowUUID: WindowUUID,
        themeManager: ThemeManager,
        onBottomButtonAction: @escaping (VM.OnboardingActionType, String) -> Void,
        onLinkTap: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.windowUUID = windowUUID
        self.themeManager = themeManager
        self.onBottomButtonAction = onBottomButtonAction
        self.onLinkTap = onLinkTap
    }

    public var body: some View {
        VStack {
            Spacer()
            VScrollView {
                VStack(spacing: UX.CardView.spacing) {
                    Spacer()
                    titleView
                    imageView
                    bodyView
                    linkView
                    Spacer()
                    VStack {
                        primaryButton
                        secondaryButton
                    }
                }
            }
            .padding(UX.CardView.verticalPadding)
            Spacer()
        }
        .onAppear {
            applyTheme(theme: themeManager.getCurrentTheme(for: windowUUID))
        }
        .onReceive(NotificationCenter.default.publisher(for: .ThemeDidChange)) {
            guard let uuid = $0.windowUUID, uuid == windowUUID else { return }
            applyTheme(theme: themeManager.getCurrentTheme(for: windowUUID))
        }
    }

    var titleView: some View {
        Text(viewModel.title)
            .font(UX.CardView.titleFont)
            .fontWeight(.bold)
            .foregroundColor(textColor)
            .multilineTextAlignment(.center)
            .accessibility(identifier: "\(viewModel.a11yIdRoot)TitleLabel")
            .accessibility(addTraits: .isHeader)
    }

    @ViewBuilder var imageView: some View {
        if let img = viewModel.image {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: UX.CardView.imageHeight)
                .accessibilityLabel(viewModel.title)
                .accessibility(identifier: "\(viewModel.a11yIdRoot)ImageView")
        }
    }

    var bodyView: some View {
        Text(viewModel.body)
            .font(UX.CardView.bodyFont)
            .foregroundColor(secondaryTextColor)
            .multilineTextAlignment(.center)
            .accessibility(identifier: "\(viewModel.a11yIdRoot)DescriptionLabel")
    }

    @ViewBuilder var linkView: some View {
        if let linkVM = viewModel.link {
            LinkButtonView(
                viewModel: LinkInfoModel(
                    title: linkVM.title,
                    url: linkVM.url,
                    accessibilityIdentifier: "\(viewModel.a11yIdRoot)LinkButton"
                ),
                action: { onLinkTap(viewModel.name) }
            )
        }
    }

    var primaryButton: some View {
        Button(
            viewModel.buttons.primary.title,
            action: {
                onBottomButtonAction(
                    viewModel.buttons.primary.action,
                    viewModel.name
                )
            }
        )
        .font(UX.CardView.primaryActionFont)
        .accessibility(identifier: "\(viewModel.a11yIdRoot)PrimaryButton")
        .buttonStyle(PrimaryButtonStyle(theme: themeManager.getCurrentTheme(for: windowUUID)))
        .frame(width: UX.CardView.primaryButtonWidthiPad)
    }

    @ViewBuilder var secondaryButton: some View {
        if let secondary = viewModel.buttons.secondary {
            Button(
                secondary.title,
                action: {
                    onBottomButtonAction(
                        secondary.action,
                        viewModel.name
                    )
                })
            .font(UX.CardView.secondaryActionFont)
            .foregroundColor(primaryActionColor)
            .padding(.top, UX.CardView.secondaryButtonTopPadding)
            .padding(.bottom, UX.CardView.secondaryButtonBottomPadding)
            .accessibility(identifier: "\(viewModel.a11yIdRoot)SecondaryButton")
        }
    }

    private func applyTheme(theme: Theme) {
        let color = theme.colors
        textColor = Color(color.textPrimary)
        secondaryTextColor = Color(color.textSecondary)
        cardBackgroundColor = Color(color.layer2)
        primaryActionColor = Color(color.actionPrimary)
    }
}
