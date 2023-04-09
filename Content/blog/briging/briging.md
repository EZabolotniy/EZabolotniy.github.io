---
date: 2023-04-09 14:47
description: In this post you'll learn about implicit bridging between Swift String and NSString and its costs
tags: Swift, Foundation
---
#  Swift String vs NSString

While I was implementing a [Hack Assempler](https://github.com/EZabolotniy/hack-assembler) I had to parse an assembly code file, which looks like this:
```
// Computes R2 = max(R0, R1)  (R0,R1,R2 refer to RAM[0],RAM[1],RAM[2])

   @R0
   D=M              // D = first number
   @R1
   D=D-M            // D = first number - second number
   @OUTPUT_FIRST
   D;JGT            // if D>0 (first is greater) goto output_first
   @R1
   D=M              // D = second number
   @OUTPUT_D
   0;JMP            // goto output_d
(OUTPUT_FIRST)
   @R0             
   D=M              // D = first number
(OUTPUT_D)
   @R2
   M=D              // M[2] = D (greatest number)
(INFINITE_LOOP)
   @INFINITE_LOOP
   0;JMP            // infinite loop
```  
The purpose of parsing was to extract all assemply commands and translate them to its binary form. So, the parser goes line by line and the first thing it does is trimming whitespaces and removing a comment. The first solution I came up with was this code:
```
extension String {
  func removeComments() -> String {
    let trimmedWhitespacesAndNewlines = trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedWhitespacesAndNewlines.hasPrefix("//") else {
      return ""
    }
    // code and comment on a single line:
    return trimmedWhitespacesAndNewlines.components(separatedBy: "//").first!
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
```
Let's go through it line by line. First I call `trimmingCharacters(in: .whitespacesAndNewlines)`, which trims whitespaces and newlines. Then I check if it starts with `//` and if so, I just return an empty string because the whole line is just a comment. Otherwise I try splitting the trimmed string with "//" in case it has trailing comment, take the part before a comment, trim whitespaces and newlines in that part and return it. Not elegant but straightforward and works correctly.
So I decided to measure the performance of this function. Let's take a string and parse it a million times.
```
let clock = ContinuousClock()
let elapsedTime = clock.measure {
  for _ in 0..<1000000 {
    let _ = "push local 1  // Test trailing comment Test trailing comment Test trailing comment Test trailing comment".removeComments()
  }
}
print("ElapsedTime = \(elapsedTime)")
```  
Build and run in release mode `swift run -c release`:
```
ElapsedTime = 3.776673785 seconds
```
Build in release mode `swift build -c release` and run with Intruments:

![Trimming](/blog/briging/trimming.png)
\  
![Components](/blog/briging/components.png)
\  
\  
Here, we can see that calling `func trimmingCharacters(in set: CharacterSet) -> String` on a `String` actually calls `- (NSString *)stringByTrimmingCharactersInSet:(NSCharacterSet *)set;` on `NSString`. And the same happens with `func components(separatedBy separator: CharacterSet) -> [String]`, it is transformed into `- (NSArray<NSString *> *)componentsSeparatedByString:(NSString *)separator;` call on `NSString`. This is what Objc-Swift Interoperability is responsible of. To make this possible Swift `String` is bridged into `NSString` by allocating a new storage with size of the `String` on the heap, and copying each chatacter into that new storage. So calling an `NSString` method on a `String` instance has cpu and memory overhead by creating a new `NSString` and then converting `NSString` back into Swift `String`. Let's try to solve this problem by staying in a Swift world, thus removing the bridging overhead.
```
extension String {
  func removeComments() -> String {
    var commentStartIndex = endIndex
    for i in indices.dropFirst() {
      if self[i] == "/" && self[index(before: i)] == "/" {
        commentStartIndex = index(before: i)
        break
      }
    }

    let noCommentString = self[..<commentStartIndex]
    if let firstLetterIndex = noCommentString.firstIndex(where: { $!$0.isWhitespace }),
       let lastLetterIndex = noCommentString.lastIndex(where: { !$0.isWhitespace }) {
      return String(self[firstLetterIndex...lastLetterIndex])
    }
    return ""
  }
}
```
Build and run in release mode `swift run -c release`:
```
ElapsedTime = 1.078179221 seconds
```
As we can see the latter code runs 3.5 times faster and does not waste memory on briging. So, measure your code and stay in Swift world!

References:  
1. [WWDC18 Using Collections Effectively](https://developer.apple.com/wwdc18/229) (timecode: 30:10)
