# Go PostgreSQL struct insertion
Created: 7/8/2025, 4:03:06 PM
Last Updated: 7/8/2025, 4:31:52 PM
---

### User

I have big struct and correspond columns in my PostgreSQL.
I would like to insert record as struct.
Is it able to do this?
I am using golang


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user is asking about inserting a struct into PostgreSQL using Go. They want to know if it's possible to insert a record directly from a struct into PostgreSQL.

This is definitely possible in Go with PostgreSQL. There are several ways to do this:

1. Using database/sql with manual field mapping
2. Using an ORM like GORM
3. Using sqlx for easier struct scanning
4. Using reflection to automatically map struct fields

I should provide a comprehensive answer showing different approaches, starting with the most common and practical ones.
</details>

Yes, you can definitely insert records from structs into PostgreSQL using Go! Here are several approaches:

## 1. Using GORM (Most Popular ORM)

```go
package main

import (
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

type User struct {
    ID    uint   `gorm:"primaryKey"`
    Name  string `gorm:"column:name"`
    Email string `gorm:"column:email"`
    Age   int    `gorm:"column:age"`
}

func main() {
    dsn := "host=localhost user=username password=password dbname=testdb port=5432 sslmode=disable"
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        panic("failed to connect database")
    }

    // Auto-migrate the schema
    db.AutoMigrate(&User{})

    // Insert a record
    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    result := db.Create(&user)
    
    if result.Error != nil {
        panic(result.Error)
    }
}
```

## 2. Using sqlx (Lighter Alternative)

```go
package main

import (
    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

func main() {
    db, err := sqlx.Connect("postgres", "user=username password=password dbname=testdb sslmode=disable")
    if err != nil {
        panic(err)
    }
    defer db.Close()

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    query := `INSERT INTO users (name, email, age) VALUES (:name, :email, :age) RETURNING id`
    rows, err := db.NamedQuery(query, user)
    if err != nil {
        panic(err)
    }
    defer rows.Close()

    if rows.Next() {
        rows.Scan(&user.ID)
    }
}
```

## 3. Using Standard database/sql with Helper Function

```go
package main

import (
    "database/sql"
    "fmt"
    "reflect"
    "strings"
    _ "github.com/lib/pq"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

func insertStruct(db *sql.DB, tableName string, data interface{}) error {
    v := reflect.ValueOf(data)
    t := reflect.TypeOf(data)
    
    if v.Kind() == reflect.Ptr {
        v = v.Elem()
        t = t.Elem()
    }
    
    var columns []string
    var placeholders []string
    var values []interface{}
    
    for i := 0; i < v.NumField(); i++ {
        field := t.Field(i)
        tag := field.Tag.Get("db")
        
        if tag != "" && tag != "id" { // Skip ID for auto-increment
            columns = append(columns, tag)
            placeholders = append(placeholders, fmt.Sprintf("$%d", len(values)+1))
            values = append(values, v.Field(i).Interface())
        }
    }
    
    query := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s)",
        tableName,
        strings.Join(columns, ", "),
        strings.Join(placeholders, ", "),
    )
    
    _, err := db.Exec(query, values...)
    return err
}

func main() {
    db, err := sql.Open("postgres", "user=username password=password dbname=testdb sslmode=disable")
    if err != nil {
        panic(err)
    }
    defer db.Close()

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    err = insertStruct(db, "users", user)
    if err != nil {
        panic(err)
    }
}
```

## 4. Using Squirrel Query Builder

```go
package main

import (
    "database/sql"
    "github.com/Masterminds/squirrel"
    _ "github.com/lib/pq"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

func main() {
    db, err := sql.Open("postgres", "user=username password=password dbname=testdb sslmode=disable")
    if err != nil {
        panic(err)
    }
    defer db.Close()

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    psql := squirrel.StatementBuilder.PlaceholderFormat(squirrel.Dollar)
    
    query, args, err := psql.Insert("users").
        Columns("name", "email", "age").
        Values(user.Name, user.Email, user.Age).
        Suffix("RETURNING id").
        ToSql()
    
    if err != nil {
        panic(err)
    }
    
    var id int
    err = db.QueryRow(query, args...).Scan(&id)
    if err != nil {
        panic(err)
    }
    
    user.ID = id
}
```

