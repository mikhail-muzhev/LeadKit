//
//  Copyright (c) 2017 Touch Instinct
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import RxSwift
import RxAlamofire

typealias ServerResponse = (HTTPURLResponse, Data)

public extension Reactive where Base: DataRequest {

    /// Method that serializes response into target object
    ///
    /// - Parameter mappingQueue: The dispatch queue to use for mapping
    /// - Parameter decoder: JSONDecoder used to decode a decodable type
    /// - Returns: Observable with HTTP URL Response and target object
    func apiResponse<T: Decodable>(mappingQueue: DispatchQueue = .global(), decoder: JSONDecoder)
        -> Observable<(response: HTTPURLResponse, model: T)> {

            return responseData()
                .observeOn(SerialDispatchQueueScheduler(queue: mappingQueue, internalSerialQueueName: mappingQueue.label))
                .tryMapResult { response, data in
                    (response, try decoder.decode(T.self, from: data))
                }
    }

    /// Method that serializes response into target object
    ///
    /// - Parameter mappingQueue: The dispatch queue to use for mapping
    /// - Returns: Observable with HTTP URL Response and target object
    func observableApiResponse<T: ObservableMappable>(mappingQueue: DispatchQueue = .global(), decoder: JSONDecoder)
        -> Observable<(response: HTTPURLResponse, model: T)> where T.ModelType == T {

            return responseData()
                .observeOn(SerialDispatchQueueScheduler(queue: mappingQueue, internalSerialQueueName: mappingQueue.label))
                .tryMapObservableResult { response, value in
                    let json = try JSONSerialization.jsonObject(with: value, options: [])
                    return T.createFrom(decoder: decoder, jsonObject: json)
                        .map { (response, $0) }
                }
    }

}

private extension ObservableType where E == ServerResponse {

    func tryMapResult<R>(_ transform: @escaping (E) throws -> R) -> Observable<R> {
        return map {
            do {
                return try transform($0)
            } catch {
                throw RequestError.mapping(error: error, response: $0.1)
            }
        }
    }

    func tryMapObservableResult<R>(_ transform: @escaping (E) throws -> Observable<R>) -> Observable<R> {
        return flatMap { response, result -> Observable<R> in
            do {
                return try transform((response, result))
                    .catchError {
                        throw RequestError.mapping(error: $0, response: result)
                    }
            } catch {
                throw RequestError.mapping(error: error, response: result)
            }
        }
    }

}
