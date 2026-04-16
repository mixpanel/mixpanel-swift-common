# JSONLogic Operators

This implementation supports 10 essential operators for targeting and filtering use cases.

## Supported Operators

### Strict Equality

**`===` (is)** - Strict equality (no type coercion)
```json
{"===": [1, 1]}          → true
{"===": [1, "1"]}        → false (different types)
{"===": ["apple", "apple"]} → true
```

**`!==` (is not)** - Strict inequality
```json
{"!==": [1, 2]}          → true
{"!==": [1, "1"]}        → true (different types)
{"!==": ["apple", "apple"]} → false
```

### Comparison Operators

**`>` (greater than)** - Numbers only, 2 arguments
```json
{">": [2, 1]}            → true
{">": [1, 2]}            → false
{">": [3.14, 2.5]}       → true
```

**`>=` (greater or equal)** - Numbers only, 2 arguments
```json
{">=": [2, 1]}           → true
{">=": [1, 1]}           → true
{">=": [1, 2]}           → false
```

**`<` (less than)** - Numbers only, 2 arguments
```json
{"<": [1, 2]}            → true
{"<": [2, 1]}            → false
{"<": [2.5, 3.14]}       → true
```

**`<=` (less or equal)** - Numbers only, 2 arguments
```json
{"<=": [1, 2]}           → true
{"<=": [1, 1]}           → true
{"<=": [2, 1]}           → false
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

**`in`** - Array membership OR substring check (strings only)
```json
// Array membership (strict equality, strings only)
{"in": ["apple", ["apple", "banana"]]} → true
{"in": ["2", ["1", "2", "3"]]}         → true

// Substring check
{"in": ["Spring", "Springfield"]}      → true
{"in": ["i", "team"]}                  → false
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
- **Supported**: `===`, `!==`, `in`
- **Not supported**: `<`, `<=`, `>`, `>=`

### Boolean
- **Supported**: `===`, `!==`
- **Not supported**: `<`, `<=`, `>`, `>=`, `in`

### Number
- **Supported**: `===`, `!==`, `<`, `<=`, `>`, `>=`
- **Not supported**: `in`

## Notes

- **No type coercion** for equality: `===` and `!==` require exact type match
- **Comparison operators** (`<`, `<=`, `>`, `>=`) only work with numbers
- **`in` operator** only works with strings (for both array membership and substring checks)
- **Strict array membership**: `in` uses `===` for array element matching
