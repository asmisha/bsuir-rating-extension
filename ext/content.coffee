### Listen for message from the popup ###

class Content
    forceStop: false

    emit: (to, method, params, callback) ->
        console.log('>', to, method, params)

        chrome.runtime.sendMessage({
            from: 'content'
            to: to
            method: method
            params: params
        }, callback)

    setMarks: (params) ->
        self = this
        students = params.students

        first = 0
        for tab,tabK in $('ul li.tab-link')
            $('a', tab)[0].click()
            last = first
            for i,k in students
                k2 = first
                k3 = 0
                while k2 < i.labs.length
                    j = i.labs[k2]

                    while true
                        $select = $($($($('table')[tabK]).find('tr')[k + 2]).find('select')[k3])

                        if !$select
                            break
                        if $select.is(':disabled')
                            k3++
                            continue
                        break

                    if !$select.length
                        break

                    v = j
                    if v*1 == v
                        $option = $select.find("option[value='#{v}']")
                    else
                        $option = $select.find("option:contains('#{v}')")
                    $option.prop('selected', true)
                    k2++
                    k3++
                    last = Math.max(last, k2)
            first = last

        for i in $('form')
            $.post($(i).attr('action'), $(i).serialize())

        return

content = new Content()

console.log('init')

chrome.runtime.onMessage.addListener((msg, sender, response) ->
    if msg.to == 'content'
        console.log(msg.from, '>', msg.to, msg.method, msg.params)
        response(content[msg.method](msg.params))

    return
)
