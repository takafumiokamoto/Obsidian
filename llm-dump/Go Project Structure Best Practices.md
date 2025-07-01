# Go Project Structure Best Practices
Created: 6/27/2025, 3:39:39 PM
Last Updated: 6/27/2025, 3:43:58 PM
---

### User

Is there a best practice for project structure in golang?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Examining the Core Question**

I've started by deconstructing the user's inquiry, focusing on the core concept: establishing best practices for Go project structure. The challenge lies in defining what truly constitutes a "best practice" in this context. It's not a simple answer.


**Analyzing Project Layout Approaches**

I'm now diving deeper into the nuances of various layout approaches. While I initially focused on unpacking the user's question and initial brainstorming, I'm now actively comparing the flat, feature-based, and Standard Go Project Layout structures. Evaluating their suitability based on project size, complexity, and maintainability is key. I'll need to articulate the trade-offs clearly.


**Clarifying Project Categorization**

My focus has shifted to the practical application of different structures. I'm actively categorizing Go projects based on size and scope. This allows for clear, tailored recommendations. Considering the user, the goal is to provide adaptable advice, not rigid rules. I'm exploring when a flat structure suffices and when the Standard Go Project Layout becomes essential.


**Expanding the Project Scope**

The project categorization exercise is opening new avenues. I'm actively assessing how different project types impact structure choices. I'm now actively considering cloud-native applications and microservices. I'll need to clearly explain the specific structural adaptations that these architectural paradigms require. It's a key expansion.


**Evaluating Adaptability and Scalability**

I'm now actively assessing the adaptability and scalability of different approaches. I've considered the initial points and am focusing on the balance between straightforward simplicity and long-term maintainability. I'm exploring how project structure can evolve gracefully, particularly with rapidly growing projects. It's about providing robust design advice.


**Contemplating Structure Evolution**

I'm now actively focusing on the evolution of project structures. My goal is to outline the key aspects related to growth. I'll need to explore how to provide clear guidance on adapting structures over time, considering factors like refactoring and code reuse. This is the central topic.
I've started by deconstructing the user's inquiry, focusing on the core concept: establishing best practices for Go project structure. The challenge lies in defining what truly constitutes a "best practice" in this context. It's not a simple answer.\n\nI'm now diving deeper into the nuances of various layout approaches. While I initially focused on unpacking the user's question and initial brainstorming, I'm now actively comparing the flat, feature-based, and Standard Go Project Layout structures. Evaluating their suitability based on project size, complexity, and maintainability is key. I'll need to articulate the trade-offs clearly.\n\nMy focus has shifted to the practical application of different structures. I'm actively categorizing Go projects based on size and scope. This allows for clear, tailored recommendations. Considering the user, the goal is to provide adaptable advice, not rigid rules. I'm exploring when a flat structure suffices and when the Standard Go Project Layout becomes essential.\n\nThe project categorization exercise is opening new avenues. I'm actively assessing how different project types impact structure choices. I'm now actively considering cloud-native applications and microservices. I'll need to clearly explain the specific structural adaptations that these architectural paradigms require. It's a key expansion.\n\nI'm now actively assessing the adaptability and scalability of different approaches. I've considered the initial points and am focusing on the balance between straightforward simplicity and long-term maintainability. I'm exploring how project structure can evolve gracefully, particularly with rapidly growing projects. It's about providing robust design advice.


**Synthesizing Best Practice Guidance**

