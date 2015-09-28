Elm.Native = Elm.Native || {};
Elm.Native.Browser = Elm.Native.Browser || {};
Elm.Native.Browser.Math = Elm.Native.Browser.Math || {};

Elm.Native.Browser.Math.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.Browser = localRuntime.Native.Browser || {};
    localRuntime.Native.Browser.Math = localRuntime.Native.Browser.Math || {};

    if (!localRuntime.Native.Browser.Math.values) {
        var Task = Elm.Native.Task.make(localRuntime);
    
        localRuntime.Native.Browser.Math.values = {
            ln2: Math.LN2,
            ln10: Math.LN10,
            log2e: Math.LOG2E,
            log10e: Math.LOG10E,
            sqrt1_2: Math.SQRT1_2,
            sqrt2: Math.SQRT2,
            exp: Math.exp,
            log: Math.log,

            random: Task.asyncFunction(function (callback) {
                callback(Task.succeed(Math.random()));
            })
        };
    }
    
    return localRuntime.Native.Browser.Math.values;
};
