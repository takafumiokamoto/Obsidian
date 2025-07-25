# Java configuration with .properties and JSON
Created: 7/25/2025, 4:36:09 PM
Last Updated: 7/25/2025, 4:40:08 PM
---

### User

Why Java tend to use .properties to configuration?
Is it able to use json?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Examining the Query's Focus**

I've initiated this thought process by dissecting the user's query. I'm focusing on the core question: why Java leans towards .properties files for configuration, and the secondary query about JSON's compatibility. I'm exploring the implications of "tends to use" in the user's initial query. This will lead to the next stage of my thoughts, focusing on the history of configuration files.


**Unpacking Historical Influences**

I'm now thinking about the historical context. Java's age and its enterprise focus significantly shaped its early preference for `.properties` files. The Java standard library's built-in `Properties` class, established early on, provided a straightforward, dependency-free solution. This simplicity and the "write once, run anywhere" philosophy further solidified their adoption. I'm starting to explore alternatives, like XML, that were common at the time.


**Investigating Alternative Formats**

I'm now delving into alternatives to `.properties` files. While XML was prevalent initially, its verbosity and complexity stand in stark contrast to the simplicity of `.properties`. JSON, gaining momentum later, offered a more concise and readable format. However, the initial focus on simplicity and the availability of the `Properties` class solidified the use of `.properties` files for early Java configurations.


**Examining JSON Compatibility**

Now, I'm diving into the second part of the query: Java's compatibility with JSON. My thoughts are shifting toward the role of external libraries, as JSON isn't natively supported in the same way as `.properties`. I'm starting to consider specific Java libraries like Jackson and Gson. These third-party solutions are integral for handling JSON parsing and serialization within Java projects.


**Analyzing Libraries' Relevance**

I'm now delving into the Java libraries that facilitate JSON use. Jackson, Gson, and JSON-B are the frontrunners, each offering distinct features and levels of integration. Jackson's flexibility is notable, while Gson is praised for its simplicity. JSON-B provides a more standardized approach. I'm considering their respective strengths and weaknesses.


**Revising Configuration Formats**

My thinking is now shifting to more modern configuration approaches. While `.properties` files remain prevalent, I'm considering the strengths of alternatives like YAML and JSON, especially in Spring Boot. I'm focusing on how these formats offer improved readability, and I'm planning to contrast their key advantages over `.properties` files.


**Exploring Configuration Modernization**

I'm now thinking about modern configuration paradigms. While .properties files still have a strong foothold, I'm examining modern alternatives like JSON and YAML. My focus is on their improved readability and hierarchical data structures. The current train of thought is to compare their advantages with the traditional format to provide developers with more knowledge.



</details>

Of course. That's an excellent question that gets to the heart of Java's history and evolution.

The tendency for Java to use `.properties` files for configuration is primarily due to two factors: **historical context** and **built-in simplicity**.

Let's break down why `.properties` became the standard, and then we'll cover using JSON.

### Why `.properties` Files are Traditional in Java

#### 1. Historical Context & The Standard Library
Java was first released in 1995. At that time, formats like JSON (popularized in the early 2000s) and YAML didn't exist or weren't mainstream. The common, simple way to store configuration was in plain text key-value files.

Crucially, the Java Development Kit (JDK) included a built-in class specifically for this purpose: `java.util.Properties`.

```java
// This has been in Java since version 1.0!
java.util.Properties props = new java.util.Properties();
```

Because this functionality was part of the standard library, developers could read configuration files **without adding any external libraries or dependencies**. This was a huge advantage, aligning with Java's "write once, run anywhere" philosophy. You could count on the `Properties` class being available on any machine with a Java Virtual Machine (JVM).

#### 2. Simplicity
The `.properties` format is extremely simple for both humans and machines.

*   **Format:** It's a list of key-value pairs, separated by an equals sign (`=`) or a colon (`:`).
*   **Comments:** Lines starting with `#` or `!` are comments.
*   **Parsing:** The parsing logic is trivial, which is why it was easy to implement in the standard library.

Here is a typical example of a `database.properties` file:
```properties
# Database Connection Settings
db.url=jdbc:mysql://localhost:3306/mydatabase
db.user=admin
db.password=secret_password

# Connection Pool Settings
db.pool.max_size=20
```

#### 3. Internationalization (i18n)
The `.properties` format is also the foundation of Java's standard internationalization framework. The `java.util.ResourceBundle` class is designed to load `.properties` files based on the user's locale.

