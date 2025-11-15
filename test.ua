# Experimental!
Sql ~ "lib"

# Test if the base type inference functions are working as expected
{NaN 42 3.14 "hello" [23 34 45]}
≡◇(Sql!⊃[IsNull|IsInt|IsFloat|IsText|IsBlob])
≍[1_0_0_0_0
  0_1_0_0_0
  0_0_1_0_0
  0_0_0_1_0
  0_0_0_0_1]
⍤"The functions to check the type of a value are not acting as expected"

# Test if the type inference function is working as expected
{NaN 42 3.14 "hello" [23 34 45]}
≡◇Sql!InferType
≍[0 1 2 3 4]
⍤"The function to infer value type is not working as expected"

# Database connection test
⍣(1 Sql~Close Sql~Open ":memory:"|0)
⍤"Opening and closing an in-memory database failed"

# Exec test
Sql~Open ":memory:"
⊸Sql~Exec $ CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT);
⊸Sql~Exec $ INSERT INTO test (name) VALUES ("ekgame"), ("kaikalii"), ("JoaoFelipe3");
Sql~Close
