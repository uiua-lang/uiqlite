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

# Insert data using a prepared statement and a batch of values
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (?, ?, ?);
  # The insert will be executed for each array of values
  Sql~ExecuteBatch [
    {"ekgame" "Generality Assurence" 42}
    {"kaikalii" "Chief Tacitness Engineer" 8}
    {"JoaoFelipe3" "AoC Connoisseur" 13}
  ]
)

# Insert data using a prepared statement and a batch of values in the form of a map
⊸(
  Sql~Prepare $ INSERT INTO test (name, title, lucky_number) VALUES (:name, :title, :lucky_number);
  map {} []
  insert□":name" {"Omnikar" "alex_s168" "casenc"}
  insert□":title" {"Math Wizard" "Macro Magician" "Tacit Guru"}
  insert□":lucky_number" {7 23 71}
  Sql~ExecuteBatchMap
)

# Query the data and pretty print the results
⊸(
  Sql~Prepare $ SELECT name, title, lucky_number FROM test;
  ⊃(Sql~Finalize|Sql~QueryValues)
  ≡&p pretty
)

# Close the database connection
Sql~Close
