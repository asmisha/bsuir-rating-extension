class @Extension
    @emit: (tabId, to, method, params, callback) ->
        console.log('>', to, method, params)

        data =
            from: 'popup'
            to: to
            method: method
            params: params

        if to == 'content'
            chrome.tabs.sendMessage(tabId, data, callback)
        else
            chrome.runtime.sendMessage(data, callback)

        return

    @waitTabLoaded: (tabId, callback) ->
        h = setInterval((() ->
            chrome.tabs.executeScript(tabId, {runAt: 'document_end', code: 'document.readyState;'}, (data) ->
                if data && data[0] == 'complete'
                    clearInterval(h)
                    setTimeout(callback, 1000)
                return
            )
        ), 500)
        return

    @setMarks: (tabId, students, overwriteOld, callback) ->
        Extension.emit(tabId, 'content', 'setMarks', {
            students: students
            overwriteOld: overwriteOld
        }, callback)
        return

angular.module('ext', ['ui.router'])
.config(($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise("/")
    $stateProvider.state('index',
        url: "/?tab",
        templateUrl: '/page/templates/index.html'
        controller: 'index'
    )
).filter('join', ()->
    (x, y) ->
        x.join(y)

).controller('index', [
    '$scope'
    '$stateParams'
    ($scope, $stateParams) ->
        console.log($stateParams.tab * 1)
        $scope.labs = {
            minCnt: 3
            cnt: 8
        }

        $scope.$watch((() -> JSON.stringify($scope.labs)), () ->
            if !$scope.labs.text
                return

            students = $scope.labs.text.split("\n");
            sl = 0

            students = students.map((p) ->
                labs = []
                info = p.split(',')

                name = info[0]
                info[0] = ''

                for i in info
                    cur = 0
                    for j in i.split(/[^\d]/).join('')
                        for k in j
                            k *= 1
                            if cur
                                labs.push(cur * 10 + k)
                                cur = 0
                            else
                                if labs.indexOf(k) == -1
                                    labs.push(k)
                                else
                                    if k * 10 <= $scope.labs.cnt
                                        cur = k

                if $scope.labs.minCnt
                    while labs.length < $scope.labs.minCnt
                        labs.push('нб')
                if $scope.labs.cnt
                    while labs.length < $scope.labs.cnt
                        labs.push('нз')

                l = info.join('').length
                sl += l
                return {
                    name: name,
                    labs: labs,
                    l: l
                }
            )

            al = sl / students.length
            minL = 1e9
            maxL = -1e9
            for i in students
                i.l = (i.l - al)/al
                minL = Math.min(minL, i.l)
                maxL = Math.max(maxL, i.l)

            q = 2
            for i in students
                i.l = (i.l - minL) / (maxL - minL)
                for j,k in i.labs
                    if j*1 == j
#                        i.labs[k] = 10 - Math.round(6*(Math.random()*(1 - i.l)))
                        i.labs[k] = 10 - Math.round(6*(1-i.l)+q*(Math.random() - 0.5))
                        i.labs[k] = Math.max(4, i.labs[k])
                        i.labs[k] = Math.min(10, i.labs[k])
                i.l = Math.round(i.l * 100)/100

            $scope.students = students;
        )

        $scope.go = () ->
            Extension.setMarks($stateParams.tab * 1, $scope.students, $scope.labs.overwriteOld)

        return
]).controller('init', [
    () ->
        return
])
