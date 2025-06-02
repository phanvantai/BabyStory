//
//  MockURLSession.swift
//  SoftDreamsTests
//
//  Created by Tests on 2/6/25.
//

import Foundation
@testable import SoftDreams

/// Mock URLSession class for testing network requests without making actual API calls
class MockURLSession: URLSession, @unchecked Sendable {
  
  // MARK: - Mock Properties
  var mockData: Data = Data()
  var mockResponse: HTTPURLResponse?
  var mockError: Error?
  var lastRequest: URLRequest?
  
  // Custom URLSessionDataTask subclass for mocking
  private class MockDataTask: URLSessionDataTask, @unchecked Sendable {
    private let completionHandler: () -> Void
    
    init(completionHandler: @escaping () -> Void) {
      self.completionHandler = completionHandler
      super.init()
    }
    
    override func resume() {
      // Execute the completion handler immediately when resume is called
      completionHandler()
    }
  }
  
  // MARK: - URLSession methods
  override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    // Store the request for verification in tests
    lastRequest = request
    
    // Create a task that will execute the completion handler immediately on resume
    let task = MockDataTask {
      if let error = self.mockError {
        completionHandler(nil, nil, error)
      } else {
        let response = self.mockResponse ?? HTTPURLResponse(
          url: request.url ?? URL(string: "https://example.com")!,
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        completionHandler(self.mockData, response, nil)
      }
    }
    
    return task
  }
  
}
