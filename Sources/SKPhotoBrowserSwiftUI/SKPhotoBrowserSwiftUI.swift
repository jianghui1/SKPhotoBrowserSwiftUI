import SwiftUI
import SKPhotoBrowser

public struct SKPhotoBrowserSwiftUI: UIViewControllerRepresentable {
    public enum CounterLocation {
        case top
        case bottom
    }
    
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
    public let counterLocaton: CounterLocation?
    public let counterExtraMarginY: CGFloat?
    public var loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)?
    public var didShowPhotoAtIndex: ((Int) -> Void)?
    
    public init(images: Binding<[UIImage]> = .constant([]), urls: Binding<[String]> = .constant([]), page: Int = 0, closeImage: UIImage? = nil, deleteImage: UIImage? = nil, displayCloseButton: Bool = false, enableSingleTapDismiss: Bool = true, displayDeleteButton: Bool? = nil, actionBackgroundColor: UIColor? = nil, actionTextColor: UIColor? = nil, actionFont: UIFont? = nil, actionTextShadowColor: UIColor? = nil, closeButtonPadding: CGPoint? = nil, closeButtonInsets: UIEdgeInsets? = nil, deleteButtonPadding: CGPoint? = nil, deleteButtonInsets: UIEdgeInsets? = nil, counterLocaton: CounterLocation? = nil, counterExtraMarginY: CGFloat? = nil, loadImageBlock: ((URL, @escaping (UIImage?, Error?) -> Void) -> Void)? = nil, didShowPhotoAtIndex: ((Int) -> Void)? = nil) {
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
    }
    
    public typealias UIViewControllerType = SKPhotoBrowser
    
    public func makeUIViewController(context: Context) -> SKPhotoBrowser {
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
        browser.delegate = context.coordinator
        
        return browser
    }
    
    public func updateUIViewController(_ uiViewController: SKPhotoBrowser, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self, closeImage: closeImage, deleteImage: deleteImage, displayDeleteButton: displayDeleteButton, actionBackgroundColor: actionBackgroundColor, actionTextColor: actionTextColor, actionFont: actionFont, actionTextShadowColor: actionTextShadowColor, closeButtonPadding: closeButtonPadding, closeButtonInsets: closeButtonInsets, deleteButtonPadding: deleteButtonPadding, deleteButtonInsets: deleteButtonInsets, counterLocaton: counterLocaton, counterExtraMarginY: counterExtraMarginY)
    }
    
    final public class Coordinator: SKPhotoBrowserDelegate {
        
        let parent: SKPhotoBrowserSwiftUI
        
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
        private var originalCounterLocaton: CounterLocation?
        private var originalCounterExtraMarginY: CGFloat?
        
        init(_ parent: SKPhotoBrowserSwiftUI, closeImage: UIImage?, deleteImage: UIImage?, displayDeleteButton: Bool?, actionBackgroundColor: UIColor?, actionTextColor: UIColor?, actionFont: UIFont?, actionTextShadowColor: UIColor?, closeButtonPadding: CGPoint?, closeButtonInsets: UIEdgeInsets?, deleteButtonPadding: CGPoint?, deleteButtonInsets: UIEdgeInsets?, counterLocaton: CounterLocation?, counterExtraMarginY: CGFloat?) {
            self.parent = parent
            
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
        
        public func didShowPhotoAtIndex(_ browser: SKPhotoBrowser, index: Int) {
            parent.didShowPhotoAtIndex?(index)
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
            
        }
        
        public func didDismissActionSheetWithButtonIndex(_ buttonIndex: Int, photoIndex: Int) {
            // handle dismissing custom actions
        }
        
        public func removePhoto(_ browser: SKPhotoBrowser, index: Int, reload: @escaping (() -> Void)) {
            if index < parent.images.count {
                parent.images.remove(at: index)
            }
            if index < parent.urls.count {
                parent.urls.remove(at: index)
            }
            reload()
        }
        
        public func viewForPhoto(_ browser: SKPhotoBrowser, index: Int) -> UIView? {
            
            if let closeImage = parent.closeImage {
                browser.updateCloseButton(closeImage)
            }
            if let delete = parent.deleteImage {
                browser.updateDeleteButton(delete)
            }
            
            return nil
        }
        
        public func captionViewForPhotoAtIndex(index: Int) -> SKCaptionView? {
            return nil
        }
    }
}

extension View {
    public func photoBrowser(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SKPhotoBrowserSwiftUI) -> some View {
        modifier(PhotoBrowserModifier(isPresented: isPresented, content: content))
    }
}

private struct PhotoBrowserModifier: ViewModifier {
    @Binding var isPresented: Bool
    let content: () -> SKPhotoBrowserSwiftUI
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                self.content()
                    .ignoresSafeArea()
            }
            .transaction({ transaction in
                transaction.disablesAnimations = isPresented
            })
    }
}
