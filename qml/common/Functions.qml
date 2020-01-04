import QtQuick 2.6

Item {

    property bool loaded: false
    property var settings

    // Functions
    function apiKeyPresent() {
        return settings.apiKey !== "" && settings.apiSecret !== ""
    }

    function currencySymbol() {
        var result = ""
        switch (settings.currency) {
        case 'EUR':
            result = "€"
            break
        case 'USD':
            result = "$"
            break
        }
        return result
    }

    function formatPrice(input, digets) {

        if(digets === undefined) {
            digets = 6
        }

        var length = Math.round(input).toString().length
        var fixedPrecision = (digets - length)
        if (fixedPrecision < 0) {
            fixedPrecision = 0
        }

        return currencySymbol() + input.toFixed(fixedPrecision)
    }

    function balanceResult(result) {
        console.debug("balance_result", result.result.BAT)
    }

    // Elements
    Settings {
        id: settings
    }
}
