module Players.Effects (..) where

import Effects exposing (Effects)
import Http
import Json.Decode as Decode exposing ((:=), oneOf, succeed)
import Json.Encode as Encode
import Task

import Settings exposing (..)

import Players.Models exposing (PlayerId, Player)
import Players.Actions exposing (..)


-- URLs

fetchAllUrl : String
fetchAllUrl =
  baseAPIUrl ++ "/players"

createUrl : String
createUrl =
  baseAPIUrl ++ "/players"

deleteUrl : PlayerId -> String
deleteUrl playerId =
  baseAPIUrl ++ "/players/" ++ (toString playerId)

saveUrl : Int -> String
saveUrl playerId =
  baseAPIUrl ++ "/players/" ++ (toString playerId)

-- Fetch

fetchAll : Effects Action
fetchAll =
  Http.get collectionDecoder fetchAllUrl
    |> Task.toResult
    |> Task.map FetchAllDone
    |> Effects.task

-- Create

create : Player -> Effects Action
create player =
  let
    body =
      memberEncoded player
        |> Encode.encode 0
        |> Http.string
  in
     -- A simple post, to set headers for CORS, etc will need to use the send 
     -- method with a config like delete below.
     -- https://github.com/evancz/elm-http/blob/3.0.0/src/Http.elm#L90
     -- or look at https://github.com/lukewestby/elm-http-extra/tree/5.2.0
     Http.post memberDecoder createUrl body
      |> Task.toResult
      |> Task.map CreatePlayerDone
      |> Effects.task

-- Delete

deleteTask : PlayerId -> Task.Task Http.Error ()
deleteTask playerId =
  let
    config =
      { verb = "DELETE"
      , headers = [ ( "Content-Type", "application/json" ) ]
      , url = deleteUrl playerId
      , body = Http.empty
      }
  in
    -- This can be switched to Post now
    Http.send Http.defaultSettings config
      |> Http.fromJson (Decode.succeed ())

delete : PlayerId -> Effects Action
delete playerId =
  deleteTask playerId
    |> Task.toResult
    |> Task.map (DeletePlayerDone playerId)
    |> Effects.task

-- Save

saveTask : Player -> Task.Task Http.Error Player
saveTask player =
  let
    body =
      memberEncoded player
        |> Encode.encode 0
        |> Http.string

    config =
      { verb = "PATCH"
      , headers = [ ( "Content-Type", "application/json" ) ]
      , url = saveUrl player.id
      , body = body
      }
  in
    Http.send Http.defaultSettings config
      |> Http.fromJson memberDecoder

save : Player -> Effects Action
save player =
  saveTask player
    |> Task.toResult
    |> Task.map SaveDone
    |> Effects.task


-- Decoders

collectionDecoder : Decode.Decoder (List Player)
collectionDecoder =
  Decode.list memberDecoder

memberDecoder : Decode.Decoder Player
memberDecoder =
  Decode.object3
    Player
    ("id" := Decode.int)
    -- This handles values missing. Not ideal but is what it is
    (oneOf [ "name" := Decode.string, succeed ""])
    (oneOf [ "level" := Decode.int, succeed 0])
    --("name" := Decode.string)
    --("level" := Decode.int)

memberEncoded : Player -> Encode.Value
memberEncoded player =
  let
    list =
      [ ( "id", Encode.int player.id )
      , ( "name", Encode.string player.name )
      , ( "level", Encode.int player.level )
      ]
  in
    list
      |> Encode.object