For example, you might have:
*   `messages_en_US.properties` (for American English)
*   `messages_fr_FR.properties` (for French)
*   `messages.properties` (a default fallback)

Java can automatically load the correct file, making it easy to support multiple languages.

***

### Yes, You Can Absolutely Use JSON for Configuration

While `.properties` files are traditional, using **JSON for configuration in modern Java is extremely common and well-supported.**

Modern applications often have more complex, hierarchical configuration needs that are a perfect fit for JSON's structure (objects and arrays). The simple key-value structure of `.properties` can become clumsy for these scenarios.

#### How to Use JSON in Java
Since JSON parsing is not built into the core Java SE library like the `Properties` class is, you need to use a third-party library. The most popular ones are:

1.  **Jackson:** The de facto standard for JSON processing in the Java ecosystem. It's incredibly powerful, fast, and flexible. Frameworks like Spring Boot use it by default.
2.  **Gson:** A library from Google that is very easy to use, especially for converting Java objects to/from their JSON representation.
3.  **JSON-B:** The official Java EE / Jakarta EE standard for JSON binding. It provides a standard API that can be implemented by different providers.

#### Example: Using Jackson to Read a JSON Config

Let's say you have a `config.json` file:

```json
{
  "database": {
    "url": "jdbc:postgresql://localhost:5432/webapp",
    "user": "db_user",
    "poolSize": 15
  },
  "apiKeys": ["key1-abc", "key2-def"],
  "featureFlags": {
    "enableNewDashboard": true
  }
}
```

You would add the Jackson dependency to your project.

**Maven Dependency:**
```xml
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-databind</artifactId>
    <version>2.17.1</version>
</dependency>
```

And then you could easily parse it in your Java code:

```java
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;
import java.io.IOException;

public class JsonConfigExample {

  public static void main(String[] args) {
    ObjectMapper mapper = new ObjectMapper();
    try {
      // Read the JSON file and parse it into a tree of nodes
      JsonNode rootNode = mapper.readTree(new File("config.json"));

      // Access values using a path
      String dbUrl = rootNode.path("database").path("url").asText();
      int poolSize = rootNode.path("database").path("poolSize").asInt();
      boolean isDashboardEnabled = rootNode
        .path("featureFlags")
        .path("enableNewDashboard")
        .asBoolean();

      System.out.println("Database URL: " + dbUrl);
      System.out.println("Pool Size: " + poolSize);
      System.out.println("Dashboard Enabled: " + isDashboardEnabled);

    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}
```

### Summary: `.properties` vs. JSON

