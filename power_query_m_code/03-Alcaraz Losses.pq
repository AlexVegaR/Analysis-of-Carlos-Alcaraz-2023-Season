// This query creates the "Alcaraz Losses" table and finishes cleaning and processing this part of the data
let
    // Referencing the "atp_matches_2023" query
    Source = atp_matches_2023,
    // Filtering the "loser_name" column to show only the rows with the "Carlos Alcaraz" value
    #"Filtered Rows" = Table.SelectRows(Source, each ([loser_name] = "Carlos Alcaraz")),
    // Removing the "loser_name", "w_ace" and "w_df" columns
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows", {"loser_name", "w_ace", "w_df"}),
    // Renaming the columns to make them easier to understand
    #"Renamed Columns" = Table.RenameColumns(
        #"Removed Columns",
        {
            {"winner_name", "Opponent"},
            {"l_ace", "Aces"},
            {"l_df", "Doubles Faults"},
            {"l_svpt", "Serve Points"},
            {"l_1stIn", "First Serves Made"},
            {"l_1stWon", "First Serve Points Won"},
            {"l_2ndWon", "Second Serve Points Won"},
            {"l_bpSaved", "Break Points Saved"},
            {"l_bpFaced", "Break Points Faced"},
            {"tourney_name", "Tourney Name"},
            {"tourney_date", "Tourney Date"},
            {"w_bpFaced", "Break Points Opportunities"},
            {"w_1stIn", "Opponent First Serves Made"},
            {"score", "Score"}
        }
    ),
    // Adding the "Break Points Converted" column by subtracting "w_bpSaved" from "Break Points Opportunities"
    #"Added Break Points Converted" = Table.AddColumn(
        #"Renamed Columns", "Break Points Converted", each [Break Points Opportunities] - [w_bpSaved], Int64.Type
    ),
    // Adding the "First Set Won" column by checking if the first digit of "Score" is greater than the second digit
    #"Added First Set Won" = Table.AddColumn(
        #"Added Break Points Converted",
        "First Set Won",
        each if Number.FromText(Text.Start([Score], 1)) > Number.FromText(Text.Range([Score], 2, 1)) then "No" else "Yes",
        type text
    ),
    // Adding the "Match Result" column with the value "Loss" in each row
    #"Added Match Result" = Table.AddColumn(#"Added First Set Won", "Match Result", each "Loss", type text),
    // Adding the "Second Serves Made" column by subtracting "First Serves Made" from "Serve Points"
    #"Added Second Serves Made" = Table.AddColumn(
        #"Added Match Result", "Second Serves Made", each [Serve Points] - [First Serves Made], Int64.Type
    ),
    // Adding the "First Serve Return Points" column by subtracting "w_1stWon" from "Opponent First Serves Made"
    #"Added First Serve Return Points" = Table.AddColumn(
        #"Added Second Serves Made",
        "First Serve Return Points",
        each [Opponent First Serves Made] - [w_1stWon],
        Int64.Type
    ),
    // Adding the "Opponent Second Serves Made" column by subtracting "Opponent First Serves Made" from "w_svpt"
    #"Added Opponent Second Serves Made" = Table.AddColumn(
        #"Added First Serve Return Points",
        "Opponent Second Serves Made",
        each [w_svpt] - [Opponent First Serves Made],
        Int64.Type
    ),
    // Adding the "Second Serve Return Points" column by subtracting "w_2ndWon" from "Opponent Second Serves Made"
    #"Added Second Serve Return Points" = Table.AddColumn(
        #"Added Opponent Second Serves Made",
        "Second Serve Return Points",
        each [Opponent Second Serves Made] - [w_2ndWon],
        Int64.Type
    ),
    // Removing the "w_bpSaved", "w_1stWon", "w_2ndWon", "w_svpt" and "Score" columns
    #"Removed Columns1" = Table.RemoveColumns(
        #"Added Second Serve Return Points", {"w_bpSaved", "w_1stWon", "w_2ndWon", "w_svpt", "Score"}
    )
in
    #"Removed Columns1"
