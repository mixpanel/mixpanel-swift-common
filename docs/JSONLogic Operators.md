# JSONLogic Operators

This implementation supports 10 essential operators for targeting and filtering use cases.

## Supported Operators

### Strict Equality

**`===` (is)** - Strict equality (no type coercion)

Supported types: String, Number, Boolean, Null

```json
{"===": [1, 1]}          → true
{"===": [1, "1"]}        → false (different types)
{"===": ["apple", "apple"]} → true
{"===": [true, true]}    → true
{"===": [null, null]}    → true
```

**`!==` (is not)** - Strict inequality

Supported types: String, Number, Boolean, Null

```json
{"!==": [1, 2]}          → true
{"!==": [1, "1"]}        → true (different types)
{"!==": ["apple", "apple"]} → false
{"!==": [true, false]}   → true
```

### Comparison Operators

**`>` (greater than)** - Numbers only, 2 arguments

Supported types: Number only

```json
{">": [2, 1]}            → true
{">": [1, 2]}            → false
{">": [3.14, 2.5]}       → true

// Strings, booleans, arrays NOT supported - throws error
{">": ["b", "a"]}        → ERROR
{">": [true, false]}     → ERROR
```

**`>=` (greater or equal)** - Numbers only, 2 arguments

Supported types: Number only

```json
{">=": [2, 1]}           → true
{">=": [1, 1]}           → true
{">=": [1, 2]}           → false

// Other types NOT supported - throws error
{">=": ["a", "a"]}       → ERROR
```

**`<` (less than)** - Numbers only, 2 arguments

Supported types: Number only

```json
{"<": [1, 2]}            → true
{"<": [2, 1]}            → false
{"<": [2.5, 3.14]}       → true

// Other types NOT supported - throws error
{"<": ["a", "b"]}        → ERROR
```

**`<=` (less or equal)** - Numbers only, 2 arguments

Supported types: Number only

```json
{"<=": [1, 2]}           → true
{"<=": [1, 1]}           → true
{"<=": [2, 1]}           → false

// Other types NOT supported - throws error
{"<=": [false, false]}   → ERROR
```

### Logical Operators

**`and`** - Returns first falsy value or last value
```json
{"and": [true, true]}    → true
{"and": [true, false]}   → false
{"and": [1, 3]}          → 3
{"and": [false, 3]}      → false
```

**`or`** - Returns first truthy value or last value
```json
{"or": [false, true]}    → true
{"or": [false, false]}   → false
{"or": [1, 3]}           → 1
{"or": [false, 3]}       → 3
```

### String/Array Operator

**`in`** - Array membership OR substring check

Supported types:
- **Needle (first argument)**: String only
- **Haystack (second argument)**: String or Array

```json
// Array membership - needle must be string, haystack is array
{"in": ["apple", ["apple", "banana"]]} → true
{"in": ["2", ["1", "2", "3"]]}         → true
{"in": ["5", [1, 2, 3]]}               → false (types don't match)

// Substring check - both must be strings
{"in": ["Spring", "Springfield"]}      → true
{"in": ["i", "team"]}                  → false

// Numbers and booleans NOT supported as needle - throws error
{"in": [5, [1, 2, 3, 5]]}              → ERROR
{"in": [true, [true, false]]}          → ERROR

// Arrays NOT supported as needle - throws error
{"in": [[1], [[1], [2]]]}              → ERROR
```

### Data Access

**`var`** - Variable resolution from data context
```json
// Simple property
{"var": "name"}          with {"name": "Alice"}    → "Alice"

// Nested property
{"var": "user.age"}      with {"user": {"age": 25}} → 25

// Array index
{"var": 1}               with ["a", "b", "c"]       → "b"

// Default value
{"var": ["missing", 0]}  with {}                    → 0
```

## Real-World Examples

**User targeting by age:**
```json
{
  "and": [
    {">=": [{"var": "age"}, 18]},
    {"<": [{"var": "age"}, 65]}
  ]
}
```
with `{"age": 25}` → `true`

**City-based targeting:**
```json
{"in": [{"var": "city"}, ["SF", "NYC", "LA"]]}
```
with `{"city": "SF"}` → `true`

**Premium user check:**
```json
{
  "and": [
    {"===": [{"var": "tier"}, "premium"]},
    {">": [{"var": "credits"}, 0]}
  ]
}
```
with `{"tier": "premium", "credits": 100}` → `true`

## Type Restrictions

Each data type supports specific operators:

### String
- **Supported operators**: `===`, `!==`, `in` (as needle)
- **Not supported**: `<`, `<=`, `>`, `>=`
- **Notes**: Can be used as needle in `in` operator, or as haystack for substring checks

### Boolean  
- **Supported operators**: `===`, `!==`
- **Not supported**: `<`, `<=`, `>`, `>=`, `in`
- **Notes**: Cannot be converted to numbers for comparison

### Number (Int or Double)
- **Supported operators**: `===`, `!==`, `<`, `<=`, `>`, `>=`
- **Not supported**: `in`
- **Notes**: Int and Double are interchangeable (e.g., `1 === 1.0` is `true`)

### Null
- **Supported operators**: `===`, `!==`
- **Not supported**: All other operators
- **Notes**: Only compares equal to itself

### Array
- **Supported operators**: None directly
- **Not supported**: `===`, `!==`, `<`, `<=`, `>`, `>=`, `in` (as needle)
- **Notes**: Can only be used as haystack (second argument) in `in` operator. Array elements cannot be arrays themselves.

## Important Notes

- **No type coercion**: `===` and `!==` require exact type match (e.g., `5 !== "5"`)
- **Comparison operators** (`<`, `<=`, `>`, `>=`) only work with numbers. Strings, booleans, and arrays will throw `typeMismatch` error
- **`in` operator** requires string as needle (first argument). Numbers, booleans, and arrays as needle will throw `typeMismatch` error
- **Array limitations**: Arrays cannot be compared with `===` or `!==`. Arrays can be used as haystack in `in` operator, but array elements cannot themselves be arrays
- **Strict matching**: The `in` operator uses strict equality (`===`) for array element matching