## Recommendations:

1. **GORM**: Best for complex applications with relationships
2. **sqlx**: Good balance of simplicity and features
3. **Standard database/sql**: Maximum control, more boilerplate
4. **Squirrel**: Good for dynamic query building

Choose based on your project's complexity and requirements. GORM is the most popular choice for full-featured applications, while sqlx is great for simpler use cases.


---

### User

how about using pgx?


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user is asking about using pgx, which is a popular PostgreSQL driver for Go. pgx is known for being faster and more feature-rich than the standard lib/pq driver. Let me provide examples of how to insert structs using pgx.

I should cover:
1. Basic pgx usage with structs
2. Using pgx with named parameters
3. Using pgx with batch inserts
4. Using pgx with reflection for dynamic struct insertion
5. Maybe mention pgxpool for connection pooling
</details>

Great choice! **pgx** is an excellent PostgreSQL driver for Go - it's faster, more feature-rich, and has better PostgreSQL-specific support than lib/pq. Here are several ways to insert structs using pgx:

## 1. Basic pgx with Manual Mapping

```go
package main

import (
    "context"
    "github.com/jackc/pgx/v5"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
    Age   int    `json:"age"`
}

func main() {
    ctx := context.Background()
    
    conn, err := pgx.Connect(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer conn.Close(ctx)

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    query := `INSERT INTO users (name, email, age) VALUES ($1, $2, $3) RETURNING id`
    err = conn.QueryRow(ctx, query, user.Name, user.Email, user.Age).Scan(&user.ID)
    if err != nil {
        panic(err)
    }
}
```

## 2. Using pgx with Named Arguments

```go
package main

import (
    "context"
    "github.com/jackc/pgx/v5"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
    Age   int    `json:"age"`
}

func main() {
    ctx := context.Background()
    
    conn, err := pgx.Connect(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer conn.Close(ctx)

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    query := `INSERT INTO users (name, email, age) VALUES (@name, @email, @age) RETURNING id`
    args := pgx.NamedArgs{
        "name":  user.Name,
        "email": user.Email,
        "age":   user.Age,
    }
    
    err = conn.QueryRow(ctx, query, args).Scan(&user.ID)
    if err != nil {
        panic(err)
    }
}
```

## 3. Using pgx with Connection Pool

```go
package main

import (
    "context"
    "github.com/jackc/pgx/v5/pgxpool"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
    Age   int    `json:"age"`
}

func main() {
    ctx := context.Background()
    
    pool, err := pgxpool.New(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer pool.Close()

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    query := `INSERT INTO users (name, email, age) VALUES ($1, $2, $3) RETURNING id`
    err = pool.QueryRow(ctx, query, user.Name, user.Email, user.Age).Scan(&user.ID)
    if err != nil {
        panic(err)
    }
}
```

## 4. Dynamic Struct Insertion with Reflection

```go
package main

import (
    "context"
    "fmt"
    "reflect"
    "strings"
    "github.com/jackc/pgx/v5"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

func insertStruct(ctx context.Context, conn *pgx.Conn, tableName string, data interface{}) error {
    v := reflect.ValueOf(data)
    t := reflect.TypeOf(data)
    
    if v.Kind() == reflect.Ptr {
        v = v.Elem()
        t = t.Elem()
    }
    
    var columns []string
    var placeholders []string
    var values []interface{}
    
    for i := 0; i < v.NumField(); i++ {
        field := t.Field(i)
        tag := field.Tag.Get("db")
        
        if tag != "" && tag != "id" { // Skip ID for auto-increment
            columns = append(columns, tag)
            placeholders = append(placeholders, fmt.Sprintf("$%d", len(values)+1))
            values = append(values, v.Field(i).Interface())
        }
    }
    
    query := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s)",
        tableName,
        strings.Join(columns, ", "),
        strings.Join(placeholders, ", "),
    )
    
    _, err := conn.Exec(ctx, query, values...)
    return err
}

func main() {
    ctx := context.Background()
    
    conn, err := pgx.Connect(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer conn.Close(ctx)

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    err = insertStruct(ctx, conn, "users", user)
    if err != nil {
        panic(err)
    }
}
```

