module Update (..) where

import Effects exposing (Effects)
import Debug

import Mailboxes exposing (..)
import Models exposing (..)
import Actions exposing (..)
import Routing
import Players.Update
import FooBar.Form


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

    FooBarAction subAction ->
      let
         --TODO: Just pass around list 
        updateModel =
          { form = model.fooForm
          --, foobars = model.foobars
          }
        ( updatedForm, fx ) =
          FooBar.Form.update subAction updateModel
      in
        ( { model | fooForm = updatedForm.form }, Effects.map FooBarAction fx )


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
