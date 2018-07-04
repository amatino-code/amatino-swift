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

````
let _ = AmatinoAlpha.create(
    email: "clever@cooke.com",
    secret: "high entropy passphrase",
    callback: {(error: Error?, amatinoAlpha: AmatinoAlpha?) in
        // Do stuff with amatinoAlpha
})
````

Requests may then be made like so:

````
let newEntityData = [[
    "name": "My First Entity",
    "description": nil,
    "region_id": nil
]]

let _ = try! amatinoAlpha!.request(
    path: "/entities",
    method: HTTPMethod.POST,
    queryString: nil,
    body: newEntityData,
    callback: {(error: Error?, responseData: Data?) in
        // Do stuff with responseData
})
````

Wherein the parameters passed to `request()` are the HTTP path, method, url parameters ('query string'),  and body laid out in the Amatino API HTTP documentation.

For example, the above request created an [Entity](https://amatino.io/documentation/entities). The requirements for Entity creation are available at https://amatino.io/documentation/entities#action-Create.

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
