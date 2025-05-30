# Go program to read, modify, encrypt CSV file
Created: 5/28/2025, 3:32:19 PM
Last Updated: 5/30/2025, 10:57:30 AM
---

### User

I want to write program like this in golang
- read CSV file
- modify data
- encrypt modified CSV file with AES
- CBC mode and PKCS5padding
- output encrypted CSV file in result directory


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Clarifying the Core Requirements**

I'm now honing in on the initial challenge. My focus has sharpened: I need to read a CSV file, make unspecified data changes, and encrypt the result. The data modification aspect needs further definition, but the core mechanics are clear. I'm building a robust foundation.


**Structuring the Go Program**

I've moved on to the program's skeleton. I'm laying out the key functions: reading the CSV, handling data modification (which is still a placeholder area), encrypting with AES-CBC, and writing the encrypted output. I also plan to incorporate error management and sensible file path handling for the output in the "result" directory.


**Detailing Package Dependencies**

I'm now identifying the exact packages I'll need. `encoding/csv` is the obvious choice for CSV handling. For file I/O, I'll lean towards `os` and `path/filepath`. AES encryption requires `crypto/aes` and `crypto/cipher`. I'll need `crypto/rand` for the IV. PKCS#7 padding will be straightforward. I'm focusing on clean error handling with `fmt` and `log`.


**Finalizing Function Implementations**

I'm now implementing the core functions, focusing on clear error handling and efficient data flow. The data modification placeholder in `modifyData` will append "MODIFIED" to the second column, if it exists. I'll utilize `bytes.Buffer` for in-memory CSV generation in `writeCSVToBytes`. I'm confirming that PKCS#7 padding is sufficient for PKCS#5. I've also added a note to emphasize the insecurity of hardcoding the encryption key, and I'll create a `utils` package. I'm focusing on simplicity and clarity in the code.


**Refining Function Definitions**

I've significantly refined the function definitions. The `modifyData` placeholder is now more concrete, appending "MODIFIED" to the second column, if present. I'm focusing on in-memory CSV generation, using `bytes.Buffer` in `writeCSVToBytes`. I've confirmed that the PKCS#7 implementation is sufficient for PKCS#5. Notably, I've added a security note about the dangers of hardcoding encryption keys. I'm also planning a `utils` package. Now it's time to build out these function implementations.


**Outlining Function Implementations**

I'm now outlining the steps for each function. I'll need a utility for directory creation, a specific function for CSV reading, and an in-memory CSV writing function. The encryption will use AES-CBC with a random IV, prepended to the ciphertext. PKCS#7 padding will ensure correct block alignment. Error handling is paramount, so I'll include thorough error checks at each step.


**Refining Functionality**

I'm now refining the core functionality of each function based on the outlined structure. I've decided to implement a more robust `modifyData` function that appends "MODIFIED" to the second column, if it exists. I'm also preparing to use `bytes.Buffer` efficiently for in-memory CSV generation. My focus is on concise implementations for reading, modifying, and writing CSV data, as well as robust encryption. The next step is to finalize these implementations.


**Defining Functionality and Structure**

I'm now delving into the core components. My current plan focuses on modularity: I'll need functions for directory handling, CSV reading, data modification (the append function), CSV-to-bytes conversion, and AES-CBC encryption. Error handling is paramount, and I'll include thorough error checks at each step.



</details>

Okay, this is a common and useful task! Let's break it down and write a Go program to achieve this.

**Key Concepts:**

1.  **CSV Handling:** Go's `encoding/csv` package is perfect for reading and writing CSV files.
2.  **AES (Advanced Encryption Standard):** A symmetric block cipher. We'll use `crypto/aes`.
3.  **CBC (Cipher Block Chaining):** An AES mode of operation that requires an Initialization Vector (IV). We'll use `crypto/cipher`.
4.  **PKCS5Padding (or PKCS7Padding):** AES works on fixed-size blocks (16 bytes for AES-128, AES-192, AES-256). If your data isn't a multiple of the block size, you need to pad it. PKCS5Padding is technically for 8-byte blocks, but it's often used interchangeably with PKCS7Padding, which is more general. For AES (16-byte blocks), PKCS7Padding is what's typically implemented and referred to as PKCS5Padding.
5.  **Initialization Vector (IV):** For CBC mode, a unique, random IV is required for each encryption operation with the same key. This IV should be prepended to the ciphertext so it can be used for decryption.
6.  **Key Management:** For this example, we'll use a hardcoded key. **In a real-world application, never hardcode keys!** Use environment variables, secure configuration files, or a proper key management system.