I'm now actively summarizing the key takeaways. My goal is to outline actionable best practices for Go project structure. I'll distill the complex material into clear, concise guidelines. I'll need to emphasize adaptability and offer a strong, easy-to-use example project.
I've started by deconstructing the user's inquiry, focusing on the core concept: establishing best practices for Go project structure. The challenge lies in defining what truly constitutes a "best practice" in this context. It's not a simple answer.\n\nI'm now diving deeper into the nuances of various layout approaches. While I initially focused on unpacking the user's question and initial brainstorming, I'm now actively comparing the flat, feature-based, and Standard Go Project Layout structures. Evaluating their suitability based on project size, complexity, and maintainability is key. I'll need to articulate the trade-offs clearly.\n\nMy focus has shifted to the practical application of different structures. I'm actively categorizing Go projects based on size and scope. This allows for clear, tailored recommendations. Considering the user, the goal is to provide adaptable advice, not rigid rules. I'm exploring when a flat structure suffices and when the Standard Go Project Layout becomes essential.\n\nThe project categorization exercise is opening new avenues. I'm actively assessing how different project types impact structure choices. I'm now actively considering cloud-native applications and microservices. I'll need to clearly explain the specific structural adaptations that these architectural paradigms require. It's a key expansion.\n\nI'm now actively assessing the adaptability and scalability of different approaches. I've considered the initial points and am focusing on the balance between straightforward simplicity and long-term maintainability. I'm exploring how project structure can evolve gracefully, particularly with rapidly growing projects. It's about providing robust design advice.\n\nI'm now actively focusing on the evolution of project structures. My goal is to outline the key aspects related to growth. I'll need to explore how to provide clear guidance on adapting structures over time, considering factors like refactoring and code reuse. This is the central topic.\n\nI'm now actively summarizing the key takeaways. My goal is to outline actionable best practices for Go project structure. I'll distill the complex material into clear, concise guidelines. I'll need to emphasize adaptability and offer a strong, easy-to-use example project.



</details>

Of course. This is an excellent question and a topic of much discussion in the Go community.

While there is no single, officially mandated project structure enforced by the Go toolchain, a set of strong conventions and best practices has emerged over time. The most well-known of these is often called the **"Standard Go Project Layout."**

The key principle is to **start simple and evolve your structure as the project's complexity grows.**

### 1. For Very Small Projects: Keep it Flat

For a small command-line tool or a microservice with only a few files, a complex directory structure is overkill. A flat structure is perfectly acceptable and idiomatic.

```
/my-simple-app
├── go.mod
├── go.sum
├── main.go
├── handlers.go
├── handlers_test.go
└── models.go
```

In this setup, all your `.go` files are in the root directory and belong to the `main` package. This is easy to navigate and understand.

### 2. The Standard Go Project Layout (for Medium to Large Applications)

As your application grows, you'll need a more organized way to handle different concerns. This is where the community-driven "Standard Go Project Layout" comes in. It provides a scalable and conventional structure.

**Important Note:** You don't need all of these directories. Start with what you need and add more as your project demands it. The most important ones are `/cmd`, `/internal`, and `/pkg`.

Here is a common structure and an explanation of each part:

```
/my-complex-app
├── /api
├── /build
├── /cmd
│   └── /my-app-server
│       └── main.go
├── /configs
├── /internal
│   ├── /auth
│   ├── /database
│   └── /handlers
├── /pkg
│   └── /some-public-util
├── /scripts
├── /web
├── go.mod
└── go.sum
```

---

#### Key Directory Explanations:

*   **/cmd**
    This is arguably the most important convention. This directory contains the entry points for your application(s). You might have a web server, a CLI tool, or a worker process for the same project. Each subdirectory in `/cmd` is a separate executable.
    *   The code inside `/cmd` should be minimal. It's responsible for parsing flags, reading configs, and wiring together the components defined in `/internal` or `/pkg`.
    *   Example: `/cmd/my-app-server/main.go` would be the `main` package for your web server.

*   **/internal**
    This is a special directory with behavior enforced by the Go compiler. Any code inside `/internal` can only be imported by code within the same parent directory.
    *   **Purpose:** To store your application's private, non-reusable code. This is the heart of your application logic.
    *   **Rule:** Code in `/my-complex-app/internal/` can be imported by code in `/my-complex-app/cmd/`, but it **cannot** be imported by any external Go project.
    *   This is the perfect place for your business logic, database access, and HTTP handlers that you don't want other projects to depend on.

*   **/pkg**
    This directory has been a source of debate, but the modern consensus is clearer.
    *   **Purpose:** To store code that is safe for external applications to import and use. Think of it as your project's public library.
    *   **Best Practice:** **Do not put everything in `/pkg`!** Only place code here if you have another project that genuinely needs to import it. If you're not sure, start with `/internal`. It's much easier to move code from `/internal` to `/pkg` later than the other way around.

