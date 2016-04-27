module Pages.NotFound (..) where

import Html exposing (..)

notFoundView : Html.Html
notFoundView =
  div
    []
    [ text "Not found"
    ]
