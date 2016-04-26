module WebAPI.Json
    ( instanceOf, JsType, typeOf
    , debox, isString, isNumber, isBoolean
    ) where


{-| Some additional functions for working with `Json.Encode.Value` and
its synonym `Json.Decode.Value`.

@docs instanceof, JsType, typeOf
@docs debox, isString, isNumber, isBoolean
-}


import Json.Encode as JE
import Json.Decode as JD

import WebAPI.Function
import Native.WebAPI.Json


{-| The browser's `instanceof` -}
instanceOf : WebAPI.Function.Function -> JE.Value -> Bool
instanceOf = Native.WebAPI.Json.instanceof


nativeTypeOf : JE.Value -> String
nativeTypeOf = Native.WebAPI.Json.nativeTypeOf


{-| A Javascript object type. Note that we distinguish between `Null`
and `Object`, which Javascript's `typeof` doesn't do. For `Other`, the string
is whatever Javascript's `typeof` returned that we weren't expecting.
-}
type JsType
    = Undefined
    | Null
    | Object
    | Boolean
    | Number
    | String
    | Symbol
    | Function
    | Other String


toJsType : String -> JsType
toJsType string =
    case string of
        "undefined" -> Undefined
        "null" -> Null
        "object" -> Object
        "boolean" -> Boolean
        "number" -> Number
        "string" -> String
        "symbol" -> Symbol
        "function" -> Function
        _ -> Other string


{-| The browser's `typeOf`. Note that we show the type of `null` as `Null`
rather than `Object`.
-}
typeOf : JE.Value -> JsType
typeOf = toJsType << nativeTypeOf


{-| Checks whether the value is a primitive string or a String object. -}
isString : JE.Value -> Bool
isString = Native.WebAPI.Json.isString


{-| Checks whether the value is a primitive number or a Number object. -}
isNumber : JE.Value -> Bool
isNumber = Native.WebAPI.Json.isNumber


{-| Checks whether the value is a primitive boolean or a Boolean object. -}
isBoolean : JE.Value -> Bool
isBoolean = Native.WebAPI.Json.isBoolean


{-| If the value is a Number, String, or Boolean object, return the
equivalent primitive. Otherwise, return the value itself.
-}
debox : JE.Value -> JE.Value
debox = Native.WebAPI.Json.debox
