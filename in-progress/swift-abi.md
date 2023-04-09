---
date: 2023-03-14 13:48
description: Let's find out what is ABI Stablity and Library Evolution
tags: Swift
---
# ABI Stability and Library Evolution 

## Introduction

Let's imagine we develop three apps and each app has camera. In the first app users can scan documents with a camera, in the second app – apply filters to a live camera stream, and in the third – take a picture to send to somebody. So, in each app we have the same code that sets up `AVCaptureSession` and runs it. Code duplication is bad, because if we make an improvement or fix a bug in the first diplicate, we need to copy that improvements to all other duplicates. It's a nightmare to support duplicate code and we should avoid it in the first place. That's why we decided to create a library that contains code that works with `AVCaptureSession`. We've created a seperate Xcode project, moved camera code to it and called it `CameraKit`. Now we need to distribute our library somehow so that our apps could import it. To choose a way of distribution we have to consider the following options: 

1. We use our library only in our projects and do not want to give it to third-party developers:
  1. Distributing source code in-house:
    - Pros:
      1. Easy to debug: if there is a bug in our library we can find it while debugind the app
      1. A library is compiled with the app, so there is no need to support ABI compatibility of the library
    - Cons:
      1. Since a library is compiled every time an app is compolied, it extends the time of an app compilation.
  1. Distributing binary code in-house:
    - Pros:
      1. Library is not compiled when an app is compiled, so app compilation is faster.
    - Cons:
      1. Can not debug a library while debugin an app
1. We want distribute our library to third-patry developers:
  1. Distributing source code in public:
    - Pros:
      1. We let everyone to audit our code and make sure that the library does not steal user data for example. 
      1. Also library users can catch and fix bugs in it and even open pull request with a fix or a feature.
      1. Open sourcing is good, because the comunity could learn something cool from our code. (I hope :))
    - Cons:
      1. Anyone can use it for free, so if we want to sell it or distribute with paid subscription open sourcing is not an option.
  1. Distributing binary code in public:
    - Pros:
      1. Nobody can see your source code, so nobody can steal it.
      1. Library is not compiled when an app is compiled, so app compilation is faster.
    - Cons:
      1. Users can not audit library code, so they have to trust authors of the library.
      
What does this have to do with [ABI Stability](https://www.swift.org/blog/abi-stability-and-more/) and [Librari Evolution](https://www.swift.org/blog/library-evolution/)? To answer the questions let's figure out what these terms mean. ABI stands for application binary interface which means it's an interface to interact with a compiled code (binary). For example we dicided to destribute 'CameraKit' as binary framework, so we compile it with say Swift 4.0 and give it to our clints. If our clients use for example Swift 4.2 they will not be able to use 'CameraKit' in their app, the app just will not compile. Why? Because Swift untill Swift 5.0 was not ABI stable, that means that binaries compiled with different version of compiler can not interact with each other. Why? Let's look at an example, suppose in 'CameraKit' we have a struct and a function: 
```
public struct Foo {
  var isGood: Bool
  var count: Int
}

public func makeGoodFoo(_ foo: Foo) { 
  var goodFoo = foo
  goodFoo.isGood = true
  goodFoo.count = goodFoo.count * 2
}
```
Since we distribute 'CameraKit' as binary then we should compile it with some version of Swift compiler, let it be Swift 4.0. So when the `struct Foo` is compiled the order of struct properties get fixed and in memory it's just and array of bytes, the first byte is for `var isGood: Bool`, followed by 8 bytes of `var count: Int`. 

```
| 0  |1|2|3|4|5|6|7|8|9|
|Bool|------Int--------|
```
But in reality compiler will add offset after `Bool` and it'll look this way:
```
| 0  |1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|
|Bool|---Offset----|---------Int---------|
```
Compiler adds offsets to align properties of structs to speed up CPU reads of data from memory, because CPU can read 8 bytes at a time. So compiled version of `struct Foo` takes 16 bytes in memory.

The compiled pseudo-code of `func makeGoodFoo` will look like this: 
```
public func makeGoodFoo(_ fooBytes: [16 Bytes]) {
    var goodFoo: [16 Bytes] = foo.copyBytes()
    goodFoo[0] = 1 // true
    goodFoo[8..<16] = goodFoo[8..<16] * 2  
}
``` 
As you can see indices are hardcoded into the binary (`goodFoo[0]` and `goodFoo[8..<16]`)

So, we compiled `CameraKit` with Swift 4.0 and sent it to our clients. Clients imported `CameraKit` to their app and built it with Swift 4.0 compiler and everything works fine.

Now let's imagine that Swift shipped new release 4.1 in which hypothetically added an optimization on structs compilation. In new release compiler can reorder struct fields to minimize final struct size. New compiler will compile `struct Foo` this way:
 ```
|1|2|3|4|5|6|7|8|9| 0  |
|------Int--------|Bool|
```
So now compiled version of `struct Foo` takes only 9 bytes in memory and all fileds are correctly aligned. But if our clients recompile their app using new compiler then `func makeGoodFoo` will crash when be called at runtime, because with new compiler `struct Foo` is 9 bytes, but `func makeGoodFoo` expects 16 bytes and when it tries to write to `goodFoo[8..<16]` it gets crashed.

That is why we could not compile app with one version of Swift if it had a library compiled with the other version of Swift. This is why apps had to embed the Swift standard library in the app bundle. This is why Apple did not officially support Swift Binary Frameworks. But then Swift 5.0 with ABI stability came out and everything changed.

This is what ABI stability is all about – "An app built with one version of the Swift compiler will be able to talk to a library built with another version". That is why ABI Stability enables the Swift runtime and standard library be shipped with the OS.

Apple implemented [Swift Standart Library](https://www.swift.org/standard-library/)
> The Swift standard library encompasses a number of data types, protocols and functions, including fundamental data types (e.g., Int, Double), collections (e.g., Array, Dictionary) along with the protocols that describe them and algorithms that operate on them, characters and strings, and low-level primitives (e.g., UnsafeMutablePointer).


 in other words it's a set of rules that determines calling convention and rules for laying out structures 


If we distribute our library as source code we do not need to warry about Labrary Evoltion becoude library's source code is compiled every time the app is compiled. 