**Let's structure the program:**

```golang
package main

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"path/filepath"
)

const (
	// IMPORTANT: Use a strong, randomly generated key of 16, 24, or 32 bytes.
	// For AES-128, use 16 bytes. For AES-256, use 32 bytes.
	// Example key (32 bytes for AES-256). REPLACE THIS IN PRODUCTION!
	// You can generate one with: openssl rand -hex 32
	encryptionKeyString = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" // 64 hex chars = 32 bytes
	inputCsvFile      = "input.csv"
	outputDir         = "result"
)

// pkcs7Padding applies PKCS#7 padding to the data.
// PKCS5Padding is a subset of PKCS7Padding where the block size is 8.
// For AES (block size 16), PKCS7Padding is appropriate.
func pkcs7Padding(data []byte, blockSize int) []byte {
	padding := blockSize - len(data)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(data, padtext...)
}

// pkcs7UnPadding removes PKCS#7 padding from the data.
// Not used in this encryption-only example, but good for completeness.
/*
func pkcs7UnPadding(data []byte) ([]byte, error) {
	length := len(data)
	if length == 0 {
		return nil, fmt.Errorf("pkcs7UnPadding: data is empty")
	}
	unpadding := int(data[length-1])
	if unpadding > length || unpadding == 0 {
		return nil, fmt.Errorf("pkcs7UnPadding: invalid padding")
	}
	// Check that all padding bytes are correct
	for i := 0; i < unpadding; i++ {
		if int(data[length-1-i]) != unpadding {
			return nil, fmt.Errorf("pkcs7UnPadding: invalid padding byte")
		}
	}
	return data[:(length - unpadding)], nil
}
*/

// encryptAESCBC encrypts plaintext using AES-CBC with PKCS#7 padding.
// The IV is prepended to the ciphertext.
func encryptAESCBC(plaintext []byte, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("could not create AES cipher: %w", err)
	}

	// Apply PKCS#7 padding
	plaintext = pkcs7Padding(plaintext, block.BlockSize())

	// The IV needs to be unique, but not secure.
	// It's common to prepend it to the ciphertext.
	ciphertext := make([]byte, aes.BlockSize+len(plaintext))
	iv := ciphertext[:aes.BlockSize]
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		return nil, fmt.Errorf("could not generate IV: %w", err)
	}

	mode := cipher.NewCBCEncrypter(block, iv)
	mode.CryptBlocks(ciphertext[aes.BlockSize:], plaintext)

	return ciphertext, nil
}

// modifyCSVData is a placeholder function to demonstrate data modification.
// You should replace this with your actual data modification logic.
func modifyCSVData(records [][]string) ([][]string, error) {
	if len(records) == 0 {
		return records, nil // No data to modify
	}

	// Example modification: Add a "Status" column and set it to "Processed"
	// Add header for the new column
	modifiedRecords := make([][]string, len(records))
	if len(records) > 0 {
		records[0] = append(records[0], "Status")
	}

	// Add data for the new column
	for i, row := range records {
		if i == 0 { // header row
			modifiedRecords[i] = row
			continue
		}
		modifiedRecords[i] = append(row, "Processed")
	}

	// Example modification: Convert a specific column to uppercase (e.g., first column)
	for i, row := range modifiedRecords {
		if i == 0 { // Skip header
			continue
		}
		if len(row) > 0 {
			// This is just an example, ensure your column exists
			// row[0] = strings.ToUpper(row[0])
		}
	}
	return modifiedRecords, nil
}

func main() {
	fmt.Printf("Starting CSV encryption process at %s\n", time.Now().Format(time.RFC1123))

	// --- 1. Prepare Key ---
	// In a real app, get this from a secure source.
	// Here, we'll decode our hex string key.
	key := make([]byte, len(encryptionKeyString)/2)
	if _, err := fmt.Sscanf(encryptionKeyString, "%x", &key); err != nil {
		fmt.Fprintf(os.Stderr, "Error decoding hex key: %v\n", err)
		os.Exit(1)
	}
	if len(key) != 16 && len(key) != 24 && len(key) != 32 {
		fmt.Fprintf(
			os.Stderr,
			"Error: Invalid key length %d. Must be 16, 24, or 32 bytes.\n",
			len(key),
		)
		os.Exit(1)
	}
	fmt.Printf("Using AES key of length: %d bytes\n", len(key))

	// --- 2. Read CSV File ---
	fmt.Printf("Reading CSV file: %s\n", inputCsvFile)
	file, err := os.Open(inputCsvFile)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening CSV file %s: %v\n", inputCsvFile, err)
		os.Exit(1)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading CSV data: %v\n", err)
		os.Exit(1)
	}
	if len(records) == 0 {
		fmt.Println("CSV file is empty. Nothing to process.")
		return
	}
	fmt.Printf("Successfully read %d records from CSV.\n", len(records))

	// --- 3. Modify Data ---
	fmt.Println("Modifying CSV data...")
	modifiedRecords, err := modifyCSVData(records)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error modifying CSV data: %v\n", err)
		os.Exit(1)
	}
	fmt.Println("CSV data modification complete.")

	// --- 4. Convert Modified Data back to CSV format (in memory) ---
	var csvBuffer bytes.Buffer
	csvWriter := csv.NewWriter(&csvBuffer)
	if err := csvWriter.WriteAll(modifiedRecords); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing modified CSV to buffer: %v\n", err)
		os.Exit(1)
	}
	csvWriter.Flush() // Don't forget to flush!
	if err := csvWriter.Error(); err != nil {
		fmt.Fprintf(os.Stderr, "Error after flushing CSV writer: %v\n", err)
		os.Exit(1)
	}

	modifiedCsvBytes := csvBuffer.Bytes()
	fmt.Printf(
		"Modified CSV data converted to bytes (length: %d).\n",
		len(modifiedCsvBytes),
	)

	// --- 5. Encrypt Modified CSV Data ---
	fmt.Println("Encrypting modified CSV data...")
	encryptedData, err := encryptAESCBC(modifiedCsvBytes, key)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error encrypting data: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf(
		"Data encrypted successfully (output size: %d bytes, includes IV).\n",
		len(encryptedData),
	)

	// --- 6. Output Encrypted CSV File ---
	// Ensure result directory exists
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		fmt.Fprintf(os.Stderr, "Error creating output directory %s: %v\n", outputDir, err)
		os.Exit(1)
	}

	outputFileName := filepath.Join(outputDir, filepath.Base(inputCsvFile)+".enc")
	fmt.Printf("Writing encrypted data to: %s\n", outputFileName)
	err = os.WriteFile(outputFileName, encryptedData, 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing encrypted file %s: %v\n", outputFileName, err)
		os.Exit(1)
	}

	fmt.Printf("Process completed successfully. Encrypted file saved to %s\n", outputFileName)
	fmt.Printf("Finished at %s\n", time.Now().Format(time.RFC1123))
}

```

