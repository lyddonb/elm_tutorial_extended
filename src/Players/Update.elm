module Players.Update (..) where

import Debug
import Effects exposing (Effects)
import Hop.Navigate exposing (navigateTo)
import Http
import Task

-- Local

import Players.Actions exposing (..)
import Players.Effects exposing (..)
import Players.Models exposing (..)


type alias UpdateModel =
  { players : List Player
  , showErrorAddress : Signal.Address String
  , deleteConfirmationAddress : Signal.Address ( PlayerId, String )
  }

noEffect : List Player -> (List Player, Effects Action)
noEffect players =
  ( players, Effects.none )

errorHandler : Http.Error -> UpdateModel -> ( List Player, Effects Action )
errorHandler error model =
  let
    errorMessage =
      toString error

    fx =
      Signal.send model.showErrorAddress errorMessage
        |> Effects.task
        |> Effects.map TaskDone
  in
    ( model.players, fx )


-- TODO: Kill the magic strings below and use the config file

update : Action -> UpdateModel -> ( List Player, Effects Action )
update action model =
  case action of
    EditPlayer id ->
      let
          path =
            "/players/" ++ (toString id) ++ "/edit"
      in
         ( model.players, Effects.map HopAction (navigateTo path) )

    ListPlayers ->
      let
          path =
            "/players"
      in
         ( model.players, Effects.map HopAction (navigateTo path) )

    FetchAllDone result ->
      case result of
        Ok players ->
          noEffect players

        Err error ->
          errorHandler error model

    CreatePlayer ->
      ( model.players, create new )

    CreatePlayerDone result ->
      case result of
        Ok player ->
          let
            updatedCollection =
              player :: model.players

            fx =
              Task.succeed (EditPlayer player.id)
                |> Effects.task
          in 
            ( updatedCollection, fx )

        Err error ->
          errorHandler error model

    DeletePlayerIntent player ->
      let
        msg =
          "Are you sure you want to delete " ++ player.name ++ "?"

        fx =
          Signal.send model.deleteConfirmationAddress ( player.id, msg )
            |> Effects.task
            |> Effects.map TaskDone
      in
        ( model.players, fx )

    DeletePlayer playerId ->
      (model.players, delete playerId)

    DeletePlayerDone playerId result ->
      case result of
        Ok _ ->
          let
            notDeleted player =
              player.id /= playerId

            updatedCollection =
              List.filter notDeleted model.players
          in
            ( updatedCollection, Effects.none )

        Err error ->
          errorHandler error model

    ChangeLevel playerId howMuch ->
      let
        fxForPlayer player =
          if player.id /= playerId then
            Effects.none
          else
            let
              updatedPlayer =
                { player | level = player.level + howMuch }
            in
              if updatedPlayer.level > 0 then
                 save updatedPlayer
              else
                 Effects.none

        fx =
          List.map fxForPlayer model.players
            |> Effects.batch
      in 
        ( model.players, fx )

    SaveDone result ->
      case result of
        Ok player ->
          let
            updatedPlayer existing =
              if existing.id == player.id then
                 player
              else
                 existing

            updatedCollection =
              List.map updatedPlayer model.players
          in
            ( updatedCollection, Effects.none )
        
        Err error ->
          errorHandler error model

    ChangeName playerId newName ->
      let
        updatedPlayer player =
          if player.id == playerId then
             { player | name = newName }
          else
             player

        updatedCollection =
          List.map updatedPlayer model.players
      in
        ( updatedCollection, Effects.none )

    SubmitForm playerId ->
      let
        path = "/players"
        fxForPlayer player =
          if player.id /= playerId then
            Effects.none
          else
            save player

        fx =
          List.map fxForPlayer model.players
            |> Effects.batch
      in 
        ( model.players, Effects.map HopAction (navigateTo path) )

    TaskDone () ->
      noEffect model.players

    HopAction _ ->
      noEffect model.players

    NoOp ->
      noEffect model.players
