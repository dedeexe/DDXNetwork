# DDXNetwork

This is a lightweight framework for handling network operations in Swift. It is designed with an educational focus rather than ambitious goals.

## Features

- **Network Requests**: Easily perform GET, POST, PUT, DELETE, and other HTTP requests.
- **Response Handling**: Parse JSON responses into Swift models seamlessly.
- **Error Management**: Comprehensive error handling to manage various network errors gracefully.
Installation

To integrate DDXNetwork into your project, you can use Swift Package Manager. Add the following dependency to your Package.swift file:

```swift
dependencies: [
    .package(url: "https://github.com/dedeexe/DDXNetwork.git", from: "1.0.0")
]
```

Then, include DDXNetwork as a dependency in your target:

```swift
targets: [
    .target(
        name: "YourTargetName",
        dependencies: ["DDXNetwork"]
    )
]
```

## Usage

Performing a Network Request
Here's how you can perform a simple GET request using DDXNetwork:

```swift
import DDXNetwork

// Create a request
let request = HTTPRequest
    .builder
    .method(.get)
    .url("https://api.example.com/data")
    .build()


// Perform the request
do {
	let fetcher = RequestFetcher()
	let decodedObject = try await fetcher.fetch(MyModel.self, request: request)
	print("Received object: \(decodedObject)"
} DataFetcherError.downloadFail(let message) {
	// Handle error here
} DataFetcherError.decodingError(let objectType) {
	// Handle error here
}

DDXNetwork.shared.perform(request) { result in
    switch result {
    case .success(let data):
        // Handle successful response
        print("Data received: \(data)")
    case .failure(let error):
        // Handle error
        print("Error: \(error.localizedDescription)")
    }
}
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to enhance DDXNetwork.

## License

DDXNetwork is released under the MIT License.