## 5. Batch Insert with pgx

```go
package main

import (
    "context"
    "github.com/jackc/pgx/v5"
)

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
    Age   int    `json:"age"`
}

func main() {
    ctx := context.Background()
    
    conn, err := pgx.Connect(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer conn.Close(ctx)

    users := []User{
        {Name: "John Doe", Email: "john@example.com", Age: 30},
        {Name: "Jane Smith", Email: "jane@example.com", Age: 25},
        {Name: "Bob Johnson", Email: "bob@example.com", Age: 35},
    }
    
    batch := &pgx.Batch{}
    query := `INSERT INTO users (name, email, age) VALUES ($1, $2, $3)`
    
    for _, user := range users {
        batch.Queue(query, user.Name, user.Email, user.Age)
    }
    
    results := conn.SendBatch(ctx, batch)
    defer results.Close()
    
    for i := 0; i < len(users); i++ {
        _, err := results.Exec()
        if err != nil {
            panic(err)
        }
    }
}
```

## 6. Using pgx with Scany (Third-party library)

```go
package main

import (
    "context"
    "github.com/georgysavva/scany/v2/pgxscan"
    "github.com/jackc/pgx/v5/pgxpool"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

func main() {
    ctx := context.Background()
    
    pool, err := pgxpool.New(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer pool.Close()

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    query := `INSERT INTO users (name, email, age) VALUES ($1, $2, $3) RETURNING *`
    rows, err := pool.Query(ctx, query, user.Name, user.Email, user.Age)
    if err != nil {
        panic(err)
    }
    defer rows.Close()
    
    var insertedUser User
    err = pgxscan.ScanOne(&insertedUser, rows)
    if err != nil {
        panic(err)
    }
}
```

## Advantages of pgx:

1. **Performance**: Faster than lib/pq
2. **PostgreSQL-specific features**: Better support for PostgreSQL types
3. **Connection pooling**: Built-in pgxpool
4. **Batch operations**: Efficient batch inserts
5. **Named parameters**: Cleaner query syntax
6. **Context support**: Full context.Context support

## Recommendations:

- Use **pgxpool** for production applications (connection pooling)
- Use **batch operations** for multiple inserts
- Consider **scany** library for easier struct scanning
- Use **named arguments** for better readability

pgx is definitely the way to go for PostgreSQL-specific applications in Go!


---

### User

So, I couldn't insert struct directly by using pgx?


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user is asking if they can insert a struct directly using pgx, and from their question it seems like they're expecting to be able to pass the entire struct as a parameter to the insert query, rather than having to extract individual fields manually.

Looking at the examples I provided, I showed manual field extraction, reflection-based approaches, and using named arguments, but none of these are truly "direct" struct insertion where you just pass the struct itself.

The truth is that pgx (and most SQL drivers) don't have built-in support for directly inserting structs. You always need some kind of mapping layer - either manual field extraction, reflection, or an ORM/query builder that handles the mapping for you.

However, there are some approaches that can make it feel more "direct":

1. Using reflection to automatically extract fields (which I showed)
2. Using a library that extends pgx with struct support
3. Using PostgreSQL's JSON capabilities to insert the entire struct as JSON
4. Using code generation to create insert functions

Let me clarify this for the user and show some additional approaches that might feel more "direct".
</details>

You're correct! **pgx doesn't support direct struct insertion out of the box**. You always need some form of mapping between struct fields and SQL parameters. However, there are several approaches to make it feel more "direct":

## 1. Using PostgreSQL's JSON Support (Most Direct)

