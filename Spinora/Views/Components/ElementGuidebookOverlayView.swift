//
//  ElementGuidebookOverlayView.swift
//  Spinora
//
//  Created by Stanley Young on 20/05/26.
//

import SwiftUI

struct ElementGuidebookOverlayView: View {
    @Binding var isPresented: Bool

    @State private var currentPageIndex: Int = 0
    @State private var isBackPressed = false
    @State private var isNextPressed = false
    @State private var isOKPressed = false

    private let pages: [ElementComboGuidePage] = [
        ElementComboGuidePage(assetName: "alert_element_fire_combo"),
        ElementComboGuidePage(assetName: "alert_element_water_combo"),
        ElementComboGuidePage(assetName: "alert_element_rock_combo")
    ]

    // MARK: - Easy Adjustment Values

    private let backgroundWidthRatio: CGFloat = 0.92
    private let maxBackgroundWidth: CGFloat = 350
    private let backgroundHeightRatio: CGFloat = 1.34

    private let contentWidthRatio: CGFloat = 0.78
    private let contentYOffsetRatio: CGFloat = 0.01

    private let navigationWidthRatio: CGFloat = 0.58
    private let navigationYOffsetRatio: CGFloat = 0.50
    private let navigationButtonSizeRatio: CGFloat = 0.09

    private let pageIndicatorYOffsetRatio: CGFloat = 0.50
    private let pageIndicatorSizeRatio: CGFloat = 0.04

    private let okButtonWidthRatio: CGFloat = 0.34
    private let okButtonYOffsetRatio: CGFloat = 0.76

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.62)
                    .ignoresSafeArea()

                guidebookContent(in: geometry)
                    .frame(
                        width: guidebookWidth(in: geometry),
                        height: guidebookHeight(in: geometry)
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
        }
        .ignoresSafeArea()
    }

    private func guidebookContent(in geometry: GeometryProxy) -> some View {
        let backgroundWidth = guidebookWidth(in: geometry)
        let backgroundHeight = guidebookHeight(in: geometry)

        return ZStack {
            Image("alert_element_background_combo")
                .resizable()
                .interpolation(.none)
                .frame(width: backgroundWidth, height: backgroundHeight)

            Image(currentPage.assetName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: backgroundWidth * contentWidthRatio)
                .offset(y: backgroundWidth * contentYOffsetRatio)

            // MARK: - Navigation Buttons

            HStack {
                Button {
                    goToPreviousPage()
                } label: {
                    Image(backButtonAsset)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(
                            width: backgroundWidth * navigationButtonSizeRatio,
                            height: backgroundWidth * navigationButtonSizeRatio
                        )
                }
                .buttonStyle(.plain)
                .opacity(canGoBack ? 1.0 : 0.35)
                .disabled(!canGoBack)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isBackPressed = true }
                        .onEnded { _ in isBackPressed = false }
                )

                Spacer()

                Button {
                    goToNextPage()
                } label: {
                    Image(nextButtonAsset)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(
                            width: backgroundWidth * navigationButtonSizeRatio,
                            height: backgroundWidth * navigationButtonSizeRatio
                        )
                }
                .buttonStyle(.plain)
                .opacity(canGoNext ? 1.0 : 0.35)
                .disabled(!canGoNext)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isNextPressed = true }
                        .onEnded { _ in isNextPressed = false }
                )
            }
            .frame(width: backgroundWidth * navigationWidthRatio)
            .offset(y: backgroundWidth * navigationYOffsetRatio)

            // MARK: - Page Indicator

            GamePixelText("\(currentPageIndex + 1)/\(pages.count)", size: backgroundWidth * pageIndicatorSizeRatio)
                .foregroundStyle(Color.white)
                .shadow(
                    color: Color(red: 0.31, green: 0.16, blue: 0.09),
                    radius: 0,
                    x: 2,
                    y: 2
                )
                .offset(y: backgroundWidth * pageIndicatorYOffsetRatio)

            // MARK: - OK Button Asset

            Button {
                isPresented = false
            } label: {
                Image(okButtonAsset)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: backgroundWidth * okButtonWidthRatio)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isOKPressed = true }
                    .onEnded { _ in isOKPressed = false }
            )
            .offset(y: backgroundWidth * okButtonYOffsetRatio)
        }
    }

    // MARK: - Current Page

    private var currentPage: ElementComboGuidePage {
        pages[currentPageIndex]
    }

    private var canGoBack: Bool {
        currentPageIndex > 0
    }

    private var canGoNext: Bool {
        currentPageIndex < pages.count - 1
    }

    private var backButtonAsset: String {
        isBackPressed ? "button_back_pressed" : "button_back_default"
    }

    private var nextButtonAsset: String {
        isNextPressed ? "button_next_pressed" : "button_next_default"
    }

    private var okButtonAsset: String {
        isOKPressed ? "button_ok_pushed" : "button_ok_default"
    }

    // MARK: - Sizing

    private func guidebookWidth(in geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * backgroundWidthRatio, maxBackgroundWidth)
    }

    private func guidebookHeight(in geometry: GeometryProxy) -> CGFloat {
        guidebookWidth(in: geometry) * backgroundHeightRatio
    }

    // MARK: - Actions

    private func goToPreviousPage() {
        guard canGoBack else { return }
        currentPageIndex -= 1
    }

    private func goToNextPage() {
        guard canGoNext else { return }
        currentPageIndex += 1
    }
}

struct ElementComboGuidePage {
    let assetName: String
}

#Preview("Element Guidebook Overlay") {
    ElementGuidebookOverlayView(
        isPresented: .constant(true)
    )
}
