Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Screen = Elm.Native.WebAPI.Screen || {};

Elm.Native.WebAPI.Screen.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Screen = localRuntime.Native.WebAPI.Screen || {};

    if (!localRuntime.Native.WebAPI.Screen.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
    
        localRuntime.Native.WebAPI.Screen.values = {
            // Note that this is a Task because in a multi-monitor setup, the
            // result depends on which monitor the browser window is being
            // displayed on. So, it's not a constant.
            //
            // That's also why we copy the screen object ... otherwise, it
            // would be *live* reference to the screen, and thus, not constant.
            screen: Task.asyncFunction(function (callback) {
                callback(
                    Task.succeed(
                        Utils.copy(window.screen)
                    )
                );
            }),

            screenXY: Task.asyncFunction(function (callback) {
                callback(
                    Task.succeed(
                        Utils.Tuple2(window.screenX, window.screenY)
                    )
                );
            })
        };
    }
    
    return localRuntime.Native.WebAPI.Screen.values;
};
