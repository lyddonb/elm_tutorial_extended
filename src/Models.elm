module Models (..) where

import Players.Models exposing (Player)
import FooBar.Form exposing (Foo, init)
import Form exposing (Form)
import Routing

type alias AppModel =
  { players : List Player 
  , routing : Routing.Model
  , errorMessage : String
  , foobars : List Foo
  , fooForm : Form() Foo
  }

initialModel : AppModel
initialModel =
  { players = []
  , routing = Routing.initialModel
  , errorMessage = ""
  , foobars = []
  , fooForm = init
  }
