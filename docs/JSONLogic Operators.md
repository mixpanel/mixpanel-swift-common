# JSONLogic Operators

This implementation supports 10 essential operators for targeting and filtering use cases.

## Supported Operators

### Strict Equality

**`===` (is)** - Strict equality (no type coercion)

Supported types: String, Number, Boolean, Null

```json
{"===": [1, 1]}          → true
{"===": [1, "1"]}        → ERROR (different types - throws typeMismatch)
{"===": ["apple", "apple"]} → true
{"===": [true, true]}    → true
{"===": [null, null]}    → true
```

**`!==` (is not)** - Strict inequality

Supported types: String, Number, Boolean, Null

```json
{"!==": [1, 2]}          → true
{"!==": [1, "1"]}        → ERROR (different types - throws typeMismatch)
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

**`and`** - Logical AND (all operands must be boolean expressions)
```json
{"and": [true, true]}    → true
{"and": [true, false]}   → false
{"and": [{"===": [1, 1]}, {">": [5, 3]}]} → true

// Non-boolean operands throw error
{"and": [1, 3]}          → ERROR (operands must be boolean)
{"and": [true, 3]}       → ERROR (3 is not boolean)
{"and": []}              → ERROR (requires at least 1 argument)
```

**`or`** - Logical OR (all operands must be boolean expressions)
```json
{"or": [false, true]}    → true
{"or": [false, false]}   → false
{"or": [{"===": [1, 2]}, {"===": [2, 2]}]} → true

// Non-boolean operands throw error
{"or": [1, 3]}           → ERROR (operands must be boolean)
{"or": [false, 3]}       → ERROR (3 is not boolean)
{"or": []}               → ERROR (requires at least 1 argument)
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
{"in": ["grape", ["apple", "banana"]]} → false

// Substring check - both must be strings
{"in": ["Spring", "Springfield"]}      → true
{"in": ["i", "team"]}                  → false

// Array must contain only strings - throws error
{"in": ["5", [1, 2, 3]]}               → ERROR (array contains non-strings)
{"in": ["a", ["a", 1, "b"]]}           → ERROR (array contains non-strings)

// Numbers and booleans NOT supported as needle - throws error
{"in": [5, [1, 2, 3, 5]]}              → ERROR (needle must be string)
{"in": [true, [true, false]]}          → ERROR (needle must be string)

// Arrays NOT supported as needle - throws error
{"in": [[1], [[1], [2]]]}              → ERROR (needle must be string)
```

### Data Access

**`var`** - Variable resolution from data context
```json
// Simple property (only non nested access supported)
{"var": "name"}          with {"name": "Alice"}    → "Alice"


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

- **Type errors throw exceptions**: All operators throw errors for invalid types rather than returning `false` or performing type coercion. This ensures type safety and prevents silent failures.
- **No type coercion**: `===` and `!==` require exact type match (e.g., `5 !== "5"` throws error, not returns true)
- **Comparison operators** (`<`, `<=`, `>`, `>=`) only work with numbers. Strings, booleans, and arrays will throw `typeMismatch` error
- **Logical operators** (`and`, `or`) require all operands to be boolean expressions. Non-boolean values (numbers, strings, etc.) will throw `typeMismatch` error. Unlike typical short-circuit evaluation, ALL operands are validated before returning, ensuring type safety even when the result could be determined early
- **`in` operator** requires string as needle (first argument). Numbers, booleans, and arrays as needle will throw `typeMismatch` error
- **Array limitations**: Arrays cannot be compared with `===` or `!==`. Arrays can be used as haystack in `in` operator, but array elements cannot themselves be arrays
- **Strict matching**: The `in` operator uses strict equality (`===`) for array element matching
