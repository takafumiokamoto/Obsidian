# Go Dependency Injection Best Practices
Created: 7/18/2025, 4:30:19 PM
Last Updated: 7/18/2025, 4:36:04 PM
---

### User

In my Go application, I have dependencies struct which contains global dependencies for “Dependency Injection” purpose.
I injected this struct every struct I use.
But one of my struct (struct A) has a is-a relationship to another struct (struct B).
therefore, embedded another struct.
This point, my the struct A has multiple of dependencies struct.
I could omit injection dependencies to Struct A when initialization.
Is this good practice?
Am I against best practices in Go?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Understanding the Nuance**

I'm currently breaking down the user's query about Go dependency injection and struct embedding. My focus is on the core concept: Dependency Injection. I'm aiming to fully grasp the question's nuances before delving into the technical aspects of structs and their embedding. This foundational understanding is crucial for a comprehensive response.


**Examining the Dependencies**

I'm now focusing on the user's "global Dependencies struct" concept. I suspect this might be a point of contention and worth careful examination. I'm considering the potential drawbacks, such as increased coupling and the difficulty of testing, while also acknowledging potential benefits in terms of centralized configuration. I need to balance these perspectives before providing a definitive answer.


**Refining the Argument**

I'm now focusing on a more nuanced approach. While the initial instinct is to discourage the practice, I'm considering scenarios where relying on embedded dependencies might be acceptable, albeit with caveats. For example, if `struct B` is truly a core dependency for `struct A`, and there's a strong logical relationship, it might be less problematic. However, I need to emphasize the potential pitfalls.


**Exploring Alternatives**

I'm now focusing on practical solutions. I'm aiming to offer the user more robust and testable dependency injection techniques. I'm considering using interfaces and constructor functions to explicitly define dependencies. Also, I'm thinking about advocating against the 'global Dependencies' setup, pointing to more flexible options.


**Revisiting the Concerns**

I'm now grappling with the inherent complexities of the user's approach. My primary focus shifts to clarifying the inherent downsides of implicit dependency injection via embedding. I must present a clear argument, emphasizing the lack of explicitness and the potential for increased coupling, using concrete examples to highlight these pitfalls.


**Analyzing the Implications**

I'm now diving deeper into the potential ramifications of the global `Dependencies` struct approach. My focus has narrowed to considering how this pattern impacts code maintainability and the overall structure. I'm exploring scenarios where this setup might initially seem convenient but eventually creates more complexities. This involves a closer look at the cascading effects when dependencies within the global struct change.


**Analyzing the Alternatives**

Now, I'm focusing on the practical solutions I'll present. My thought is to contrast the user's approach with explicit dependency injection, clearly demonstrating the advantages of injecting only the required dependencies. I'll also explore the use of interfaces to abstract away from concrete implementations, offering a more robust and testable architecture.



</details>

Excellent question. This touches on some very important and nuanced aspects of software design in Go, specifically concerning dependency injection, struct embedding, and API clarity.

Let's break it down.

The short answer is: **No, this is generally not considered good practice.** While it might seem like a clever shortcut, it can lead to code that is harder to understand, maintain, and test.

Here’s the detailed explanation of why and what the best practices are.

### The Problem with Relying on Embedded Dependencies

What you're describing is relying on a *promoted field*. When `struct A` embeds `struct B`, all of `B`'s fields and methods are "promoted" to `A`. So, if `B` has a `Dependencies` field, you can access it directly via `a.Dependencies`.

Here are the main reasons this approach is discouraged:

1.  **It Hides Dependencies:** The primary goal of dependency injection is to make a component's dependencies **explicit**. Someone reading the constructor for `struct A` (`NewA(...)`) should be able to see exactly what `A` needs to function. If `A`'s dependencies are secretly provided by an embedded struct, its true requirements are hidden. This violates the "Principle of Least Astonishment."

2.  **It Creates Tight Coupling:** `struct A` is now tightly coupled to the *implementation* of `struct B`. It relies on the fact that `B` happens to have a `Dependencies` field. What if you refactor `B` in the future, and it no longer needs the entire `Dependencies` struct, or it gets its dependencies in a different way? `struct A` would suddenly break in a non-obvious way.

3.  **It Complicates Testing:** When you want to write a unit test for `struct A`, you now have a problem. You can't just provide mock dependencies directly to `A`. You have to construct a `struct B` with the mocked dependencies and embed that into your test instance of `A`. This makes setting up tests more complex and couples `A`'s tests to `B`'s structure.