*   **/api**
    Contains API definition files, such as OpenAPI/Swagger specs, gRPC `.proto` files, or JSON schema files. This keeps your API contracts separate from the implementation.

*   **/web** or **/ui**
    For web application assets like static files, templates, and frontend code (e.g., a React or Vue app).

*   **/configs**
    For configuration file templates or default configs.

*   **/scripts**
    For helper scripts to build, install, analyze, or deploy your application.

*   **/build**
    For packaging and Continuous Integration (CI) files. You might put your `Dockerfile`, `docker-compose.yml`, or CI configuration here.

---

### 3. Alternative Philosophies: Clean/Hexagonal Architecture

For very large, domain-heavy applications, some teams adopt structures inspired by Clean Architecture or Hexagonal Architecture. This focuses on separating business logic from external concerns (like databases or web frameworks).

A simplified structure might look like this:

```
/my-ddd-app
├── /cmd
│   └── /server
│       └── main.go
├── /internal
│   ├── /domain          // Core business models and logic (e.g., User, Order)
│   ├── /repository      // Interfaces for data storage (e.g., UserRepository)
│   ├── /service         // Application-specific use cases
│   └── /transport       // Adapters for delivery (e.g., HTTP, gRPC)
│       └── /http
├── go.mod
└── go.sum
```

### Guiding Principles & Best Practices

1.  **Start Simple:** Don't create a 15-directory structure for a 100-line CLI tool. Let the structure evolve.
2.  **Use `/cmd` for Binaries:** Always place your `main` packages in subdirectories of `/cmd`.
3.  **Default to `/internal`:** Place your core application logic in `/internal`. This prevents other projects from creating unwanted dependencies on your private code.
4.  **Use `/pkg` with Intention:** Only use `/pkg` for code that you explicitly want to share with other projects.
5.  **Keep `main.go` Lean:** Your `main` function should be a "wiring" layer, not a business logic layer. It sets up dependencies and starts the application.
6.  **Consistency is Key:** The most important thing is to be consistent within your project and your team. Choose a structure and stick to it.


---

### User

Can I use src layout?
is it against best practice?
because I am in big monorepo


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Exploring the `/src` Layout**

I've started by carefully unpacking the user's inquiry. The core revolves around the viability of using a `/src` layout, and whether it aligns with established best practices in Go development. I'm focusing on the implied "best practice" aspect and how to address it.


**Investigating Alternatives to `/src`**

I'm now delving into the established Go project structure, specifically the "Standard Go Project Layout," to understand the alternatives to `/src`. This helps clarify why `/src` isn't conventional and how the Go toolchain handles source code organization. I'm focusing on the implications of a monorepo structure.


**Refining the Monorepo Approach**

I'm now refining the argument for and against `/src` in a monorepo setting. I'm focusing on providing practical, structured advice. My goal is to show the user how a `/src` layout could be made to work *effectively* within the monorepo context. I plan to construct an example directory structure demonstrating how to organize different Go services or components, such as `service-a` and `library-b`, within a `/src` directory. This example will highlight how to maintain clarity and ease of use in a monorepo.


**Elaborating on Monorepo Nuances**

I'm now diving deeper into the monorepo context, analyzing the interplay between `/src` and dependency management. Specifically, I'm fleshing out the example directory structure and the *crucial* decision of how to handle `go.mod` files. Should it be a single root `go.mod` or a more polyrepo-style approach? I'm weighing the pros and cons of each choice for clarity and maintainability.


**Reflecting on Best Practices**

I'm now assessing how well `/src` fits into "best practice" principles. While standard Go prefers a flatter structure, I realize that for a monorepo, a `/src` directory can be a pragmatic choice, especially when it promotes clarity and organization. I'm focusing on crafting the most *effective* monorepo structure.


**Analyzing Monorepo `go.mod` Choices**

I'm now investigating the pivotal decision of `go.mod` file strategy in a monorepo with a `/src` layout. Should we opt for individual `go.mod` files per service or a consolidated root `go.mod`? I'm weighing the advantages and disadvantages of each method concerning dependency management and code clarity. The ultimate goal is to offer the user a clear rationale for making the best decision for their specific situation.



