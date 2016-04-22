module Players.Actions (..) where

import Http
import Hop

import Players.Models exposing (PlayerId, Player)

type Action
  = NoOp
  | HopAction ()
  | EditPlayer PlayerId
  | ListPlayers
  | FetchAllDone ( Result Http.Error (List Player) )
  | TaskDone ()
  | CreatePlayer
  | CreatePlayerDone (Result Http.Error Player)
  | DeletePlayerIntent Player
  | DeletePlayer PlayerId
  | DeletePlayerDone PlayerId (Result Http.Error ())
  | ChangeLevel PlayerId Int
  | SaveDone (Result Http.Error Player)
  | ChangeName PlayerId String
  | SubmitForm PlayerId
