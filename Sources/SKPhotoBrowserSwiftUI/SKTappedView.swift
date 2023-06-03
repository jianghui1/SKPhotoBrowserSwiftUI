//
//  SKTappedView.swift
//  TestFindView
//
//  Created by jzh on 2023/5/6.
//

import SwiftUI
import SKPhotoBrowser

private let tappedViewTag = 100
struct SKTappedView: UIViewRepresentable {
    var action: (UIView?) -> Void
    
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.tag = tappedViewTag
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(_:)))
        view.addGestureRecognizer(tap)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator {
        var parent: SKTappedView
        
        init(parent: SKTappedView) {
            self.parent = parent
        }
        
        @objc func tapped(_ sender: UIGestureRecognizer) {
            parent.action(sender.view)
        }
    }
}

extension UIView {
    private struct AssociatedKeys {
        static var tappedModel: UInt8 = 0
    }
    
    fileprivate var tappedModel: TappedModel? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.tappedModel) as? TappedModel
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tappedModel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class TappedModel {
    @Binding public var images: [UIImage]
    @Binding public var urls: [String]
    public let page: Int
    public let closeImage: UIImage?
    public let deleteImage: UIImage?
    public let displayCloseButton: Bool
    public let enableSingleTapDismiss: Bool
    public let displayDeleteButton: Bool?
    public let actionBackgroundColor: UIColor?
    public let actionTextColor: UIColor?
    public let actionFont: UIFont?
    public let actionTextShadowColor: UIColor?
    public let closeButtonPadding: CGPoint?
    public let closeButtonInsets: UIEdgeInsets?
    public let deleteButtonPadding: CGPoint?
    public let deleteButtonInsets: UIEdgeInsets?
    public let counterLocaton: SKPhotoBrowserSwiftUI.CounterLocation?
    public let counterExtraMarginY: CGFloat?
    public var loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)?
    public var didShowPhotoAtIndex: ((Int) -> Void)?
    
    private var originalBackImage: UIImage?
    private var originalDeleteImage: UIImage?
    private var originalDisplayDeleteButton: Bool?
    private var originalActionBackgroundColor: UIColor?
    private var originalActionTextColor: UIColor?
    private var originalActionFont: UIFont?
    private var originalActionTextShadowColor: UIColor?
    private var originalCloseButtonPadding: CGPoint?
    private var originalCloseButtonInsets: UIEdgeInsets?
    private var originalDeleteButtonPadding: CGPoint?
    private var originalDeleteButtonInsets: UIEdgeInsets?
    private var originalCounterLocaton: SKPhotoBrowserSwiftUI.CounterLocation?
    private var originalCounterExtraMarginY: CGFloat?
    private var contentVc: UIViewController!
    
    private var uiViews: [UIView]?
    private var initialUIView: UIView?
    private var contentViewModel = SKContentViewModel()
    
    static func show<Content: View>(from uiView: UIView?, images: Binding<[UIImage]> = .constant([]), urls: Binding<[String]> = .constant([]), page: Int = 0, closeImage: UIImage? = nil, deleteImage: UIImage? = nil, displayCloseButton: Bool = false, enableSingleTapDismiss: Bool = true, displayDeleteButton: Bool? = nil, actionBackgroundColor: UIColor? = nil, actionTextColor: UIColor? = nil, actionFont: UIFont? = nil, actionTextShadowColor: UIColor? = nil, closeButtonPadding: CGPoint? = nil, closeButtonInsets: UIEdgeInsets? = nil, deleteButtonPadding: CGPoint? = nil, deleteButtonInsets: UIEdgeInsets? = nil, counterLocaton: SKPhotoBrowserSwiftUI.CounterLocation? = nil, counterExtraMarginY: CGFloat? = nil, loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)? = nil, didShowPhotoAtIndex: ((Int) -> Void)? = nil, @ViewBuilder content: (SKContentViewModel) -> Content) {
        if let uiView = uiView,
           let controller = uiView.window?.rootViewController
        {
            let model = TappedModel(images: images, urls: urls, page: page, closeImage: closeImage, deleteImage: deleteImage, displayCloseButton: displayCloseButton, enableSingleTapDismiss: enableSingleTapDismiss, displayDeleteButton: displayDeleteButton, actionBackgroundColor: actionBackgroundColor, actionTextColor: actionTextColor, actionFont: actionFont, actionTextShadowColor: actionTextShadowColor, closeButtonPadding: closeButtonPadding, closeButtonInsets: closeButtonInsets, deleteButtonPadding: deleteButtonPadding, deleteButtonInsets: deleteButtonInsets, counterLocaton: counterLocaton, counterExtraMarginY: counterExtraMarginY, loadImageBlock: loadImageBlock, didShowPhotoAtIndex: didShowPhotoAtIndex)
            model.contentViewModel.selectedIndex = page
            model.contentVc = UIHostingController(rootView: content(model.contentViewModel))
            let browser = model.config()
            func findInitialImage(from uiView: UIView, size: CGSize) -> UIView {
                func loop(uiView: UIView) -> UIView? {
                    func sizeEqual(size1: CGSize, size2: CGSize) -> Bool {
                        return Int(size1.width - size2.width) == 0 && Int(size1.height - size2.height) == 0
                    }
                    if let sp = uiView.superview {
                        if let ssp = sp.superview, let index = ssp.subviews.firstIndex(of: sp), index + 1 < ssp.subviews.count {
                            let nextView = ssp.subviews[index + 1]
                            if sizeEqual(size1: nextView.frame.size, size2: size) {
                                return nextView
                            }
                        }
                        else {
                            return loop(uiView: sp)
                        }
                    }
                    return nil
                }
                if uiView.tag == tappedViewTag {
                    return loop(uiView: uiView) ?? uiView
                }
                return uiView
            }
            if images.wrappedValue.count > 1 || urls.wrappedValue.count > 1 {
                func findAllUIViews(from superview: UIView) -> [UIView] {
                    var uiViews: [UIView] = []
                    func loop(_superview: UIView) -> [UIView] {
                        var _uiViews: [UIView] = []
                        for subview in _superview.subviews {
                            if subview.tag == tappedViewTag {
                                _uiViews.append(subview)
                                break
                            }
                            else {
                                _uiViews.append(contentsOf: loop(_superview: subview))
                            }
                        }
                        return _uiViews
                    }
                    uiViews.append(contentsOf: loop(_superview: superview))
                    let maxCount = max(images.wrappedValue.count, urls.wrappedValue.count)
                    if uiViews.count == maxCount {
                        return uiViews
                    }
                    else if uiViews.count > maxCount, let index = uiViews.firstIndex(of: uiView), index >= page, index - page + maxCount <= uiViews.count {
                        return Array(uiViews.suffix(from: index - page).prefix(maxCount))
                    }
                    if let superview = superview.superview {
                        return findAllUIViews(from: superview)
                    }
                    else {
                        return []
                    }
                }
                
                let uiViews = findAllUIViews(from: uiView)
                model.uiViews = uiViews.isEmpty ? [uiView] : uiViews
            }
            else {
                model.uiViews = [uiView]
            }
            model.initialUIView = findInitialImage(from: uiView, size: uiView.frame.size)
            controller.present(browser, animated: true)
            uiView.tappedModel = model
        }
    }
    
    init(images: Binding<[UIImage]> = .constant([]), urls: Binding<[String]> = .constant([]), page: Int, closeImage: UIImage?, deleteImage: UIImage?, displayCloseButton: Bool, enableSingleTapDismiss: Bool, displayDeleteButton: Bool?, actionBackgroundColor: UIColor?, actionTextColor: UIColor?, actionFont: UIFont?, actionTextShadowColor: UIColor?, closeButtonPadding: CGPoint?, closeButtonInsets: UIEdgeInsets?, deleteButtonPadding: CGPoint?, deleteButtonInsets: UIEdgeInsets?, counterLocaton: SKPhotoBrowserSwiftUI.CounterLocation?, counterExtraMarginY: CGFloat?, loadImageBlock: ( (URL, @escaping (UIImage?, Error?) -> Void) -> Void)? = nil, didShowPhotoAtIndex: ( (Int) -> Void)? = nil) {
        self._images = images
        self._urls = urls
        self.page = page
        self.closeImage = closeImage
        self.deleteImage = deleteImage
        self.displayCloseButton = displayCloseButton
        self.enableSingleTapDismiss = enableSingleTapDismiss
        self.displayDeleteButton = displayDeleteButton
        self.actionBackgroundColor = actionBackgroundColor
        self.actionTextColor = actionTextColor
        self.actionFont = actionFont
        self.actionTextShadowColor = actionTextShadowColor
        self.closeButtonPadding = closeButtonPadding
        self.closeButtonInsets = closeButtonInsets
        self.deleteButtonPadding = deleteButtonPadding
        self.deleteButtonInsets = deleteButtonInsets
        self.counterLocaton = counterLocaton
        self.counterExtraMarginY = counterExtraMarginY
        self.loadImageBlock = loadImageBlock
        self.didShowPhotoAtIndex = didShowPhotoAtIndex
        
        if displayDeleteButton != nil {
            originalDisplayDeleteButton = SKPhotoBrowserOptions.displayDeleteButton
        }
        if actionBackgroundColor != nil {
            originalActionBackgroundColor = SKActionOptions.backgroundColor
        }
        if actionTextColor != nil {
            originalActionTextColor = SKActionOptions.textColor
        }
        if actionFont != nil {
            originalActionFont = SKActionOptions.font
        }
        if actionTextShadowColor != nil {
            originalActionTextShadowColor = SKActionOptions.textShadowColor
        }
        if closeButtonPadding != nil {
            originalCloseButtonPadding = SKButtonOptions.closeButtonPadding
        }
        originalCloseButtonInsets = SKButtonOptions.closeButtonInsets
        if deleteButtonPadding != nil {
            originalDeleteButtonPadding = SKButtonOptions.deleteButtonPadding
        }
        originalDeleteButtonInsets = SKButtonOptions.deleteButtonInsets
        if counterLocaton != nil {
            originalCounterLocaton = SKCounterOptions.counterLocaton == .top ? .top : .bottom
        }
        if counterExtraMarginY != nil {
            originalCounterExtraMarginY = SKCounterOptions.counterExtraMarginY
        }
    }
    
    private func config() -> SKPhotoBrowser {
        SKPhotoBrowserOptions.displayCloseButton = displayCloseButton
        if let displayDeleteButton = displayDeleteButton {
            SKPhotoBrowserOptions.displayDeleteButton = displayDeleteButton
        }
        if let actionBackgroundColor = actionBackgroundColor {
            SKActionOptions.backgroundColor = actionBackgroundColor
        }
        if let actionTextColor = actionTextColor {
            SKActionOptions.textColor = actionTextColor
        }
        if let actionFont = actionFont {
            SKActionOptions.font = actionFont
        }
        if let actionTextShadowColor = actionTextShadowColor {
            SKActionOptions.textShadowColor = actionTextShadowColor
        }
        if let closeButtonPadding = closeButtonPadding {
            SKButtonOptions.closeButtonPadding = closeButtonPadding
        }
        if let closeButtonInsets = closeButtonInsets {
            SKButtonOptions.closeButtonInsets = closeButtonInsets
        }
        if let deleteButtonPadding = deleteButtonPadding {
            SKButtonOptions.deleteButtonPadding = deleteButtonPadding
        }
        if let deleteButtonInsets = deleteButtonInsets {
            SKButtonOptions.deleteButtonInsets = deleteButtonInsets
        }
        if let counterLocaton = counterLocaton {
            SKCounterOptions.counterLocaton = counterLocaton == .top ? .top : .bottom
        }
        if let counterExtraMarginY = counterExtraMarginY {
            SKCounterOptions.counterExtraMarginY = counterExtraMarginY
        }
        SKPhotoBrowserOptions.displayStatusbar = true
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayPaginationView = false
        SKPhotoBrowserOptions.enableSingleTapDismiss = enableSingleTapDismiss
        SKPhotoBrowserOptions.longPhotoWidthMatchScreen = true
        SKPhotoBrowserOptions.displayPagingHorizontalScrollIndicator = false
        
        var photos: [SKPhotoProtocol] = []
        if !images.isEmpty {
            photos = images.map({ SKPhoto.photoWithImage($0) })
        }
        else if !urls.isEmpty {
            photos = urls.map{
                let photo = SKPhoto.photoWithImageURL($0)
                photo.loadImageBlock = loadImageBlock
                return photo
            }
        }
        let browser = SKPhotoBrowser(photos: photos, initialPageIndex: page)
        browser.delegate = self
        return browser
    }
}