```go
package main

import (
    "context"
    "encoding/json"
    "github.com/jackc/pgx/v5"
)

type User struct {
    Name  string `json:"name"`
    Email string `json:"email"`
    Age   int    `json:"age"`
}

func main() {
    ctx := context.Background()
    
    conn, err := pgx.Connect(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer conn.Close(ctx)

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    // Convert struct to JSON
    userJSON, err := json.Marshal(user)
    if err != nil {
        panic(err)
    }
    
    // Insert JSON directly
    query := `INSERT INTO users (data) VALUES ($1) RETURNING id`
    var id int
    err = conn.QueryRow(ctx, query, userJSON).Scan(&id)
    if err != nil {
        panic(err)
    }
}
```

## 2. Using pgx with a Helper Library (bun-like approach)

```go
package main

import (
    "context"
    "fmt"
    "reflect"
    "strings"
    "github.com/jackc/pgx/v5"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

// Helper function to make struct insertion feel more direct
func Insert[T any](ctx context.Context, conn *pgx.Conn, tableName string, data T) error {
    columns, placeholders, values := structToSQL(data)
    
    query := fmt.Sprintf("INSERT INTO %s (%s) VALUES (%s)",
        tableName,
        strings.Join(columns, ", "),
        strings.Join(placeholders, ", "),
    )
    
    _, err := conn.Exec(ctx, query, values...)
    return err
}

func structToSQL(data interface{}) ([]string, []string, []interface{}) {
    v := reflect.ValueOf(data)
    t := reflect.TypeOf(data)
    
    if v.Kind() == reflect.Ptr {
        v = v.Elem()
        t = t.Elem()
    }
    
    var columns []string
    var placeholders []string
    var values []interface{}
    
    for i := 0; i < v.NumField(); i++ {
        field := t.Field(i)
        tag := field.Tag.Get("db")
        
        if tag != "" && tag != "id" {
            columns = append(columns, tag)
            placeholders = append(placeholders, fmt.Sprintf("$%d", len(values)+1))
            values = append(values, v.Field(i).Interface())
        }
    }
    
    return columns, placeholders, values
}

func main() {
    ctx := context.Background()
    
    conn, err := pgx.Connect(ctx, "postgres://username:password@localhost/testdb")
    if err != nil {
        panic(err)
    }
    defer conn.Close(ctx)

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    // Now this feels more "direct"
    err = Insert(ctx, conn, "users", user)
    if err != nil {
        panic(err)
    }
}
```

## 3. Using Third-party Libraries for "Direct" Insertion

### Using Bun (Modern ORM with pgx support)

```go
package main

import (
    "context"
    "database/sql"
    "github.com/uptrace/bun"
    "github.com/uptrace/bun/dialect/pgdialect"
    "github.com/uptrace/bun/driver/pgdriver"
)

type User struct {
    ID    int    `bun:"id,pk,autoincrement"`
    Name  string `bun:"name"`
    Email string `bun:"email"`
    Age   int    `bun:"age"`
}

func main() {
    ctx := context.Background()
    
    pgdb := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN("postgres://username:password@localhost/testdb")))
    db := bun.NewDB(pgdb, pgdialect.New())
    defer db.Close()

    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    // Direct struct insertion!
    _, err := db.NewInsert().Model(&user).Exec(ctx)
    if err != nil {
        panic(err)
    }
}
```

### Using Rel (Another ORM)

```go
package main

import (
    "context"
    "github.com/go-rel/rel"
    "github.com/go-rel/postgres"
    _ "github.com/lib/pq"
)

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

func main() {
    ctx := context.Background()
    
    adapter, err := postgres.Open("postgres://username:password@localhost/testdb?sslmode=disable")
    if err != nil {
        panic(err)
    }
    defer adapter.Close()

    repo := rel.New(adapter)
    
    user := User{Name: "John Doe", Email: "john@example.com", Age: 30}
    
    // Direct struct insertion!
    err = repo.Insert(ctx, &user)
    if err != nil {
        panic(err)
    }
}
```

## 4. Using Code Generation

You can generate insertion functions from your structs:

