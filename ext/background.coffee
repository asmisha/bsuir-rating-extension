chrome.browserAction.onClicked.addListener((tab) ->
    url = "#{chrome.extension.getURL('page/index.html')}#/?tab=#{tab.id}"

    chrome.tabs.create({url: url});
);