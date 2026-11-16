
import SwiftUI
import WebKit

struct ShopWebView: UIViewRepresentable {

    func makeUIView(context: Context) -> WKWebView {

        let configuration = WKWebViewConfiguration()

        // Lưu cookie đăng nhập và phiên làm việc
        configuration.websiteDataStore = .default()

        // Cho phép JavaScript và cửa sổ mới
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Hỗ trợ video phát trực tiếp trong trang
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // Vuốt sang trái/phải để quay lại hoặc tiến
        webView.allowsBackForwardNavigationGestures = true

        webView.backgroundColor = .white
        webView.isOpaque = false

        // Mở shop hiện tại
        if let url = URL(string: "https://mapmodios.shop") {
            let request = URLRequest(
                url: url,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 30
            )
            webView.load(request)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject,
                       WKNavigationDelegate,
                       WKUIDelegate {

        // Xử lý link target="_blank"
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {

            if navigationAction.targetFrame == nil,
               let url = navigationAction.request.url {

                webView.load(URLRequest(url: url))
            }

            return nil
        }

        // Xử lý điều hướng
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {

            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = (url.scheme ?? "").lowercased()

            // Mở liên kết gọi điện, email, SMS bằng ứng dụng tương ứng
            if ["tel", "mailto", "sms"].contains(scheme) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            // Website, QR thanh toán và trang đăng nhập
            if scheme == "https" || scheme == "http" {
                decisionHandler(.allow)
                return
            }

            // Các liên kết ứng dụng khác
            UIApplication.shared.open(url, options: [:]) { _ in }
            decisionHandler(.cancel)
        }

        // Xử lý lỗi tải trang
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            print("MAPMODIOS Error: \(error.localizedDescription)")
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            print("MAPMODIOS Load Error: \(error.localizedDescription)")
        }
    }
}
