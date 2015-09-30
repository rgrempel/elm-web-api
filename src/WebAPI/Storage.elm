module WebAPI.Storage
    ( Storage, localStorage, sessionStorage
    , length, key, getItem, setItem, removeItem, clear
    ) where


{-| Facilities from the browser's `Storage` object.

See the [Mozilla documentation](https://developer.mozilla.org/en-US/docs/Web/API/Storage)

## Objects 

@docs Storage, localStorage, sessionStorage

## Functions

@docs length, key, getItem, setItem, removeItem, clear
-}


import Task exposing (Task)
import Native.WebAPI.Storage


{-| The browser's `Storage` API. Access via `localStorage` or `sessionStorage`.
-}
type Storage = Storage


{-| The browser's `localStorage` object.
-}
localStorage : Storage
localStorage = Native.WebAPI.Storage.localStorage


{-| The browser's `sessionStorage` object.
-}
sessionStorage : Storage
sessionStorage = Native.WebAPI.Storage.sessionStorage


{-| A task which, when executed, determines the number of items stored in the
`Storage` object.
-}
length : Storage -> Task x Int
length = Native.WebAPI.Storage.length


{-| A task which, when executed, determines the name of the key at the given
index (zero-based).
-}
key : Storage -> Int -> Task x (Maybe String)
key = Native.WebAPI.Storage.key


{-| A task which, when executed, gets the value at the given key.
-}
getItem : Storage -> String -> Task x (Maybe String)
getItem = Native.WebAPI.Storage.getItem


{-| A task which, when executed, sets the value (third parameter)
at the given key (second parameter), or fails with an error message.
-}
setItem : Storage -> String -> String -> Task String ()
setItem = Native.WebAPI.Storage.setItem


{-| A task which, when executed, removes the item with the given key.
-}
removeItem : Storage -> String -> Task x ()
removeItem = Native.WebAPI.Storage.removeItem


{-| A task which, when executed, removes all items.
-}
clear : Storage -> Task x ()
clear = Native.WebAPI.Storage.clear
