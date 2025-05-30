# Go program to read, modify, encrypt CSV file
Created: 5/30/2025, 11:00:34 AM
Last Updated: 5/30/2025, 11:02:23 AM
---

### User

I want to write program like this in golang
- read CSV file
- modify data
- encrypt modified CSV file with AES
- CBC mode and PKCS5padding
- output encrypted CSV file in result directory


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants a Go program that:
1. Reads a CSV file
2. Modifies the data
3. Encrypts the modified CSV file using AES with CBC mode and PKCS5 padding
4. Outputs the encrypted file to a result directory

I'll need to create a comprehensive example that includes:
- CSV reading/writing using the encoding/csv package
- AES encryption with CBC mode
- PKCS5 padding (which is essentially PKCS7 padding)
- File operations
- Error handling

Let me structure this step by step:

1. Read CSV file
2. Modify the data (I'll show a simple example of modification)
3. Convert modified data back to CSV format
4. Encrypt using AES-CBC with PKCS5 padding
5. Write to result directory

I'll need to import the necessary packages and create helper functions for encryption.
</details>

I'll help you create a Go program that reads a CSV file, modifies the data, encrypts it with AES-CBC and PKCS5 padding, then outputs it to a result directory.

```go
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
	"strings"
)

// PKCS5Padding adds padding to the data
func PKCS5Padding(data []byte, blockSize int) []byte {
	padding := blockSize - len(data)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(data, padtext...)
}

// PKCS5UnPadding removes padding from the data
func PKCS5UnPadding(data []byte) []byte {
	length := len(data)
	unpadding := int(data[length-1])
	return data[:(length - unpadding)]
}

// EncryptAESCBC encrypts data using AES-CBC mode
func EncryptAESCBC(data, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	// Add PKCS5 padding
	paddedData := PKCS5Padding(data, aes.BlockSize)

	// Generate random IV
	iv := make([]byte, aes.BlockSize)
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		return nil, err
	}

	// Encrypt
	mode := cipher.NewCBCEncrypter(block, iv)
	encrypted := make([]byte, len(paddedData))
	mode.CryptBlocks(encrypted, paddedData)

	// Prepend IV to encrypted data
	result := append(iv, encrypted...)
	return result, nil
}

// DecryptAESCBC decrypts data using AES-CBC mode
func DecryptAESCBC(encryptedData, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	if len(encryptedData) < aes.BlockSize {
		return nil, fmt.Errorf("encrypted data too short")
	}

	// Extract IV and encrypted data
	iv := encryptedData[:aes.BlockSize]
	encrypted := encryptedData[aes.BlockSize:]

	// Decrypt
	mode := cipher.NewCBCDecrypter(block, iv)
	decrypted := make([]byte, len(encrypted))
	mode.CryptBlocks(decrypted, encrypted)

	// Remove PKCS5 padding
	result := PKCS5UnPadding(decrypted)
	return result, nil
}

// ReadCSV reads a CSV file and returns the records
func ReadCSV(filename string) ([][]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, err
	}

	return records, nil
}

// ModifyCSVData modifies the CSV data (example: convert to uppercase)
func ModifyCSVData(records [][]string) [][]string {
	modified := make([][]string, len(records))
	
	for i, record := range records {
		modified[i] = make([]string, len(record))
		for j, field := range record {
			// Example modification: convert to uppercase
			// You can implement your own modification logic here
			modified[i][j] = strings.ToUpper(field)
		}
	}
	
	return modified
}

// ConvertCSVToBytes converts CSV records to byte array
func ConvertCSVToBytes(records [][]string) ([]byte, error) {
	var buffer bytes.Buffer
	writer := csv.NewWriter(&buffer)
	
	for _, record := range records {
		if err := writer.Write(record); err != nil {
			return nil, err
		}
	}
	
	writer.Flush()
	if err := writer.Error(); err != nil {
		return nil, err
	}
	
	return buffer.Bytes(), nil
}

// WriteEncryptedFile writes encrypted data to a file
func WriteEncryptedFile(filename string, data []byte) error {
	// Create result directory if it doesn't exist
	dir := filepath.Dir(filename)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}
	
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()
	
	_, err = file.Write(data)
	return err
}

func main() {
	// Configuration
	inputCSVFile := "input.csv"
	outputEncryptedFile := "result/encrypted_output.bin"
	
	// AES key (32 bytes for AES-256)
	// In production, use a secure key management system
	key := []byte("your-32-byte-key-here-for-aes256") // 32 bytes
	
	fmt.Println("Starting CSV encryption process...")
	
	// Step 1: Read CSV file
	fmt.Println("1. Reading CSV file...")
	records, err := ReadCSV(inputCSVFile)
	if err != nil {
		fmt.Printf("Error reading CSV file: %v\n", err)
		return
	}
	fmt.Printf("   Read %d records\n", len(records))
	
	// Step 2: Modify data
	fmt.Println("2. Modifying data...")
	modifiedRecords := ModifyCSVData(records)
	fmt.Println("   Data modification completed")
	
	// Step 3: Convert modified CSV back to bytes
	fmt.Println("3. Converting CSV to bytes...")
	csvBytes, err := ConvertCSVToBytes(modifiedRecords)
	if err != nil {
		fmt.Printf("Error converting CSV to bytes: %v\n", err)
		return
	}
	fmt.Printf("   CSV data size: %d bytes\n", len(csvBytes))
	
	// Step 4: Encrypt the CSV data
	fmt.Println("4. Encrypting data with AES-CBC...")
	encryptedData, err := EncryptAESCBC(csvBytes, key)
	if err != nil {
		fmt.Printf("Error encrypting data: %v\n", err)
		return
	}
	fmt.Printf("   Encrypted data size: %d bytes\n", len(encryptedData))
	
	// Step 5: Write encrypted file to result directory
	fmt.Println("5. Writing encrypted file...")
	err = WriteEncryptedFile(outputEncryptedFile, encryptedData)
	if err != nil {
		fmt.Printf("Error writing encrypted file: %v\n", err)
		return
	}
	
	fmt.Printf("✓ Successfully encrypted CSV file saved to: %s\n", outputEncryptedFile)
	
	// Optional: Demonstration of decryption
	fmt.Println("\n--- Decryption Test ---")
	decryptedData, err := DecryptAESCBC(encryptedData, key)
	if err != nil {
		fmt.Printf("Error decrypting data: %v\n", err)
		return
	}
	
	fmt.Printf("Decrypted data preview:\n%s\n", string(decryptedData[:min(200, len(decryptedData))]))
}

// Helper function for min
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
```

You'll also need to create a sample `input.csv` file for testing:

```csv
name,age,city,email
John Doe,30,New York,john@example.com
Jane Smith,25,Los Angeles,jane@example.com
Bob Johnson,35,Chicago,bob@example.com
Alice Brown,28,Houston,alice@example.com
```

Here's how to use this program:

## Setup and Usage

1. **Create the input CSV file** (`input.csv`) in the same directory as your Go program.

2. **Install dependencies** (if needed):
   ```bash
   go mod init csv-encryption
   ```

3. **Run the program**:
   ```bash
   go run main.go
   ```

## Key Features

- **CSV Reading**: Uses Go's built-in `encoding/csv` package
- **Data Modification**: Example shows converting all text to uppercase
- **AES-CBC Encryption**: Implements proper AES encryption with CBC mode
- **PKCS5 Padding**: Adds proper padding for block cipher
- **Random IV**: Generates a random initialization vector for each encryption
- **Directory Creation**: Automatically creates the result directory
- **Error Handling**: Comprehensive error handling throughout

## Security Notes

1. **Key Management**: Replace the hardcoded key with a secure key management solution
2. **Key Size**: The example uses AES-256 (32-byte key). You can also use AES-128 (16 bytes) or AES-192 (24 bytes)
3. **IV**: The program generates a random IV for each encryption and prepends it to the encrypted data

## Customization

- Modify the `ModifyCSVData` function to implement your specific data transformation logic
- Change file paths and names as needed
- Adjust the key size and encryption parameters based on your requirements

The encrypted file will be saved in the `result/` directory as `encrypted_output.bin`.


---

### User

Integrate this program into Cobra which is CLI framework for golang.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants me to integrate the CSV encryption program into Cobra, which is a CLI framework for Go. I need to:

1. Create a Cobra CLI application structure
2. Add commands for the different operations (encrypt, decrypt)
3. Add flags for input file, output file, key, etc.
4. Organize the code properly with commands
5. Make it more modular and user-friendly

I should create:
- A root command
- An encrypt command
- A decrypt command (optional but useful)
- Proper flags for all options
- Better error handling and user feedback

Let me structure this properly:
- main.go (root command)
- cmd/encrypt.go (encrypt command)
- cmd/decrypt.go (decrypt command)
- pkg/crypto.go (encryption/decryption functions)
- pkg/csv.go (CSV handling functions)
</details>

I'll help you integrate the CSV encryption program into Cobra CLI framework. Here's a well-structured implementation:

## Project Structure
```
csv-encryption/
├── main.go
├── cmd/
│   ├── root.go
│   ├── encrypt.go
│   └── decrypt.go
├── pkg/
│   ├── crypto/
│   │   └── aes.go
│   └── csv/
│       └── handler.go
├── go.mod
└── go.sum
```

## 1. Initialize the project

```bash
go mod init csv-encryption
go get github.com/spf13/cobra@latest
```

## 2. main.go

```go
package main

import "csv-encryption/cmd"

func main() {
	cmd.Execute()
}
```

## 3. cmd/root.go

```go
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var (
	cfgFile string
	verbose bool
)

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "csv-encryption",
	Short: "A CLI tool for encrypting and decrypting CSV files",
	Long: `CSV Encryption Tool is a command-line application that allows you to:
- Read CSV files
- Modify data with custom transformations
- Encrypt CSV files using AES-CBC with PKCS5 padding
- Decrypt encrypted CSV files
- Output results to specified directories`,
	Version: "1.0.0",
}

// Execute adds all child commands to the root command and sets flags appropriately.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.PersistentFlags().BoolVarP(
		&verbose,
		"verbose",
		"v",
		false,
		"verbose output",
	)
}
```

## 4. pkg/crypto/aes.go

```go
package crypto

import (
	"bytes"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"fmt"
	"io"
)

// PKCS5Padding adds padding to the data
func PKCS5Padding(data []byte, blockSize int) []byte {
	padding := blockSize - len(data)%blockSize
	padtext := bytes.Repeat([]byte{byte(padding)}, padding)
	return append(data, padtext...)
}

// PKCS5UnPadding removes padding from the data
func PKCS5UnPadding(data []byte) []byte {
	length := len(data)
	unpadding := int(data[length-1])
	return data[:(length - unpadding)]
}

// EncryptAESCBC encrypts data using AES-CBC mode
func EncryptAESCBC(data, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("failed to create cipher: %w", err)
	}

	// Add PKCS5 padding
	paddedData := PKCS5Padding(data, aes.BlockSize)

	// Generate random IV
	iv := make([]byte, aes.BlockSize)
	if _, err := io.ReadFull(rand.Reader, iv); err != nil {
		return nil, fmt.Errorf("failed to generate IV: %w", err)
	}

	// Encrypt
	mode := cipher.NewCBCEncrypter(block, iv)
	encrypted := make([]byte, len(paddedData))
	mode.CryptBlocks(encrypted, paddedData)

	// Prepend IV to encrypted data
	result := append(iv, encrypted...)
	return result, nil
}

// DecryptAESCBC decrypts data using AES-CBC mode
func DecryptAESCBC(encryptedData, key []byte) ([]byte, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, fmt.Errorf("failed to create cipher: %w", err)
	}

	if len(encryptedData) < aes.BlockSize {
		return nil, fmt.Errorf("encrypted data too short")
	}

	// Extract IV and encrypted data
	iv := encryptedData[:aes.BlockSize]
	encrypted := encryptedData[aes.BlockSize:]

	if len(encrypted)%aes.BlockSize != 0 {
		return nil, fmt.Errorf("encrypted data is not a multiple of block size")
	}

	// Decrypt
	mode := cipher.NewCBCDecrypter(block, iv)
	decrypted := make([]byte, len(encrypted))
	mode.CryptBlocks(decrypted, encrypted)

	// Remove PKCS5 padding
	result := PKCS5UnPadding(decrypted)
	return result, nil
}

// ValidateKeySize validates the AES key size
func ValidateKeySize(key []byte) error {
	keyLen := len(key)
	if keyLen != 16 && keyLen != 24 && keyLen != 32 {
		return fmt.Errorf(
			"invalid key size: %d bytes. Must be 16, 24, or 32 bytes",
			keyLen,
		)
	}
	return nil
}
```

## 5. pkg/csv/handler.go

```go
package csv

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"os"
	"strings"
)

// TransformType represents different data transformation types
type TransformType string

const (
	TransformUppercase TransformType = "uppercase"
	TransformLowercase TransformType = "lowercase"
	TransformNone      TransformType = "none"
)

// ReadCSV reads a CSV file and returns the records
func ReadCSV(filename string) ([][]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open file %s: %w", filename, err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("failed to read CSV data: %w", err)
	}

	return records, nil
}

// TransformCSVData applies transformations to CSV data
func TransformCSVData(
	records [][]string,
	transform TransformType,
	skipHeader bool,
) [][]string {
	if len(records) == 0 {
		return records
	}

	modified := make([][]string, len(records))
	startRow := 0

	// Copy header if skipping transformation
	if skipHeader && len(records) > 0 {
		modified[0] = make([]string, len(records[0]))
		copy(modified[0], records[0])
		startRow = 1
	}

	for i := startRow; i < len(records); i++ {
		modified[i] = make([]string, len(records[i]))
		for j, field := range records[i] {
			switch transform {
			case TransformUppercase:
				modified[i][j] = strings.ToUpper(field)
			case TransformLowercase:
				modified[i][j] = strings.ToLower(field)
			case TransformNone:
				fallthrough
			default:
				modified[i][j] = field
			}
		}
	}

	return modified
}

// ConvertCSVToBytes converts CSV records to byte array
func ConvertCSVToBytes(records [][]string) ([]byte, error) {
	var buffer bytes.Buffer
	writer := csv.NewWriter(&buffer)

	for _, record := range records {
		if err := writer.Write(record); err != nil {
			return nil, fmt.Errorf("failed to write CSV record: %w", err)
		}
	}

	writer.Flush()
	if err := writer.Error(); err != nil {
		return nil, fmt.Errorf("CSV writer error: %w", err)
	}

	return buffer.Bytes(), nil
}

// ConvertBytesToCSV converts byte array back to CSV records
func ConvertBytesToCSV(data []byte) ([][]string, error) {
	reader := csv.NewReader(bytes.NewReader(data))
	records, err := reader.ReadAll()
	if err != nil {
		return nil, fmt.Errorf("failed to parse CSV data: %w", err)
	}
	return records, nil
}

// WriteCSV writes CSV records to a file
func WriteCSV(filename string, records [][]string) error {
	file, err := os.Create(filename)
	if err != nil {
		return fmt.Errorf("failed to create file %s: %w", filename, err)
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	for _, record := range records {
		if err := writer.Write(record); err != nil {
			return fmt.Errorf("failed to write CSV record: %w", err)
		}
	}

	return writer.Error()
}
```

## 6. cmd/encrypt.go

```go
package cmd

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"csv-encryption/pkg/crypto"
	"csv-encryption/pkg/csv"

	"github.com/spf13/cobra"
)

var (
	inputFile    string
	outputFile   string
	keyFile      string
	keyString    string
	transform    string
	skipHeader   bool
	outputDir    string
)

// encryptCmd represents the encrypt command
var encryptCmd = &cobra.Command{
	Use:   "encrypt",
	Short: "Encrypt a CSV file",
	Long: `Encrypt a CSV file using AES-CBC encryption with PKCS5 padding.

The command reads a CSV file, applies optional data transformations,
and encrypts the result using AES-CBC mode with a provided key.`,
	Example: `  # Encrypt with uppercase transformation
  csv-encryption encrypt -i input.csv -o encrypted.bin -k "your-32-byte-key-here-for-aes256" -t uppercase

  # Encrypt from key file, skip header transformation
  csv-encryption encrypt -i input.csv -o encrypted.bin --key-file key.txt -t lowercase --skip-header

  # Encrypt to specific directory
  csv-encryption encrypt -i input.csv --output-dir ./result -k "your-32-byte-key-here-for-aes256"`,
	RunE: runEncrypt,
}

func init() {
	rootCmd.AddCommand(encryptCmd)

	encryptCmd.Flags().StringVarP(
		&inputFile,
		"input",
		"i",
		"",
		"input CSV file path (required)",
	)
	encryptCmd.Flags().StringVarP(
		&outputFile,
		"output",
		"o",
		"",
		"output encrypted file path",
	)
	encryptCmd.Flags().StringVar(
		&outputDir,
		"output-dir",
		"./result",
		"output directory for encrypted file",
	)
	encryptCmd.Flags().StringVarP(
		&keyString,
		"key",
		"k",
		"",
		"encryption key (16, 24, or 32 bytes)",
	)
	encryptCmd.Flags().StringVar(
		&keyFile,
		"key-file",
		"",
		"file containing encryption key",
	)
	encryptCmd.Flags().StringVarP(
		&transform,
		"transform",
		"t",
		"none",
		"data transformation: none, uppercase, lowercase",
	)
	encryptCmd.Flags().BoolVar(
		&skipHeader,
		"skip-header",
		false,
		"skip transformation for header row",
	)

	encryptCmd.MarkFlagRequired("input")
}

func runEncrypt(cmd *cobra.Command, args []string) error {
	// Validate input file
	if _, err := os.Stat(inputFile); os.IsNotExist(err) {
		return fmt.Errorf("input file does not exist: %s", inputFile)
	}

	// Get encryption key
	key, err := getEncryptionKey()
	if err != nil {
		return err
	}

	// Validate key
	if err := crypto.ValidateKeySize(key); err != nil {
		return err
	}

	// Set output file if not provided
	if outputFile == "" {
		filename := filepath.Base(inputFile)
		name := filename[:len(filename)-len(filepath.Ext(filename))]
		outputFile = filepath.Join(outputDir, name+"_encrypted.bin")
	}

	// Create output directory
	if err := os.MkdirAll(filepath.Dir(outputFile), 0755); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}

	if verbose {
		fmt.Printf("Reading CSV file: %s\n", inputFile)
	}

	// Read CSV file
	records, err := csv.ReadCSV(inputFile)
	if err != nil {
		return err
	}

	if verbose {
		fmt.Printf("Read %d records\n", len(records))
		fmt.Printf("Applying transformation: %s\n", transform)
	}

	// Transform data
	transformType := csv.TransformType(transform)
	modifiedRecords := csv.TransformCSVData(records, transformType, skipHeader)

	// Convert to bytes
	csvBytes, err := csv.ConvertCSVToBytes(modifiedRecords)
	if err != nil {
		return err
	}

	if verbose {
		fmt.Printf("CSV data size: %d bytes\n", len(csvBytes))
		fmt.Println("Encrypting data...")
	}

	// Encrypt data
	encryptedData, err := crypto.EncryptAESCBC(csvBytes, key)
	if err != nil {
		return fmt.Errorf("encryption failed: %w", err)
	}

	// Write encrypted file
	if err := ioutil.WriteFile(outputFile, encryptedData, 0644); err != nil {
		return fmt.Errorf("failed to write encrypted file: %w", err)
	}

	fmt.Printf("✓ Successfully encrypted CSV file saved to: %s\n", outputFile)
	if verbose {
		fmt.Printf("Encrypted data size: %d bytes\n", len(encryptedData))
	}

	return nil
}

func getEncryptionKey() ([]byte, error) {
	if keyString != "" && keyFile != "" {
		return nil, fmt.Errorf("cannot specify both --key and --key-file")
	}

	if keyString == "" && keyFile == "" {
		return nil, fmt.Errorf("must specify either --key or --key-file")
	}

	if keyString != "" {
		return []byte(keyString), nil
	}

	// Read key from file
	keyData, err := ioutil.ReadFile(keyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read key file: %w", err)
	}

	return keyData, nil
}
```

## 7. cmd/decrypt.go

```go
package cmd

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"

	"csv-encryption/pkg/crypto"
	"csv-encryption/pkg/csv"

	"github.com/spf13/cobra"
)

var (
	decryptInputFile  string
	decryptOutputFile string
	decryptKeyFile    string
	decryptKeyString  string
	decryptOutputDir  string
)

// decryptCmd represents the decrypt command
var decryptCmd = &cobra.Command{
	Use:   "decrypt",
	Short: "Decrypt an encrypted CSV file",
	Long: `Decrypt a CSV file that was encrypted using the encrypt command.

The command reads an encrypted file, decrypts it using AES-CBC decryption,
and outputs the original CSV data.`,
	Example: `  # Decrypt with key string
  csv-encryption decrypt -i encrypted.bin -o decrypted.csv -k "your-32-byte-key-here-for-aes256"

  # Decrypt with key file
  csv-encryption decrypt -i encrypted.bin -o decrypted.csv --key-file key.txt

  # Decrypt to specific directory
  csv-encryption decrypt -i encrypted.bin --output-dir ./decrypted`,
	RunE: runDecrypt,
}

func init() {
	rootCmd.AddCommand(decryptCmd)

	decryptCmd.Flags().StringVarP(
		&decryptInputFile,
		"input",
		"i",
		"",
		"input encrypted file path (required)",
	)
	decryptCmd.Flags().StringVarP(
		&decryptOutputFile,
		"output",
		"o",
		"",
		"output CSV file path",
	)
	decryptCmd.Flags().StringVar(
		&decryptOutputDir,
		"output-dir",
		"./decrypted",
		"output directory for decrypted file",
	)
	decryptCmd.Flags().StringVarP(
		&decryptKeyString,
		"key",
		"k",
		"",
		"decryption key (16, 24, or 32 bytes)",
	)
	decryptCmd.Flags().StringVar(
		&decryptKeyFile,
		"key-file",
		"",
		"file containing decryption key",
	)

	decryptCmd.MarkFlagRequired("input")
}

func runDecrypt(cmd *cobra.Command, args []string) error {
	// Validate input file
	if _, err := os.Stat(decryptInputFile); os.IsNotExist(err) {
		return fmt.Errorf("input file does not exist: %s", decryptInputFile)
	}

	// Get decryption key
	key, err := getDecryptionKey()
	if err != nil {
		return err
	}

	// Validate key
	if err := crypto.ValidateKeySize(key); err != nil {
		return err
	}

	// Set output file if not provided
	if decryptOutputFile == "" {
		filename := filepath.Base(decryptInputFile)
		name := filename[:len(filename)-len(filepath.Ext(filename))]
		decryptOutputFile = filepath.Join(decryptOutputDir, name+"_decrypted.csv")
	}

	// Create output directory
	if err := os.MkdirAll(filepath.Dir(decryptOutputFile), 0755); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}

	if verbose {
		fmt.Printf("Reading encrypted file: %s\n", decryptInputFile)
	}

	// Read encrypted file
	encryptedData, err := ioutil.ReadFile(decryptInputFile)
	if err != nil {
		return fmt.Errorf("failed to read encrypted file: %w", err)
	}

	if verbose {
		fmt.Printf("Encrypted data size: %d bytes\n", len(encryptedData))
		fmt.Println("Decrypting data...")
	}

	// Decrypt data
	decryptedData, err := crypto.DecryptAESCBC(encryptedData, key)
	if err != nil {
		return fmt.Errorf("decryption failed: %w", err)
	}

	// Parse CSV data
	records, err := csv.ConvertBytesToCSV(decryptedData)
	if err != nil {
		return err
	}

	if verbose {
		fmt.Printf("Decrypted %d records\n", len(records))
	}

	// Write CSV file
	if err := csv.WriteCSV(decryptOutputFile, records); err != nil {
		return err
	}

	fmt.Printf("✓ Successfully decrypted CSV file saved to: %s\n", decryptOutputFile)

	return nil
}

func getDecryptionKey() ([]byte, error) {
	if decryptKeyString != "" && decryptKeyFile != "" {
		return nil, fmt.Errorf("cannot specify both --key and --key-file")
	}

	if decryptKeyString == "" && decryptKeyFile == "" {
		return nil, fmt.Errorf("must specify either --key or --key-file")
	}

	if decryptKeyString != "" {
		return []byte(decryptKeyString), nil
	}

	// Read key from file
	keyData, err := ioutil.ReadFile(decryptKeyFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read key file: %w", err)
	}

	return keyData, nil
}
```

## 8. Create sample files for testing

**input.csv:**
```csv
name,age,city,email
John Doe,30,New York,john@example.com
Jane Smith,25,Los Angeles,jane@example.com
Bob Johnson,35,Chicago,bob@example.com
Alice Brown,28,Houston,alice@example.com
```

**key.txt:**
```
your-32-byte-key-here-for-aes256
```

## Usage Examples

```bash
# Build the application
go build -o csv-encryption

# Show help
./csv-encryption --help

# Encrypt with uppercase transformation
./csv-encryption encrypt -i input.csv -o encrypted.bin -k "your-32-byte-key-here-for-aes256" -t uppercase -v

# Encrypt using key file, skip header transformation
./csv-encryption encrypt -i input.csv --key-file key.txt -t lowercase --skip-header -v

# Decrypt the file
./csv-encryption decrypt -i encrypted.bin -o decrypted.csv -k "your-32-byte-key-here-for-aes256" -v

# Encrypt to specific directory
./csv-encryption encrypt -i input.csv --output-dir ./results -k "your-32-byte-key-here-for-aes256"
```

## Features

- **Modular Design**: Separated concerns into different packages
- **Flexible CLI**: Multiple options for input/output and transformations
- **Key Management**: Support for both direct key input and key files
- **Data Transformations**: Uppercase, lowercase, or no transformation
- **Header Handling**: Option to skip transformation for header rows
- **Verbose Output**: Detailed logging with `-v` flag
- **Error Handling**: Comprehensive error messages and validation
- **Directory Creation**: Automatic creation of output directories

This CLI tool provides a professional and user-friendly interface for CSV encryption operations!


---
