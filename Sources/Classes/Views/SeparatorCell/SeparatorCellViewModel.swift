//
//  Copyright (c) 2017 Touch Instinct
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the Software), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// By default this class does not provide any separators
open class SeparatorCellViewModel {

    internal var separatorType = CellSeparatorType.none

    /// Configuration for topSeparator
    /// - Importnat: Bottom dimension is ignored
    internal var topSeparatorConfiguration: SeparatorConfiguration?

    /// Configuration for topSeparator
    /// - Importnat: Top dimension is ignored
    internal var bottomSeparatorConfiguration: SeparatorConfiguration?

    public init() {}

}

public extension SeparatorCellViewModel {

    func set(separatorType: CellSeparatorType) {
        self.separatorType = separatorType

        switch separatorType {
        case .top(let configuration):
            topSeparatorConfiguration    = configuration
            bottomSeparatorConfiguration = nil
        case .bottom(let configuration):
            topSeparatorConfiguration    = nil
            bottomSeparatorConfiguration = configuration
        case .full(let top, let bottom):
            topSeparatorConfiguration    = top
            bottomSeparatorConfiguration = bottom
        case .none:
            topSeparatorConfiguration    = nil
            bottomSeparatorConfiguration = nil
        }
    }

}