extension TappedModel: SKPhotoBrowserDelegate {
    public func didShowPhotoAtIndex(_ browser: SKPhotoBrowser, index: Int) {
        didShowPhotoAtIndex?(index)
        
        if contentVc.view.superview == nil {
            browser.addChild(contentVc)
            browser.view.addSubview(contentVc.view)
            contentVc.view.frame = browser.view.bounds
            contentVc.view.backgroundColor = .clear
            contentVc.view.isUserInteractionEnabled = false
        }
        withAnimation {
            contentViewModel.selectedIndex = index
        }
    }
    
    public func willDismissAtPageIndex(_ index: Int) {
        if let originalDisplayDeleteButton = originalDisplayDeleteButton {
            SKPhotoBrowserOptions.displayDeleteButton = originalDisplayDeleteButton
        }
        if let originalActionBackgroundColor = originalActionBackgroundColor {
            SKActionOptions.backgroundColor = originalActionBackgroundColor
        }
        if let originalActionTextColor = originalActionTextColor {
            SKActionOptions.textColor = originalActionTextColor
        }
        if let originalActionFont = originalActionFont {
            SKActionOptions.font = originalActionFont
        }
        if let originalActionTextShadowColor = originalActionTextShadowColor {
            SKActionOptions.textShadowColor = originalActionTextShadowColor
        }
        if let originalCloseButtonPadding = originalCloseButtonPadding {
            SKButtonOptions.closeButtonPadding = originalCloseButtonPadding
        }
        SKButtonOptions.closeButtonInsets = originalCloseButtonInsets
        if let originalDeleteButtonPadding = originalDeleteButtonPadding {
            SKButtonOptions.deleteButtonPadding = originalDeleteButtonPadding
        }
        SKButtonOptions.deleteButtonInsets = originalDeleteButtonInsets
        if let originalCounterLocaton = originalCounterLocaton {
            SKCounterOptions.counterLocaton = originalCounterLocaton == .top ? .top : .bottom
        }
        if let originalCounterExtraMarginY = originalCounterExtraMarginY {
            SKCounterOptions.counterExtraMarginY = originalCounterExtraMarginY
        }
    }
    
