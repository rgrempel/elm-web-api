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

            fromPartsLocal : function (parts) {
                return new Date(
                    parts.year,
                    parts.month,
                    parts.day,
                    parts.hour,
                    parts.minute,
                    parts.second,
                    parts.millisecond
                );
            },

            fromPartsUtc : function (parts) {
                return new Date(
                    Date.UTC(
                        parts.year,
                        parts.month,
                        parts.day,
                        parts.hour,
                        parts.minute,
                        parts.second,
                        parts.millisecond
                    )
                );
            },

            toPartsLocal : function (date) {
                return {
                    year: date.getFullYear(),
                    month: date.getMonth(),
                    day: date.getDate(),
                    hour: date.getHours(),
                    minute: date.getMinutes(),
                    second: date.getSeconds(),
                    millisecond: date.getMilliseconds()
                };
            },

            toPartsUtc : function (date) {
                return {
                    year: date.getUTCFullYear(),
                    month: date.getUTCMonth(),
                    day: date.getUTCDate(),
                    hour: date.getUTCHours(),
                    minute: date.getUTCMinutes(),
                    second: date.getUTCSeconds(),
                    millisecond: date.getUTCMilliseconds()
                };
            },

            timezoneOffsetInMinutes : function (date) {
                return date.getTimezoneOffset();
            },

            dayOfWeekUTC : function (date) {
                return date.getUTCDay();
            },

            offsetYearLocal : F2(function (offset, date) {
                var copy = new Date(date);
                copy.setFullYear(date.getFullYear() + offset);
                return copy;
            }),

            offsetYearUTC : F2(function (offset, date) {
                var copy = new Date(date);
                copy.setUTCFullYear(date.getUTCFullYear() + offset);
                return copy;
            }),

            offsetMonthLocal : F2(function (offset, date) {
                var copy = new Date(date);
                copy.setMonth(date.getMonth() + offset);
                return copy;
            }),

            offsetMonthUTC : F2(function (offset, date) {
                var copy = new Date(date);
                copy.setUTCMonth(date.getUTCMonth() + offset);
                return copy;
            }),

            dateString : function (date) {
                return date.toDateString();
            },

            timeString : function (date) {
                return date.toTimeString();
            },

            isoString : function (date) {
                return date.toISOString();
            },

            utcString : function (date) {
                return date.toUTCString();
            }
        };
    }

    return localRuntime.Native.WebAPI.Date.values;
};
