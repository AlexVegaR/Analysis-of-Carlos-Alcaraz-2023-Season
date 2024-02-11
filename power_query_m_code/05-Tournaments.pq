// This query creates the "Tournaments" table
let
    // Appending the "Alcaraz Wins" and "Alcaraz Losses" tables
    Source = Table.Combine({#"Alcaraz Wins", #"Alcaraz Losses"}),
    // Removing all the columns except "Tourney Name", "Tourney Date", "Tourney Level", "Surface", "Round" and "Match Result"
    #"Removed Other Columns" = Table.SelectColumns(
        Source, {"Tourney Name", "Tourney Date", "Tourney Level", "Surface", "Round", "Match Result"}
    ),
    // Adding the "Title Check" column by checking the values from the "Round" and "Match Result" columns
    #"Added Title Check" = Table.AddColumn(
        #"Removed Other Columns",
        "Title Check",
        each if [Round] = "Finals" and [Match Result] = "Win" then 1 else 0,
        Int64.Type
    ),
    // Removing the "Round" and "Match Result" columns
    #"Removed Columns" = Table.RemoveColumns(#"Added Title Check", {"Round", "Match Result"}),
    // Grouping rows by "Tourney Name", "Surface", "Tourney Date" and "Tourney Level" with the DISTINCT COUNT aggregation
    #"Grouped Rows" = Table.Group(
        #"Removed Columns",
        {"Tourney Name", "Surface", "Tourney Date", "Tourney Level"},
        {{"Distinct Count", each Table.RowCount(Table.Distinct(_)), Int64.Type}}
    ),
    // Adding the "Title" column by checking if "Distinct Count" is greater than 1
    #"Added Title" = Table.AddColumn(
        #"Grouped Rows", "Title", each if [Distinct Count] > 1 then "Yes" else "No", type text
    ),
    // Removing the "Distinct Count" column
    #"Removed Columns1" = Table.RemoveColumns(#"Added Title", {"Distinct Count"})
in
    #"Removed Columns1"