    public func willShowActionSheet(_ photoIndex: Int) {
        // do some handle if you need
    }
    
    public func didDismissAtPageIndex(_ index: Int) {
        uiViews?.removeAll()
    }
    
    public func didDismissActionSheetWithButtonIndex(_ buttonIndex: Int, photoIndex: Int) {
        // handle dismissing custom actions
    }
    
    public func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
        if index < images.count {
            images.remove(at: index)
        }
        if index < urls.count {
            urls.remove(at: index)
        }
        reload()
    }
    
    public func viewForPhoto(_ browser: SKPhotoBrowser, index: Int) -> UIView? {
        
        if let closeImage = closeImage {
            browser.updateCloseButton(closeImage)
        }
        if let delete = deleteImage {
            browser.updateDeleteButton(delete)
        }
        
        if let initialUIView = initialUIView {
            self.initialUIView = nil
            return initialUIView
        }
        return uiViews != nil && index < uiViews!.count ? uiViews?[index] : (uiViews?.first ?? nil)
    }
    
    public func captionViewForPhotoAtIndex(index: Int) -> SKCaptionView? {
        return nil
    }
}

extension View {
    public func tapped(images: Binding<[UIImage]> = .constant([]), urls: Binding<[String]> = .constant([]), page: Int = 0, closeImage: UIImage? = nil, deleteImage: UIImage? = nil, displayCloseButton: Bool = false, enableSingleTapDismiss: Bool = true, displayDeleteButton: Bool? = nil, actionBackgroundColor: UIColor? = nil, actionTextColor: UIColor? = nil, actionFont: UIFont? = nil, actionTextShadowColor: UIColor? = nil, closeButtonPadding: CGPoint? = nil, closeButtonInsets: UIEdgeInsets? = nil, deleteButtonPadding: CGPoint? = nil, deleteButtonInsets: UIEdgeInsets? = nil, counterLocaton: SKPhotoBrowserSwiftUI.CounterLocation? = nil, counterExtraMarginY: CGFloat? = nil, loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)? = nil, didShowPhotoAtIndex: ((Int) -> Void)? = nil) -> some View {
        tapped(images: images, urls: urls, page: page, closeImage: closeImage, deleteImage: deleteImage, displayCloseButton: displayCloseButton, enableSingleTapDismiss: enableSingleTapDismiss, displayDeleteButton: displayDeleteButton, actionBackgroundColor: actionBackgroundColor, actionTextColor: actionTextColor, actionFont: actionFont, actionTextShadowColor: actionTextShadowColor, closeButtonPadding: closeButtonPadding, closeButtonInsets: closeButtonInsets, deleteButtonPadding: deleteButtonPadding, deleteButtonInsets: deleteButtonInsets, counterLocaton: counterLocaton, counterExtraMarginY: counterExtraMarginY, loadImageBlock: loadImageBlock, didShowPhotoAtIndex: didShowPhotoAtIndex) { _ in
            EmptyView()
        }
    }
    public func tapped<Content: View>(images: Binding<[UIImage]> = .constant([]), urls: Binding<[String]> = .constant([]), page: Int = 0, closeImage: UIImage? = nil, deleteImage: UIImage? = nil, displayCloseButton: Bool = false, enableSingleTapDismiss: Bool = true, displayDeleteButton: Bool? = nil, actionBackgroundColor: UIColor? = nil, actionTextColor: UIColor? = nil, actionFont: UIFont? = nil, actionTextShadowColor: UIColor? = nil, closeButtonPadding: CGPoint? = nil, closeButtonInsets: UIEdgeInsets? = nil, deleteButtonPadding: CGPoint? = nil, deleteButtonInsets: UIEdgeInsets? = nil, counterLocaton: SKPhotoBrowserSwiftUI.CounterLocation? = nil, counterExtraMarginY: CGFloat? = nil, loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)? = nil, didShowPhotoAtIndex: ((Int) -> Void)? = nil, @ViewBuilder content: @escaping (SKContentViewModel) -> Content) -> some View {
        modifier(TappedModifier(images: images, urls: urls, page: page, closeImage: closeImage, deleteImage: deleteImage, displayCloseButton: displayCloseButton, enableSingleTapDismiss: enableSingleTapDismiss, displayDeleteButton: displayDeleteButton, actionBackgroundColor: actionBackgroundColor, actionTextColor: actionTextColor, actionFont: actionFont, actionTextShadowColor: actionTextShadowColor, closeButtonPadding: closeButtonPadding, closeButtonInsets: closeButtonInsets, deleteButtonPadding: deleteButtonPadding, deleteButtonInsets: deleteButtonInsets, counterLocaton: counterLocaton, counterExtraMarginY: counterExtraMarginY, loadImageBlock: loadImageBlock, didShowPhotoAtIndex: didShowPhotoAtIndex, contentView: content))
    }
}

