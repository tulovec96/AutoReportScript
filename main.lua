-- Function to normalize message and catch common bypasses
local function normalize(msg)
    msg = string.lower(msg)
    msg = msg:gsub("[%p%c%s]", "") -- remove punctuation, control chars, spaces
    msg = msg
        :gsub("0", "o")
        :gsub("1", "i")
        :gsub("3", "e")
        :gsub("4", "a")
        :gsub("@", "a")
        :gsub("%$", "s")
        :gsub("!", "i")
        :gsub("5", "s")
        :gsub("|", "i")
    return msg
end

-- Expanded dictionary
local words = {
    -- One-word & short insults
    ['l'] = 'Bullying',
    ['looser'] = 'Bullying',
    ['loser'] = 'Bullying',
    ['shutup'] = 'Bullying',
    ['yousuck'] = 'Bullying',
    ['getlost'] = 'Bullying',
    ['cryaboutit'] = 'Bullying',
    ['ihateyou'] = 'Bullying',
    ['killurself'] = 'Bullying',
    ['dumbass'] = 'Bullying',
    ['bitch'] = 'Bullying',
    ['asshole'] = 'Bullying',
    ['bastard'] = 'Bullying',

    -- Existing bullying entries
    ['gay'] = 'Bullying', ['lesbian'] = 'Bullying', ['retard'] = 'Bullying', ['r3tard'] = 'Bullying',
    ['clown'] = 'Bullying', ['bozo'] = 'Bullying', ['getalife'] = 'Bullying', ['nolife'] = 'Bullying',
    ['fatherless'] = 'Bullying', ['motherless'] = 'Bullying', ['dumb'] = 'Bullying', ['stupid'] = 'Bullying',
    ['cringe'] = 'Bullying', ['skillissue'] = 'Bullying', ['ugly'] = 'Bullying', ['child'] = 'Bullying',
    ['kys'] = 'Bullying', ['k!s'] = 'Bullying', ['kyslf'] = 'Bullying', ['kysyourself'] = 'Bullying',
    ['die'] = 'Bullying', ['d!e'] = 'Bullying', ['d13'] = 'Bullying', ['unalive'] = 'Bullying',
    ['killyou'] = 'Bullying', ['kill'] = 'Bullying', ['k!ll'] = 'Bullying', ['kll'] = 'Bullying',
    ['fat'] = 'Bullying', ['fatty'] = 'Bullying', ['skid'] = 'Bullying',
    ['sk1d'] = 'Bullying', ['idiot'] = 'Bullying', ['moron'] = 'Bullying',
    ['worthless'] = 'Bullying', ['nobodylikesyou'] = 'Bullying', ['goaway'] = 'Bullying',
    ['nobodycares'] = 'Bullying', ['bot'] = 'Bullying', ['trash'] = 'Bullying', ['npc'] = 'Bullying',
    ['smd'] = 'Bullying', ['suckmy'] = 'Bullying', ['d1e'] = 'Bullying', ['dum'] = 'Bullying',
    ['fool'] = 'Bullying', ['scrub'] = 'Bullying',

    -- Identity-based Slurs
    ['nigger'] = 'Bullying', ['n1gger'] = 'Bullying', ['n!gger'] = 'Bullying', ['ni99er'] = 'Bullying',
    ['nigg'] = 'Bullying', ['niga'] = 'Bullying', ['nibba'] = 'Bullying',
    ['faggot'] = 'Bullying', ['f@ggot'] = 'Bullying', ['f@g'] = 'Bullying', ['fgt'] = 'Bullying',
    ['faqqot'] = 'Bullying', ['tranny'] = 'Bullying', ['tr4nny'] = 'Bullying', ['tr@nny'] = 'Bullying',
    ['he-she'] = 'Bullying', ['shemale'] = 'Bullying', ['dyke'] = 'Bullying', ['d!ke'] = 'Bullying',
    ['queer'] = 'Bullying', ['monkey'] = 'Bullying', ['ape'] = 'Bullying', ['coon'] = 'Bullying',
    ['wetback'] = 'Bullying', ['beaner'] = 'Bullying', ['chink'] = 'Bullying', ['gook'] = 'Bullying',

    -- Exploiting / Scamming
    ['hack'] = 'Scamming', ['h@ck'] = 'Scamming', ['cheat'] = 'Scamming', ['exploit'] = 'Scamming',
    ['executor'] = 'Scamming', ['inject'] = 'Scamming', ['dll'] = 'Scamming', ['injector'] = 'Scamming',
    ['.exe'] = 'Scamming', ['ex3'] = 'Scamming', ['blox'] = 'Scamming', ['krnl'] = 'Scamming',
    ['synapse'] = 'Scamming', ['silentaim'] = 'Scamming', ['aimbot'] = 'Scamming',
    ['esp'] = 'Scamming', ['autoclick'] = 'Scamming', ['flyhack'] = 'Scamming',

    -- Offsite Links
    ['discord'] = 'Offsite Links', ['d!scord'] = 'Offsite Links', ['d1sc0rd'] = 'Offsite Links',
    ['blueapp'] = 'Offsite Links', ['youtube'] = 'Offsite Links', ['yt'] = 'Offsite Links',
    ['.gg'] = 'Offsite Links', ['https://'] = 'Offsite Links', ['link'] = 'Offsite Links',
    ['l1nk'] = 'Offsite Links', ['tiktok'] = 'Offsite Links', ['invite'] = 'Offsite Links',
    ['freerobux'] = 'Offsite Links', ['r0bux'] = 'Offsite Links', ['tinyurl'] = 'Offsite Links',
    ['bitly'] = 'Offsite Links', ['goo.gl'] = 'Offsite Links'
}

-- Webhook reporter
local function sendWebhook(speaker, msg, keyword, category)
    local plr = game.Players:FindFirstChild(speaker)
    if not plr then return end

    local avatar = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png", plr.UserId)
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local embed = {
        ["embeds"] = {{
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

-- Main handler
function handler(msg, speaker)
    local norm = normalize(msg)
    for word, reason in pairs(words) do
        if string.find(norm, word, 1, true) then
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