**To use this program:**

1.  **Save:** Save the code as `csv_encryptor.go` (or any name ending in `.go`).
2.  **Create `input.csv`:** In the same directory as your Go program, create a sample CSV file named `input.csv`. For example:
    ```csv
    ID,Name,Email
    1,Alice Wonderland,alice@example.com
    2,Bob The Builder,bob@example.com
    3,Charlie Brown,charlie@example.com
    ```
3.  **Modify `encryptionKeyString` (Optional but Recommended for Testing):**
    *   The provided key is just an example. You can generate a new one using OpenSSL (if you have it installed):
        `openssl rand -hex 32` (for a 32-byte key / AES-256)
        `openssl rand -hex 16` (for a 16-byte key / AES-128)
    *   Replace the value of `encryptionKeyString` with the hex string you generate. Remember, the string length will be twice the byte length (e.g., 32 bytes = 64 hex characters).
4.  **Run:**
    ```bash
    go run csv_encryptor.go
    ```
5.  **Check Output:**
    *   A directory named `result` will be created (if it doesn't exist).
    *   Inside `result`, you'll find `input.csv.enc`. This is your encrypted file.
    *   If you open the original `input.csv` after running (if you didn't modify it in the `modifyCSVData` function directly but rather created `modifiedRecords`), it will be unchanged. The `modifyCSVData` function in the example creates a new slice for modifications.

**Important Security Notes:**

*   **Key Management:** As stated before, **DO NOT hardcode keys in production applications.** This example does it for simplicity. Real applications should use secure methods like environment variables, secrets management services (like HashiCorp Vault, AWS KMS, Google Cloud KMS), or configuration files with strict permissions.
*   **IV Uniqueness:** The IV must be unique for every encryption operation performed with the same key. Prepending a randomly generated IV to the ciphertext is a standard and secure practice.
*   **Error Handling:** The provided code includes basic error handling. Robust applications would have more comprehensive error logging and recovery mechanisms.
*   **PKCS5 vs PKCS7:** While often used interchangeably, PKCS5 padding is technically defined for 8-byte block ciphers (like DES). PKCS7 padding is more general and can handle any block size. For AES (which has a 16-byte block size), the padding scheme is effectively PKCS7. The implementation above correctly handles this.

This program provides a solid foundation. You'll need to customize the `modifyCSVData` function to implement your specific data transformation logic.


---

### User

Integrate this program into Cobra which is CLI framework for golang.


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Considering CLI Integration**

I've been thinking about integrating the existing Go program into a Cobra CLI application. The plan is to create a project structure with `main.go` driving the application. The root command, managed by `cmd/root.go`, will allow for subcommands. This approach seems logical. I'm now exploring how to best structure the existing functionality within the CLI framework, mapping the current operations into subcommands.


**Planning Subcommand Structure**

I'm now outlining the `encrypt` subcommand's structure. It will handle input and output flags, along with the essential encryption key. The plan emphasizes robust error handling and potentially offering multiple encryption modes for future expansion. The core logic from the existing Go program will be refactored into relevant packages.


**Outlining `encrypt` Functionality**

I'm now detailing the steps within the `encrypt` subcommand's `RunE` function. I've broken it down into retrieving flag values, validating the input (including key length and file existence), decoding the hex key, calling the combined CSV reading/modifying function, executing the AES encryption, and finally writing the encrypted file. Error handling is integrated throughout, and I'm considering adding progress messages for better user feedback during execution. Key handling is critical in a CLI, so I will ensure that the key is treated securely with this approach.


**Establishing File Structure**

I'm now implementing the CLI structure. `main.go` will be responsible for calling the root command. The focus is on the `cmd` package, specifically `root.go` for the root command setup and `encrypt.go` for the `encrypt` subcommand. The `pkg` directory will house `crypto` and `csvutils` packages. I'm prioritizing efficient file organization for future scalability.


**Defining Input/Output**

I've been working on defining the input and output mechanisms for the `encrypt` subcommand. I've designed flags for input and output file paths, and output file name, while implementing default values for the output path and filename, ensuring flexibility for the user. I'm focusing on validating these inputs, specifically key length and file existence, ensuring a smoother user experience, and have implemented security warnings for key usage as a flag. I plan on implementing progress messages in this flow.



</details>

Okay, let's integrate this program into a Cobra CLI application. This will make it more user-friendly and extensible.

We'll structure the project like this:

```
csv-encryptor-cli/
├── main.go                 // Main entry point for the CLI
├── cmd/
│   ├── root.go             // Defines the root command
│   └── encrypt.go          // Defines the 'encrypt' subcommand
├── pkg/
│   ├── crypto/
│   │   └── aes_cbc.go      // AES encryption and padding logic
│   └── csvmodifier/
│       └── modifier.go     // CSV data modification logic
└── go.mod
└── go.sum
```

**Step 1: Initialize Go Module (if you haven't already)**

```bash
mkdir csv-encryptor-cli
cd csv-encryptor-cli
go mod init github.com/yourusername/csv-encryptor-cli # Replace with your actual module path
go get github.com/spf13/cobra@latest
go get github.com/spf13/pflag@latest # Cobra dependency
```

**Step 2: Create `pkg/crypto/aes_cbc.go`**

This file will contain our encryption and padding functions.

```golang
// csv-encryptor-cli/pkg/crypto/aes_cbc.go
package crypto

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"io"
)

// PKCS7Padding applies PKCS#7 padding to the data.
func PKCS7Padding(data []byte, blockSize int) []byte {
	padding := blockSize - len(data)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(data, padtext...)
}

// PKCS7UnPadding removes PKCS#7 padding. (Not used in encryption, but good for completeness)
/*
func PKCS7UnPadding(data []byte) ([]byte, error) {
	length := len(data)
	if length == 0 {
		return nil, fmt.Errorf("pkcs7UnPadding: data is empty")
	}
	unpadding := int(data[length-1])
	if unpadding > length || unpadding == 0 {
		return nil, fmt.Errorf("pkcs7UnPadding: invalid padding")
	}
	for i := 0; i < unpadding; i++ {
		if int(data[length-1-i]) != unpadding {
			return nil, fmt.Errorf("pkcs7UnPadding: invalid padding byte")
		}
	}
	return data[:(length - unpadding)], nil
}
*/

// EncryptAESCBC encrypts plaintext using AES-CBC with PKCS#7 padding.
// The IV is prepended to the ciphertext.
func EncryptAESCBC(plaintext []byte, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("could not create AES cipher: %w", err)
	}

	plaintextPadded := PKCS7Padding(plaintext, block.BlockSize())

	ciphertext := make([]byte, aes.BlockSize+len(plaintextPadded))
	iv := ciphertext[:aes.BlockSize]
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		return nil, fmt.Errorf("could not generate IV: %w", err)
	}

	mode := cipher.NewCBCEncrypter(block, iv)
	mode.CryptBlocks(ciphertext[aes.BlockSize:], plaintextPadded)

	return ciphertext, nil
}
```

**Step 3: Create `pkg/csvmodifier/modifier.go`**

This file will contain our CSV data modification logic.

```golang
// csv-encryptor-cli/pkg/csvmodifier/modifier.go
package csvmodifier

// ModifyCSVData is a placeholder function to demonstrate data modification.
// You should replace this with your actual data modification logic.
func ModifyCSVData(records [][]string) ([][]string, error) {
	if len(records) == 0 {
		return records, nil // No data to modify
	}

	// Example modification: Add a "Status" column and set it to "Processed"
	modifiedRecords := make([][]string, len(records))

	// Add header for the new column if headers exist
	if len(records) > 0 && len(records[0]) > 0 {
		records[0] = append(records[0], "Status_CLI") // Modified header name
	}

	// Add data for the new column
	for i, row := range records {
		if i == 0 { // header row
			modifiedRecords[i] = row
			continue
		}
		// Ensure row is copied before appending to avoid modifying original 'records'
		// if 'records' is used elsewhere after this function.
		// However, since we are creating modifiedRecords from scratch, this is fine.
		modifiedRecords[i] = append(row, "Processed_By_CLI")
	}
	return modifiedRecords, nil
}
```

**Step 4: Create `cmd/root.go`**

```golang
// csv-encryptor-cli/cmd/root.go
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "csv-encryptor-cli",
	Short: "A CLI tool to read, modify, and encrypt CSV files.",
	Long: `csv-encryptor-cli is a command-line application that allows you to
process CSV files by reading them, applying custom modifications,
and then encrypting the output using AES-CBC.`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	// Run: func(cmd *cobra.Command, args []string) { },
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func init() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.
	// rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.csv-encryptor-cli.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	// rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
```

**Step 5: Create `cmd/encrypt.go`**

This is where the main logic of our previous program will reside, adapted for Cobra.

```golang
// csv-encryptor-cli/cmd/encrypt.go
package cmd

import (
	"bytes"
	"encoding/csv"
	"encoding/hex"
	"fmt"
	"os"
	"path/filepath"
	"time" // Added for timestamp

	"github.com/spf13/cobra"
	// Adjust the import path based on your go.mod module name
	"github.com/yourusername/csv-encryptor-cli/pkg/crypto"
	"github.com/yourusername/csv-encryptor-cli/pkg/csvmodifier"
)

var (
	inputFile       string
	outputDir       string
	encryptionKey   string
	outputFileName  string // New flag for custom output filename
)

// encryptCmd represents the encrypt command
var encryptCmd = &cobra.Command{
	Use:   "encrypt",
	Short: "Encrypts a CSV file after modifying it.",
	Long: `Reads a CSV file, applies predefined modifications to its content,
encrypts the modified data using AES-CBC with PKCS#7 padding,
and saves the encrypted output to a specified directory.

The encryption key must be provided as a hex string (16, 24, or 32 bytes).
Example:
  csv-encryptor-cli encrypt -i input.csv -k YOUR_HEX_KEY_HERE
  csv-encryptor-cli encrypt --input data.csv --key YOUR_HEX_KEY_HERE --output-dir ./encrypted_files --output-filename data.enc`,
	RunE: func(cmd *cobra.Command, args []string) error {
		fmt.Printf(
			"Starting CSV encryption process at %s\n",
			time.Now().Format(time.RFC1123),
		)

		// --- 1. Validate and Prepare Key ---
		if encryptionKey == "" {
			return fmt.Errorf("encryption key (-k, --key) is required")
		}
		keyBytes, err := hex.DecodeString(encryptionKey)
		if err != nil {
			return fmt.Errorf("invalid hex encryption key: %w", err)
		}
		keyLen := len(keyBytes)
		if keyLen != 16 && keyLen != 24 && keyLen != 32 {
			return fmt.Errorf(
				"invalid key length: %d bytes. Must be 16 (AES-128), 24 (AES-192), or 32 (AES-256) bytes",
				keyLen,
			)
		}
		fmt.Printf("Using AES key of length: %d bytes\n", keyLen)
		fmt.Println(
			"WARNING: Providing keys via command-line flags can be insecure due to shell history. Consider environment variables or other secure methods for production.",
		)

		// --- 2. Read CSV File ---
		if inputFile == "" {
			return fmt.Errorf("input CSV file (-i, --input) is required")
		}
		fmt.Printf("Reading CSV file: %s\n", inputFile)
		file, err := os.Open(inputFile)
		if err != nil {
			return fmt.Errorf("error opening CSV file %s: %w", inputFile, err)
		}
		defer file.Close()

		reader := csv.NewReader(file)
		records, err := reader.ReadAll()
		if err != nil {
			return fmt.Errorf("error reading CSV data: %w", err)
		}
		if len(records) == 0 {
			fmt.Println("CSV file is empty. Nothing to process.")
			return nil
		}
		fmt.Printf("Successfully read %d records from CSV.\n", len(records))

		// --- 3. Modify Data ---
		fmt.Println("Modifying CSV data...")
		modifiedRecords, err := csvmodifier.ModifyCSVData(records)
		if err != nil {
			return fmt.Errorf("error modifying CSV data: %w", err)
		}
		fmt.Println("CSV data modification complete.")

		// --- 4. Convert Modified Data back to CSV format (in memory) ---
		var csvBuffer bytes.Buffer
		csvWriter := csv.NewWriter(&csvBuffer)
		if err := csvWriter.WriteAll(modifiedRecords); err != nil {
			return fmt.Errorf(
				"error writing modified CSV to buffer: %w",
				err,
			)
		}
		csvWriter.Flush()
		if err := csvWriter.Error(); err != nil {
			return fmt.Errorf("error after flushing CSV writer: %w", err)
		}
		modifiedCsvBytes := csvBuffer.Bytes()
		fmt.Printf(
			"Modified CSV data converted to bytes (length: %d).\n",
			len(modifiedCsvBytes),
		)

		// --- 5. Encrypt Modified CSV Data ---
		fmt.Println("Encrypting modified CSV data...")
		encryptedData, err := crypto.EncryptAESCBC(modifiedCsvBytes, keyBytes)
		if err != nil {
			return fmt.Errorf("error encrypting data: %w", err)
		}
		fmt.Printf(
			"Data encrypted successfully (output size: %d bytes, includes IV).\n",
			len(encryptedData),
		)

		// --- 6. Output Encrypted CSV File ---
		if err := os.MkdirAll(outputDir, 0755); err != nil {
			return fmt.Errorf(
				"error creating output directory %s: %w",
				outputDir,
				err,
			)
		}

		var finalOutputFileName string
		if outputFileName != "" {
			finalOutputFileName = outputFileName
		} else {
			finalOutputFileName = filepath.Base(inputFile) + ".enc"
		}
		outputPath := filepath.Join(outputDir, finalOutputFileName)

		fmt.Printf("Writing encrypted data to: %s\n", outputPath)
		err = os.WriteFile(outputPath, encryptedData, 0644)
		if err != nil {
			return fmt.Errorf(
				"error writing encrypted file %s: %w",
				outputPath,
				err,
			)
		}

		fmt.Printf(
			"Process completed successfully. Encrypted file saved to %s\n",
			outputPath,
		)
		fmt.Printf("Finished at %s\n", time.Now().Format(time.RFC1123))
		return nil
	},
}

func init() {
	rootCmd.AddCommand(encryptCmd)

	encryptCmd.Flags().StringVarP(
		&inputFile,
		"input",
		"i",
		"",
		"Path to the input CSV file (required)",
	)
	encryptCmd.MarkFlagRequired("input") // Make it truly required by Cobra

	encryptCmd.Flags().StringVarP(
		&outputDir,
		"output-dir",
		"d",
		"result",
		"Directory to save the encrypted file",
	)
	encryptCmd.Flags().StringVarP(
		&encryptionKey,
		"key",
		"k",
		"",
		"AES encryption key as a hex string (e.g., for AES-256, a 64-char hex string for 32 bytes) (required)",
	)
	encryptCmd.MarkFlagRequired("key")

	encryptCmd.Flags().StringVarP(
		&outputFileName,
		"output-filename",
		"o",
		"",
		"Optional name for the output encrypted file (e.g., mydata.enc). If not provided, it defaults to <input_filename>.enc",
	)
}
```
**Important:** In `cmd/encrypt.go`, make sure to replace `github.com/yourusername/csv-encryptor-cli` with your actual module path from `go.mod`.

**Step 6: Create `main.go`**

```golang
// csv-encryptor-cli/main.go
package main

import (
	// Adjust the import path based on your go.mod module name
	"github.com/yourusername/csv-encryptor-cli/cmd"
)

func main() {
	cmd.Execute()
}
```
Again, replace `github.com/yourusername/csv-encryptor-cli` with your module path.

**Step 7: Build and Run**

1.  **Tidy modules:**
    ```bash
    go mod tidy
    ```
2.  **Build the CLI:**
    ```bash
    go build -o csv-encryptor .
    ```
    (This creates an executable named `csv-encryptor` or `csv-encryptor.exe` on Windows)

3.  **Create a sample `input.csv`:**
    ```csv
    ID,Name,Value
    1,Alice,100
    2,Bob,200
    ```

4.  **Run the CLI:**
    *   **Get help:**
        ```bash
        ./csv-encryptor --help
        ./csv-encryptor encrypt --help
        ```
    *   **Encrypt a file:**
        You'll need a hex key. For AES-256 (32 bytes), you need a 64-character hex string.
        Example key (generate your own for real use!): `openssl rand -hex 32`
        Let's say it's `abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789`

        ```bash
        ./csv-encryptor encrypt -i input.csv -k abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789
        ```
        This will create `result/input.csv.enc`.

    *   **Specify output directory and filename:**
        ```bash
        ./csv-encryptor encrypt -i input.csv -k YOUR_HEX_KEY -d ./my_encrypted_data -o custom_encrypted.dat
        ```
        This will create `my_encrypted_data/custom_encrypted.dat`.

**Key Improvements with Cobra:**

*   **Clear Command Structure:** `encrypt` is now a subcommand. You can add more subcommands later (e.g., `decrypt`, `generate-key`).
*   **Automatic Help Messages:** Cobra generates helpful `--help` output.
*   **Flag Parsing:** Handles flags like `-i`, `-k`, `-d`, `-o` easily.
*   **Required Flags:** `MarkFlagRequired` ensures essential flags are provided.
*   **Error Handling:** `RunE` allows returning errors, which Cobra can then display.

This structure provides a much more robust and user-friendly CLI application for your CSV encryption task! Remember the security warning about providing keys via command-line flags in production environments.


---
