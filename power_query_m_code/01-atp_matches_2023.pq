// This query is the first step in creating the "Alcaraz 2023 Matches" dataset
let
    // Getting data from the csv file "atp_matches_2023 - copy.csv"
    Source = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Carlos Alcaraz 2023 Season\datasets\atp_matches_2023 - copy.csv"),
        [
            Delimiter = ",",
            Columns = 49,
            Encoding = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),
    // Promoting the headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Removing unnecessary columns for the analysis
    #"Removed Columns" = Table.RemoveColumns(
        #"Promoted Headers",
        {
            "tourney_id",
            "draw_size",
            "match_num",
            "winner_id",
            "winner_seed",
            "winner_entry",
            "winner_ht",
            "winner_ioc",
            "winner_age",
            "loser_id",
            "loser_seed",
            "loser_entry",
            "loser_ht",
            "loser_ioc",
            "loser_age",
            "best_of",
            "w_SvGms",
            "l_SvGms",
            "winner_hand",
            "loser_hand",
            "minutes",
            "winner_rank",
            "winner_rank_points",
            "loser_rank",
            "loser_rank_points"
        }
    ),
    /*Adding the columns "Tourney Level", "Round" and "Surface" by replacing the values of the existing ones 
    to make them easier to understand*/
    #"Added Columns" = Table.AddColumn(
        #"Removed Columns",
        "Custom",
        each
            [
                Tourney Level = if [tourney_level] = "A" then
                    "Other Events"
                else if [tourney_level] = "G" then
                    "Grand Slams"
                else if [tourney_level] = "M" then
                    "Masters 1000s"
                else
                    null,
                Round = if [round] = "F" then
                    "Finals"
                else if [round] = "QF" then
                    "Quarter-Finals"
                else if [round] = "R128" then
                    "Round of 128"
                else if [round] = "R16" then
                    "Round of 16"
                else if [round] = "R32" then
                    "Round of 32"
                else if [round] = "R64" then
                    "Round of 64"
                else if [round] = "RR" then
                    "Round Robin"
                else if [round] = "SF" then
                    "Semi-Finals"
                else
                    null,
                Surface = if [surface] = "Hard" then
                    "Hard Court"
                else if [surface] = "Grass" then
                    "Grass Court"
                else if [surface] = "Clay" then
                    "Clay Court"
                else
                    null
            ]
    ),
    // Expanding the previously added columns "Tourney Level", "Round" and "Surface"
    #"Expanded Columns" = Table.ExpandRecordColumn(
        #"Added Columns", "Custom", {"Tourney Level", "Round", "Surface"}, {"Tourney Level", "Round", "Surface"}
    ),
    // Removing the original columns "tourney_level", "round" and "surface"
    #"Removed Columns1" = Table.RemoveColumns(#"Expanded Columns", {"tourney_level", "round", "surface"}),
    // Changing the columns to their proper data type
    #"Changed Type" = Table.TransformColumnTypes(
        #"Removed Columns1",
        {
            {"tourney_name", type text},
            {"Surface", type text},
            {"tourney_date", type date},
            {"winner_name", type text},
            {"loser_name", type text},
            {"score", type text},
            {"w_ace", Int64.Type},
            {"w_df", Int64.Type},
            {"w_svpt", Int64.Type},
            {"w_1stIn", Int64.Type},
            {"w_1stWon", Int64.Type},
            {"w_2ndWon", Int64.Type},
            {"w_bpSaved", Int64.Type},
            {"w_bpFaced", Int64.Type},
            {"l_ace", Int64.Type},
            {"l_df", Int64.Type},
            {"l_svpt", Int64.Type},
            {"l_1stIn", Int64.Type},
            {"l_1stWon", Int64.Type},
            {"l_2ndWon", Int64.Type},
            {"l_bpSaved", Int64.Type},
            {"l_bpFaced", Int64.Type},
            {"Tourney Level", type text},
            {"Round", type text}
        }
    )
in
    #"Changed Type"