```go
//go:generate go run generate_insert.go

type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

// Generated function would look like:
func (u *User) Insert(ctx context.Context, conn *pgx.Conn) error {
    query := `INSERT INTO users (name, email, age) VALUES ($1, $2, $3) RETURNING id`
    return conn.QueryRow(ctx, query, u.Name, u.Email, u.Age).Scan(&u.ID)
}
```

## Summary

**Pure pgx doesn't support direct struct insertion** - you need:

1. **Manual field extraction** (what I showed initially)
2. **Reflection-based helpers** (like my generic Insert function)
3. **JSON insertion** (if your table supports JSONB columns)
4. **ORMs/Query builders** (Bun, GORM, Rel, etc.)
5. **Code generation**

The closest to "direct" insertion while still using pgx would be the reflection-based helper or using an ORM that supports pgx as the underlying driver (like Bun).


---

### User

Which library support directly insert struct to table?


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user is asking which libraries support directly inserting a struct to a table without having to manually map fields. Let me think about the various Go libraries that support this:

1. GORM - definitely supports this
2. Bun - supports this
3. Ent - supports this
4. sqlx - doesn't directly support struct insertion, but has good struct scanning
5. Rel - supports this
6. SQLBoiler - generates code but supports direct operations
7. Upper/db - supports this
8. Xo - code generation
9. Reform - supports this
10. Bob - supports this

I should categorize these and provide examples of the ones that truly support direct struct insertion.
</details>

Here are the Go libraries that support **direct struct insertion** to PostgreSQL tables:

## 1. **GORM** (Most Popular)

```go
type User struct {
    ID    uint   `gorm:"primaryKey"`
    Name  string
    Email string
    Age   int
}

// Direct insertion
db.Create(&user)
```

## 2. **Bun** (Modern, Fast)

```go
type User struct {
    ID    int    `bun:"id,pk,autoincrement"`
    Name  string
    Email string
    Age   int
}

// Direct insertion
db.NewInsert().Model(&user).Exec(ctx)
```

## 3. **Ent** (Facebook's ORM)

```go
// After schema generation
client.User.Create().
    SetName("John").
    SetEmail("john@example.com").
    SetAge(30).
    Save(ctx)

// Or with struct-like approach
client.User.Create().
    SetUser(&user).
    Save(ctx)
```

## 4. **Upper/db** 

```go
type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

// Direct insertion
sess.Collection("users").Insert(user)
```

## 5. **go-rel/rel**

```go
type User struct {
    ID    int
    Name  string
    Email string
    Age   int
}

// Direct insertion
repo.Insert(ctx, &user)
```

## 6. **Bob** (Query Builder)

```go
type User struct {
    ID    int    `db:"id"`
    Name  string `db:"name"`
    Email string `db:"email"`
    Age   int    `db:"age"`
}

// Direct insertion
psql.Insert(
    sm.Into("users"),
    sm.Values(user),
).Exec(ctx, db)
```

## 7. **SQLBoiler** (Code Generation)

```go
// Generated models support direct insertion
user := models.User{
    Name:  "John",
    Email: "john@example.com",
    Age:   30,
}

user.Insert(ctx, db, boil.Infer())
```

## 8. **Reform** 

```go
//go:generate reform

//reform:users
type User struct {
    ID    int32  `reform:"id,pk"`
    Name  string `reform:"name"`
    Email string `reform:"email"`
    Age   int32  `reform:"age"`
}

// Direct insertion
db.Insert(&user)
```

## 9. **Kallax** (Archived but still works)

```go
//go:generate kallax gen

type User struct {
    kallax.Model
    Name  string
    Email string
    Age   int
}

// Direct insertion
store.Insert(&user)
```

## **Comparison Table:**

| Library | Direct Insert | Learning Curve | Performance | PostgreSQL Support |
|---------|---------------|----------------|-------------|---------------------|
| **GORM** | ✅ | Easy | Good | Excellent |
| **Bun** | ✅ | Medium | Very Good | Excellent |
| **Ent** | ✅ | Hard | Good | Excellent |
| **Upper/db** | ✅ | Medium | Good | Good |
| **go-rel** | ✅ | Easy | Good | Good |
| **Bob** | ✅ | Medium | Good | Excellent |
| **SQLBoiler** | ✅ | Hard | Very Good | Excellent |
| **Reform** | ✅ | Medium | Good | Good |

