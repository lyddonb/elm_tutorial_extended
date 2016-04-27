module Pages.FooBarPage (..) where

import Html exposing (..)

import Actions exposing (..)
import Models exposing (..)

import FooBar.Form

foobarCreatePage : Signal.Address Action -> AppModel -> Html.Html
foobarCreatePage address model =
  let
    viewModel =
      { form = model.fooForm 
      }
  in
    FooBar.Form.view (Signal.forwardTo address FooBarAction) viewModel