</details>

That's an excellent and very practical question, especially in the context of a large monorepo.

The short answer is: **Yes, you can use a `/src` layout, but it is generally considered non-idiomatic and not a best practice for a *standard, single* Go project.**

However, in a large, polyglot monorepo, the rules can change. Let's break this down.

### Why `/src` is Not Idiomatic in Go

The convention of a top-level `/src` directory comes from other language ecosystems (like Java/Maven, Rust/Cargo, Node.js) where the build tools expect source code to be in a specific location.

The Go toolchain was designed differently. With the introduction of Go Modules (the `go.mod` file), the concept of `GOPATH` as a single workspace became less central. The Go compiler finds your packages based on:

1.  The module path defined in your `go.mod` file (e.g., `module github.com/my-org/my-project`).
2.  The import paths you use in your code (e.g., `import "github.com/my-org/my-project/pkg/utils"`).

The compiler resolves these paths starting from the directory containing the `go.mod` file. A `/src` directory adds an extra, unnecessary layer of nesting that doesn't provide any value to the Go toolchain itself. It can even make import paths longer and more cumbersome.

For a **single Go project**, this structure is preferred:

```
/my-go-project  <-- Root of the repo, contains go.mod
├── go.mod
├── go.sum
├── cmd/
├── internal/
└── pkg/
```

Adding `/src` would make it:

```
/my-go-project
└── /src
    ├── go.mod  <-- go.mod would likely be here
    ├── go.sum
    ├── cmd/
    ├── internal/
    └── pkg/
```

This adds no benefit and is not what experienced Go developers expect to see.

### The Monorepo Exception: Where `/src` Can Make Sense

Your context of a **"big monorepo"** is the key detail. In a monorepo, you aren't just managing one Go project; you're managing many applications, services, and libraries, potentially in different languages.

In this scenario, the primary goal of the top-level directory structure is to **organize the components of the monorepo**, not to appease the Go toolchain. A `/src` directory (or alternatives like `/services`, `/apps`, `/packages`) becomes a very sensible and pragmatic choice for grouping all the source code.

Here’s how it could look in a monorepo:

```
/my-company-monorepo
├── /docs
├── /scripts
├── /src  <-- A reasonable choice for grouping source code
│   ├── /go-service-a    <-- This is a self-contained Go module
│   │   ├── go.mod
│   │   ├── cmd/service-a/main.go
│   │   └── internal/
│   ├── /go-service-b
│   │   ├── go.mod
│   │   ├── cmd/service-b/main.go
│   │   └── internal/
│   ├── /go-shared-lib
│   │   ├── go.mod
│   │   └── pkg/      <-- Code intended for sharing across go-service-a/b
│   ├── /python-data-processor
│   │   └── src/
│   └── /frontend-app
│       └── src/
└── README.md
```

In this structure:

1.  **The `/src` directory is for monorepo organization.** It cleanly separates source code from top-level docs, scripts, and CI/CD configuration.
2.  **Each Go project *inside* `/src` follows Go best practices.** Notice that `go-service-a` and `go-service-b` have their own `go.mod` files at their root and then use the standard `/cmd` and `/internal` layout.
3.  This avoids the anti-pattern. The Go project itself doesn't have a `/src` directory; the monorepo does. The Go module root is `/src/go-service-a`, not `/src`.

### Verdict and Best Practice for Your Monorepo

So, is using `/src` against best practice?

*   **For a standalone Go repository:** Yes, it's against convention. Avoid it.
*   **For a large, polyglot monorepo:** No, it's a perfectly reasonable and common organizational pattern. It is not against best practice *in this context*.

**The best practice for you is to:**

1.  Use a top-level directory like `/src`, `/services`, or `/apps` to group your projects within the monorepo.
2.  Ensure that **each individual Go project** within that directory is a self-contained Go module (has its own `go.mod`).
3.  Structure each of those Go modules according to the "Standard Go Project Layout" (`/cmd`, `/internal`, etc.).

This approach gives you the best of both worlds: a clean, organized monorepo at the top level, and idiomatic, maintainable Go projects within it.


---
