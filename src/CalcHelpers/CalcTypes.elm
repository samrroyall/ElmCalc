module CalcHelpers.CalcTypes exposing (..)

type Expr = Integer Int
          | Floating Float
          | Plus Expr Expr
          | Divide Expr Expr
          | Multiply Expr Expr
          | Power Expr Expr
          | Sin Expr
          | Cos Expr
          | Tan Expr
          | Arcsin Expr
          | Arccos Expr
          | Arctan Expr
          | Ln Expr
          | Log Expr
          | Invalid

type Msg = Calculate
         | AddSymbol String
         | PushSymbol
         | Build (String, Symbol)
         | Clear
         | DoNothing
         | Error String
         | WaitForChar
         | Backspace
         | HandleMinus
         | Trig String

type Symbol = INum Int
            | FNum Float
            | LParen
            | RParen
            | Op String
            | Empty
            | Ex Symbol Symbol Symbol

type Key = Character Char
         | Control String
