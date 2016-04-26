module FooBar.Form (..) where

import Effects exposing (Effects)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Form exposing (Form)
import Form.Field as Field
import Form.Validate as Validate exposing (..)
import Form.Input as Input

-- Our record to manage

type alias Foo =
  { bar : String
  , baz : Bool
  }

new : Foo
new =
  { bar = ""
  , baz = False
  }


-- FORM Stuff

type alias FormModel =
  { form : Form() Foo }


type Action =
  NoOp
  | FormAction Form.Action


init : Form() Foo
init =
  Form.initial [] validate

validate : Validation () Foo
validate =
  form2 Foo
    (get "bar" email)
    (get "baz" bool)

getFooFromModel : FormModel -> Foo
--getFooFromModel : Form a Foo -> Foo
getFooFromModel formModel =
  new
  --let 
    --model = Form.getOutput formModel
  --in
    --case model of

      --Just model ->
        --model

      --Nothing ->
        --new

--update : Action -> FormModel -> (Foo, Effects Action)
--update action ({form} as model) =
  --case action of

    --NoOp ->
      --((getFooFromModel model), Effects.none)

    --FormAction formAction ->
      --((getFooFromModel { model | form = Form.update formAction form }), Effects.none)

update : Action -> FormModel -> (FormModel, Effects Action)
update action ({form} as model) =
  case action of
    NoOp ->
      (model, Effects.none)

    FormAction formAction ->
      ({ model | form = Form.update formAction form }, Effects.none)

view : Signal.Address Action -> FormModel -> Html
view address {form} =
  let
    --form = Form.initial [ ("bar", Field.Text foo.bar)
                        --, ("baz", Field.Check foo.baz)] validate

    -- Our form event address
    formAddress = Signal.forwardTo address FormAction

    -- error presenter
    errorFor field =
      case field.liveError of
        Just error ->
          -- replace the toString with custom translations
          div [ class "error" ] [ text (toString error) ]
        Nothing ->
          text ""

    -- field states
    bar = Form.getFieldAsString "bar" form
    baz = Form.getFieldAsBool "baz" form
  in
    div []
      [ label [] [ text "Bar" ] 
      , Input.textInput bar formAddress []
      , errorFor bar
      
      , label []
        [ Input.checkboxInput baz formAddress []
        , text "Baz"
        ]
      , errorFor baz

      , button
        [ onClick formAddress Form.Submit ]
        [ text "Submit" ]
      ]
