module Actions (..) where

import Players.Actions
import FooBar.Form
import Routing

type Action
  = NoOp
  | RoutingAction Routing.Action
  | PlayersAction Players.Actions.Action
  | FooBarAction FooBar.Form.Action
  | ShowError String
