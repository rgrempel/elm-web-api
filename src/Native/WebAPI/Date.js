Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Date = Elm.Native.WebAPI.Date || {};

Elm.Native.WebAPI.Date.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Date = localRuntime.Native.WebAPI.Date || {};

    if (!localRuntime.Native.WebAPI.Date.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);

        localRuntime.Native.WebAPI.Date.values = {
            current : Task.asyncFunction(function (callback) {
                callback(
                    Task.succeed(
                        new Date ()
                    )
                );
            }),

            now : Task.asyncFunction(function (callback) {
                callback(
                    Task.succeed(
                        Date.now()
                    )
                );
            }),

            fromParts : function (parts) {
                return new Date(
                    parts.year,
                    parts.month,
                    parts.day,
                    parts.hour,
                    parts.minutes,
                    parts.seconds,
                    parts.milliseconds
                );
            },

            utc : function (parts) {
                return Date.UTC(
                    parts.year,
                    parts.month,
                    parts.day,
                    parts.hour,
                    parts.minutes,
                    parts.seconds,
                    parts.milliseconds
                );
            }
        };
    }

    return localRuntime.Native.WebAPI.Date.values;
};
