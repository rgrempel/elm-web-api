Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.AnimationFrame = Elm.Native.WebAPI.AnimationFrame || {};

Elm.Native.WebAPI.AnimationFrame.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.AnimationFrame = localRuntime.Native.WebAPI.AnimationFrame || {};

    if (!localRuntime.Native.WebAPI.AnimationFrame.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
       
        localRuntime.Native.WebAPI.AnimationFrame.values = {
            task: Task.asyncFunction(function (callback) {
                requestAnimationFrame(function (time) {
                    callback(Task.succeed(time));
                });
            }),

            request: function (taskProducer) {
                return Task.asyncFunction(function (callback) {
                    var request = requestAnimationFrame(function (time) {
                        Task.perform(taskProducer(time));
                    });

                    callback(Task.succeed(request));
                });
            },

            cancel: function (request) {
                return Task.asyncFunction(function (callback) {
                    cancelAnimationFrame(request);
                    callback(Task.succeed(Utils.Tuple0));
                });
            }
        };
    }
    
    return localRuntime.Native.WebAPI.AnimationFrame.values;
};