## **My Recommendations:**

### **For Beginners:**
```go
// GORM - Easiest to start with
db.Create(&user)
```

### **For Performance-Critical Apps:**
```go
// Bun - Best balance of performance and features
db.NewInsert().Model(&user).Exec(ctx)
```

### **For Complex Schemas:**
```go
// Ent - Best for complex relationships
client.User.Create().SetUser(&user).Save(ctx)
```

### **For Type Safety:**
```go
// SQLBoiler - Generated code with full type safety
user.Insert(ctx, db, boil.Infer())
```

## **Quick Setup Examples:**

### GORM:
```bash
go get gorm.io/gorm
go get gorm.io/driver/postgres
```

### Bun:
```bash
go get github.com/uptrace/bun
go get github.com/uptrace/bun/driver/pgdriver
```

### Ent:
```bash
go get entgo.io/ent/cmd/ent
```

**Bottom Line:** If you want the **simplest direct struct insertion**, go with **GORM**. If you want **performance + direct insertion**, choose **Bun**. If you want **type safety + code generation**, pick **SQLBoiler**.


---

### User

I would like to use Bun.
Can you create snippet?


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants to use Bun for direct struct insertion. I should create a comprehensive snippet that shows:

1. Installation/setup
2. Basic struct definition with Bun tags
3. Database connection
4. Direct struct insertion
5. Maybe some additional useful operations like select, update, etc.

I'll make it practical and complete.
</details>

Absolutely! Here's a comprehensive Bun snippet for direct struct insertion:

## Installation

```bash
go get github.com/uptrace/bun
go get github.com/uptrace/bun/driver/pgdriver
go get github.com/uptrace/bun/dialect/pgdialect
```

## Complete Example

```go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "log"
    "time"

    "github.com/uptrace/bun"
    "github.com/uptrace/bun/dialect/pgdialect"
    "github.com/uptrace/bun/driver/pgdriver"
)

// User struct with Bun tags
type User struct {
    ID        int       `bun:"id,pk,autoincrement"`
    Name      string    `bun:"name,notnull"`
    Email     string    `bun:"email,unique,notnull"`
    Age       int       `bun:"age"`
    CreatedAt time.Time `bun:"created_at,nullzero,notnull,default:current_timestamp"`
    UpdatedAt time.Time `bun:"updated_at,nullzero,notnull,default:current_timestamp"`
}

func main() {
    ctx := context.Background()

    // Database connection
    dsn := "postgres://username:password@localhost:5432/testdb?sslmode=disable"
    sqldb := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(dsn)))
    
    db := bun.NewDB(sqldb, pgdialect.New())
    defer db.Close()

    // Optional: Enable query logging
    db.AddQueryHook(bundebug.NewQueryHook(bundebug.WithVerbose(true)))

    // Create table (optional - you can skip this if table exists)
    _, err := db.NewCreateTable().Model((*User)(nil)).IfNotExists().Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }

    // 1. Insert single struct
    user := User{
        Name:  "John Doe",
        Email: "john@example.com",
        Age:   30,
    }

    _, err = db.NewInsert().Model(&user).Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Inserted user with ID: %d\n", user.ID)

    // 2. Insert multiple structs
    users := []User{
        {Name: "Jane Smith", Email: "jane@example.com", Age: 25},
        {Name: "Bob Johnson", Email: "bob@example.com", Age: 35},
        {Name: "Alice Brown", Email: "alice@example.com", Age: 28},
    }

    _, err = db.NewInsert().Model(&users).Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Inserted %d users\n", len(users))

    // 3. Insert with returning specific columns
    newUser := User{
        Name:  "Charlie Wilson",
        Email: "charlie@example.com",
        Age:   32,
    }

    _, err = db.NewInsert().
        Model(&newUser).
        Returning("id, created_at").
        Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("New user ID: %d, Created: %v\n", newUser.ID, newUser.CreatedAt)

    // 4. Insert with ON CONFLICT (upsert)
    conflictUser := User{
        Name:  "John Doe Updated",
        Email: "john@example.com", // This will conflict
        Age:   31,
    }

    _, err = db.NewInsert().
        Model(&conflictUser).
        On("CONFLICT (email) DO UPDATE").
        Set("name = EXCLUDED.name").
        Set("age = EXCLUDED.age").
        Set("updated_at = EXCLUDED.updated_at").
        Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println("Upserted user successfully")

    // 5. Bulk insert with better performance
    bigUsers := make([]User, 1000)
    for i := range bigUsers {
        bigUsers[i] = User{
            Name:  fmt.Sprintf("User %d", i),
            Email: fmt.Sprintf("user%d@example.com", i),
            Age:   20 + (i % 50),
        }
    }

    _, err = db.NewInsert().Model(&bigUsers).Exec(ctx)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Bulk inserted %d users\n", len(bigUsers))
}
```

