module WebAPI.Native
    ( unsafeCoerce
    ) where

{-| These represent functions which should only be used as a substitute for
otherwise needing to write 'native' code. That is, these functions are just as
dangerous as native code is -- they are not subject to the usual Elm
guarantees. However, they are no worse than *actually* writing native code.
That is, the ways in which you have to be careful with these functions are
exactly the same ways you have to be careful with native code. So, these
are meant for use only when you would otherwise be writing 'native' code.

@docs unsafeCoerce
-}


import Native.WebAPI.Native


{-| Like `Basics.identity`, but will accept any type and return any type. So,
this is for cases where you know that you have something of a particular type,
but (for some reason) the type checker does not know that. As the name implies,
this is "unsafe" in the sense that the type checker does not verify that the
types line up. So, it's sort of like `Debug.crash`, in the sense that it permits
you to express some things which you know that the type checker can't understand.

This is equivalent to any use of native code, since the type checker also
cannot check that the values returned from native code are of the correct type.
-}
unsafeCoerce : a -> b
unsafeCoerce = Native.WebAPI.Native.unsafeCoerce
