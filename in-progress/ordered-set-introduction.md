# Ordered Set Introduction

In this article I'll introduce Ordered Set data structure and why is it useful.

Suppose we have an app and every time a user launches the app, it send an analytics event to our server that a user with an ID launched the app at a specific time. Our server is pretty dumb and all it does with such events is appending them to a file. So one day a manager comes and asks you to calculate a number of unique users of the app. How will you solve that problem? The first solution that you might come up with is to create a new array and append users there only if that new array does not already contain such user: 

```
struct UserEntry: Equatable {
  let id: Int
  let timestamp: Int
  
  static func ==(lhs: UserEntry, rhs: UserEntry) -> Bool {
      lhs.id == rhs.id
  }
}

func unique(users: [UserEntry]) -> [UserEntry] {
  var uniqueUsers = [User]()
  for user in users {
    if uniqueUsers.contains(user) == false {
        uniqueUsers.append(user)
    }
  }
  return uniqueUsers
}
```

Here we use `contains` array method that iterates over the array and checks if such element already exists. To better understand the complexity of our `unique` functions let's rewrite it without using `contains`:

```
struct UserEntry {
  let id: Int
  let timestamp: Int
}

func unique(users: [UserEntry]) -> [UserEntry] {
  var uniqueUsers = [UserEntry]()
  for user in users {
    var isUnique = true
    for uniqueUser in uniqueUsers {
      if uniqueUser.id == user.id {
        isUnique = false
        break
      }
    }
    if isUnique {
      uniqueUsers.append(user)
    }
  }
  return uniqueUsers
}
```

So, what is the complexity of `unique` function? It seems hard to say how many operations this functions does on an arbitrary input, so let's consider two edge cases. The first one is when an input consists of users with the same id:

```
[
  UserEntry(id: 0, timestamp: 0),
  UserEntry(id: 0, timestamp: 1),
  UserEntry(id: 0, timestamp: 2),
  ...
]
```  

In this case the inner loop `for uniqueUser in uniqueUsers {` will have no effect on complexity since `uniqueUsers` will have only one single entry. So for such particular input `unique` function will have `O(n)` complexity, because it has one loop over input elemetns and inner loop does not count since it has only one element. 

The other edge case is when input contains users with unique ids only:

```
[
  UserEntry(id: 0, timestamp: 0),
  UserEntry(id: 1, timestamp: 0),
  UserEntry(id: 2, timestamp: 0),
  ...
]
```

In this case on every iteration of outer loop `for user in users` the `uniqueUsers` array will grow by one element and that is why `for uniqueUser in uniqueUsers {` loop does metter in this case. Let's calculate how many iterations `unique` function will perform for such input of `n` values. For the 1st iteration of outer loop  `uniqueUser` array is empty, so the inner loop performs 0 operations and the first user is appended to `uniqueUser` array. For the 2nd iteration of outer loop `uniqueUser` array size is one, since on previous iteration we appended one unique user, so the inner loop performs 1 operation and the second user is appended to `uniqueUser` array. For 3rd iteration of outer loop the inner loop performs 2 operations and so on. For n-th iteration of outer loop the inner loop performs n-1 operations. To calculate the number of all inner loop interations we need to sum them up: 

```
0 + 1 + 2 + 3 + ... + n-1
```

To sum this series we can see sum of the first and the last numbers are equal to sum of the second and the penultimate numbers and so on.

```
0 + n-1 = n-1
1 + n-2 = n-1
2 + n-3 = n-1
...
```
How many such pairs do we have? N devided by 2. So we have the following:

```
0 + 1 + 2 + 3 + ... + n-1 = (0 + n-1) + (1 + n-2) + (2 + n-3) + ... = (n-1) * n / 2 = (n^2 - n) / 2 = (n^2 / 2) - (n / 2) 
```

Let's convert it to big-O notation. First we can drop `n/2` part since we have more segnificant  `n^2 / 2`, and we also can drop `1/2` constant. Eventually we get this: 

```
O((n^2 / 2) - (n / 2)) = O(n^2 / 2) = O(n^2)
```

So for such particular input of unique elements `unique` function will have `O(n^2)` complexity.

For inputs between upper mentioned edge cases number of operations are between `O(n)` and `O(n^2)`, but in the worst case complexity is `O(n^2)` that is why we say that complexity of `unique` function is `O(n^2)`.

The question is can we do any better? Yes we can, let's consider `Set` data structure.