## Advanced Features

### 1. Custom Insert with Validation

```go
func InsertUserWithValidation(ctx context.Context, db *bun.DB, user *User) error {
    // Validation before insert
    if user.Name == "" {
        return fmt.Errorf("name cannot be empty")
    }
    if user.Age < 0 {
        return fmt.Errorf("age cannot be negative")
    }

    // Insert with custom logic
    _, err := db.NewInsert().
        Model(user).
        On("CONFLICT (email) DO NOTHING").
        Returning("*").
        Exec(ctx)
    
    return err
}
```

### 2. Insert with Transactions

```go
func InsertUsersWithTransaction(ctx context.Context, db *bun.DB, users []User) error {
    tx, err := db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()

    for _, user := range users {
        _, err := tx.NewInsert().Model(&user).Exec(ctx)
        if err != nil {
            return err
        }
    }

    return tx.Commit()
}
```

### 3. Insert with Custom Query

```go
func InsertUserCustom(ctx context.Context, db *bun.DB, user *User) error {
    query := db.NewInsert().
        Model(user).
        Where("NOT EXISTS (SELECT 1 FROM users WHERE email = ?)", user.Email).
        Returning("*")

    _, err := query.Exec(ctx)
    return err
}
```

### 4. Complete Setup with Environment Variables

```go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "os"

    "github.com/uptrace/bun"
    "github.com/uptrace/bun/dialect/pgdialect"
    "github.com/uptrace/bun/driver/pgdriver"
    "github.com/uptrace/bun/extra/bundebug"
)

func setupDatabase() *bun.DB {
    dsn := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
        getEnv("DB_USER", "postgres"),
        getEnv("DB_PASSWORD", "password"),
        getEnv("DB_HOST", "localhost"),
        getEnv("DB_PORT", "5432"),
        getEnv("DB_NAME", "testdb"),
    )

    sqldb := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(dsn)))
    db := bun.NewDB(sqldb, pgdialect.New())

    // Add query hook for development
    if getEnv("ENV", "development") == "development" {
        db.AddQueryHook(bundebug.NewQueryHook(bundebug.WithVerbose(true)))
    }

    return db
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func main() {
    ctx := context.Background()
    db := setupDatabase()
    defer db.Close()

    user := User{
        Name:  "Test User",
        Email: "test@example.com",
        Age:   25,
    }

    // Direct struct insertion!
    _, err := db.NewInsert().Model(&user).Exec(ctx)
    if err != nil {
        panic(err)
    }

    fmt.Printf("Successfully inserted user with ID: %d\n", user.ID)
}
```

## Key Bun Features:

1. **Direct struct insertion**: `db.NewInsert().Model(&user).Exec(ctx)`
2. **Automatic ID return**: The ID is automatically populated after insert
3. **Bulk operations**: Insert multiple structs at once
4. **Upsert support**: Handle conflicts gracefully
5. **Transaction support**: Full transaction capabilities
6. **Query hooks**: Built-in debugging and logging
7. **Type safety**: Compile-time type checking

This should give you everything you need to get started with Bun for direct struct insertion!


---
