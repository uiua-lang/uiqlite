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
  Sql~Finalize ◌⊸Sql~Step # Use "Step" to execute the prepared statement and "Finalize" to clean it up
)

# Insert data using a prepared statement with named parameters
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (:name, :title, :lucky_number);
  ⊸Sql~BindNamedValue "kaikalii" ":name"
  ⊸Sql~BindNamedValue "Chief Tacitness Engineer" ":title"
  ⊸Sql~BindNamedValue 8 ":lucky_number"
  Sql~Finalize ◌⊸Sql~Step
)

# Insert data using a prepared statement with named parameters map
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (:name, :title, :lucky_number);
  ⊸Sql~BindNamedValueMap map {":name" ":title" ":lucky_number"} {"JoaoFelipe3" "AoC Connoisseur" 13}
  Sql~Finalize ◌⊸Sql~Step
)

# Query the data and pretty print the results
⊸(
  Sql~Prepare $ SELECT name, title, lucky_number FROM test;
  ⊃(Sql~Finalize|Sql~QueryValues)
  ≡&p pretty
)

# Close the database connection
Sql~Close
