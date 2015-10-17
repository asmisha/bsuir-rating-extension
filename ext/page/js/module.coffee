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

    @setMarks: (tabId, students, callback) ->
        Extension.emit(tabId, 'content', 'setMarks', {
            students: students
        }, callback)
        return

angular.module('ext', ['RDash']);
angular.module('RDash', ['ui.bootstrap', 'ui.router', 'ngCookies']);

angular.module('ext')

routes =
    index:
        url: '/?tab'
        template: 'index.html'
        controller: 'index'

angular.module('ext').config(['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->
    addRoute = ($stateProvider, p, n, r) ->
        state =
            url: r.url
            controller: r.controller
            reloadOnSearch: r.reloadOnSearch
        if (r.template)
            state.templateUrl = '/page/templates/' + r.template + '?' + (new Date().getTime() / 1000 | 0)
        if (r.views)
            state.views = r.views;
        $stateProvider.state(p + n, state)
        if r.routes
            for nn of r.routes
                addRoute($stateProvider, p + n + '.', nn, r.routes[nn])

    $urlRouterProvider.otherwise '/'
    for name of routes
        addRoute($stateProvider, '', name, routes[name])
]).filter('join', ()->
    (x, y) ->
        x.join(y)

).controller('index', [
    '$scope'
    '$stateParams'
    ($scope, $stateParams) ->
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

            q = 0.7
            for i in students
                i.l = (i.l - minL) / (maxL - minL)
                for j,k in i.labs
                    if j*1 == j
                        i.labs[k] = 5 + Math.round(5*(q-Math.random()*(1 - i.l)*q))
                i.l = Math.round(i.l * 100)/100

            $scope.students = students;
        )

        $scope.go = () ->
            Extension.setMarks($stateParams.tab * 1, $scope.students)

        return
]).controller('init', [
    '$scope'
    '$cookieStore'
    '$stateParams'
    ($scope, $cookieStore, $stateParams) ->
        return
])
