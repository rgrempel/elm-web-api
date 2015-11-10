Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Document = Elm.Native.WebAPI.Document || {};

Elm.Native.WebAPI.Document.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Document = localRuntime.Native.WebAPI.Document || {};

    if (!localRuntime.Native.WebAPI.Document.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var NS = Elm.Native.Signal.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);

        var Loading = {ctor: 'Loading'};
        var Interactive = {ctor: 'Interactive'};
        var Complete = {ctor: 'Complete'};

        var getState = function () {
            switch (document.readyState) {
                case "loading":
                    return Loading;

                case "interactive":
                    return Interactive;

                case "complete":
                    return Complete;

                default:
                    throw new Error("Got unrecognized document.readyState: " + document.readyState);
            }
        };

        var readyState = NS.input('WebAPI.Document.readyState', getState());

        localRuntime.addListener([readyState.id], document, 'readystatechange', function () {
            localRuntime.notify(readyState.id, getState());
        });

        localRuntime.Native.WebAPI.Document.values = {
            readyState: readyState,

            getReadyState: Task.asyncFunction(function (callback) {
                callback(Task.succeed(getState()));
            }),

            getTitle : Task.asyncFunction(function (callback) {
                callback(Task.succeed(document.title));
            }),

            setTitle : function (title) {
                return Task.asyncFunction(function (cb) {
                    document.title = title;
                    cb(Task.succeed(Utils.Tuple0));
                });
            },

            events : document
        };
    }

    return localRuntime.Native.WebAPI.Document.values;
};
