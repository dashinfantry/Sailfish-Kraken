import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "../common"
import "../views"

Page {

    // Properties
    property var assetPrairs: []
    property bool loading: false

    // Element values
    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All
    id: page

    // Functions
    function changeTab(index) {
        settings.homeTab = index
        tabs.moveTo(index)
    }

    function refreshData() {
        console.debug("Reload the data from the API")
        loading = true
        krakenApi.queryPublic(['AssetPairs'], refreshResult)
    }

    function refreshResult(data) {
        var assetPrairsResult = data.result
        var results = []
        var pairQuery = []
        for (var assetPrairKey in assetPrairsResult) {
            var assetPrair = assetPrairsResult[assetPrairKey]
            if (assetPrair.quote.indexOf(settings.currency) !== -1
                    && assetPrair.wsname) {
                results.push({
                                 "key": assetPrairKey,
                                 "name": assetPrair.base,
                                 "quote": assetPrair.quote,
                                 "ticker": {
                                     "opening": 0,
                                     "low": 0,
                                     "high": 0,
                                     "ask": 0,
                                     "bid": 0,
                                     "current": 0,
                                     "last24": 0
                                 }
                             })
                pairQuery.push(assetPrairKey)
            }
        }

        // Collect all keys so that we can gather the ticker data
        //var tickerUrl = "https://api.kraken.com/0/public/Ticker?pair="
        var tickerResult = krakenApi.queryPublic(['Ticker', {pair: pairQuery.join(",")}])
        var tickerData = tickerResult.result
        for (var idx in results) {

            results[idx].ticker.opening = parseFloat(
                        tickerData[results[idx].key].o)
            results[idx].ticker.low = parseFloat(
                        tickerData[results[idx].key].l[0])
            results[idx].ticker.high = parseFloat(
                        tickerData[results[idx].key].h[0])
            results[idx].ticker.ask = parseFloat(
                        tickerData[results[idx].key].a[0])
            results[idx].ticker.bid = parseFloat(
                        tickerData[results[idx].key].b[0])
            results[idx].ticker.current = parseFloat(
                        tickerData[results[idx].key].c[0])
            results[idx].ticker.low24 = parseFloat(
                        tickerData[results[idx].key].l[1])
        }

        // Save the results in the state
        assetPrairs = results

        loading = false
    }

    function setCurrency(cur) {
        console.debug(cur)
        settings.currency = cur
        refreshData()
    }

    // Elements
    Functions {
        id: functions
    }

    KrakenApi {
        id: krakenApi
    }

    Settings {
        id: settings
    }

    Component.onCompleted: {
        if (assetPrairs.length === 0) {
            refreshData()
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: functions.apiKeyPresent() ? qsTr("update-login") : qsTr("login")
                onClicked: pageStack.push(Qt.resolvedUrl("Credentials.qml"))
            }

            MenuItem {
                text: qsTr("refresh-now")
                onClicked: refreshData()
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: loading
        }

        TabView {
            id: tabs

            anchors.fill: parent
            currentIndex: settings.homeTab

            header: TabButtonRow {
                Repeater {
                    model: [qsTrId("market"), qsTrId("balance")]

                    TabButton {
                        onClicked: changeTab(model.index)

                        title: modelData
                        tabIndex: model.index
                    }
                }
            }

            model: [marketView, balanceView]
            Component {
                id: marketView
                Market {
                }
            }
            Component {
                id: balanceView
                Balance {
                }
            }
        }
    }
}
