// This query creates the "Alcaraz Wins" table and finishes cleaning and processing this part of the data
let
    // Referencing the "atp_matches_2023" query
    Source = atp_matches_2023,
    // Filtering the "winner_name" column to show only the rows with the "Carlos Alcaraz" value
    #"Filtered Rows" = Table.SelectRows(Source, each ([winner_name] = "Carlos Alcaraz")),
    // Removing the "winner_name", "l_ace" and "l_df" columns
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows", {"winner_name", "l_ace", "l_df"}),
    // Renaming the columns to make them easier to understand
    #"Renamed Columns" = Table.RenameColumns(
        #"Removed Columns",
        {
            {"loser_name", "Opponent"},
            {"w_ace", "Aces"},
            {"w_df", "Doubles Faults"},
            {"w_svpt", "Serve Points"},
            {"w_1stIn", "First Serves Made"},
            {"w_1stWon", "First Serve Points Won"},
            {"w_2ndWon", "Second Serve Points Won"},
            {"w_bpSaved", "Break Points Saved"},
            {"w_bpFaced", "Break Points Faced"},
            {"tourney_name", "Tourney Name"},
            {"tourney_date", "Tourney Date"},
            {"l_bpFaced", "Break Points Opportunities"},
            {"l_1stIn", "Opponent First Serves Made"},
            {"score", "Score"}
        }
    ),
    // Adding the "Break Points Converted" column by subtracting "l_bpSaved" from "Break Points Opportunities"
    #"Added Break Points Converted" = Table.AddColumn(
        #"Renamed Columns", "Break Points Converted", each [Break Points Opportunities] - [l_bpSaved], Int64.Type
    ),
    // Adding the "First Set Won" column by checking if the first digit of "Score" is greater than the second digit
    #"Added First Set Won" = Table.AddColumn(
        #"Added Break Points Converted",
        "First Set Won",
        each if Number.FromText(Text.Start([Score], 1)) > Number.FromText(Text.Range([Score], 2, 1)) then "Yes" else "No",
        type text
    ),
    // Adding the "Match Result" column with the value "Win" in each row
    #"Added Match Result" = Table.AddColumn(#"Added First Set Won", "Match Result", each "Win", type text),
    // Adding the "Second Serves Made" column by subtracting "First Serves Made" from "Serve Points"
    #"Added Second Serves Made" = Table.AddColumn(
        #"Added Match Result", "Second Serves Made", each [Serve Points] - [First Serves Made], Int64.Type
    ),
    // Adding the "First Serve Return Points" column by subtracting "l_1stWon" from "Opponent First Serves Made"
    #"Added First Serve Return Points" = Table.AddColumn(
        #"Added Second Serves Made",
        "First Serve Return Points",
        each [Opponent First Serves Made] - [l_1stWon],
        Int64.Type
    ),
    // Adding the "Opponent Second Serves Made" column by subtracting "Opponent First Serves Made" from "l_svpt"
    #"Added Opponent Second Serves Made" = Table.AddColumn(
        #"Added First Serve Return Points",
        "Opponent Second Serves Made",
        each [l_svpt] - [Opponent First Serves Made],
        Int64.Type
    ),
    // Adding the "Second Serve Return Points" column by subtracting "l_2ndWon" from "Opponent Second Serves Made"
    #"Added Second Serve Return Points" = Table.AddColumn(
        #"Added Opponent Second Serves Made",
        "Second Serve Return Points",
        each [Opponent Second Serves Made] - [l_2ndWon],
        Int64.Type
    ),
    // Removing the "l_bpSaved", "l_svpt", "l_1stWon", "l_2ndWon" and "Score" columns
    #"Removed Columns1" = Table.RemoveColumns(
        #"Added Second Serve Return Points", {"l_bpSaved", "l_svpt", "l_1stWon", "l_2ndWon", "Score"}
    )
in
    #"Removed Columns1"
