# Experimental!
Sql ~ "../lib"

Sql~Open ":memory:" # or file name to persist data

# Create a table
⊸Sql~Exec $ CREATE TABLE test (
          $   id INTEGER PRIMARY KEY,
          $   name TEXT,
          $   title TEXT,
          $   lucky_number INTEGER
          $ );

# Insert some data
⊸Sql~Exec $ INSERT INTO test (name, title, lucky_number) VALUES
          $ ("ekgame", "Generality Assurence", 42),
          $ ("kaikalii", "Chief Tacitness Engineer", 8),
          $ ("JoaoFelipe3", "AoC Connoisseur", 13);

# Query the data and pretty print the results
⊸(
  Sql~Prepare $ SELECT id as Id, name as Name, lucky_number as LuckyNumber FROM test;
  ⊃(Sql~Finalize|Sql~QueryValuesAsMap)

  # Create datadef with the same fields as the query result column names
  ~Results {Id Name LuckyNumber}

  # Convert each thre result map to a struct of arrays
  °{°Results}getResults~Fields

  ≡&p pretty
)

# Close the database connection
Sql~Close
