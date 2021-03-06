local mod = {}

-- Anycomplete
function mod.anycomplete()
    -- local ENDPOINT = 'https://suggestqueries.google.com/complete/search?client=firefox&q=%s'
    local ENDPOINT = 'https://duckduckgo.com/ac/?q=%s'
    local current = hs.application.frontmostApplication()

    local chooser = hs.chooser.new(function(choosen)
        current:activate()
        hs.eventtap.keyStrokes(choosen.text)
    end)

    chooser:queryChangedCallback(function(string)
        local query = hs.http.encodeForQuery(string)

        hs.http.asyncGet(string.format(ENDPOINT, query), nil, function(status, data)
            if not data then return end

            local ok, results = pcall(function() return hs.json.decode(data) end)
            if not ok then return end

            -- Google
            -- choices = hs.fnutils.imap(results[2], function(result)
            --     return {
            --         ["text"] = result,
            --     }
            -- end)

            -- DuckCuckGo
            choices = hs.fnutils.imap(results, function(result)
                return {
                    ["text"] = result["phrase"],
                }
            end)

            chooser:choices(choices)
        end)
    end)

    chooser:searchSubText(false)

    chooser:show()
end

function mod.registerDefaultBindings(mods, key)
    mods = mods or {"cmd", "alt", "ctrl"}
    key = key or "G"
    hs.hotkey.bind(mods, key, mod.anycomplete)
end

return mod
