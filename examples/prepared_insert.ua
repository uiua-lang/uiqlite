# Experimental!
Sql ~ "../lib"

Sql~Open ":memory:" # or file name to persist data

# Create a table
$ CREATE TABLE test (
$   id INTEGER PRIMARY KEY,
$   name TEXT,
$   title TEXT,
$   lucky_number INTEGER
$ );
⊸Sql~Exec

# Insert data using a prepared statement
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (?, ?, ?);
  ⊸Sql~BindValues {"ekgame" "Generality Assurence" 42}
  Sql~ExecuteAndFinalize
)

# Insert data using a prepared statement with named parameters
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (:name, :title, :lucky_number);
  ⊸Sql~BindNamedValue ":name" "kaikalii"
  ⊸Sql~BindNamedValue ":title" "Chief Tacitness Engineer"
  ⊸Sql~BindNamedValue ":lucky_number" 8
  Sql~ExecuteAndFinalize
)

# Insert data using a prepared statement with named parameters map
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (:name, :title, :lucky_number);
  ⊸Sql~BindNamedValueMap map {":name" ":title" ":lucky_number"} {"JoaoFelipe3" "AoC Connoisseur" 13}
  Sql~ExecuteAndFinalize
)

# Query the data and pretty print the results
⊸(
  Sql~Prepare $ SELECT name, title, lucky_number FROM test;
  ⊃(Sql~Finalize|Sql~QueryValues)
  ≡&p pretty
)

# Close the database connection
Sql~Close
