// This query creates the "Rank History" dataset
let
    // Getting data from the csv file "alcaraz_rank_history.csv"
    Source = Csv.Document(
        File.Contents("D:\Documents\Portfolio\Carlos Alcaraz 2023 Season\datasets\alcaraz_rank_history.csv"),
        [
            Delimiter = ",",
            Columns = 3,
            Encoding = 1252,
            QuoteStyle = QuoteStyle.None
        ]
    ),
    // Promoting the headers
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Changing the columns to their proper data type
    #"Changed Type" = Table.TransformColumnTypes(
        #"Promoted Headers", {{"date", type date}, {"singles_rank", Int64.Type}, {"atp_points", Int64.Type}}
    ),
    // Renaming the columns "date", "singles_rank" and "atp_points" to "Date", "Rank" and "Rank Points"
    #"Renamed Columns" = Table.RenameColumns(
        #"Changed Type", {{"date", "Date"}, {"singles_rank", "Rank"}, {"atp_points", "Rank Points"}}
    )
in
    #"Renamed Columns"
