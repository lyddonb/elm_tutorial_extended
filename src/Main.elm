module Main (..) where

import Html exposing (..)
import Effects exposing (Effects, Never)
import Task
import StartApp

-- Local Imports
import Routing

import Actions exposing (..)
import Mailboxes exposing (..)
import Models exposing (..)
import Update exposing (..)
import View exposing (..)

import Players.Actions
import Players.Effects

getDeleteConfirmationSignal : Signal Actions.Action
getDeleteConfirmationSignal =
  let
    toAction id =
      id
        |> Players.Actions.DeletePlayer
        |> PlayersAction
  in
    Signal.map toAction getDeleteConfirmation

routerSignal : Signal Action
routerSignal =
  Signal.map RoutingAction Routing.signal

init : (AppModel, Effects Action)
init =
  let
      fxs =
        [ Effects.map PlayersAction Players.Effects.fetchAll
        ]

      fx =
        Effects.batch fxs
  in
    (Models.initialModel, fx)

app : StartApp.App AppModel
app =
  StartApp.start
    { init = init
    , inputs = [ routerSignal
               , actionsMailbox.signal
               , getDeleteConfirmationSignal
               ]
    , update = update
    , view = view
    }

main : Signal.Signal Html.Html
main =
  app.html

port routeRunTask : Task.Task () ()
port routeRunTask =
  Routing.run

port askDeleteConfirmation : Signal ( Int, String )
port askDeleteConfirmation =
  askDeleteConfirmationMailbox.signal

port getDeleteConfirmation : Signal Int

port runner : Signal (Task.Task Never ())
port runner =
  app.tasks
