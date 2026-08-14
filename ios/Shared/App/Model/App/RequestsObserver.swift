//
//  RequestsObserver.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/4/22.
//

import Foundation
import Combine

class RequestsObserver : ObservableObject {
    @Published private var array: Set<URL> = []
    
    func append(_ newElement: URL) {
        DispatchQueue.main.async {
            self.array.insert(newElement)
        }
    }
    
    func remove(_ newElement: URL) {
        DispatchQueue.main.async {
            self.array.remove(newElement)
        }
    }
    
    func contains(_ newElement: URL) -> Bool{
        self.array.contains(where: {$0 == newElement})
    }
    
    func getRequestPublisherFor(_ fileFirebaseURL : URL) -> Publishers.Filter<Published<Set<URL>>.Publisher>{
        return $array
            .filter({ !$0.contains(fileFirebaseURL) })
    }
}