| Feature | `.properties` | JSON |
| :--- | :--- | :--- |
| **Format** | Simple key-value pairs. | Hierarchical (objects, arrays). |
| **Data Structure** | Flat. Nesting is faked with dot notation (e.g., `db.pool.size`). | Naturally nested and complex. |
| **Data Types** | All values are read as Strings and must be manually converted. | Supports native types (string, number, boolean, array, object). |
| **Standard Library** | **Yes** (`java.util.Properties`). No external dependencies needed. | **No**. Requires an external library like Jackson or Gson. |
| **Common Use Cases** | Simple configs, database credentials, feature flags, internationalization. | Complex configs, REST API communication, structured data exchange. |
| **Modern Frameworks** | Still widely supported (e.g., Spring Boot's `application.properties`). | First-class support (e.g., Spring Boot also supports `application.json` or `application.yml`). |

**Conclusion:** Java's use of `.properties` is a legacy of its long history and the convenience of its standard library. For modern, complex applications, **JSON (and YAML) are often a better choice** and are fully supported by the modern Java ecosystem.


---

### User

How to bind properties to bean?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Examining the Core Problem**

I've initiated a thorough deconstruction of the user's query, pinpointing "bind," "properties," and "bean" as the pivotal terms. My focus now centers on the inherent relationship between these elements within a Java/Spring framework, striving to craft a precise, expert-level response.


**Unpacking the User's Intent**

I'm now zeroing in on the nuanced meaning of "bind."  It seems the user wants an automated process to link properties, not a manual approach. Therefore, I must elucidate the *how* of automatic configuration. I have identified Spring Boot's Configuration Properties as the key concept to be explained.


**Delving into Spring Boot**

I've progressed past the initial deconstruction and am now meticulously outlining the key components for the Spring Boot example. I'm focusing on crafting a step-by-step guide that is clear and easy to follow, detailing how to bind properties using Spring Boot's configuration capabilities. I'm aiming for practical utility.

**Expanding the Scope**

I've expanded my perspective and am now preparing to address validation concerns, recognizing its crucial role in robust property binding. I'm exploring Jakarta Bean Validation annotations. I will also incorporate alternatives for those not using Spring.


**Outlining the Spring Boot Example**

I'm now deep into crafting the Spring Boot example, meticulously developing the `application.properties` and the corresponding `ApiProperties` class. I will include validation annotations, ensuring a robust and practical demonstration. I'm focusing on clarity and ease of adaptation for the user, crafting the explanation with the expert in mind. I am also considering how to present the Lombok option.


**Developing the Spring Example**

I'm presently building the Spring Boot example, meticulously crafting the `application.properties` file and the `ApiProperties` class. I will include validation annotations for robustness. The guide will be crafted with clarity and ease of adaptation for the user, with the expert in mind. I am also planning how to include a Lombok option, to demonstrate it's value.


**Developing the Example Code**

I'm deep into the Spring Boot example, crafting both the `application.properties` file and the `ApiProperties` class. I've included the necessary validation annotations to ensure a practical, robust demonstration. My focus is on clarity and ease of adaptation, keeping the expert in mind. I'm also planning to incorporate a Lombok option to showcase its value. The MicroProfile and manual Java parts are planned.


**Synthesizing a Comprehensive Answer**

I'm synthesizing the steps outlined above into a comprehensive, informative response. I will now integrate the outlined code examples, focusing on clear, concise explanations and highlighting the advantages of the Spring Boot approach. My goal is to deliver an easily understandable, practical guide.



</details>

Excellent question. Binding properties to a bean (a Java object) is a fundamental practice in modern Java development, especially when using frameworks like Spring. It's the key to creating **type-safe, maintainable, and easy-to-use configuration**.

Let's walk through how this is done, focusing on the most common approach: using the **Spring Boot framework**.

### The Core Idea: From Text to a Java Object

The goal is to automatically take flat text properties like this:

**`application.properties`**
```properties
app.name=My Awesome App
app.server.port=8080
app.feature.enable-new-ui=true
app.security.allowed-roles=ADMIN,USER,GUEST
```

And "bind" them to the fields of a structured Java class, like this:

```java
// This is our target "bean"
public class AppProperties {
    private String name;
    private Server server;
    private Feature feature;
    private Security security;
    // ... getters and setters
}
```

This avoids error-prone manual lookups like `properties.getProperty("app.server.port")` and provides compile-time safety and IDE autocompletion.

---

### How to Bind Properties in Spring Boot (The Standard Way)

Here is a step-by-step guide.

#### Step 1: Add the Necessary Dependency

If you're using Spring Boot, you need the `spring-boot-configuration-processor`. This is an annotation processor that generates metadata for your properties, giving you excellent autocompletion in your IDE.

**Maven:**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

#### Step 2: Create the Properties Class (The Bean)

Create a POJO (Plain Old Java Object) that mirrors the structure of your properties.

*   Use a **prefix** to group related properties.
*   Use **nested classes** for hierarchical data.
*   Spring Boot is smart about matching names (e.g., `enable-new-ui` in properties maps to `enableNewUi` in Java).

```java
import org.springframework.boot.context.properties.ConfigurationProperties;
import java.util.List;

// This annotation tells Spring to bind properties starting with "app"
@ConfigurationProperties(prefix = "app")
public class AppProperties {

    private String name;
    private final Server server = new Server();
    private final Feature feature = new Feature();
    private final Security security = new Security();

    // Nested class for "app.server.*" properties
    public static class Server {
        private int port;
        // getter and setter
        public int getPort() { return port; }
        public void setPort(int port) { this.port = port; }
    }

    // Nested class for "app.feature.*" properties
    public static class Feature {
        private boolean enableNewUi;
        // getter and setter
        public boolean isEnableNewUi() { return enableNewUi; }
        public void setEnableNewUi(boolean enableNewUi) { this.enableNewUi = enableNewUi; }
    }

    // Nested class for "app.security.*" properties
    public static class Security {
        private List<String> allowedRoles;
        // getter and setter
        public List<String> getAllowedRoles() { return allowedRoles; }
        public void setAllowedRoles(List<String> allowedRoles) { this.allowedRoles = allowedRoles; }
    }

    // Getters and setters for top-level properties and nested objects
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Server getServer() { return server; }
    public Feature getFeature() { return feature; }
    public Security getSecurity() { return security; }
}
```
**Note:** You must provide getters and setters for the fields you want to bind. Using a library like Lombok with `@Data` or `@Getter`/`@Setter` can reduce this boilerplate.

#### Step 3: Enable the Configuration Properties

You need to tell Spring to find your `@ConfigurationProperties` class and register it as a bean. You have two primary ways to do this:

**Method A (Recommended): Use `@EnableConfigurationProperties`**

This is the cleanest and most explicit approach. You add this annotation to one of your `@Configuration` classes (like your main application class).

```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
// This enables the binding for the specified class(es)
@EnableConfigurationProperties(AppProperties.class)
public class MyApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```

**Method B: Use `@Component`**

Alternatively, you can annotate your properties class directly with `@Component`. Spring's component scanning will then find it and register it.

```java
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component // Spring will find this during component scanning
@ConfigurationProperties(prefix = "app")
public class AppProperties {
    // ... same fields and methods as before
}
```

#### Step 4: Inject and Use the Bean

Now you can inject your fully-populated `AppProperties` bean anywhere in your application using standard dependency injection. Constructor injection is the recommended practice.

```java
import org.springframework.stereotype.Service;

@Service
public class MyService {

    private final AppProperties appProperties;

    // Inject the properties bean via the constructor
    public MyService(AppProperties appProperties) {
        this.appProperties = appProperties;
    }

    public void doSomething() {
        System.out.println("Application Name: " + appProperties.getName());

        int port = appProperties.getServer().getPort();
        System.out.println("Server Port: " + port);

        if (appProperties.getFeature().isEnableNewUi()) {
            System.out.println("The new UI is enabled!");
        }

        System.out.println(
            "Allowed Roles: " + appProperties.getSecurity().getAllowedRoles()
        );
    }
}
```

### Adding Validation

One of the biggest advantages of this approach is that you can add validation. If a required property is missing or invalid, the application will fail to start with a clear error message.

1.  **Add the validation starter:**

    ```xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    ```

2.  **Annotate your properties class:**

    ```java
    import jakarta.validation.constraints.Min;
    import jakarta.validation.constraints.NotEmpty;
    import jakarta.validation.constraints.NotNull;
    import org.springframework.boot.context.properties.ConfigurationProperties;
    import org.springframework.validation.annotation.Validated;

    @ConfigurationProperties(prefix = "app")
    @Validated // Enable validation on this bean
    public class AppProperties {

        @NotEmpty // Fails if app.name is empty or not present
        private String name;

        // ...

        public static class Server {
            @Min(1024) // Port must be 1024 or higher
            private int port;
            // ...
        }
    }
    ```

### Summary: Why Bind Properties to a Bean?

*   **Type Safety:** You get real Java types (`int`, `boolean`, `List`), not just `String`s. This prevents runtime parsing errors.
*   **IDE Support:** With the configuration processor, you get autocompletion and documentation for your properties right in your `.properties` or `.yml` file.
*   **Validation:** You can enforce rules on your configuration at application startup.
*   **Maintainability:** Grouping related properties into a class makes the code cleaner and easier to refactor.
*   **Decoupling:** The code that *uses* the configuration doesn't need to know the exact property keys or where they come from (file, environment variable, etc.).


---

### User

I am not using Spring Boot. 
Also , I would like to switch properties by environment variable when reading


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Examining the Core Task**

I've zeroed in on the core task: property binding to a bean. The initial constraint – no Spring Boot – is clear. I'm focusing on alternatives, evaluating pure Java approaches for environment-based configuration switching. I'm moving toward identifying essential steps to fulfill the user's needs outside the Spring Boot ecosystem.


**Dissecting the Constraints**

I'm now fully immersed in the constraints. The focus is on the impact of "no Spring Boot" and environment-based property switching. I'm exploring the nuances of handling properties with pure Java and devising a strategy for manual binding. I'm actively considering ways to select and load properties dynamically based on external variables.


**Mapping the Solution Path**

I'm now charting the solution path. My focus is on manual binding, using `java.util.Properties` as a base. I'm exploring Apache Commons Configuration and OWNER as potential enhancements to ease the binding process. I'm also considering the format aspects: while the question is about .properties, I'm noting potential for JSON/YAML via Jackson/Gson, but keeping the current requirement's priority in mind.


**Outlining the Core Elements**

I've outlined the essential elements of the answer. Manual binding using `java.util.Properties` will be key to demonstrating the fundamental approach. I'll showcase how to read properties, map them to a POJO, and handle type conversion. I'm also considering the integration of a lightweight library like Owner for a more streamlined solution.

I'll structure the response into a clear section for environment-specific configuration and the selected approach.


**Developing the Code Structure**

I'm solidifying the code structure. I'll provide a clear example of environment switching using a utility class, independent of the binding approach. Then, I'll demonstrate manual binding with `Properties` and a contrasting Owner-based method, highlighting the pros and cons. I'll maintain a logical flow for ease of understanding.


**Streamlining the Approach**

I'm now streamlining the code structure. I'll include a simple utility for environment-based property file selection, followed by the manual `Properties`-based binding. I'll then demonstrate a much cleaner solution using the Owner library, highlighting the benefits of each approach. The structure will be clear and the code concise.

I've also decided to use `File` instead of `InputStream` in the loading logic for better clarity in error handling and property file path management.


**Structuring the Response**

I'm now structuring the response based on the outlined strategy. I will provide a clear section for environment-specific configuration and then compare manual binding versus the Owner library. I'll include a code example of `java.util.Properties` manual binding and then one using Owner. Both samples will use the environment switching utility for property file loading.

I'm aiming for concise code and clear explanations.


**Formulating the Response Structure**

I've established the structure. It starts with a utility for environment-based file loading, which the manual binding and Owner examples will utilize. I'll include thorough explanations.
I'll also showcase the manual binding with `java.util.Properties` and then introduce the cleaner OWNER approach.
Both examples will be included, and I will highlight their key differences.

I'm aiming for clean, understandable code and concise explanations.



</details>

Excellent. This is a very practical and common scenario in non-Spring environments or in projects where you want to maintain minimal dependencies.

Let's break this down into two parts:
1.  **The logic for switching properties based on an environment variable.**
2.  **How to bind those properties to a bean (a Java object) without Spring.**

We'll cover two main approaches for the binding part: a pure Java manual approach and a much cleaner approach using a lightweight library.

---

### Part 1: Switching Properties by Environment Variable

This is the foundation. The goal is to load a different `.properties` file based on an external setting. A common convention is to have an environment variable, say `APP_ENV`, which can be set to `dev`, `staging`, `prod`, etc.

Your properties files would be named accordingly:
*   `config-dev.properties`
*   `config-staging.properties`
*   `config-prod.properties`
*   `config.properties` (as a fallback or for common values)

Here is a robust Java method to get the correct properties file as a stream. You would place this in a utility class, for example, `ConfigLoader`.

```java
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class ConfigLoader {

    /**
     * Loads properties from a file specified by the APP_ENV environment variable.
     * Falls back to a default file if the specific one is not found.
     *
     * @return A populated Properties object.
     * @throws IOException if the default properties file cannot be read.
     */
    public static Properties loadProperties() throws IOException {
        // 1. Determine the filename
        String env = System.getenv("APP_ENV"); // e.g., "dev", "prod"
        String fileName = (env != null && !env.isEmpty())
            ? "config-" + env + ".properties"
            : "config.properties";

        System.out.println("Attempting to load configuration from: " + fileName);

        Properties properties = new Properties();

        // 2. Try to load the environment-specific file
        InputStream inputStream =
            ConfigLoader.class.getClassLoader().getResourceAsStream(fileName);

        // 3. If not found, fall back to the default config.properties
        if (inputStream == null) {
            System.out.println(
                "Could not find " +
                fileName +
                ", falling back to config.properties"
            );
            inputStream = ConfigLoader.class
                .getClassLoader()
                .getResourceAsStream("config.properties");
            if (inputStream == null) {
                throw new FileNotFoundException(
                    "Default config.properties file not found in classpath."
                );
            }
        }

        // 4. Load the properties from the input stream
        properties.load(inputStream);
        return properties;
    }
}
```

---

### Part 2: Binding Properties to a Bean

Now that we have a `Properties` object, let's bind it to a POJO.

#### Approach 1: The Pure Java (Manual) Method

This approach requires no external libraries but involves writing boilerplate code to manually map each property.

**Step 1: Create your configuration bean (POJO).**

```java
// AppConfig.java
public class AppConfig {
    private String appName;
    private String apiUrl;
    private int timeoutSeconds;
    private boolean featureEnabled;

    // Getters and Setters for all fields...
    public String getAppName() { return appName; }
    public void setAppName(String appName) { this.appName = appName; }
    public String getApiUrl() { return apiUrl; }
    public void setApiUrl(String apiUrl) { this.apiUrl = apiUrl; }
    public int getTimeoutSeconds() { return timeoutSeconds; }
    public void setTimeoutSeconds(int timeoutSeconds) { this.timeoutSeconds = timeoutSeconds; }
    public boolean isFeatureEnabled() { return featureEnabled; }
    public void setFeatureEnabled(boolean featureEnabled) { this.featureEnabled = featureEnabled; }
}
```

**Step 2: Manually populate the bean.**

You would extend your `ConfigLoader` to include a method that creates and populates the `AppConfig` object.

```java
// Inside the ConfigLoader class or another factory class
public static AppConfig createConfigBean() throws IOException {
    Properties props = loadProperties(); // Use the method from Part 1

    AppConfig config = new AppConfig();

    // Manually get each property and set it on the bean
    config.setAppName(props.getProperty("app.name"));
    config.setApiUrl(props.getProperty("api.url"));

    // Handle type conversion and provide defaults
    String timeoutStr = props.getProperty("api.timeout.seconds", "30");
    config.setTimeoutSeconds(Integer.parseInt(timeoutStr));

    String featureFlag = props.getProperty("feature.x.enabled", "false");
    config.setFeatureEnabled(Boolean.parseBoolean(featureFlag));

    return config;
}
```

**Drawbacks of this method:**
*   **Boilerplate:** You have to write `getProperty` and `set...` for every single field.
*   **Not Type-Safe:** Everything is a `String` initially. You are responsible for parsing to `int`, `boolean`, etc., which can cause `NumberFormatException` and other runtime errors.
*   **Error-Prone:** A typo in the property key string (`"app.nane"`) won't be caught by the compiler.

---

#### Approach 2: The Lightweight Library Method (Recommended)

A much better way is to use a library designed specifically for this. My top recommendation for a non-Spring project is **Owner (OWNER - Object-Oriented Properties)**. It's tiny, fast, and does exactly what you want with minimal code.

**Step 1: Add the Owner dependency.**

**Maven:**
```xml
<dependency>
    <groupId>org.aeonbits.owner</groupId>
    <artifactId>owner</artifactId>
    <version>1.0.12</version>
</dependency>
```

**Step 2: Create your configuration bean as an `interface`.**

This is the magic of Owner. You define an interface, not a class.

```java
import org.aeonbits.owner.Config;

// AppConfig.java
@Config.LoadPolicy(Config.LoadType.MERGE) // Allows merging multiple sources
public interface AppConfig extends Config {

    @Key("app.name")
    @DefaultValue("My Default App Name")
    String appName();

    @Key("api.url")
    String apiUrl();

    @Key("api.timeout.seconds")
    @DefaultValue("30")
    int timeoutSeconds();

    @Key("feature.x.enabled")
    @DefaultValue("false")
    boolean isFeatureEnabled();
}
```

**Step 3: Load the properties and bind them using Owner's `ConfigFactory`.**

Now, we combine our environment-switching logic from Part 1 with the power of Owner.

```java
import org.aeonbits.owner.ConfigFactory;
import java.io.IOException;
import java.util.Properties;

public class MainApplication {

    public static void main(String[] args) throws IOException {
        // 1. Load properties using our environment-aware loader
        Properties props = ConfigLoader.loadProperties();

        // 2. Use Owner's ConfigFactory to create a type-safe config object
        // It will use our loaded properties as the source.
        AppConfig config = ConfigFactory.create(AppConfig.class, props);

        // 3. Use the bean! It's fully populated and type-safe.
        System.out.println("Application Name: " + config.appName());
        System.out.println("API URL: " + config.apiUrl());
        System.out.println("Timeout: " + config.timeoutSeconds());

        if (config.isFeatureEnabled()) {
            System.out.println("Feature X is ON!");
        } else {
            System.out.println("Feature X is OFF.");
        }
    }
}
```

### Summary: Manual vs. Owner Library

| Feature | Pure Java (Manual) | Owner Library |
| :--- | :--- | :--- |
| **Dependencies** | None | Yes (one small JAR) |
| **Boilerplate** | High (getters, setters, manual mapping) | Very Low (define an interface) |
| **Type Safety** | Low (manual string conversion) | **High** (types are defined in the interface) |
| **Error-Proneness** | High (typos in property keys) | Low (keys are defined in `@Key` annotations) |
| **Default Values** | Manual (if-null checks) | Built-in (`@DefaultValue` annotation) |
| **Recommendation** | Good for simple cases or to understand the mechanics. | **Highly recommended** for any real project. |

By combining a simple environment-aware `ConfigLoader` with the Owner library, you get a solution that is robust, type-safe, and nearly as powerful as Spring Boot's configuration binding, but without the entire framework.


---