4.  **Embedding is Composition ("has-a"), not Inheritance ("is-a"):** This is a crucial point in Go. While you used the term "is-a," embedding in Go is a form of composition. It means `struct A` *has a* `struct B` and can leverage its functionality. It does not mean `A` *is a* `B`. Thinking of it as inheritance can lead to design choices that don't fit the Go paradigm. `A` should manage its own direct dependencies.

### Example: The Problematic vs. The Idiomatic Way

Let's illustrate with code.

```go
// Your global dependencies
type Dependencies struct {
	// DB *sql.DB, Logger *log.Logger, etc.
}

// --- The Problematic Approach ---

type StructB struct {
	Deps *Dependencies
}

func (b *StructB) DoSomethingB() {
	// uses b.Deps
}

// StructA embeds StructB and relies on its dependencies
type StructA struct {
	StructB
}

func NewA_Problematic(b StructB) *StructA {
	// The dependency on `Deps` is hidden!
	return &StructA{StructB: b}
}

func (a *StructA) DoSomethingA() {
	// This works, but it's not clear where `Deps` comes from
	// without inspecting the definition of StructB.
	// uses a.Deps
}
```

### Best Practice 1: Explicit Dependency Injection

The most direct and idiomatic fix is to make the dependency explicit in `struct A`.

```go
// --- The Good Practice: Explicit Injection ---

type StructB_Good struct {
	Deps *Dependencies
}

func NewB_Good(deps *Dependencies) *StructB_Good {
	return &StructB_Good{Deps: deps}
}

func (b *StructB_Good) DoSomethingB() { /* ... */ }

type StructA_Good struct {
	StructB_Good
	// A has its own explicit dependency
	Deps *Dependencies
}

// The constructor makes dependencies clear
func NewA_Good(deps *Dependencies) *StructA_Good {
	return &StructA_Good{
		// We explicitly initialize the embedded struct and A's own fields
		StructB_Good: StructB_Good{Deps: deps},
		Deps:         deps,
	}
}

func (a *StructA_Good) DoSomethingA() {
	// Clearly uses its own dependency field
	// uses a.Deps
}
```

This is much clearer. The `NewA_Good` function signature tells you everything you need to know.

### Best Practice 2: Inject Only What You Need (Interface-Based DI)

