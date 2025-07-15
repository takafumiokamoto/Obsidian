# Zap logging library in Go singleton pattern
Created: 7/15/2025, 3:41:39 PM
Last Updated: 7/15/2025, 3:58:46 PM
---

### User

Help me encapsulate Zap which is logging library in Go.
I want to create global logger instance as singleton.
I have to use With() function which is create child logger with attributes.
As I mentioned earlier, this behavior might break singleton.


---

### Assistant (grok-v4)

<details>
<summary>Reasoning</summary>

Thinking... Thinking... Thinking... Thinking... Thinking... Thinking... 
</details>

Below, I'll help you encapsulate the Zap logging library in Go to create a global logger instance as a singleton. I'll address your concerns about the `With()` method, which indeed returns a new child logger instance (Zap loggers are immutable by design, so `With()` doesn't modify the original). This can "break" the singleton pattern if you're not careful, as it leads to multiple logger instances floating around instead of a single shared one.

To handle this:
- We'll create a **singleton root logger** using a package-level variable and `sync.Once` for thread-safe initialization. This ensures there's only one global instance.
- For `With()`, I'll recommend a pattern where you **don't modify the singleton directly**. Instead, retrieve the singleton and call `With()` on it to create short-lived child loggers for specific contexts (e.g., per request or function). This preserves the singleton while allowing attribute addition without global mutation.
- If you truly need to add permanent attributes to the global logger (e.g., app-wide fields like version or environment), I'll provide an optional thread-safe way to update the singleton. However, this should be used sparingly to avoid complexity—Zap is designed for immutable loggers.

I'll provide a complete, self-contained Go package example. This assumes you have Zap installed (`go get go.uber.org/zap`). The code is formatted using Prettier with a print width of 80 characters.

### Key Design Decisions
- **Singleton Initialization**: Use `sync.Once` to lazily initialize the logger only once.
- **Encapsulation**: We'll create a package (e.g., `logger`) that exports functions like `GetLogger()` and `InitLogger()` for control.
- **With() Handling**: Encourage creating child loggers on-the-fly. This avoids breaking the singleton while leveraging Zap's strengths.
- **Thread Safety**: All access to the singleton is protected.
- **Best Practices**: Use Zap's production config for efficiency. You can customize it (e.g., for development mode).

### Example Implementation

Create a new package in your project, e.g., `internal/logger/logger.go`:

```go
// Package logger provides a singleton wrapper around Zap for global logging.
// It ensures thread-safe access and handles child loggers via With() without
// breaking the singleton pattern.
package logger

import (
	"fmt"
	"sync"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var (
	once     sync.Once
	instance *zap.Logger
	mu       sync.Mutex // For optional updates to the singleton.
)

// InitLogger initializes the global singleton logger with a production config.
// Call this early in your application (e.g., in main). It can be called multiple
// times, but initialization happens only once.
func InitLogger() {
	once.Do(func() {
		config := zap.NewProductionConfig()
		config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
		config.EncoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder

		var err error
		instance, err = config.Build()
		if err != nil {
			panic(fmt.Sprintf("failed to initialize zap logger: %v", err))
		}
	})
}

// GetLogger returns the global singleton logger. If not initialized, it panics.
// Use this as the base for creating child loggers with With().
func GetLogger() *zap.Logger {
	if instance == nil {
		panic("logger not initialized; call InitLogger() first")
	}
	return instance
}

// UpdateGlobalFields optionally updates the global singleton with permanent
// fields. This creates a new logger instance and replaces the singleton.
// Use sparingly, as it mutates the global state. Thread-safe.
func UpdateGlobalFields(fields ...zap.Field) {
	mu.Lock()
	defer mu.Unlock()
	if instance == nil {
		panic("logger not initialized; call InitLogger() first")
	}
	instance = instance.With(fields...)
}

// Example usage functions (you can call these from other packages).

// LogInfo logs an info message using the global logger.
func LogInfo(msg string, fields ...zap.Field) {
	GetLogger().Info(msg, fields...)
}

// CreateChildLogger creates and returns a child logger with the given fields.
// This does not modify the global singleton.
func CreateChildLogger(fields ...zap.Field) *zap.Logger {
	return GetLogger().With(fields...)
}
```

### How to Use It
1. **Initialization**: Call `logger.InitLogger()` once early in your app (e.g., in `main()`).
2. **Basic Logging**: Use the singleton directly for global logs.
3. **With Attributes**: Always create a child logger via `With()` (or the helper `CreateChildLogger()`) for contextual logging. This keeps the singleton intact.
4. **Updating Global Fields**: If needed, use `UpdateGlobalFields()` to add permanent attributes (e.g., during app startup).

Example in your `main.go`:

```go
package main

import (
	"github.com/yourproject/internal/logger" // Adjust import path.
	"go.uber.org/zap"
)

func main() {
	// Initialize the singleton once.
	logger.InitLogger()

	// Optional: Add permanent global fields (e.g., app version).
	logger.UpdateGlobalFields(zap.String("app_version", "1.0.0"))

	// Use the global logger directly.
	logger.GetLogger().Info("Application started")

	// Create a child logger with context-specific attributes.
	// This does not affect the singleton.
	child := logger.CreateChildLogger(
		zap.String("user_id", "123"),
		zap.String("request_id", "abc456"),
	)
	child.Info("Processing request")

	// Or use With() directly.
	anotherChild := logger.GetLogger().With(zap.String("module", "auth"))
	anotherChild.Error("Authentication failed")

	// Sync logs before exit (Zap best practice).
	defer logger.GetLogger().Sync()
}
```

### Why This Doesn't Break the Singleton
- The **root logger** (`instance`) is initialized only once and shared globally.
- `With()` creates new, independent child loggers without touching the singleton. These children inherit from the root but are not stored globally—they're typically short-lived (e.g., per HTTP request or goroutine).
- If you need to "add attributes globally," `UpdateGlobalFields` safely replaces the singleton with a new instance (under a mutex). This maintains singleton semantics (one global instance at a time) but allows mutation. Avoid overusing this, as it goes against Zap's immutable design—prefer child loggers instead.
- Thread-safety ensures no races during init or updates.

### Potential Improvements
- **Configuration**: Customize the Zap config in `InitLogger()` (e.g., add development mode with `zap.NewDevelopmentConfig()` for stack traces).
- **Error Handling**: Instead of panicking, you could return errors from `InitLogger()`.
- **Testing**: For unit tests, you might want a way to reset the singleton (e.g., expose a `Reset()` function that sets `instance = nil` and resets `once` via reflection, but that's advanced).
- **Performance**: Zap is fast, but creating many child loggers is fine—it's optimized for this.

If this doesn't match what you had in mind (e.g., if you want to avoid child loggers entirely or need something more specific), provide more details about your use case, and I'll refine it!


---

### User

Maybe I am sensitive but in your code, I have to import Zap in main.go
Is this achieved encapsulation?


---

### Assistant (grok-v4)

<details>
<summary>Reasoning</summary>

Thinking... Thinking... Thinking... Thinking... Thinking... Thinking... Thinking... 
</details>

I understand your concern—it's a fair point! In my previous example, while the logger package encapsulates the initialization and singleton management of Zap, the usage in `main.go` still requires importing `go.uber.org/zap` to create fields (e.g., `zap.String`) or to work directly with `*zap.Logger`. This does leak the underlying Zap implementation, which isn't full encapsulation. If your goal is to completely hide Zap from the rest of your codebase (so no external imports of Zap are needed, and the logger feels like a custom, opaque API), we can improve this.

### Improved Encapsulation Approach
To achieve better encapsulation:
- We'll **hide all Zap types** (`*zap.Logger`, `zap.Field`, etc.) from external code.
- Instead of returning `*zap.Logger` or requiring `zap.Field`, we'll provide:
  - A custom `Logger` interface (or struct) with methods like `Info`, `Error`, etc.
  - For fields/attributes, use a **variadic key-value pair API** (e.g., `Info(msg, "key1", val1, "key2", val2)`). This is simple, doesn't require importing Zap, and is inspired by libraries like Logrus or Zerolog. Internally, we'll convert these to `zap.Field` using a helper.
  - A global singleton root `Logger`.
  - A `With` method on the `Logger` that returns a new `Logger` instance (a child). This preserves the singleton for the root while allowing contextual children without exposing Zap.
- The logger package will handle all Zap-specific logic internally, including field conversion and error handling.
- This way, your `main.go` (or any other package) only imports your custom `logger` package—no Zap imports needed.

This doesn't "break" the singleton because:
- The **root logger** remains a true singleton (thread-safely initialized once).
- `With` creates short-lived child loggers (as before), but now they're wrapped in your custom `Logger` type, keeping everything encapsulated.

If you prefer a different field API (e.g., a custom `Field` type or builder), let me know—I kept it simple with key-value pairs for usability.

### Revised Code Example

Update your `internal/logger/logger.go` (or wherever you placed it):

```go
// Package logger provides a fully encapsulated singleton logger, hiding the
// underlying Zap implementation. It supports global logging and contextual
// child loggers via With() without exposing Zap types.
package logger

import (
	"fmt"
	"sync"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var (
	once     sync.Once
	instance Logger
	mu       sync.Mutex // For optional updates to the singleton.
)

// Logger is the interface for logging operations. It hides the Zap
// implementation.
type Logger interface {
	// Info logs an info-level message with optional key-value fields.
	Info(msg string, keyvals ...interface{})

	// Error logs an error-level message with optional key-value fields.
	Error(msg string, keyvals ...interface{})

	// Debug logs a debug-level message with optional key-value fields.
	Debug(msg string, keyvals ...interface{})

	// Warn logs a warn-level message with optional key-value fields.
	Warn(msg string, keyvals ...interface{})

	// With returns a new child Logger with the given key-value fields added as
	// context. This does not modify the original Logger.
	With(keyvals ...interface{}) Logger

	// Sync flushes any buffered logs.
	Sync()
}

// zapLogger is the internal implementation of Logger, wrapping *zap.Logger.
type zapLogger struct {
	z *zap.Logger
}

// Ensure zapLogger implements Logger.
var _ Logger = (*zapLogger)(nil)

func (l *zapLogger) Info(msg string, keyvals ...interface{}) {
	l.z.Info(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) Error(msg string, keyvals ...interface{}) {
	l.z.Error(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) Debug(msg string, keyvals ...interface{}) {
	l.z.Debug(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) Warn(msg string, keyvals ...interface{}) {
	l.z.Warn(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) With(keyvals ...interface{}) Logger {
	return &zapLogger{z: l.z.With(toZapFields(keyvals...)...)}
}

func (l *zapLogger) Sync() {
	_ = l.z.Sync() // Ignore error for simplicity.
}

// toZapFields converts variadic key-value pairs to []zap.Field.
// Keys must be strings; values can be any type (handled by zap.Any).
// If the number of keyvals is odd, the last value is ignored.
func toZapFields(keyvals ...interface{}) []zap.Field {
	if len(keyvals)%2 != 0 {
		// For safety, we could log a warning here, but for now, just truncate.
		keyvals = keyvals[:len(keyvals)-1]
	}
	fields := make([]zap.Field, 0, len(keyvals)/2)
	for i := 0; i < len(keyvals); i += 2 {
		key, ok := keyvals[i].(string)
		if !ok {
			continue // Skip invalid keys.
		}
		val := keyvals[i+1]
		fields = append(fields, zap.Any(key, val))
	}
	return fields
}

// Init initializes the global singleton logger with a production config.
// Call this early in your application (e.g., in main). It can be called multiple
// times, but initialization happens only once.
func Init() {
	once.Do(func() {
		config := zap.NewProductionConfig()
		config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
		config.EncoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder

		z, err := config.Build()
		if err != nil {
			panic(fmt.Sprintf("failed to initialize zap logger: %v", err))
		}
		instance = &zapLogger{z: z}
	})
}

// Get returns the global singleton Logger. If not initialized, it panics.
func Get() Logger {
	if instance == nil {
		panic("logger not initialized; call logger.Init() first")
	}
	return instance
}

// UpdateGlobalContext optionally updates the global singleton with permanent
// context fields. This creates a new logger instance and replaces the singleton.
// Use sparingly, as it mutates the global state. Thread-safe.
func UpdateGlobalContext(keyvals ...interface{}) {
	mu.Lock()
	defer mu.Unlock()
	if instance == nil {
		panic("logger not initialized; call logger.Init() first")
	}
	z := instance.(*zapLogger).z.With(toZapFields(keyvals...)...)
	instance = &zapLogger{z: z}
}

// Sync flushes the global logger's buffers. Call this before app exit.
func Sync() {
	if instance != nil {
		instance.Sync()
	}
}
```

### How to Use It
Now, in your `main.go` (or other packages), you **don't need to import Zap at all**. Everything is handled through the custom `Logger` interface and key-value pairs.

```go
package main

import (
	"github.com/yourproject/internal/logger" // Adjust import path.
	"time"
)

func main() {
	// Initialize the singleton once.
	logger.Init()

	// Optional: Add permanent global context (e.g., app version).
	logger.UpdateGlobalContext("app_version", "1.0.0", "env", "production")

	// Use the global logger directly with key-value pairs.
	// Supports any value types (strings, ints, structs, etc.).
	logger.Get().Info("Application started", "timestamp", time.Now())

	// Create a child logger with context-specific attributes.
	// This does not affect the global singleton.
	child := logger.Get().With("user_id", 123, "request_id", "abc456")
	child.Info("Processing request", "duration_ms", 150)

	// Another child example with mixed types.
	anotherChild := logger.Get().With("module", "auth", "attempts", 3)
	anotherChild.Error("Authentication failed", "error", "invalid credentials")

	// Sync logs before exit (best practice).
	defer logger.Sync()
}
```

### Why This Achieves Better Encapsulation
- **No Zap Exposure**: External code never sees `*zap.Logger`, `zap.Field`, or any Zap types. You only interact with the custom `Logger` interface and simple key-value pairs.
- **Singleton Intact**: The root logger is still a singleton. `With` creates new `Logger` instances (wrapping Zap children) without modifying the global one.
- **Flexibility**: The key-value API is easy to use and supports arbitrary types (via `zap.Any` internally). If you pass an odd number of keyvals, it safely handles it by truncating.
- **Extensibility**: You can add more methods to the `Logger` interface (e.g., `Panic`, `Fatal`) or customize the config in `Init()`. For development mode, swap to `zap.NewDevelopmentConfig()`.
- **Thread-Safety**: Initialization and global updates are protected.
- **Limitations**: The key-value API isn't as type-safe as Zap's native fields (e.g., no compile-time checks for specific types like `zap.Int`). If you need that, we could define custom field builder functions (e.g., `StringField(k, v string) interface{}`), but this keeps it minimal.

If this still doesn't feel fully encapsulated (e.g., you want to avoid key-value pairs or need more logging levels), or if you'd like adjustments (like returning errors instead of panicking), let me know—I'm happy to iterate!


---

### User

Can I omit Get() in your example?


---

### Assistant (grok-v4)

<details>
<summary>Reasoning</summary>

Thinking... Thinking... Thinking... Thinking... 
</details>

Yes, absolutely—you can omit the explicit `Get()` calls in your usage code to make the API even simpler and more ergonomic. This is a common pattern for global loggers (e.g., similar to Go's standard `log` package or global wrappers in other logging libraries). We'll achieve this by adding package-level logging functions (e.g., `logger.Info(...)`) that internally retrieve the singleton via `Get()` and delegate to it. This hides the singleton retrieval from the user while keeping everything encapsulated.

### Key Changes
- **Package-Level Functions**: Add top-level functions like `Info`, `Error`, `Debug`, `Warn`, `With`, and `Sync` that operate on the global singleton. These implicitly use `Get()` under the hood.
- **Omit Get()**: You can now log directly (e.g., `logger.Info("msg")`) without calling `Get()`. The `Get()` function is still available if you need to retrieve the `Logger` interface explicitly (e.g., to pass it to another function or for advanced use).
- **With() Behavior**: I've added a package-level `With` function that returns a new child `Logger` based on the global singleton. You can chain or use it to create contextual loggers without touching `Get()`.
- **Singleton Integrity**: This doesn't change the underlying singleton—it's still thread-safely managed. If the logger isn't initialized, these functions will panic (consistent with before), but you could modify them to auto-initialize or return errors if preferred.
- **Backwards Compatibility**: The `Logger` interface and other parts remain the same.

This makes the API feel more "global" and less verbose, while preserving full encapsulation (no Zap exposure).

### Revised Code Example

Update your `internal/logger/logger.go`:

```go
// Package logger provides a fully encapsulated singleton logger, hiding the
// underlying Zap implementation. It supports global logging and contextual
// child loggers via With() without exposing Zap types.
package logger

import (
	"fmt"
	"sync"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var (
	once     sync.Once
	instance Logger
	mu       sync.Mutex // For optional updates to the singleton.
)

// Logger is the interface for logging operations. It hides the Zap
// implementation.
type Logger interface {
	// Info logs an info-level message with optional key-value fields.
	Info(msg string, keyvals ...interface{})

	// Error logs an error-level message with optional key-value fields.
	Error(msg string, keyvals ...interface{})

	// Debug logs a debug-level message with optional key-value fields.
	Debug(msg string, keyvals ...interface{})

	// Warn logs a warn-level message with optional key-value fields.
	Warn(msg string, keyvals ...interface{})

	// With returns a new child Logger with the given key-value fields added as
	// context. This does not modify the original Logger.
	With(keyvals ...interface{}) Logger

	// Sync flushes any buffered logs.
	Sync()
}

// zapLogger is the internal implementation of Logger, wrapping *zap.Logger.
type zapLogger struct {
	z *zap.Logger
}

// Ensure zapLogger implements Logger.
var _ Logger = (*zapLogger)(nil)

func (l *zapLogger) Info(msg string, keyvals ...interface{}) {
	l.z.Info(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) Error(msg string, keyvals ...interface{}) {
	l.z.Error(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) Debug(msg string, keyvals ...interface{}) {
	l.z.Debug(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) Warn(msg string, keyvals ...interface{}) {
	l.z.Warn(msg, toZapFields(keyvals...)...)
}

func (l *zapLogger) With(keyvals ...interface{}) Logger {
	return &zapLogger{z: l.z.With(toZapFields(keyvals...)...)}
}

func (l *zapLogger) Sync() {
	_ = l.z.Sync() // Ignore error for simplicity.
}

// toZapFields converts variadic key-value pairs to []zap.Field.
// Keys must be strings; values can be any type (handled by zap.Any).
// If the number of keyvals is odd, the last value is ignored.
func toZapFields(keyvals ...interface{}) []zap.Field {
	if len(keyvals)%2 != 0 {
		keyvals = keyvals[:len(keyvals)-1]
	}
	fields := make([]zap.Field, 0, len(keyvals)/2)
	for i := 0; i < len(keyvals); i += 2 {
		key, ok := keyvals[i].(string)
		if !ok {
			continue // Skip invalid keys.
		}
		val := keyvals[i+1]
		fields = append(fields, zap.Any(key, val))
	}
	return fields
}

// Init initializes the global singleton logger with a production config.
// Call this early in your application (e.g., in main). It can be called multiple
// times, but initialization happens only once.
func Init() {
	once.Do(func() {
		config := zap.NewProductionConfig()
		config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
		config.EncoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder

		z, err := config.Build()
		if err != nil {
			panic(fmt.Sprintf("failed to initialize zap logger: %v", err))
		}
		instance = &zapLogger{z: z}
	})
}

// Get returns the global singleton Logger. If not initialized, it panics.
// This is optional; use package-level functions like Info() instead for simplicity.
func Get() Logger {
	if instance == nil {
		panic("logger not initialized; call logger.Init() first")
	}
	return instance
}

// UpdateGlobalContext optionally updates the global singleton with permanent
// context fields. This creates a new logger instance and replaces the singleton.
// Use sparingly, as it mutates the global state. Thread-safe.
func UpdateGlobalContext(keyvals ...interface{}) {
	mu.Lock()
	defer mu.Unlock()
	if instance == nil {
		panic("logger not initialized; call logger.Init() first")
	}
	z := instance.(*zapLogger).z.With(toZapFields(keyvals...)...)
	instance = &zapLogger{z: z}
}

// Info logs an info-level message using the global logger.
func Info(msg string, keyvals ...interface{}) {
	Get().Info(msg, keyvals...)
}

// Error logs an error-level message using the global logger.
func Error(msg string, keyvals ...interface{}) {
	Get().Error(msg, keyvals...)
}

// Debug logs a debug-level message using the global logger.
func Debug(msg string, keyvals ...interface{}) {
	Get().Debug(msg, keyvals...)
}

// Warn logs a warn-level message using the global logger.
func Warn(msg string, keyvals ...interface{}) {
	Get().Warn(msg, keyvals...)
}

// With returns a new child Logger based on the global logger, with the given
// key-value fields added as context.
func With(keyvals ...interface{}) Logger {
	return Get().With(keyvals...)
}

// Sync flushes the global logger's buffers. Call this before app exit.
func Sync() {
	if instance != nil {
		instance.Sync()
	}
}
```

### How to Use It (Omitting Get())
Now, your `main.go` (or other packages) can log directly via package-level functions, without ever calling `Get()`. It's cleaner and more concise:

```go
package main

import (
	"github.com/yourproject/internal/logger" // Adjust import path.
	"time"
)

func main() {
	// Initialize the singleton once.
	logger.Init()

	// Optional: Add permanent global context (e.g., app version).
	logger.UpdateGlobalContext("app_version", "1.0.0", "env", "production")

	// Log directly using package-level functions (no Get() needed).
	logger.Info("Application started", "timestamp", time.Now())

	// Create a child logger with context-specific attributes.
	// This does not affect the global singleton.
	child := logger.With("user_id", 123, "request_id", "abc456")
	child.Info("Processing request", "duration_ms", 150)

	// Another child example with mixed types.
	anotherChild := logger.With("module", "auth", "attempts", 3)
	anotherChild.Error("Authentication failed", "error", "invalid credentials")

	// If you need to log from the global logger again.
	logger.Error("Global error occurred")

	// Sync logs before exit (best practice).
	defer logger.Sync()
}
```

### Benefits and Notes
- **Simplicity**: No need for `Get()` in everyday use—logging feels global and direct.
- **Flexibility**: You can still use `With` to create children, and they return a `Logger` that you can use for contextual logging. If you need to pass a logger around (e.g., to a function), you can use `Get()` or `With` to obtain one.
- **Consistency**: All logging goes through the singleton internally. Child loggers are still short-lived and don't modify the global one.
- **Edge Cases**: If you call logging functions before `Init()`, it will panic (as before). For auto-initialization, you could modify `Get()` to call `Init()` implicitly, but that might hide errors—let me know if you want that.
- **Extensibility**: You can add more package-level functions (e.g., `Fatal` that calls `os.Exit` after logging) if needed.

This should feel even more encapsulated and user-friendly. If you'd like further tweaks (e.g., auto-init, more logging levels, or handling for uninitialized states), just say the word!


---
