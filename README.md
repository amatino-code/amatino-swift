# Amatino Swift

Amatino is a double entry accounting system. It provides double entry accounting as a service. Amatino is served via a web API. Amatino Swift is a library for interacting with the Amatino API from within a Swift application. By using Amatino Swift, a Swift developer can utilise Amatino services without needing to deal with raw HTTP requests.

## Under construction

Right now, the Amatino API pffers a full range of accounting services via HTTP requests. However, this Amatino Swift library is in an 'Alpha' state. Its capabilities are limited. One class is available: `AmatinoAlpha`.

`AmatinoAlpha` is a thin wrapper around asynchronous HTTP requests to the Amatino API. It facilitates testing and experimentation with the Amatino API without having to resort to raw HTTP request manipulation and HMAC computation.

Amatino Swift will eventually offer expressive, object-oriented interfaces for all Amatino API services. To be notified when Amatino Swift enters a Beta state, with all capabilities available, sign up to the [Amatino Development Newsletter](https://amatino.io/newsletter).

In the mean time, you may wish to review [Amatino's HTTP documentation](https://amatino.io/documentation) to see what capabilities you can expect from Amatino Swift in the future.

## Example Usage

The `AmatinoAlpha` object allows you to use the Amatino API without dealing with raw HTTP requests or HMACs. It lacks the expressive syntax, input validation, and error handling that Amatino Swift will have in the beta stage.

Initialise an `AmatinoAlpha` instance like so:

````swift
let _ = AmatinoAlpha.create(
    email: "clever@cooke.com",
    secret: "high entropy passphrase",
    callback: {(error: Error?, amatinoAlpha: AmatinoAlpha?) in
        // Do stuff with amatinoAlpha
})
````

Requests may then be made like so:

````swift
let newEntityData = try! EntityCreateArguments(name: "My First Entity")

let _ = try! amatinoAlpha.request(
    path: "/entities",
    method: HTTPMethod.POST,
    queryString: nil,
    body: [newEntityData],
    callback: {(error: Error?, responseData: Data?) in
        // Do stuff with responseData
})
````

Wherein the parameters passed to `request()` are the HTTP path, method, url parameters ('query string'),  and body laid out in the Amatino API HTTP documentation.

For example, the above request created an [Entity](https://amatino.io/documentation/entities). The requirements for Entity creation are available at [/entities#action-Create](https://amatino.io/documentation/entities#action-Create).

The example uses the `EntityCreateArguments` struct to form the `body` required by the `AmatinoAlpha.request()` method. You can pass any `encodable` to `body`. For example, a dictionary of form `[String: Any]`.

However, encoding JSON `null` values in dictionaries with the Swift Foundation library requires verbose code. A dictionary with a `nil` key, for example:

```swift
let newEntityData = [
    "name": "My First Entity",
    "description": nil,
    "region_id": nil
]
```

... Will be encoded by the default Foundation JSONEncoder as ...

````
'{"name": "My First Entity"}'
````

While the [Amatino API specification](https://amatino.io/documentation/entities#action-Create) requires:

````
'{"name": "My First Entity", "description": null, "region_id": null}'
````

This problem can be solved by defining an explicit implmentation of `encode()`. For example, the `EntityCreateArguments` struct we used above includes the following `encode`:

````swift
// ...
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case regionId = "region_id"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(regionId, forKey: .regionId)
        return
    }
// ...
````
At this stage, Amatino Swift also includes the following Encodable structs:

+ [`EntityCreateArguments`](https://github.com/amatino-code/amatino-swift/blob/master/Sources/Amatino/EntityCreateArguments.swift)
+ [`SessionCreateArguments`](https://github.com/amatino-code/amatino-swift/blob/master/Sources/Amatino/Session.swift)
+ [`AccountCreateArguments`](https://github.com/amatino-code/amatino-swift/blob/master/Sources/Amatino/AccountCreateArguments.swift)
+ [`TransactionCreateArguments`](https://github.com/amatino-code/amatino-swift/blob/master/Sources/Amatino/TransactionCreateArguments.swift)

To interact with other objects using `AmatinoAlpha`, you will need to either avoid `nil` values in encodable dictionaries, or write your own implementation of `encode()`. Obviously this sucks!

As Amatino Swift matures to Beta stage, encodable structs will become available for all objects. Further, you won't need to deal with them directly. For example, check out the more expressive syntax already available for Entity creation:

````swift
let _ = Entity.create(
    session: session,
    name: "My First Entity",
    callback: {(error: Error?, entity: Entity? in
        // Do stuff with entity
    })
````
To receive occasional updates on Amatino Swift development progress, including notification when the library enters a full-featured beta state, sign up to the [Amatino Development Newsletter](https://amatino.io/newsletter).

For more examples of `AmatinoAlpha` usage, see the [getting started guide](https://amatino.io/articles/getting-started).

## Other languages

Amatino libraries are also available in [Python](https://github.com/Amatino-Code/amatino-python), [C# (.NET)](https://github.com/Amatino-Code/amatino-dotnet), and [Javascript](https://github.com/Amatino-Code/amatino-js).

## Useful links

- [Amatino home](https://amatino.io)
- [Development blog](https://amatino.io/blog)
- [Development newsletter](https://amatino.io/newsletter)
- [Discussion forum](https://amatino.io/discussion) 
- [More Amatino client libraries](https://github.com/amatino-code)
- [Documentation](https://amatino.io/documentation)
- [Billing and account management](https://amatino.io/billing)
- [About Amatino Pty Ltd](https://amatino.io/about)
