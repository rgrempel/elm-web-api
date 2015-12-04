Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Native = Elm.Native.WebAPI.Native || {};

Elm.Native.WebAPI.Native.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Native = localRuntime.Native.WebAPI.Native || {};

    if (!localRuntime.Native.WebAPI.Native.values) {
        localRuntime.Native.WebAPI.Native.values = {
            unsafeCoerce: function (a) {
                return a;
            }
        };
    }
    
    return localRuntime.Native.WebAPI.Native.values;
};