private struct TappedModifier<ContentView: View>: ViewModifier {
    @Binding public var images: [UIImage]
    @Binding public var urls: [String]
    public let page: Int
    public let closeImage: UIImage?
    public let deleteImage: UIImage?
    public let displayCloseButton: Bool
    public let enableSingleTapDismiss: Bool
    public let displayDeleteButton: Bool?
    public let actionBackgroundColor: UIColor?
    public let actionTextColor: UIColor?
    public let actionFont: UIFont?
    public let actionTextShadowColor: UIColor?
    public let closeButtonPadding: CGPoint?
    public let closeButtonInsets: UIEdgeInsets?
    public let deleteButtonPadding: CGPoint?
    public let deleteButtonInsets: UIEdgeInsets?
    public let counterLocaton: SKPhotoBrowserSwiftUI.CounterLocation?
    public let counterExtraMarginY: CGFloat?
    public var loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)?
    public var didShowPhotoAtIndex: ((Int) -> Void)?
    public var contentView: (SKContentViewModel) -> ContentView
    
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(false)
            .background(
                SKTappedView { uiView in
                    TappedModel.show(from: uiView, images: $images, urls: $urls, page: page, closeImage: closeImage, deleteImage: deleteImage, displayCloseButton: displayCloseButton, enableSingleTapDismiss: enableSingleTapDismiss, displayDeleteButton: displayDeleteButton, actionBackgroundColor: actionBackgroundColor, actionTextColor: actionTextColor, actionFont: actionFont, actionTextShadowColor: actionTextShadowColor, closeButtonPadding: closeButtonPadding, closeButtonInsets: closeButtonInsets, deleteButtonPadding: deleteButtonPadding, deleteButtonInsets: deleteButtonInsets, counterLocaton: counterLocaton, counterExtraMarginY: counterExtraMarginY, loadImageBlock: loadImageBlock, didShowPhotoAtIndex: didShowPhotoAtIndex, content: contentView)
                }
            )
    }
}
