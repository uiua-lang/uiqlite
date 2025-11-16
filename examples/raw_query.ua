# Experimental!
Sql ~ "../lib"

Sql~Open ":memory:" # or file name to persist data

# Create a table and insert some data
⊸Sql~Exec $ CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT);
          $ INSERT INTO test (name) VALUES ("ekgame"), ("kaikalii"), ("JoaoFelipe3");

# Query the data and pretty print the results
⊸(
  Sql~Prepare $ SELECT id, name FROM test;
  ⊃(Sql~Finalize|⊂⊃(Sql~ColumnNames|Sql~QueryValues))
  ≡&p pretty
)

# Close the database connection
Sql~Close
