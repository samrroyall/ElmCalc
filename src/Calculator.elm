module Calculator exposing (main)

import CalcHelpers.SubscriptionsHelpers exposing (..)
import CalcHelpers.UpdateHelpers exposing (..)
import CalcHelpers.ViewHelpers exposing (..)
import CalcHelpers.CalcTypes exposing (..)

import Browser
import Browser.Events
import Html exposing (..)
import Html.Events
import Html.Attributes
import Platform.Sub exposing (batch)
import Json.Decode as Decode
import Tuple

--------------------------------------------------------------------------------
------------------------------------ Types -------------------------------------
--------------------------------------------------------------------------------


type alias Flags = ()

type alias Model =
  { exprs : List (String, (Expr, String))
  , currSymbols : List (Symbol)
  , currSymbol : String
  , currString : String
  , error : String
  , shiftChar : Maybe (String)
  }

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

init : Flags -> (Model, Cmd Msg)
init () = (initModel, Cmd.none)

initModel : Model
initModel =
  { exprs = []
  , currSymbols = []
  , currSymbol = ""
  , currString = ""
  , error = ""
  , shiftChar = Nothing
  }

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Browser.Events.onKeyDown
      (Decode.map assignKey keyDecoder)
    ]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Calculate      ->
      if model.currString == ""
        then (model, Cmd.none)
      else
        let
          newModel = Tuple.first (update PushSymbol model)
          newExpr =  parseSymbolList newModel.currSymbols
          newAnswer =
            case newExpr of
              Invalid -> "Invalid"
              _       ->
                let answer = Debug.toString (eval newExpr) in
                  if answer == "Infinity" || answer == "-Infinity"
                    then "Undefined"
                    else answer
        in
          ( {initModel | exprs = checkLog (List.append newModel.exprs [(newModel.currString, (newExpr, newAnswer))])}
          , Cmd.none
          )
    AddSymbol s    ->
      case model.shiftChar of
        Nothing ->
          ( { model | currString = model.currString ++ s, currSymbol = model.currSymbol ++ s, error = "" }
          , Cmd.none
          )
        Just _  ->
          update (assignShift s) { model | shiftChar = Nothing }
    PushSymbol      ->
      let newSym = getSymbol model.currSymbol in
        case newSym of
          Empty -> (model, Cmd.none)
          _     ->
            ( { model | currSymbols = List.append model.currSymbols [newSym], currSymbol = ""}
            , Cmd.none
            )
    Build (s, sym) ->
      let
        newModel = Tuple.first (update PushSymbol model)
        newSyms =
          case sym of
            Empty -> newModel.currSymbols
            _     -> List.append newModel.currSymbols [sym]
        str =
          case s of
            "r" -> "\u{221A}"
            _   -> s
      in
        ( { newModel | currString = newModel.currString ++ str, currSymbols = newSyms, error = "", shiftChar = Nothing }
        , Cmd.none
        )
    Clear          -> ( initModel , Cmd.none )
    Error s        -> ( { model | error = s }, Cmd.none )
    WaitForChar    -> ({model | shiftChar = Just " "}, Cmd.none)
    DoNothing      -> (model, Cmd.none)
    HandleMinus    ->
      let
        len = List.length model.currSymbols
        lastSymbol = case (List.drop (len-1) model.currSymbols) of
          x :: [] -> x
          _       -> Empty
        number = case lastSymbol of
          Op o   -> False
          LParen -> True
          RParen -> True
          INum i -> True
          FNum f -> True
          Empty  -> False
          _      -> Debug.todo "Should not happen"
      in
        if (model.currSymbol == "") && (number == False)
          then update (AddSymbol "-") model
          else update (Build ("-", Op "-")) model
    Trig s         ->
      let newModel = Tuple.first (update (Build (s, Op s)) model) in
        update (Build ("(", LParen)) newModel

    Backspace      ->
      let
        len1 = String.length model.currString
        len2 = String.length model.currSymbol
        len3 = List.length model.currSymbols
      in
        if model.currSymbol /= ""
          then
            ( { model | currString = String.slice 0 (len1-1) model.currString
                      , currSymbol = String.slice 0 (len2-1) model.currSymbol
                      , shiftChar  = Nothing
              }
              , Cmd.none
            )
          else
            ( { model | currString = String.slice 0 (len1-1) model.currString
                      , currSymbols = List.take (len3-1) model.currSymbols
                      , currSymbol = ""
                      , shiftChar = Nothing
              }
              , Cmd.none
            )

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

view : Model -> Html Msg
view model =
     Html.div []
     [
       Html.div (class "calculator")
         [ Html.div (class "screenWrapper")
             [ Html.div (class "title")
                 [Html.text "ElmCalc"]
             , Html.div (class "log")
               (displayLog model.exprs)
             , Html.div (class "entry")
               [ Html.text model.currString ]
             ]
         , Html.div (class "buttons")
               [ Html.div (class "row")
                   [makeButton "\u{221A}", makeButton ".", makeButton "(", makeButton ")", makeButton "^", makeButton "DEL"]
               , Html.div (class "row")
                   [makeButton "log", makeButton "ln", makeButton "7", makeButton "8", makeButton "9", makeButton "/"]
               , Html.div (class "row")
                   [makeButton "sin\u{207b}\u{00b9}", makeButton "sin", makeButton "4", makeButton "5", makeButton "6", makeButton "*"]
               , Html.div (class "row")
                   [makeButton "cos\u{207b}\u{00b9}", makeButton "cos", makeButton "1", makeButton "2", makeButton "3", makeButton "+"]
               , Html.div (class "row")
                   [makeButton "tan\u{207b}\u{00b9}", makeButton "tan", makeButton "0", makeButton "ENTER", makeButton "CLEAR", makeButton "-"]
               ]
         ]
     , Html.div (class "errors")
          [ Html.text model.error ]
     ]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
