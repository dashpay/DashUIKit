//
//  Created by Roman Chornyi
//  Copyright © 2026 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#else
public typealias UIImage = Never
#endif

@available(iOS 14, macOS 11, *)
public enum DashIconSource {
    case system(_ name: String)
    case custom(_ name: String, bundle: Bundle? = nil)
    case uiImage(_ image: UIImage)
}

@available(iOS 14, macOS 11, *)
public extension Image {
    /// Resolves a Dash icon source into a plain `Image`. The caller applies all
    /// styling (`.resizable()`, `.foregroundStyle()`, sizing, etc.).
    init(dash source: DashIconSource) {
        switch source {
        case .system(let name):
            self = Image(systemName: name)
        case .custom(let name, let bundle):
            self = Image(name, bundle: bundle)
        case .uiImage(let image):
            #if canImport(UIKit)
            self = Image(uiImage: image)
            #else
            switch image {}
            #endif
        }
    }
}
