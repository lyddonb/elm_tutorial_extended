module Update (..) where

import Effects exposing (Effects)
import Debug

import Mailboxes exposing (..)
import Models exposing (..)
import Actions exposing (..)
import Routing
import Players.Update


update : Action -> AppModel -> ( AppModel, Effects Action )
update action model =
  case (Debug.log "action" action) of
    PlayersAction subAction ->
      let
        updateModel =
          { players = model.players
          , showErrorAddress = Signal.forwardTo actionsMailbox.address ShowError
          , deleteConfirmationAddress = askDeleteConfirmationMailbox.address
          }

        ( updatedPlayers, fx ) =
          Players.Update.update subAction updateModel
      in
        ( { model | players = updatedPlayers }, Effects.map PlayersAction fx )

    RoutingAction subAction ->
      let
        ( updatedRouting, fx ) =
          Routing.update subAction model.routing
      in
        ( { model | routing = updatedRouting }, Effects.map RoutingAction fx )

    ShowError message ->
      ( { model | errorMessage = message }, Effects.none )

    NoOp ->
      (model, Effects.none)
