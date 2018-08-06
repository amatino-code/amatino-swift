# Amatino Swift
Amatino is an accounting engine. It provides double entry accounting as a service. Amatino is served via a web API. Amatino Swift is a library for interacting with the Amatino API from within a Swift application, on macOS or iOS.

## Under construction
The Amatino API pffers a full range of accounting services via HTTP requests. Amatino Swift is in an Alpha state, offering expressive, object-oriented Swift interfaces for almost all Amatino API services.

A few API features, such as [Custom Units](https://amatino.io/documentation/custom_units) and [Entity ](https://amatino.io/documentation/entities) Permissions Graphs, are not yet available in Amatino Swift.  While Amatino's [HTTP documentation](https://amatino.io/documentation) is full and comprehensive, Amatino Swift documentation is still under construction.

To be notified when Amatino Swift enters a Beta state, with all capabilities and documentation available, sign up to the [Amatino Development Newsletter](https://amatino.io/newsletter).

## Installation
You may install Amatino Swift in a variety of ways:

### Carthage
Add Amatino to your `Cartfile`:

```
github "amatino-code/amatino-swift"
```

For help, see the [Carthage quick start guide](https://github.com/Carthage/Carthage#quick-start).

### CocoaPods
Add Amatino to your `Podfile`:

```
pod 'Amatino', '>= 0.0.8'
```
For help, see [the CocoaPods user guide](https://guides.cocoapods.org/using/using-cocoapods.html).

### Manually
You can clone this repository, compile Amatino, and drag the compiled .framework into your Xcode project. Or, pre-compiled .framework binaries are available on [Amatino Swift's Releases page](https://github.com/amatino-code/amatino-swift/releases).  

## Example Usage
To get started, you will need a `Session`. Creating a `Session` is analogous to 'logging in' to Amatino.

```swift
try Session.create(
  email: "clever@cookie.com",
  secret: "high entropy passphrase",
  callback: { (error, session) in
    // Session instances are the keys to unlocking
    // Amatino services throughout your application
})
```
 All financial data are stored in [`Entities`](https://amatino.io/documentation/entities), ultra-generic objects that may represent a person, company, project, or any other being which you wish to describe with financial information.

```swift
try Entity.create(
  session: session,
  name: "Mega Corporation",
  callback: { (error, entity) in
    // We can now store information describing Mega
    // Corporation
})
```
Entities are structured with [`Accounts`](https://amatino.io/documentation/accounts). For example, a bank account, a pile of physical cash, income from sale of accounting software, or travel expenses.
```swift
try Account.create(
  session: session,
  entity: entity,
  name: "Widget Sales",
  type: .revenue,
  description: "Revenue from sale of excellent widgets",
  globalUnit: usd,
  callback( { error, account} in 
	  // Accounts can be nested, their denominations
	  // mixed and matched
})
```
Once we have some Accounts, we can store records of economic activity! To do so, we use the [`Transaction`]("https://amatino.io/documentation/transactions") class.
```swift
try Transaction.create(
  session: session,
  entity: entity,
  transactionTime: Date(),
  description: "Record some widget sales",
  globalUnit: usd,
  entries: [
    Entry(
      side: .debit,
      account: cash,
      amount: Decimal(7)
    ),
    Entry(
      side: .debit,
      account: customerDeposits,
      amount: Decimal(3)
    ),
    Entry(
      side: .credit,
      account: widgetSales,
      amount: Decimal(10)
    )
  ],
  callback: { (error, transaction) in
    // Transactions can contain up to 100 constituent
    // entries, and be denominated in an arbitrary unit
})
```
Storing information is nice, but the real power comes from Amatino's ability to organise and retrieve it. For example, we could retrieve a [`Ledger`](https://amatino.io/documentation/ledgers) that lists all Transactions party to an Account.
```swift
try Ledger.retrieve(
  session: session,
  entity: entity,
  account: widgetSales,
  callback: { (error, ledger) in
    // You can also retrieve RecursiveLedgers, which
    // list all transactions in the target and all the
    // target's children 
})
```
Many more classes and methods are available. However, in this early Alpha state, they are not comprehensively documented. Follow [@AmatinoAPI on Twitter](https://twitter.com/amatinoapi) or sign up to the [Development Newsletter](https://amatino.io/newsletter) to be notified when full documentation is available.

## Development Updates

To receive occasional updates on Amatino Swift development progress, including notification when the library enters a full-featured beta state, sign up to the [Amatino Development Newsletter](https://amatino.io/newsletter).

Get notified about new library versions by following [@AmatinoAPI](https://amatinoapi) on Twitter.

## Other languages

Amatino libraries are also available in [Python](https://github.com/Amatino-Code/amatino-python) and [Javascript](https://github.com/Amatino-Code/amatino-js).
  
## Useful links

-  [Amatino home](https://amatino.io)
-  [Development blog](https://amatino.io/blog)
-  [Development newsletter](https://amatino.io/newsletter)
-  [Discussion forum](https://amatino.io/discussion)
-  [More Amatino client libraries](https://github.com/amatino-code)
-  [Documentation](https://amatino.io/documentation)
- [Billing and account management](https://amatino.io/billing)
-  [About Amatino Pty Ltd](https://amatino.io/about)
  
## Get in contact

To quickly speak to a human about Amatino, [email hugh@amatino.io](mailto:hugh@amatino.io) or [yell at him on Twitter (@hugh_jeremy)](https://twitter.com/hugh_jeremy).