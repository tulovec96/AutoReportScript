-- Function to normalize message and catch common bypasses
local function normalize(msg)
    msg = string.lower(msg)
    msg = msg:gsub("[%p%c%s]", "") -- remove punctuation, control chars, and spaces

    -- Character substitutions (leetspeak/common evasion)
    msg = msg
        :gsub("0", "o")
        :gsub("1", "i")
        :gsub("2", "z")
        :gsub("3", "e")
        :gsub("4", "a")
        :gsub("5", "s")
        :gsub("6", "g")
        :gsub("7", "t")
        :gsub("8", "b")
        :gsub("9", "g")
        :gsub("@", "a")
        :gsub("%$", "s")
        :gsub("!", "i")
        :gsub("|", "i")
        :gsub("£", "e")
        :gsub("€", "e")
        :gsub("¢", "c")
        :gsub("§", "s")
        :gsub("™", "tm")
        :gsub("æ", "ae")
        :gsub("œ", "oe")
        :gsub("ß", "ss")

    return msg
end

-- Expanded dictionary
local words = {
    -- Bullying
    ['gay'] = 'Bullying', ['lesbian'] = 'Bullying', ['retard'] = 'Bullying',
    ['clown'] = 'Bullying', ['cl0wn'] = 'Bullying', ['bozo'] = 'Bullying',
    ['getalife'] = 'Bullying', ['nolife'] = 'Bullying', ['fatherless'] = 'Bullying',
    ['motherless'] = 'Bullying', ['dumb'] = 'Bullying', ['stupid'] = 'Bullying',
    ['cringe'] = 'Bullying', ['skillissue'] = 'Bullying', ['ugly'] = 'Bullying',
    ['child'] = 'Bullying', ['kys'] = 'Bullying', ['die'] = 'Bullying',
    ['d!e'] = 'Bullying', ['killyou'] = 'Bullying', ['kill'] = 'Bullying',
    ['k!ll'] = 'Bullying', ['loser'] = 'Bullying', ['fat'] = 'Bullying',
    ['fatty'] = 'Bullying', ['skid'] = 'Bullying', ['sk1d'] = 'Bullying',
    ['f@ggot'] = 'Bullying', ['f@g'] = 'Bullying', ['n1gger'] = 'Bullying',
    ['n!gger'] = 'Bullying', ['ni99er'] = 'Bullying', ['nibba'] = 'Bullying',
    ['tranny'] = 'Bullying', ['tr4nny'] = 'Bullying', ['simp'] = 'Bullying',
    ['incel'] = 'Bullying', ['beta'] = 'Bullying', ['weak'] = 'Bullying',
    ['crybaby'] = 'Bullying', ['goaway'] = 'Bullying', ['nobodylikesyou'] = 'Bullying',

    -- Scamming / Exploits
    ['hack'] = 'Scamming', ['cheat'] = 'Scamming', ['exploit'] = 'Scamming',
    ['executor'] = 'Scamming', ['dll'] = 'Scamming', ['inject'] = 'Scamming',
    ['injector'] = 'Scamming', ['.exe'] = 'Scamming', ['ex3'] = 'Scamming',
    ['h@ck'] = 'Scamming', ['bl0x'] = 'Scamming', ['krnl'] = 'Scamming',
    ['synapse'] = 'Scamming', ['script'] = 'Scamming', ['aimbot'] = 'Scamming',
    ['triggerbot'] = 'Scamming', ['silentaim'] = 'Scamming', ['esp'] = 'Scamming',
    ['speedhack'] = 'Scamming', ['godmode'] = 'Scamming', ['noclip'] = 'Scamming',
    ['flyhack'] = 'Scamming',

    -- Offsite / Phishing
    ['discord'] = 'Offsite Links', ['d!scord'] = 'Offsite Links',
    ['d1sc0rd'] = 'Offsite Links', ['blueapp'] = 'Offsite Links',
    ['youtube'] = 'Offsite Links', ['yt'] = 'Offsite Links',
    ['.gg'] = 'Offsite Links', ['https://'] = 'Offsite Links',
    ['http://'] = 'Offsite Links', ['link'] = 'Offsite Links',
    ['l1nk'] = 'Offsite Links', ['tiktok'] = 'Offsite Links',
    ['invite'] = 'Offsite Links', ['joinmyserver'] = 'Offsite Links',
    ['freerobux'] = 'Offsite Links', ['r0bux'] = 'Offsite Links',
    ['robuxgiveaway'] = 'Offsite Links', ['robuxgen'] = 'Offsite Links',
    ['clickhere'] = 'Offsite Links', ['verify'] = 'Offsite Links',
    ['nitro'] = 'Offsite Links', ['giftcard'] = 'Offsite Links',
    ['promo'] = 'Offsite Links'
}

-- Send webhook notification
local function sendWebhook(speaker, msg, keyword, category)
    local plr = game.Players:FindFirstChild(speaker)
    if not plr then return end

    local avatar = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", plr.UserId)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local embed = {
        ["embeds"] = { {
            ["title"] = "🚨 AutoReport Triggered",
            ["description"] = "A message violated the Roblox ToS and was auto-reported.",
            ["color"] = tonumber(0xff3333),
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = string.format("[%s](https://www.roblox.com/users/%d)", plr.Name, plr.UserId), ["inline"] = true},
                {["name"] = "🧠 Message", ["value"] = msg, ["inline"] = false},
                {["name"] = "🚫 Trigger", ["value"] = "`" .. keyword .. "` (" .. category .. ")", ["inline"] = true},
                {["name"] = "🕒 Time", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = true},
                {["name"] = "🎮 Game", ["value"] = "[" .. gameName .. "](https://www.roblox.com/games/" .. game.PlaceId .. ")", ["inline"] = false}
            },
            ["thumbnail"] = {["url"] = avatar},
            ["footer"] = {["text"] = "AutoReport Logger"},
            ["author"] = {["name"] = "Roblox AutoReporter"}
        }}
    }

    local http = game:GetService("HttpService")
    local request = http_request or request or HttpPost or http.request or syn.request
    request({
        Url = autoreportcfg.Webhook,
        Body = http:JSONEncode(embed),
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"}
    })
end

-- Core handler
function handler(msg, speaker)
    local norm = normalize(msg)
    for word, reason in pairs(words) do
        if norm:find(word) then
            local player = game.Players:FindFirstChild(speaker)
            if player then
                game.Players:ReportAbuse(player, reason, "Reported for " .. reason)
                task.wait(1.5)
                game.Players:ReportAbuse(player, reason, "Reported again for " .. reason)

                if autoreportcfg.Webhook and autoreportcfg.Webhook:match("%S") then
                    sendWebhook(speaker, msg, word, reason)
                end

                if autoreportcfg.autoMessage.enabled then
                    DCSCE.SayMessageRequest:FireServer("/w " .. speaker .. " " .. autoreportcfg.autoMessage.Message, "All")
                end
            end
            break
        end
    end
end