An even better practice is to move away from a single, monolithic `Dependencies` struct. This struct often becomes a "grab bag" of services that violates the [Interface Segregation Principle](https://en.wikipedia.org/wiki/Interface_segregation_principle).

Instead, define small interfaces for the behavior each struct needs.

```go
// --- The Best Practice: Interface-Based Injection ---

// Define interfaces for what you need
type Logger interface {
	Log(msg string)
}

type Database interface {
	GetUser(id int) string
}

// StructB only needs a logger
type StructB_Best struct {
	log Logger
}

func (b *StructB_Best) DoSomethingB() {
	b.log.Log("Doing something in B")
}

// StructA needs a logger (to pass to B) and a database
type StructA_Best struct {
	StructB_Best
	db Database
}

// Constructor asks for exactly what it and its children need.
func NewA_Best(log Logger, db Database) *StructA_Best {
	return &StructA_Best{
		StructB_Best: StructB_Best{log: log}, // Pass the dependency down
		db:           db,
	}
}

func (a *StructA_Best) FindUser(id int) {
	a.log.Log("Finding user in A") // Can use the promoted Log method
	user := a.db.GetUser(id)
	// ...
}
```

This approach is the most flexible, testable, and decoupled. `StructA_Best` doesn't need to know about a giant `Dependencies` object, only about the `Logger` and `Database` interfaces it directly uses or passes down.

### Summary

| Approach | Pros | Cons | Verdict |
| :--- | :--- | :--- | :--- |
| **Rely on Embedded Dependency** | Less typing in the constructor. | Hides dependencies, tight coupling, hard to test, misuses composition. | **Avoid.** Against Go best practices for clarity and maintainability. |
| **Explicitly Inject Dependency** | Dependencies are clear and explicit. Easier to test and reason about. | Can be slightly more verbose. | **Good Practice.** This is the standard, idiomatic way to handle DI. |
| **Inject Minimal Interfaces** | Maximum flexibility and decoupling. Very easy to mock and test. Follows SOLID principles. | Requires more upfront design to define interfaces. | **Best Practice.** The gold standard for building large, maintainable Go applications. |

**Conclusion:** You are right to question your initial approach. While the compiler allows it, you would be fighting against the Go ethos of explicitness and clarity. **Always make your dependencies explicit.** Your future self (and your teammates) will thank you for it.


---

### User

Please help me understand correctly.
Is this means, if I have global dependencies which inject every struct, I should not create embedded struct ?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Analyzing the Problem's Core**

I'm currently dissecting the user's situation. The crux is a global `Dependencies` struct injected ubiquitously, causing issues. I'm focusing on the downsides of this pattern, particularly how `struct A` interacts with it. This involves understanding the implications of extensive dependency injection in this specific scenario.


**Reframing the Dependency Issue**

I'm now zeroing in on the crucial aspect: explicitness. The user's implicit dependency via embedding directly contradicts the core DI principle. It obscures the necessary components. My focus has shifted from the initial gut reaction to a structured response, directly addressing the implicit dependency conundrum and clarifying that embedding isn't inherently problematic. I'm aiming to articulate why this shortcut is detrimental to the project.


**Articulating the Core Issue**

I'm now clarifying the core problem with the implicit dependency via embedding. It hinders maintainability and readability. Struct `A`'s reliance on `B`'s injected `Dependencies` creates a hidden contract. I'm focusing on the potential for unexpected breakage if `B`'s dependencies change, highlighting the risks of this shortcut and advocating for explicitness. It's the implicit nature, not embedding itself, that causes the problem.


**Dissecting the Advantages**

I'm now elaborating on the "Good" and "Best" approaches. Explicit dependency management enhances readability, simplifying reasoning about dependencies. I'm focusing on contrasting implicit dependency promotion with direct dependency injection, highlighting the advantages of the latter. I'll include a table to summarize the key differences, solidifying these concepts for the user.


**Refining the Argument's Flow**

I'm now focusing on a robust answer structure. I'll begin with a direct correction of the user's implicit dependency misconception. Then, I'll emphasize clarity through "Good" and "Best" examples, highlighting the benefits of explicit dependency management and presenting a table for easy understanding. I'll ensure my tone is helpful, and the examples are concise, illustrating the core principles.


**Synthesizing Key Principles**

I'm now integrating the core concepts into a cohesive narrative. The central idea revolves around explicitness in dependency management, directly challenging the initial confusion. I'll structure the answer starting with a correction and progressing through varying examples, highlighting the advantages of explicit dependency injection. I am going to keep my response empathetic to the user's situation and will address their concerns thoroughly.

I'm now synthesizing the key arguments for a structured response, starting with a direct clarification. I'll provide a concise analysis of the user's specific problem, aiming to provide a comprehensive explanation in terms they can comprehend. I am planning on providing a response that addresses the core confusion and offers insights into best practices.



</details>

That's a fantastic clarifying question. Let me be very precise:

**No, it does not mean you should avoid struct embedding.**

You can and absolutely should use struct embedding. It is a powerful and idiomatic feature in Go for composition.

The key principle is not about *avoiding embedding*, but about being **explicit with dependencies**.

Let's reframe the rule:

> **A struct should always be explicitly responsible for its own direct dependencies, even if it embeds another struct that has similar needs.**

Think of it like building with LEGOs. If you have a large LEGO car (`StructA`) that contains a pre-built LEGO engine block (`StructB`), both pieces might need a specific type of connector peg (`Dependencies`).

*   **The Bad Way (Implicit):** You attach the pegs to the engine block (`B`), snap the engine into the car (`A`), and then hope the car's chassis can find and use the pegs that are deep inside the engine. It's hidden and fragile.
*   **The Good Way (Explicit):** The car's blueprint (`NewA`) says, "I need connector pegs." The engine's blueprint (`NewB`) also says, "I need connector pegs." When you build the car, you explicitly give pegs to the car chassis *and* you give pegs to the engine block. Everything is clear and properly constructed.

### Let's Look at the Code Again

Here is the correct and idiomatic way to handle this. This pattern uses **both** struct embedding and explicit dependency injection, and they work together perfectly.

```go
package main

import "fmt"

// Your global dependencies struct
type Dependencies struct {
	Database string
	Logger   string
}

// --- Struct B ---
// It needs dependencies to do its job.
type StructB struct {
	deps *Dependencies
}

// The constructor for B explicitly asks for what it needs.
func NewB(deps *Dependencies) *StructB {
	return &StructB{deps: deps}
}

func (b *StructB) Greet() {
	// It uses its own dependency field.
	fmt.Printf("StructB says hello using logger: %s\n", b.deps.Logger)
}

// --- Struct A ---
// It embeds StructB to gain its functionality (the Greet method).
// It ALSO has its own dependency needs.
type StructA struct {
	*StructB // Embedding StructB
	deps     *Dependencies
}

// The constructor for A explicitly asks for what IT needs.
func NewA(deps *Dependencies) *StructA {
	return &StructA{
		// It is A's responsibility to correctly construct
		// the StructB that it is embedding.
		StructB: NewB(deps),

		// It is also A's responsibility to satisfy its own
		// direct dependencies.
		deps: deps,
	}
}

func (a *StructA) FindUser(id int) {
	// It uses its own dependency field.
	fmt.Printf(
		"StructA is finding user %d using database: %s\n",
		id,
		a.deps.Database,
	)
}

func main() {
	// You create the dependencies once.
	globalDeps := &Dependencies{
		Database: "PostgreSQL_Connection",
		Logger:   "ZapLogger_Instance",
	}

	// You inject the dependencies where they are needed.
	myA := NewA(globalDeps)

	// You can call the promoted method from the embedded struct.
	myA.Greet() // "StructB says hello using logger: ZapLogger_Instance"

	// You can call the method on the parent struct.
	myA.FindUser(101) // "StructA is finding user 101 using database: PostgreSQL_Connection"
}
```

### When to Use Embedding vs. When to Inject

This table should clarify the distinct roles they play:

| Concern | Use Struct Embedding | Use Dependency Injection |
| :--- | :--- | :--- |
| **Purpose** | To **reuse code** and **compose behavior**. You want `StructA` to have all the methods of `StructB`. It's a "has-a" relationship. | To **provide resources** and **decouple components**. You want to give a struct the tools it needs (like a database connection or logger) without it knowing how to create them. |
| **Example** | A `Car` struct embeds an `Engine` struct to gain `Start()` and `Stop()` methods. | A `UserRepository` struct receives a `*sql.DB` database connection in its constructor so it can be tested with a mock database. |
| **Your Scenario** | `StructA` embeds `StructB` because `A` needs to be able to do everything `B` can do. | `StructA` and `StructB` **both** need access to the global dependencies to perform their respective tasks. |

### Conclusion

**Do not stop using struct embedding.** It's a core part of the language.

The lesson here is about the responsibilities of a constructor. The constructor's job is to fully and correctly initialize a struct, and that includes:
1.  Satisfying its own direct dependencies.
2.  Correctly initializing any structs it embeds.

By following the explicit pattern in the code above, you get the best of both worlds: the code reuse from embedding and the clarity, testability, and maintainability from dependency injection.


---

### User

So, I should inject Dependencies explicitly even if it duplicates?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Investigating the Core Query**

I'm analyzing the user's primary question, focusing on the word "duplicates." This suggests a possible misconception about dependency injection. It seems they're concerned about redundancy in explicitly injecting dependencies. I'm starting to explore the reasons why duplication might not be as problematic as initially perceived in this context. I'm now exploring scenarios where explicit injection might be beneficial despite the perceived duplication.


**Reframing the "Duplication"**

I'm now focusing on reframing the user's perception of "duplication" in dependency injection. It's crucial to clarify that the repetition isn't about duplicating *data*. Instead, it's about explicitly managing dependencies for clarity and separation of concerns, which I plan to emphasize in my response. I'm exploring how to present this concept to the user effectively.


**Elaborating on the Benefits**

I'm now focusing on the advantages of explicit dependency injection. I've broken down the misconception of "duplication," and now I'm building a concise list of benefits: enhanced readability, decoupling, and easier testing. I'm exploring an example where changing the dependencies of a related struct doesn't impact other structs that use the same dependency. This example helps highlight the principle of separation of concerns.


**Solidifying Key Arguments**

I'm solidifying my key arguments for addressing the user's concerns about "duplicate" dependency injection. I've pinpointed that the repetition isn't about data, but declaration. Clarity, decoupling, and testing are the core benefits. Now I'm preparing a visual example to showcase how an isolated change in one struct's dependencies won't impact others, reinforcing the principle of separation of concerns.


**Elaborating the Refinement**

I'm now focusing on a more explicit and actionable response to the user's query about "duplicate" dependency injection. I realized that directly answering with "yes" and then listing benefits might not address the core concern. I'm prioritizing addressing the misconception directly, framing it as explicit dependency declaration. My plan is to emphasize that this perceived repetition is essential for clarity, decoupling, and unit testing. I'll provide an annotated code example to illustrate this concretely.


**Formulating a Concise Response**

Okay, I'm now crafting a concise and direct response, starting with "Yes, absolutely," followed by a clear explanation. I'm focusing on "explicit declaration" to reframe "duplication." I'll then list the benefits and provide a code example with comments. The goal is to make the response immediately understandable and address the user's specific concern about perceived redundancy.

\n\n

I've crafted an initial response that directly addresses the user's question, emphasizing explicit dependency declaration. I've now introduced the core benefits: readability, decoupling, and testability, each linked back to the user's concern. Next, I plan to build a code snippet, adding comments that directly address the concept of "duplication," to provide a practical illustration.



</details>

Yes, absolutely. That is the correct takeaway.

You should explicitly inject the `Dependencies` struct into `StructA`, even though you are also passing it down to the embedded `StructB`.

What feels like "duplication" is actually **explicitness and separation of concerns**, which are highly valued principles in Go.

Let's break down why this perceived duplication is not only acceptable but is the preferred, robust design.

### It's Not Duplicating the Object, It's Duplicating the *Declaration of Need*

You are not creating two copies of your `Dependencies` object. You create it once and pass the same pointer to multiple places.

```go
// You create ONE dependency object in memory.
globalDeps := &Dependencies{...}

// You pass a POINTER (an address) to that one object.
myA := NewA(globalDeps)
```

Inside `NewA`, you are doing this:

```go
func NewA(deps *Dependencies) *StructA {
	return &StructA{
		// Pass the pointer to NewB
		StructB: NewB(deps),
		// Store the same pointer in StructA's field
		deps: deps,
	}
}
```

Both `a.deps` and `a.StructB.deps` point to the **exact same object in memory**. There is no duplication of the actual dependency data.

The "duplication" is in the struct definitions:

```go
type StructB struct {
	deps *Dependencies // B declares it needs dependencies.
}

type StructA struct {
	*StructB
	deps *Dependencies // A declares it needs dependencies.
}
```

This is a good thing! Here’s why:

#### 1. It Makes Each Struct Self-Contained and Independent

*   **Readability:** If a developer looks *only* at the definition of `StructA`, they can see `deps *Dependencies` and know immediately that it has a dependency. They don't have to go on a treasure hunt into `StructB` to discover this hidden requirement.
*   **Decoupling:** This is the most important reason. Imagine you refactor `StructB` in the future.

    *   **Scenario:** You realize `StructB` no longer needs the `Database` from the `Dependencies` struct. You change `StructB` to only accept a `Logger`.
    *   **If `A` relied on `B`'s dependency:** Your `StructA` would instantly break, because the `Database` it was secretly using via `B` is now gone.
    *   **With the explicit design:** `StructA` is completely unaffected. It has its own `deps` field and can continue using the `Database`. The only thing that needs to change is how `A` constructs its embedded `B`, which is a small, localized change in `NewA`.

#### 2. It Radically Simplifies Unit Testing

When you write a test for `StructA`, you want to test *only* `StructA`'s logic, not `B`'s.

**Without explicit dependencies**, testing `A`'s methods would be a nightmare. You'd have to construct a real `StructB` with mock dependencies just to satisfy `A`.

**With explicit dependencies**, testing `A` is trivial. You don't even need to provide a real `StructB` if the method you're testing doesn't use it.

```go
func TestStructA_FindUser(t *testing.T) {
	// Create mock dependencies specifically for this test.
	mockDeps := &Dependencies{Database: "MockDB"}

	// We can construct StructA for our test.
	// We can even provide a `nil` for the embedded struct if FindUser
	// doesn't call any of its methods.
	testA := &StructA{
		StructB: nil, // We are not testing B's functionality here.
		deps:    mockDeps,
	}

	// Now we can test A's method in complete isolation.
	testA.FindUser(123)

	// ... assertions ...
}
```

### Summary: Duplication vs. Explicitness

| Your Concern | The Go Philosophy |
| :--- | :--- |
| "This feels like I'm duplicating the `deps` field." | "You are explicitly declaring the requirements for each component independently." |
| "It's more verbose to pass `deps` to `NewA` and also to `NewB`." | "Clarity is better than brevity. Hidden 'magic' leads to bugs and unmaintainable code." |
| "Why can't `A` just use the dependency from `B`?" | "Because `A` is not `B`. `A` *has a* `B`. Each component is responsible for its own needs. This makes your system decoupled and resilient to change." |

**Final Answer:** Yes, you are on the right track. What you identified as potential "duplication" is the cornerstone of this robust, testable, and maintainable design pattern in Go. Embrace the explicitness.


---
