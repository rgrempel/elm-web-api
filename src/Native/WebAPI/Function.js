Elm.Native = Elm.Native || {};
Elm.Native.WebAPI = Elm.Native.WebAPI || {};
Elm.Native.WebAPI.Function = Elm.Native.WebAPI.Function || {};

Elm.Native.WebAPI.Function.make = function (localRuntime) {
    localRuntime.Native = localRuntime.Native || {};
    localRuntime.Native.WebAPI = localRuntime.Native.WebAPI || {};
    localRuntime.Native.WebAPI.Function = localRuntime.Native.WebAPI.Function || {};

    if (!localRuntime.Native.WebAPI.Function.values) {
        var Task = Elm.Native.Task.make(localRuntime);
        var List = Elm.Native.List.make(localRuntime);
        var Utils = Elm.Native.Utils.make(localRuntime);
        var Result = Elm.Result.make(localRuntime);

        // Copied from Native/Json.js
        var crash = function crash (expected, actual) {
            throw new Error(
                'expecting ' + expected + ' but got ' + JSON.stringify(actual)
            );
        };

        var handleResponse = function handleResponse (response) {
            var result;

            switch (response.ctor) {
                case 'Result':
                    result = response._0;
                    break;

                case 'Async':
                    // Perform the task, but ignore it
                    Task.perform(response._0);
                    result = response._1;
                    break;

                case 'Sync':
                    // We'll use the supplied default, unless the Task is
                    // actually synchronous, in which case we'll get that
                    // below.
                    result = response._1;

                    // Construct success and failure tasks, so we can get the
                    // success or failure values as we perform.
                    var success = A2(Task.andThen, response._0, function (value) {
                        result = Result.Ok(value);
                        return Task.succeed(value);
                    });

                    var failure = A2(Task.catch_, success, function (value) {
                        result = Result.Err(value);
                        return Task.fail(value);
                    });

                    Task.perform(failure);
                    break;

                default:
                    throw new Error("Incomplete pattern match in Function.js");
            }

            if (result.ctor === 'Ok') {
                return result._0;
            } else {
                throw result._0;
            }
        };
        
        localRuntime.Native.WebAPI.Function.values = {
            message: function (error) {
                if (error.message) {
                    return error.message;
                } else {
                    return error.toString();
                }
            },

            error: function (message) {
                return new Error(message);
            },

            decoder: function (value) {
                if (typeof value === 'function') {
                    return value;
                }

                crash('a Javascript function', value);
            },

            encode: function (value) {
                return value;
            },

            length: function (func) {
                return func.length;
            },

            apply: F3(function (self, params, func) {
                return Task.asyncFunction(function (callback) {
                    try {
                        var result = func.apply(self, List.toArray(params));
                        callback(Task.succeed(result));
                    } catch (ex) {
                        callback(Task.fail(ex));
                    }
                });
            }),

            pure: F3(function (self, params, func) {
                try {
                    var result = func.apply(self, List.toArray(params));
                    return Result.Ok(result);
                } catch (ex) {
                    return Result.Err(ex);
                }
            }),

            construct: F2(function (params, func) {
                return Task.asyncFunction(function (callback) {
                    try {
                        // We need to use `new` with an array of params. We can
                        // do that via `bind`, since `bind` binds a function to
                        // some params. We initially bind to a `null` this,
                        // because `new` will supply the `this` anyway, of
                        // course. And, we need to `apply` the bind, because we
                        // want to supply the arguments to `bind` as an array.
                        //
                        // There is also probably a way to do this with
                        // Object.create.
                        var args = [null].concat(List.toArray(params));
                        var funcWithArgs = Function.prototype.bind.apply(func, args);
                        var result = new funcWithArgs();
                        callback(Task.succeed(result));
                    } catch (ex) {
                        callback(Task.fail(ex));
                    }
                });
            }),

            javascript: F2(function (params, body) {
                try {
                    /* jshint evil:true */
                    var func = new Function(List.toArray(params), body);
                    return Result.Ok(func);
                } catch (ex) {
                    return Result.Err(ex);
                }
            }),

            elm: function (func) {
                return function () {
                    var self = this;
                    
                    // Json.Decode expects to see primitives, so we use valueOf.
                    if (
                        self instanceof String ||
                        self instanceof Boolean ||
                        self instanceof Number
                    ) self = self.valueOf();

                    // Func wants to be called with a Javascript array in which
                    // the first element is whatever `this` is, and the rest
                    // are the arguments. So, we construct one!
                    var params = [self];

                    var length = arguments.length;
                    for (var i = 0; i < length; i++) {
                        params.push(arguments[i]);
                    }

                    var response = func(params); 
                    return handleResponse(response);
                };
            }
        };
    }

    return localRuntime.Native.WebAPI.Function.values;
};
