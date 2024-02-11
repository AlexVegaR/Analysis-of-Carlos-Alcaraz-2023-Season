// This query completes the "Alcaraz 2023 Matches" table
let
    // Appending the "Alcaraz Wins" and "Alcaraz Losses" tables
    Source = Table.Combine({#"Alcaraz Wins", #"Alcaraz Losses"}),
    // Removing the "Surface", "Tourney Date" and "Tourney Level" columns
    #"Removed Columns" = Table.RemoveColumns(Source, {"Surface", "Tourney Date", "Tourney Level"})
in
    #"Removed Columns"
