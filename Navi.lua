local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local player = Player
local getgenv = getgenv or function() return _G end

local isEnemy, estaEnLobby, IsInMatchStrict
local esEnemigoValido, esCuchillo, esPistola, obtenerPistola
local startTargetMonitor, stopTargetMonitor
do
local playerGui = player:WaitForChild("PlayerGui")
local dmvsInvalidateRedirectSelection
local dmvsClearTargetParts
local function dmvsDisconnectConnectionList(list)
    if not list then return end
    for i = #list, 1, -1 do
        local connection = list[i]
        list[i] = nil
        if connection and connection.Connected then connection:Disconnect() end
    end
end
local dmvsIsInfectionMode
local function dmvsIsTargetAlive(target)
    local character = target
    if typeof(target) == "Instance" and target:IsA("Player") then
        character = target.Character
    end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if dmvsIsInfectionMode and dmvsIsInfectionMode() then
        return character:GetAttribute("InfectionDowned") ~= true
    end
    return humanoid.Health >= 99
end
local function dmvsGetInGameScoreboard()
    local gui = player:FindFirstChild("PlayerGui")
    local main = gui and gui:FindFirstChild("Main")
    local frame = main and main:FindFirstChild("MainGameFrame")
    return frame and frame:FindFirstChild("IngameScore") or nil
end

local dmvsTeamResolverState = {
    Snapshot = {},
    Scoreboard = nil,
    InGame = false,
    LocalGame = nil,
    LastRefresh = 0,
    RefreshInterval = 2,
    Dirty = true,
    WatchConnections = {}
}

local function dmvsInvalidateScoreboard()
    dmvsTeamResolverState.Dirty = true
end

local function dmvsWatchScoreboard(score)
    local state = dmvsTeamResolverState
    if state.Scoreboard == score then return end
    dmvsDisconnectConnectionList(state.WatchConnections)
    state.Scoreboard = score
    if not score then return end
    local watchTeams
    watchTeams = function()
        dmvsInvalidateScoreboard()
        dmvsDisconnectConnectionList(state.WatchConnections)
        state.WatchConnections[#state.WatchConnections + 1] = score.ChildAdded:Connect(watchTeams)
        state.WatchConnections[#state.WatchConnections + 1] = score.ChildRemoved:Connect(watchTeams)
        for _, name in ipairs({"TeamRed", "TeamBlue"}) do
            local folder = score:FindFirstChild(name)
            if folder then
                state.WatchConnections[#state.WatchConnections + 1] = folder.ChildAdded:Connect(dmvsInvalidateScoreboard)
                state.WatchConnections[#state.WatchConnections + 1] = folder.ChildRemoved:Connect(dmvsInvalidateScoreboard)
            end
        end
    end
    watchTeams()
end

local function dmvsRefreshScoreboardTeams(force)
    local state = dmvsTeamResolverState
    local now = os.clock()
    local localGame = player:GetAttribute("Game")
    if not force and not state.Dirty and now - state.LastRefresh < state.RefreshInterval
        and state.LocalGame == localGame
        and (not state.Scoreboard or state.Scoreboard.Parent) then
        return state.Snapshot
    end

    state.LastRefresh = now
    state.LocalGame = localGame
    local snapshot = {}
    local score = dmvsGetInGameScoreboard()
    if score ~= state.Scoreboard then dmvsWatchScoreboard(score) end
    for _, teamName in ipairs({"TeamRed", "TeamBlue"}) do
        local teamFolder = score and score:FindFirstChild(teamName)
        if teamFolder then
            local team = teamName == "TeamRed" and "Red" or "Blue"
            for _, entry in ipairs(teamFolder:GetChildren()) do
                if entry:IsA("GuiObject") then
                    snapshot[string.lower(entry.Name)] = team
                end
            end
        end
    end
    state.Snapshot = snapshot
    state.Dirty = false
    state.InGame = score ~= nil and snapshot[string.lower(player.Name)] ~= nil
    return snapshot
end

local dmvsInfectionRoleAttributes = {"InfectionInfected", "IsInfected", "Infected", "IsZombie", "Zombie"}
local dmvsInfectionModeAttributes = {"GameMode", "MatchMode", "Mode"}
local dmvsInfectionState = {
    Active = false,
    LastRefresh = -math.huge,
    RefreshInterval = 0.4,
    RoleTeams = {},
    Inferred = {},
    Targets = {},
    Converted = {},
    ConvertedAt = {},
    Pending = {},
    LateJoiners = {},
    LastLocalGame = nil,
    LastMatchId = nil,
    HasMatchContext = false,
    RoundEnded = false
}

local function dmvsInfectionReadMarker(holder)
    if not holder then return nil end
    if holder:GetAttribute("InfectionPatientZero") == true then return true end
    local sawSurvivor = false
    for _, name in ipairs(dmvsInfectionRoleAttributes) do
        local value = holder:GetAttribute(name)
        if typeof(value) == "boolean" then
            if value then return true end
            sawSurvivor = true
        elseif typeof(value) == "string" then
            local normalized = value:lower()
            if normalized == "infected" or normalized == "infection" or normalized == "zombie" or normalized == "true" then
                return true
            end
            if normalized == "survivor" or normalized == "human" or normalized == "false" then
                sawSurvivor = true
            end
        end
    end
    if sawSurvivor then return false end
    return nil
end

local function dmvsInfectionHasPatientZero(other)
    if other:GetAttribute("InfectionPatientZero") == true then return true end
    local character = other.Character
    if not character then return false end
    if character:GetAttribute("InfectionPatientZero") == true then return true end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid:GetAttribute("InfectionPatientZero") == true
end

local function dmvsInfectionAttribute(playerInstance)
    if not playerInstance then return nil end
    local character = playerInstance.Character
    local characterStatus = dmvsInfectionReadMarker(character)
    local playerStatus = dmvsInfectionReadMarker(playerInstance)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local humanoidStatus = dmvsInfectionReadMarker(humanoid)
    if characterStatus == true or playerStatus == true or humanoidStatus == true then return true end
    if characterStatus == false or playerStatus == false or humanoidStatus == false then return false end
    return nil
end

local function dmvsReadInfectionRoster(teams)
    local frame = playerGui:FindFirstChild("Main")
    frame = frame and frame:FindFirstChild("MainGameFrame")
    if not frame then return end
    local playerFrame = frame:FindFirstChild("PlayersFrame")
    local regularFrame = frame:FindFirstChild("IngameScore")
    local playerNames = {}
    local displayCandidates = {}
    local ambiguousDisplays = {}
    for _, other in ipairs(Players:GetPlayers()) do
        playerNames[other.Name:lower()] = other
        playerNames[tostring(other.UserId)] = other
        local displayKey = other.DisplayName:lower()
        if displayCandidates[displayKey] then ambiguousDisplays[displayKey] = true end
        displayCandidates[displayKey] = other
    end
    for displayKey, other in pairs(displayCandidates) do
        if not ambiguousDisplays[displayKey] and not playerNames[displayKey] then
            playerNames[displayKey] = other
        end
    end
    local function collect(group, team)
        if not group then return end
        for _, entry in ipairs(group:GetChildren()) do
            if entry:IsA("GuiObject") then
                local other = playerNames[entry.Name:lower():gsub("^@", "")]
                if not other then
                    local entryUserId = entry:GetAttribute("UserId")
                    if entryUserId then other = playerNames[tostring(entryUserId)] end
                end
                if not other then
                    for _, sub in ipairs(entry:GetDescendants()) do
                        if sub:IsA("TextLabel") and (sub.Name == "PlayerName" or sub.Name == "TextLabel") then
                            other = playerNames[sub.Text:lower():gsub("^@", "")]
                            if other then break end
                        end
                    end
                end
                if other then teams[other] = team end
            end
        end
    end
    if regularFrame then
        collect(regularFrame:FindFirstChild("TeamRed"), "Red")
        collect(regularFrame:FindFirstChild("TeamBlue"), "Blue")
    end
    if playerFrame then
        collect(playerFrame:FindFirstChild("TeamRedFrame"), "Red")
        collect(playerFrame:FindFirstChild("TeamBlueFrame"), "Blue")
    end
end

local function dmvsClearInfectionRound(ended)
    local state = dmvsInfectionState
    table.clear(state.Converted)
    table.clear(state.ConvertedAt)
    table.clear(state.Pending)
    table.clear(state.LateJoiners)
    table.clear(state.Inferred)
    table.clear(state.Targets)
    table.clear(state.RoleTeams)
    state.Active = false
    state.RoundEnded = ended == true
    state.LastRefresh = -math.huge
    if dmvsInvalidateRedirectSelection then dmvsInvalidateRedirectSelection() end
end

local function dmvsRefreshInfectionState(force)
    local state = dmvsInfectionState
    local now = os.clock()
    local localGame = player:GetAttribute("Game")
    local matchId = player:GetAttribute("MatchId")
    if state.HasMatchContext and (localGame ~= state.LastLocalGame or matchId ~= state.LastMatchId) then
        dmvsClearInfectionRound(false)
    end
    state.HasMatchContext = true
    state.LastLocalGame = localGame
    state.LastMatchId = matchId
    if not force and now - state.LastRefresh < state.RefreshInterval then
        return state
    end
    state.LastRefresh = now
    local regularRoster = dmvsRefreshScoreboardTeams(false)
    local foundPatientZero = false
    local ownCharacter = player.Character
    local myRoot = ownCharacter and ownCharacter:FindFirstChild("HumanoidRootPart")
    local allPlayers = Players:GetPlayers()
    for _, other in ipairs(allPlayers) do
        if dmvsInfectionHasPatientZero(other) then
            local compatible = other == player
            if not compatible then
                compatible = true
                local otherGame = other:GetAttribute("Game")
                local otherMatch = other:GetAttribute("MatchId")
                if localGame ~= nil and localGame ~= ""
                    and otherGame ~= nil and otherGame ~= "" and localGame ~= otherGame then
                    compatible = false
                end
                if (localGame == nil or localGame == "")
                    and otherGame ~= nil and otherGame ~= "" then
                    compatible = false
                end
                if matchId ~= nil and matchId ~= ""
                    and otherMatch ~= nil and otherMatch ~= "" and matchId ~= otherMatch then
                    compatible = false
                end
                local theirCharacter = other.Character
                local theirRoot = theirCharacter and theirCharacter:FindFirstChild("HumanoidRootPart")
                if myRoot and theirRoot and (myRoot.Position - theirRoot.Position).Magnitude > 1200 then
                    compatible = false
                end
            end
            if compatible then
                foundPatientZero = true
                break
            end
        end
    end
    local modeAttribute
    for _, name in ipairs(dmvsInfectionModeAttributes) do
        local value = player:GetAttribute(name)
        if typeof(value) == "string" and value ~= "" then
            modeAttribute = value:lower()
            break
        end
    end
    if not modeAttribute then
        for _, name in ipairs(dmvsInfectionModeAttributes) do
            local value = workspace:GetAttribute(name)
            if typeof(value) == "string" and value ~= "" then
                modeAttribute = value:lower()
                break
            end
        end
    end
    local active = not state.RoundEnded and
        (modeAttribute == "infection" or
            (not modeAttribute and (foundPatientZero or
                (state.Active and not dmvsTeamResolverState.InGame))))
    if not active then
        if modeAttribute and modeAttribute ~= "infection" and next(state.LateJoiners) ~= nil then
            table.clear(state.LateJoiners)
        end
        if state.Active or next(state.Targets) ~= nil then
            if modeAttribute and modeAttribute ~= "infection" then
                dmvsClearInfectionRound(false)
            else
                state.Active = false
                table.clear(state.Targets)
                table.clear(state.Inferred)
                table.clear(state.RoleTeams)
                if dmvsInvalidateRedirectSelection then dmvsInvalidateRedirectSelection() end
            end
        end
        return state
    end
    state.Active = true
    local teams = {}
    dmvsReadInfectionRoster(teams)
    state.RoleTeams = teams
    local infectedTeam
    local ambiguousTeam = false
    local markers = {}
    for _, other in ipairs(allPlayers) do
        local marker = dmvsInfectionAttribute(other)
        markers[other] = marker
        if marker == true or state.Converted[other] == true then
            local team = teams[other]
            if team then
                if infectedTeam and infectedTeam ~= team then ambiguousTeam = true end
                infectedTeam = team
            end
        end
    end
    local inferred = {}
    if infectedTeam and not ambiguousTeam then
        for other, team in pairs(teams) do
            if team == infectedTeam and markers[other] ~= false then
                inferred[other] = true
            end
        end
    end
    state.Inferred = inferred
    local function createTargets()
        local targets = {}
        for _, other in ipairs(allPlayers) do
            if markers[other] == true or state.Converted[other] == true
                or (markers[other] ~= false and inferred[other] == true) then
                targets[other] = true
            end
        end
        return targets
    end
    local targets = createTargets()
    local infectedRoots = {}
    for infectedPlayer in pairs(targets) do
        local infectedCharacter = infectedPlayer.Character
        local infectedRoot = infectedCharacter and infectedCharacter:FindFirstChild("HumanoidRootPart")
        if infectedRoot and infectedRoot:IsA("BasePart") then
            infectedRoots[#infectedRoots + 1] = infectedRoot
        end
    end
    for _, other in ipairs(allPlayers) do
        if other ~= player and state.LateJoiners[other] and markers[other] == nil
            and not targets[other] and other.Character then
            local rosterTeam = teams[other] or regularRoster[other.Name:lower()]
            local otherGame = other:GetAttribute("Game")
            local otherMatch = other:GetAttribute("MatchId")
            local sameGame = localGame ~= nil and localGame ~= "" and otherGame == localGame
            local sameMatch = matchId ~= nil and matchId ~= "" and otherMatch == matchId
            local differentGame = localGame ~= nil and localGame ~= "" and otherGame ~= nil
                and otherGame ~= "" and otherGame ~= localGame
            local differentMatch = matchId ~= nil and matchId ~= "" and otherMatch ~= nil
                and otherMatch ~= "" and otherMatch ~= matchId
            if not differentGame and not differentMatch then
                local sharesInfectedTeam = false
                for infectedPlayer in pairs(targets) do
                    local infectedRobloxTeam = infectedPlayer.Team
                    if infectedRobloxTeam and other.Team == infectedRobloxTeam
                        and (markers[infectedPlayer] == true or state.Converted[infectedPlayer] == true
                            or inferred[infectedPlayer] == true) then
                        sharesInfectedTeam = true
                        break
                    end
                end
                local nearInfected = false
                if not rosterTeam and not sameGame and not sameMatch and not sharesInfectedTeam then
                    local characterRoot = other.Character:FindFirstChild("HumanoidRootPart")
                    if characterRoot and characterRoot:IsA("BasePart") then
                        local position = characterRoot.Position
                        for _, infectedRoot in ipairs(infectedRoots) do
                            if (infectedRoot.Position - position).Magnitude <= 300 then
                                nearInfected = true
                                break
                            end
                        end
                    end
                end
                local participates = rosterTeam ~= nil or sameGame or sameMatch
                    or sharesInfectedTeam or nearInfected
                if participates and (not infectedTeam or ambiguousTeam or not rosterTeam or rosterTeam == infectedTeam) then
                    targets[other] = true
                end
            end
        end
    end
    local pending = state.Pending
    local changed = true
    while changed do
        changed = false
        for index = #pending, 1, -1 do
            local entry = pending[index]
            if now - entry.Time > 10 or entry.Killer.Parent ~= Players or entry.Victim.Parent ~= Players then
                table.remove(pending, index)
            elseif targets[entry.Killer] and not targets[entry.Victim]
                and (not state.ConvertedAt[entry.Killer]
                    or state.ConvertedAt[entry.Killer] <= entry.Time) then
                state.Converted[entry.Victim] = true
                state.ConvertedAt[entry.Victim] = entry.Time
                targets[entry.Victim] = true
                table.remove(pending, index)
                changed = true
            elseif targets[entry.Killer] then
                table.remove(pending, index)
            end
        end
    end
    local previous = state.Targets
    local targetChanged = false
    for other in pairs(previous) do
        if not targets[other] then targetChanged = true; break end
    end
    if not targetChanged then
        for other in pairs(targets) do
            if not previous[other] then targetChanged = true; break end
        end
    end
    state.Targets = targets
    if targetChanged and dmvsInvalidateRedirectSelection then
        dmvsInvalidateRedirectSelection()
    end
    return state
end

dmvsIsInfectionMode = function()
    return dmvsRefreshInfectionState(false).Active
end

local function dmvsIsInfectedTarget(targetPlayer)
    if not targetPlayer then return false end
    local state = dmvsRefreshInfectionState(false)
    return state.Active and state.Targets[targetPlayer] == true
end

local function dmvsInfectionMatchAllowed(targetPlayer, allowMissingCharacter)
    if not targetPlayer or targetPlayer == player or not targetPlayer.Parent
        or (not allowMissingCharacter and not targetPlayer.Character) then
        return false
    end
    local myGame = player:GetAttribute("Game")
    local targetGame = targetPlayer:GetAttribute("Game")
    if myGame ~= nil and myGame ~= "" and targetGame ~= nil and targetGame ~= "" and myGame ~= targetGame then
        return false
    end
    if (myGame == nil or myGame == "") and targetGame ~= nil and targetGame ~= "" then
        return false
    end
    local myMatch = player:GetAttribute("MatchId")
    local targetMatch = targetPlayer:GetAttribute("MatchId")
    if myMatch ~= nil and myMatch ~= "" and targetMatch ~= nil and targetMatch ~= "" and myMatch ~= targetMatch then
        return false
    end
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local otherRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and otherRoot and (myRoot.Position - otherRoot.Position).Magnitude > 1200 then
        return false
    end
    return true
end

local function dmvsInfectionMarkDirty()
    dmvsInfectionState.LastRefresh = -math.huge
end

local function dmvsInfectionOnKill(killer, victim)
    if typeof(killer) ~= "Instance" or not killer:IsA("Player")
        or typeof(victim) ~= "Instance" or not victim:IsA("Player")
        or killer == victim or not dmvsIsInfectionMode()
        or (killer ~= player and not dmvsInfectionMatchAllowed(killer, true))
        or (victim ~= player and not dmvsInfectionMatchAllowed(victim, true)) then
        return
    end
    local state = dmvsRefreshInfectionState(false)
    if state.Targets[victim] then return end
    if state.Targets[killer] then
        state.Converted[victim] = true
        state.ConvertedAt[victim] = os.clock()
        state.LastRefresh = -math.huge
        dmvsRefreshInfectionState(true)
    else
        if #state.Pending >= 96 then table.remove(state.Pending, 1) end
        state.Pending[#state.Pending + 1] = {Killer = killer, Victim = victim, Time = os.clock()}
        state.LastRefresh = -math.huge
    end
end

local dmvsIsInSameGame
dmvsIsInSameGame = function(targetPlayer)
    if not targetPlayer or targetPlayer == player or not targetPlayer.Parent then
        return false
    end

    if dmvsIsInfectionMode() then
        return dmvsInfectionMatchAllowed(targetPlayer) and dmvsIsInfectedTarget(targetPlayer)
    end

    local roster = dmvsRefreshScoreboardTeams(false)
    if not dmvsTeamResolverState.InGame or not roster[string.lower(targetPlayer.Name)] then
        return false
    end

    local myGame = player:GetAttribute("Game")
    local targetGame = targetPlayer:GetAttribute("Game")
    if myGame ~= nil and myGame ~= "" and targetGame ~= nil and targetGame ~= "" then
        if myGame ~= targetGame then return false end
    elseif (myGame == nil or myGame == "") and targetGame ~= nil and targetGame ~= "" then
        return false
    end

    local myMatch = player:GetAttribute("MatchId")
    local targetMatch = targetPlayer:GetAttribute("MatchId")
    if myMatch ~= nil and myMatch ~= "" and targetMatch ~= nil and targetMatch ~= "" and myMatch ~= targetMatch then
        return false
    end

    return true
end

local function dmvsResolvePlayerTeam(targetPlayer)
    if not targetPlayer then return nil end

    local snapshot = dmvsRefreshScoreboardTeams(false)
    local byName = snapshot[string.lower(targetPlayer.Name)]

    if not byName and targetPlayer.DisplayName then
        byName = snapshot[string.lower(targetPlayer.DisplayName)]
    end

    if byName then
        return byName
    end

    local attr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
    if attr ~= nil and tostring(attr) ~= "" then
        return tostring(attr)
    end

    if targetPlayer.Team then
        return targetPlayer.Team.Name
    end

    local teamColor = targetPlayer.TeamColor
    if teamColor and teamColor.Name ~= "White" and teamColor.Name ~= "Medium stone grey" then
        return "Color:" .. teamColor.Name
    end

    return nil
end

local function dmvsPlayersAreEnemies(firstPlayer, secondPlayer)
    if not firstPlayer or not secondPlayer or firstPlayer == secondPlayer then
        return false
    end
    if dmvsIsInfectionMode() then
        return dmvsIsInfectedTarget(secondPlayer)
    end

    local firstTeam = dmvsResolvePlayerTeam(firstPlayer)
    local secondTeam = dmvsResolvePlayerTeam(secondPlayer)

    if firstTeam ~= nil and secondTeam ~= nil then
        return firstTeam ~= secondTeam
    end

    return true
end

local function updateMyTeam()
    dmvsInvalidateScoreboard()
    if dmvsInvalidateRedirectSelection then dmvsInvalidateRedirectSelection() end
end

local function updateEnemy()
    dmvsInvalidateScoreboard()
    dmvsInfectionMarkDirty()
    if dmvsInvalidateRedirectSelection then dmvsInvalidateRedirectSelection() end
end

local dmvsTeamPlayerConnections = {}
local dmvsInfectionCharacterConnections = {}

local function disconnectPlayerTeamEvents(p)
    dmvsDisconnectConnectionList(dmvsInfectionCharacterConnections[p])
    dmvsInfectionCharacterConnections[p] = nil
    local connections = dmvsTeamPlayerConnections[p]
    if connections then
        dmvsDisconnectConnectionList(connections)
        dmvsTeamPlayerConnections[p] = nil
    end
end

local function dmvsWatchInfectionCharacter(p, character)
    dmvsDisconnectConnectionList(dmvsInfectionCharacterConnections[p])
    dmvsInfectionCharacterConnections[p] = nil
    if not character then return end
    local connections = {}
    dmvsInfectionCharacterConnections[p] = connections
    local function changed(name)
        if name == "InfectionPatientZero" or name == "InfectionInfected"
            or name == "IsInfected" or name == "Infected"
            or name == "IsZombie" or name == "Zombie" then
            dmvsInfectionMarkDirty()
            updateEnemy()
        end
    end
    connections[#connections + 1] = character.AttributeChanged:Connect(changed)
    local function bindHumanoid(humanoid)
        if humanoid and humanoid:IsA("Humanoid") then
            connections[#connections + 1] = humanoid.AttributeChanged:Connect(changed)
        end
    end
    bindHumanoid(character:FindFirstChildOfClass("Humanoid"))
    connections[#connections + 1] = character.ChildAdded:Connect(function(child)
        if child:IsA("Humanoid") then
            bindHumanoid(child)
            dmvsInfectionMarkDirty()
        end
    end)
end

local function setupPlayerEvents(p)
    if not p or p == player or not p.Parent then return end
    disconnectPlayerTeamEvents(p)
    dmvsTeamPlayerConnections[p] = {
        p:GetPropertyChangedSignal("Team"):Connect(updateEnemy),
        p:GetPropertyChangedSignal("TeamColor"):Connect(updateEnemy),
        p:GetAttributeChangedSignal("Team"):Connect(updateEnemy),
        p:GetAttributeChangedSignal("team"):Connect(updateEnemy),
        p:GetAttributeChangedSignal("Game"):Connect(updateEnemy),
        p:GetAttributeChangedSignal("MatchId"):Connect(updateEnemy),
        p.AttributeChanged:Connect(function(name)
            if name == "InfectionPatientZero" or name == "InfectionInfected"
                or name == "IsInfected" or name == "Infected"
                or name == "IsZombie" or name == "Zombie" then
                dmvsInfectionMarkDirty()
                updateEnemy()
            end
        end),
        p.CharacterAdded:Connect(function(character)
            dmvsWatchInfectionCharacter(p, character)
            dmvsInfectionMarkDirty()
            updateEnemy()
        end),
        p.CharacterRemoving:Connect(function(character)
            dmvsWatchInfectionCharacter(p, nil)
            dmvsInfectionMarkDirty()
            if dmvsClearTargetParts then dmvsClearTargetParts(character) end
        end)
    }
    dmvsWatchInfectionCharacter(p, p.Character)
    updateEnemy()
end

local nexvyrTargetConnections = {}
local nexvyrTargetMonitorActive = false
local nexvyrTargetMonitorSession = 0
local function nexvyrMonitorConnection(connection)
    nexvyrTargetConnections[#nexvyrTargetConnections + 1] = connection
    return connection
end
local function nexvyrStartTargetMonitor()
    if nexvyrTargetMonitorActive then return end
    nexvyrTargetMonitorActive = true
    nexvyrTargetMonitorSession += 1
    local session = nexvyrTargetMonitorSession
    local function localChanged() updateMyTeam(); dmvsInfectionMarkDirty() end
    for _, name in ipairs({"Team", "TeamColor"}) do
        nexvyrMonitorConnection(player:GetPropertyChangedSignal(name):Connect(localChanged))
    end
    for _, name in ipairs({"Team", "team", "Game", "MatchId", "GameMode", "MatchMode", "Mode"}) do
        nexvyrMonitorConnection(player:GetAttributeChangedSignal(name):Connect(localChanged))
    end
    nexvyrMonitorConnection(player.AttributeChanged:Connect(function(name)
        if name == "InfectionPatientZero" or name == "InfectionInfected" or name == "IsInfected"
            or name == "Infected" or name == "IsZombie" or name == "Zombie" then dmvsInfectionMarkDirty() end
    end))
    nexvyrMonitorConnection(player.CharacterAdded:Connect(dmvsInfectionMarkDirty))
    nexvyrMonitorConnection(playerGui.DescendantAdded:Connect(function(instance)
        if instance.Name == "IngameScore" or instance.Name == "TeamRed" or instance.Name == "TeamBlue" then
            dmvsInvalidateScoreboard(); dmvsInfectionMarkDirty()
        end
    end))
    nexvyrMonitorConnection(playerGui.DescendantRemoving:Connect(function(instance)
        if instance == dmvsTeamResolverState.Scoreboard or instance.Name == "IngameScore"
            or instance.Name == "TeamRed" or instance.Name == "TeamBlue" then
            dmvsInvalidateScoreboard(); dmvsInfectionMarkDirty()
        end
    end))
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then setupPlayerEvents(other) end
    end
    nexvyrMonitorConnection(Players.PlayerAdded:Connect(function(other)
        dmvsInfectionState.LateJoiners[other] = true
        setupPlayerEvents(other)
        dmvsInfectionMarkDirty()
    end))
    nexvyrMonitorConnection(Players.PlayerRemoving:Connect(function(other)
        disconnectPlayerTeamEvents(other)
        for i = #dmvsInfectionState.Pending, 1, -1 do
            local entry = dmvsInfectionState.Pending[i]
            if entry.Killer == other or entry.Victim == other then table.remove(dmvsInfectionState.Pending, i) end
        end
        for _, bucket in ipairs({"Converted", "ConvertedAt", "LateJoiners", "Inferred", "Targets", "RoleTeams"}) do
            dmvsInfectionState[bucket][other] = nil
        end
        updateEnemy()
    end))
    dmvsInvalidateScoreboard()
    dmvsInfectionMarkDirty()
    task.spawn(function()
        local registered = {}
        local listeners = {
            ["RE/Combat/Killed"] = dmvsInfectionOnKill,
            ["RE/Match/PlayerRespawned"] = dmvsInfectionMarkDirty,
            ["RE/Match/StartRoundGui"] = function() dmvsClearInfectionRound(false) end,
            ["RE/Match/MatchResults"] = function()
                if dmvsInfectionState.Active then dmvsClearInfectionRound(true) end
            end
        }
        while nexvyrTargetMonitorActive and session == nexvyrTargetMonitorSession do
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            local networking = packages and packages:FindFirstChild("Networking")
            local finished = true
            for name, callback in pairs(listeners) do
                if not registered[name] then
                    local remote = networking and networking:FindFirstChild(name)
                    if remote and remote:IsA("RemoteEvent") then
                        nexvyrMonitorConnection(remote.OnClientEvent:Connect(callback))
                        registered[name] = true
                    else
                        finished = false
                    end
                end
            end
            if finished then break end
            task.wait(2)
        end
    end)
end
local function nexvyrStopTargetMonitor()
    if not nexvyrTargetMonitorActive then return end
    nexvyrTargetMonitorActive = false
    nexvyrTargetMonitorSession += 1
    dmvsDisconnectConnectionList(nexvyrTargetConnections)
    for other in pairs(dmvsTeamPlayerConnections) do disconnectPlayerTeamEvents(other) end
    dmvsDisconnectConnectionList(dmvsTeamResolverState.WatchConnections)
    dmvsTeamResolverState.Scoreboard = nil
    dmvsTeamResolverState.Snapshot = {}
    dmvsTeamResolverState.InGame = false
    dmvsTeamResolverState.Dirty = true
    dmvsClearInfectionRound(false)
end
startTargetMonitor = nexvyrStartTargetMonitor
stopTargetMonitor = nexvyrStopTargetMonitor

isEnemy = function(targetPlayer)
    if not dmvsIsInSameGame(targetPlayer) or not targetPlayer.Character then return false end
    if not dmvsIsTargetAlive(targetPlayer) then return false end
    return dmvsPlayersAreEnemies(player, targetPlayer)
end
local SAFE_ZONES = {
    {Center = Vector3.new(-320.50, 280.82, 16.00), Radius = 500},
    {Center = Vector3.new(1564.14, -155.45, 40.04), Radius = 300}
}
estaEnLobby = function()
    local character = player.Character
    if not character then return true end
    if character:FindFirstChildOfClass("ForceField") then return true end
    if player.Team then
        local name = player.Team.Name:lower()
        if name:find("lobby") or name:find("spectat") or name:find("espectador")
            or name:find("menu") or name:find("dead") then return true end
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        for _, zone in ipairs(SAFE_ZONES) do
            if (root.Position - zone.Center).Magnitude <= zone.Radius then return true end
        end
    end
    return false
end
IsInMatchStrict = function()
    if estaEnLobby() then return false end
    dmvsRefreshScoreboardTeams(false)
    return dmvsTeamResolverState.InGame or dmvsIsInfectionMode()
end
esEnemigoValido = function(other)
    if not isEnemy(other) then return false end
    local character = other.Character
    return character ~= nil and not character:FindFirstChildOfClass("ForceField")
        and dmvsIsTargetAlive(other)
end
esCuchillo = function(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("Slash") or tool:FindFirstChild("SlashStart") then return true end
    local name = tool.Name:lower()
    return name:find("knife", 1, true) ~= nil or name:find("cuchillo", 1, true) ~= nil
        or name:find("dagger", 1, true) ~= nil
end
esPistola = function(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local beam = tool:FindFirstChild("showBeam")
    return beam ~= nil and beam:IsA("RemoteEvent")
end
obtenerPistola = function()
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if esPistola(tool) then return tool end
        end
    end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if esPistola(tool) then return tool end
        end
    end
    return nil
end
end

getgenv().RoxHubAutoEventFarm = false

task.spawn(function()
    local Networking, RemoteFarm
    while task.wait(0.05) do
        if not getgenv().RoxHubAutoEventFarm then continue end
        pcall(function()
            if not RemoteFarm then
                Networking = ReplicatedStorage:FindFirstChild("Packages")
                Networking = Networking and Networking:FindFirstChild("Networking")
                RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")
            end
            if RemoteFarm then RemoteFarm:FireServer() end
        end)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local container = workspace:FindFirstChild("SpawnablesClient")
            if container then
                for _, obj in ipairs(container:GetChildren()) do
                    if not getgenv().RoxHubAutoEventFarm then break end
                    local touchPart = obj:FindFirstChild("Touch")
                    if touchPart then
                        pcall(function()
                            firetouchinterest(hrp, touchPart, 0)
                            firetouchinterest(hrp, touchPart, 1)
                        end)
                    end
                end
            end
        end
    end
end)

local KILLALL_MOVE_SPEED               = 39.9
local KILLALL_APPROACH_DISTANCE        = 2.5
local KILLALL_APPROACH_TOLERANCE       = 0.35
local KILLALL_SWING_INTERVAL           = 0.5
local KILLALL_SAFE_GROUND_THRESHOLD    = 3
local KILLALL_STICK_MAX_TIME           = 2.5
local KILLALL_STICK_MAX_DISTANCE       = 20
local KILLALL_VOID_PROTECTION          = 15
local KILLALL_HEALTH_STALL_TIME        = 1.5
local KILLALL_TARGET_GRACE_TIME        = 1.2
local KILLALL_PITCH_DEGREES            = 90
local KILLALL_HEIGHT_OFFSET            = 1.9
local KILLALL_HIDE_DEPTH               = 4
local KILLALL_HIDE_DURATION            = 0.5
local KILLALL_KNIFE_RANGE_Y            = 4.5
local KILLALL_PREDICTION_TIME          = 0.08
local KILLALL_JITTER_AMPLITUDE         = 0.8
local KILLALL_JITTER_SWITCH_MIN        = 0.05
local KILLALL_JITTER_SWITCH_MAX        = 0.12
local KILLALL_JITTER_LERP_SPEED        = 25
local KILLALL_UNDERGROUND_DEPTH        = 5
local KILLALL_UNDERGROUND_TOLERANCE    = 1.5
local KILLALL_TRIGGER_RADIUS           = 6.0
local KILLALL_VALIDATION_TOLERANCE     = 1.0
local KILLALL_VALIDATION_FRAMES        = 3

local RoxConnectionManager = {}
RoxConnectionManager.__index = RoxConnectionManager
function RoxConnectionManager.new() return setmetatable({ Items = {} }, RoxConnectionManager) end
function RoxConnectionManager:Add(task) self.Items[#self.Items + 1] = task; return task end
function RoxConnectionManager:Cleanup()
    for i = #self.Items, 1, -1 do
        local item = self.Items[i]
        self.Items[i] = nil
        local t = typeof(item)
        if t == "RBXScriptConnection" then pcall(function() item:Disconnect() end)
        elseif t == "Instance" then pcall(function() item:Destroy() end)
        elseif t == "function" then pcall(item) end
    end
end

local RoxKillAll = {}
RoxKillAll.__index = RoxKillAll

function RoxKillAll.new()
    return setmetatable({
        running = false,
        connections = RoxConnectionManager.new(),
        savedCollisions = {},
        swingAccumulator = 0,
        safePosition = nil,
        sticking = false,
        stickingStartTime = 0,
        lastEnemyHealth = nil,
        lastHealthChangeTime = 0,
        lastTargetSeenTime = 0,
        currentTarget = nil,
        lockedTargetPlayer = nil,
        lastStickTarget = nil,
        lastStickTargetHum = nil,
        hiding = false,
        hidingUntil = 0,
        targetFloor = nil,
        targetFloorY = nil,
        lastFloorTarget = nil,
        inKnifeRangeNow = false,
        forceDescent = false,
        jitterSide = 1,
        jitterCurrent = 0,
        jitterNextSwitch = 0,
        lastSetCFrame = nil,
        validFrames = 0,
        killActivated = false,
    }, RoxKillAll)
end

function RoxKillAll:DisableCollisions()
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            if self.savedCollisions[part] == nil then
                self.savedCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

function RoxKillAll:RestoreCollisions()
    for part, value in pairs(self.savedCollisions) do
        if part.Parent then
            pcall(function() part.CanCollide = value end)
        end
    end
    table.clear(self.savedCollisions)
end

function RoxKillAll:GetRoot(p)
    local char = p and p.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then return root end
    return nil
end

function RoxKillAll:GetHumanoid(p)
    local char = p and p.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function RoxKillAll:GetFloorY(targetRoot)
    local hum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    local hip = hum and tonumber(hum.HipHeight) or 2
    return targetRoot.Position.Y - hip - targetRoot.Size.Y / 2
end

function RoxKillAll:GetPlatformFloorY(targetRoot)
    if not targetRoot then return nil end
    if self.lastFloorTarget == targetRoot and self.targetFloorY then
        return self.targetFloorY
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character, targetRoot.Parent }
    local origin = targetRoot.Position + Vector3.new(0, 3, 0)
    local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
    if result then
        self.targetFloorY = result.Position.Y
        self.lastFloorTarget = targetRoot
        return self.targetFloorY
    end
    self.targetFloorY = self:GetFloorY(targetRoot)
    self.lastFloorTarget = targetRoot
    return self.targetFloorY
end

function RoxKillAll:IsInKnifeRange(myRoot, targetRoot)
    if not myRoot or not targetRoot then return false end
    local delta = targetRoot.Position - myRoot.Position
    local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
    local vertical = math.abs(delta.Y)
    return horizontal <= (KILLALL_APPROACH_DISTANCE + KILLALL_APPROACH_TOLERANCE) and vertical <= KILLALL_KNIFE_RANGE_Y
end

function RoxKillAll:IsLockedTargetValid()
    local lp = self.lockedTargetPlayer
    if not lp then return false end
    if not lp.Parent then return false end
    if not esEnemigoValido(lp) then return false end
    local char = lp.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end
    if hum.Health <= 0 then return false end
    return root
end

function RoxKillAll:GetClosestEnemy()
    local myRoot = self:GetRoot(player)
    if not myRoot then return nil end
    local lockedRoot = self:IsLockedTargetValid()
    if lockedRoot then return lockedRoot end
    self.lockedTargetPlayer = nil
    self.currentTarget = nil
    local best, bestDist, bestPlayer = nil, nil, nil
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and esEnemigoValido(other) then
            local hum = self:GetHumanoid(other)
            local root = self:GetRoot(other)
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if not bestDist or dist < bestDist then
                    best, bestDist, bestPlayer = root, dist, other
                end
            end
        end
    end
    if bestPlayer then self.lockedTargetPlayer = bestPlayer end
    return best
end

function RoxKillAll:IsInMatch() return IsInMatchStrict() end

function RoxKillAll:ResetState()
    self.sticking = false
    self.stickingStartTime = 0
    self.lastEnemyHealth = nil
    self.lastHealthChangeTime = 0
    self.targetFloor = nil
    self.inKnifeRangeNow = false
    self.forceDescent = false
    self.jitterSide = 1
    self.jitterCurrent = 0
    self.jitterNextSwitch = 0
    self.lastSetCFrame = nil
    self.validFrames = 0
    self.killActivated = false
    self:RestoreCollisions()
    local hum = self:GetHumanoid(player)
    if hum and hum.PlatformStand then pcall(function() hum.PlatformStand = false end) end
end

function RoxKillAll:ReturnToSafePosition(myRoot)
    if not self.safePosition or not myRoot then return end
    if myRoot.Position.Y < (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD) then
        pcall(function()
            myRoot.CFrame = CFrame.new(self.safePosition)
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

function RoxKillAll:ForceReturnToSafe(myRoot)
    if not self.safePosition or not myRoot then return end
    pcall(function()
        myRoot.CFrame = CFrame.new(self.safePosition)
        myRoot.AssemblyLinearVelocity  = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function RoxKillAll:IsFallingIntoVoid(myRoot)
    if not self.safePosition or not myRoot then return false end
    return myRoot.Position.Y < (self.safePosition.Y - KILLALL_VOID_PROTECTION)
end

function RoxKillAll:HideBelowMap()
    local myRoot = self:GetRoot(player)
    if not myRoot then return end
    local baseY = self.safePosition and self.safePosition.Y or myRoot.Position.Y
    local hideY = baseY - KILLALL_HIDE_DEPTH
    local x, z = myRoot.Position.X, myRoot.Position.Z
    pcall(function()
        myRoot.CFrame = CFrame.new(x, hideY, z)
        myRoot.AssemblyLinearVelocity  = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    self.hiding = true
    self.hidingUntil = os.clock() + KILLALL_HIDE_DURATION
end

function RoxKillAll:IsKnife(tool)
    if not (tool and tool:IsA("Tool")) then return false end
    if tool:FindFirstChild("fire") or tool:FindFirstChild("showBeam") then return false end
    return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
end

function RoxKillAll:FindKnife()
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if self:IsKnife(child) then return child, true end
        end
    end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if self:IsKnife(child) then return child, false end
        end
    end
    return nil, false
end

function RoxKillAll:SwingKnife(dt)
    self.swingAccumulator = self.swingAccumulator + dt
    if self.swingAccumulator < KILLALL_SWING_INTERVAL then return end
    self.swingAccumulator = 0
    local tool, equipped = self:FindKnife()
    if not tool then return end
    if not equipped then
        local hum = self:GetHumanoid(player)
        if not hum then return end
        pcall(function() hum:EquipTool(tool) end)
        if tool.Parent ~= player.Character then return end
    end
    pcall(function() tool:Activate() end)
end

function RoxKillAll:UpdateJitter(dt)
    local now = os.clock()
    if now >= self.jitterNextSwitch then
        self.jitterSide = (math.random() < 0.5) and 1 or -1
        self.jitterNextSwitch = now + KILLALL_JITTER_SWITCH_MIN + math.random() * (KILLALL_JITTER_SWITCH_MAX - KILLALL_JITTER_SWITCH_MIN)
    end
    local targetOffset = self.jitterSide * KILLALL_JITTER_AMPLITUDE
    self.jitterCurrent = self.jitterCurrent + (targetOffset - self.jitterCurrent) * math.clamp(dt * KILLALL_JITTER_LERP_SPEED, 0, 1)
end

function RoxKillAll:CheckServerValidation(myRoot)
    if self.killActivated then return true end
    if not self.lastSetCFrame then return false end
    local diff = (myRoot.Position - self.lastSetCFrame.Position).Magnitude
    if diff <= KILLALL_VALIDATION_TOLERANCE then
        self.validFrames = self.validFrames + 1
        if self.validFrames >= KILLALL_VALIDATION_FRAMES then
            self.killActivated = true
            self.swingAccumulator = KILLALL_SWING_INTERVAL
            return true
        end
    else
        self.validFrames = 0
    end
    return false
end

function RoxKillAll:ForceUnderground(myRoot, targetRoot)
    if not myRoot or not targetRoot then return end
    local floorY = self:GetPlatformFloorY(targetRoot)
    if not floorY then return end
    local targetY = floorY - KILLALL_UNDERGROUND_DEPTH
    if myRoot.Position.Y > targetY + KILLALL_UNDERGROUND_TOLERANCE then
        pcall(function()
            myRoot.CFrame = CFrame.new(myRoot.Position.X, targetY, myRoot.Position.Z)
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

function RoxKillAll:ApproachTarget(myRoot, targetRoot, dt)
    dt = dt or 0
    local myPos = myRoot.Position
    local targetPos = targetRoot.Position
    local deltaXZ = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
    local hDist = deltaXZ.Magnitude

    if hDist <= KILLALL_TRIGGER_RADIUS then
        if not self.sticking then
            local lookTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
            local targetCF = CFrame.lookAt(myPos, lookTarget)
            self.lastSetCFrame = targetCF
            pcall(function()
                myRoot.CFrame = targetCF
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            if self:CheckServerValidation(myRoot) then
                self.sticking = true
                self.stickingStartTime = os.clock()
                self.lastStickTarget = targetRoot
                self.targetFloor = nil
                self.forceDescent = true
                local hum = self:GetHumanoid(targetRoot.Parent)
                self.lastEnemyHealth = hum and hum.Health or nil
                self.lastHealthChangeTime = os.clock()
                self.lastStickTargetHum = hum
                self.jitterCurrent = 0
            end
        end
        return
    end

    self.lastSetCFrame = nil
    self.validFrames = 0
    local dir = deltaXZ.Unit
    local perp = Vector3.new(-dir.Z, 0, dir.X)
    self:UpdateJitter(dt)
    local step = KILLALL_MOVE_SPEED * dt
    local travel = math.min(step, math.max(0, hDist - KILLALL_TRIGGER_RADIUS))
    local maxJitterByDistance = math.sqrt(math.max(0, travel * (2 * hDist - travel))) * 0.85
    local jitterFactor = math.clamp((hDist - KILLALL_TRIGGER_RADIUS) / 8, 0, 1)
    local desiredJitter = self.jitterCurrent * jitterFactor
    local actualJitter = math.clamp(desiredJitter, -maxJitterByDistance, maxJitterByDistance)

    local baseX = myPos.X + dir.X * travel
    local baseZ = myPos.Z + dir.Z * travel
    local newX = baseX + perp.X * actualJitter
    local newZ = baseZ + perp.Z * actualJitter

    local floorY = self:GetPlatformFloorY(targetRoot)
    local newY
    if floorY then newY = floorY - KILLALL_UNDERGROUND_DEPTH else newY = myPos.Y end

    local newPos = Vector3.new(newX, newY, newZ)
    local lookTarget = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
    local newCFrame = CFrame.lookAt(newPos, lookTarget)

    pcall(function()
        myRoot.CFrame = newCFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function RoxKillAll:CanStickToTarget(myRoot, targetRoot)
    if not targetRoot or not targetRoot.Parent then return false end
    local targetPlayer = Players:GetPlayerFromCharacter(targetRoot.Parent)
    if not targetPlayer or not esEnemigoValido(targetPlayer) then return false end
    local targetHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return false end
    local distHorizontal = (Vector3.new(myRoot.Position.X, 0, myRoot.Position.Z) - Vector3.new(targetRoot.Position.X, 0, targetRoot.Position.Z)).Magnitude
    if distHorizontal > KILLALL_STICK_MAX_DISTANCE then return false end
    return true
end

function RoxKillAll:StickToTarget(myRoot, targetRoot)
    local targetPos = targetRoot.Position
    local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    local onGround  = targetHum and targetHum.FloorMaterial ~= Enum.Material.Air
    if targetRoot ~= self.lastStickTarget then
        self.lastStickTarget = targetRoot
        self.targetFloor     = nil
    end
    if onGround or not self.targetFloor then
        self.targetFloor = self:GetFloorY(targetRoot)
    end
    local myPos = myRoot.Position
    local dir = Vector3.new(myPos.X - targetPos.X, 0, myPos.Z - targetPos.Z)
    if dir.Magnitude < 0.05 then dir = Vector3.new(0, 0, 1) else dir = dir.Unit end
    local x = targetPos.X + dir.X * KILLALL_APPROACH_DISTANCE
    local z = targetPos.Z + dir.Z * KILLALL_APPROACH_DISTANCE
    local inRange = self:IsInKnifeRange(myRoot, targetRoot)
    local y
    if inRange and not self.forceDescent then
        y = myPos.Y
    else
        y = self.targetFloor - KILLALL_HEIGHT_OFFSET
        if inRange then self.forceDescent = false end
    end
    pcall(function()
        myRoot.CFrame = CFrame.new(x, y, z) * CFrame.Angles(math.rad(KILLALL_PITCH_DEGREES), 0, 0)
        myRoot.AssemblyLinearVelocity  = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function RoxKillAll:CheckEnemyHealth(targetRoot)
    local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    if not targetHum then return false end
    local currentHealth = targetHum.Health
    if self.lastEnemyHealth == nil then
        self.lastEnemyHealth = currentHealth
        self.lastHealthChangeTime = os.clock()
        return false
    end
    if currentHealth < self.lastEnemyHealth then
        self.lastEnemyHealth = currentHealth
        self.lastHealthChangeTime = os.clock()
        return false
    end
    if (os.clock() - self.lastHealthChangeTime) >= KILLALL_HEALTH_STALL_TIME then return true end
    return false
end

function RoxKillAll:Update(dt)
    if not self:IsInMatch() then
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastFloorTarget = nil
        self.targetFloorY = nil
        return
    end
    local myRoot = self:GetRoot(player)
    if not myRoot then
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        return
    end
    if self.lastStickTargetHum then
        local hum = self.lastStickTargetHum
        if not hum.Parent or hum.Health <= 0 then
            self:HideBelowMap()
            self.inKnifeRangeNow      = false
            self.forceDescent         = false
            self.lastStickTargetHum   = nil
            self.lastStickTarget      = nil
            self.sticking             = false
            self.stickingStartTime    = 0
            self.lastEnemyHealth      = nil
            self.lastHealthChangeTime = 0
            self.targetFloor          = nil
            self.killActivated        = false
            self.validFrames          = 0
            self.lastSetCFrame        = nil
            return
        end
    end
    if self.hiding then
        if os.clock() >= self.hidingUntil then
            self.hiding = false
        else
            pcall(function()
                myRoot.AssemblyLinearVelocity  = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            return
        end
    end
    if self:IsFallingIntoVoid(myRoot) then
        self:ForceReturnToSafe(myRoot)
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        local hum = self:GetHumanoid(player)
        if hum then pcall(function() hum.PlatformStand = false end) end
        return
    end
    local target = self:GetClosestEnemy()
    if target then
        self.currentTarget      = target
        self.lastTargetSeenTime = os.clock()
    end
    if not target then
        local justLostTarget = (os.clock() - (self.lastTargetSeenTime or 0)) < KILLALL_TARGET_GRACE_TIME
        local isUnderground  = self.safePosition and myRoot.Position.Y < (self.safePosition.Y - 2)
        if justLostTarget and isUnderground then
            pcall(function()
                myRoot.AssemblyLinearVelocity  = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            return
        end
        self:ReturnToSafePosition(myRoot)
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastFloorTarget = nil
        self.targetFloorY = nil
        if self.safePosition then
            local hum = self:GetHumanoid(player)
            if hum then pcall(function() hum.PlatformStand = false end) end
        end
        return
    end
    self:DisableCollisions()
    if self.lastStickTarget then
        local inRange = self:IsInKnifeRange(myRoot, self.lastStickTarget)
        if inRange and not self.inKnifeRangeNow then
            self.swingAccumulator = KILLALL_SWING_INTERVAL
            self.inKnifeRangeNow = true
        elseif not inRange then
            self.inKnifeRangeNow = false
        end
    end
    self:SwingKnife(dt or 0)
    local hum = self:GetHumanoid(player)
    if hum and not hum.PlatformStand then
        pcall(function() hum.PlatformStand = true end)
    end
    if self.safePosition and myRoot.Position.Y >= (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD) then
        self.safePosition = Vector3.new(myRoot.Position.X, self.safePosition.Y, myRoot.Position.Z)
    end
    if not self.sticking then self:ForceUnderground(myRoot, target) end
    if self.sticking then
        local lostTarget  = (target ~= self.lastStickTarget)
        local timedOut    = (os.clock() - self.stickingStartTime) > KILLALL_STICK_MAX_TIME
        local cannotStick = not self:CanStickToTarget(myRoot, target)
        local cannotKill  = self:CheckEnemyHealth(target)
        if lostTarget or timedOut or cannotStick or cannotKill then
            self.sticking             = false
            self.stickingStartTime    = 0
            self.lastEnemyHealth      = nil
            self.lastHealthChangeTime = 0
            self.targetFloor          = nil
            self.inKnifeRangeNow      = false
            self.forceDescent         = false
            self.killActivated        = false
            self.validFrames          = 0
            self.lastSetCFrame        = nil
            if lostTarget then self.lastStickTarget = nil end
        else
            self:StickToTarget(myRoot, target)
            return
        end
    end
    self:ApproachTarget(myRoot, target, dt or 0)
end

function RoxKillAll:Start()
    if self.running then return end
    self.running = true
    self.swingAccumulator      = 0
    self.sticking              = false
    self.stickingStartTime     = 0
    self.lastEnemyHealth       = nil
    self.lastHealthChangeTime  = 0
    self.lastTargetSeenTime    = 0
    self.currentTarget         = nil
    self.lockedTargetPlayer    = nil
    self.lastStickTarget       = nil
    self.lastStickTargetHum    = nil
    self.hiding                = false
    self.hidingUntil           = 0
    self.targetFloor           = nil
    self.targetFloorY          = nil
    self.lastFloorTarget       = nil
    self.inKnifeRangeNow       = false
    self.forceDescent          = false
    self.jitterSide = 1
    self.jitterCurrent = 0
    self.jitterNextSwitch = 0
    self.lastSetCFrame = nil
    self.validFrames = 0
    self.killActivated = false

    local myRoot = self:GetRoot(player)
    if myRoot then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { player.Character }
        local origin = myRoot.Position + Vector3.new(0, 5, 0)
        local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
        if result then
            self.safePosition = Vector3.new(myRoot.Position.X, result.Position.Y + 3, myRoot.Position.Z)
        else
            self.safePosition = myRoot.Position
        end
    else
        self.safePosition = nil
    end

    self.connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.running then return end
        self:Update(dt)
    end))

    self.connections:Add(player.CharacterAdded:Connect(function()
        table.clear(self.savedCollisions)
        self.sticking = false
        self.safePosition = nil
        self.stickingStartTime = 0
        self.lastEnemyHealth = nil
        self.lastHealthChangeTime = 0
        self.lastTargetSeenTime = 0
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastStickTargetHum = nil
        self.hiding = false
        self.hidingUntil = 0
        self.targetFloor = nil
        self.targetFloorY = nil
        self.lastFloorTarget = nil
        self.inKnifeRangeNow = false
        self.forceDescent = false
        self.jitterSide = 1
        self.jitterCurrent = 0
        self.jitterNextSwitch = 0
        self.lastSetCFrame = nil
        self.validFrames = 0
        self.killActivated = false
    end))
end

function RoxKillAll:Stop()
    if not self.running then return end
    local myRoot = self:GetRoot(player)
    if myRoot and self.safePosition then
        pcall(function()
            myRoot.CFrame = CFrame.new(self.safePosition)
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    self.running = false
    self.connections:Cleanup()
    self.connections = RoxConnectionManager.new()
    self:ResetState()
    self.currentTarget = nil
    self.lockedTargetPlayer = nil
    self.lastStickTarget = nil
    self.lastStickTargetHum = nil
    self.hiding = false
    self.hidingUntil = 0
    self.inKnifeRangeNow = false
    self.forceDescent = false
    self.killActivated = false
    self.targetFloorY = nil
    self.lastFloorTarget = nil
end

local RoxKillAllInstance = RoxKillAll.new()

local Players01 = game:GetService("Players")
local ContentProvider01 = game:GetService("ContentProvider")
local RunService01 = game:GetService("RunService")
local LocalPlayer01 = Players01.LocalPlayer
local SHELL_NAME_01ROXHUB = "01ROXHUB_Shell"
local env01 = (getgenv and getgenv()) or _G
if env01.RoxhubAvatarCleanup then pcall(env01.RoxhubAvatarCleanup) end
local function withTimeout01(secs, fn)
    local res,done=nil,false
    task.spawn(function() local ok,r=pcall(fn) if ok then res=r end done=true end)
    local t0=os.clock() while not done and os.clock()-t0<secs do task.wait(0.05) end
    return res
end
local function preload01(model)
    local list={} for _,d in ipairs(model:GetDescendants()) do if d:IsA("MeshPart") or d:IsA("SpecialMesh") or d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance") or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then list[#list+1]=d end end if #list==0 then return end withTimeout01(15,function() ContentProvider01:PreloadAsync(list) end)
end
local LEG_NAMES_01ROXHUB={LeftFoot=true,RightFoot=true,LeftLowerLeg=true,RightLowerLeg=true,["Left Leg"]=true,["Right Leg"]=true}
local State01={template=nil,desc=nil,shell=nil,sRoot=nil,shellParts={},char=nil,conns={},hidden={},pairList={},offset=CFrame.new(),fp=false,lastScan=0,sAnimator=nil,mirror={},animActive=false,c0Dirty=false}
local Build01={} local BuildOrder01={} local MAX_BUILDS_01=4
local function loadAsset01(id) local obj local ok=pcall(function() obj=game:GetObjects("rbxassetid://"..id)[1] end) if ok and obj then return obj end ok=pcall(function() obj=game:GetService("InsertService"):LoadAsset(id) end) if ok and obj then return obj end end
local function findClass01(obj,class) if not obj then return nil end if obj:IsA(class) then return obj end return obj:FindFirstChildWhichIsA(class,true) end
local function buildFromAssets01(desc) local model=Instance.new("Model") model.Name="AvatarSource01ROXHUB" local pending=0 local function async(fn) pending=pending+1 task.spawn(function() pcall(fn) pending=pending-1 end) end local bc=Instance.new("BodyColors") bc.HeadColor3=desc.HeadColor bc.TorsoColor3=desc.TorsoColor bc.LeftArmColor3=desc.LeftArmColor bc.RightArmColor3=desc.RightArmColor bc.LeftLegColor3=desc.LeftLegColor bc.RightLegColor3=desc.RightLegColor bc.Parent=model local function loadInto(id,class,rename) if id and id>0 then async(function() local o=findClass01(loadAsset01(id),class) if o then if rename then o.Name=rename end o.Parent=model end end) end end loadInto(desc.Shirt,"Shirt") loadInto(desc.Pants,"Pants") loadInto(desc.GraphicTShirt,"ShirtGraphic") loadInto(desc.Face,"Decal","face") local okA,accs=pcall(function() return desc:GetAccessories(true) end) if okA and type(accs)=="table" then for _,a in ipairs(accs) do if a.AssetId and a.AssetId>0 then async(function() local acc=findClass01(loadAsset01(a.AssetId),"Accessory") if acc then local wl=acc:FindFirstChildWhichIsA("WrapLayer",true) if wl then if a.Order then wl.Order=a.Order end if a.Puffiness then wl.Puffiness=a.Puffiness end end acc.Parent=model end end) end end end local t0=os.clock() while pending>0 and os.clock()-t0<25 do task.wait(0.05) end return model end
local function attachByAttachments01(model,acc) local handle=acc:FindFirstChild("Handle") if not handle or not handle:IsA("BasePart") then acc.Parent=model return false end for _,d in ipairs(handle:GetChildren()) do if d:IsA("Weld") or d:IsA("Motor6D") or d:IsA("WeldConstraint") then d:Destroy() end end for _,a in ipairs(handle:GetChildren()) do if a:IsA("Attachment") then local target for _,p in ipairs(model:GetChildren()) do if p:IsA("BasePart") then local t=p:FindFirstChild(a.Name) if t and t:IsA("Attachment") then target=t break end end end if target then local w=Instance.new("Weld") w.Name="AccessoryWeld01ROXHUB" w.Part0=handle w.Part1=target.Parent w.C0=a.CFrame w.C1=target.CFrame w.Parent=handle acc.Parent=model return true end end end acc.Parent=model return false end
local function prepShell01(model) for _,d in ipairs(model:GetDescendants()) do if d:IsA("LuaSourceContainer") or d:IsA("Tool") or d:IsA("ForceField") or d:IsA("Sound") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then pcall(function() d:Destroy() end) end end for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then pcall(function() d.Anchored=false d.CanCollide=false d.CanTouch=false d.CanQuery=false d.Massless=true end) end end local root=model:FindFirstChild("HumanoidRootPart") if root then root.Anchored=true end local h=model:FindFirstChildOfClass("Humanoid") if h then pcall(function() h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end) pcall(function() h.HealthDisplayType=Enum.HumanoidHealthDisplayType.AlwaysOff end) pcall(function() h.BreakJointsOnDeath=false end) pcall(function() h.RequiresNeck=false end) pcall(function() h.EvaluateStateMachine=false end) pcall(function() h.AutoRotate=false end) pcall(function() h.WalkSpeed=0 end) pcall(function() h.PlatformStand=true end) end end
local function templateFromDescription01(desc,rig) for attempt=1,3 do local m=withTimeout01(30,function() return Players01:CreateHumanoidModelFromDescription(desc,rig) end) if typeof(m)=="Instance" then local h=m:FindFirstChildOfClass("Humanoid") if m:FindFirstChild("HumanoidRootPart") and h and h.RigType==rig then return m end pcall(function() m:Destroy() end) end task.wait(0.3) end return nil end
local function templateFromAssets01(desc,char) local base local okc=pcall(function() char.Archivable=true for _,d in ipairs(char:GetDescendants()) do pcall(function() d.Archivable=true end) end for inst,t in pairs(State01.hidden) do if inst.Parent then inst.Transparency=t end end base=char:Clone() for inst in pairs(State01.hidden) do if inst.Parent then inst.Transparency=1 end end end) if not okc or not base then return nil end for _,d in ipairs(base:GetDescendants()) do if d:IsA("LuaSourceContainer") or d:IsA("Tool") or d:IsA("Accoutrement") or d:IsA("CharacterAppearance") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("Highlight") or d:IsA("ForceField") then pcall(function() d:Destroy() end) end end local src=buildFromAssets01(desc) for _,c in ipairs(src:GetChildren()) do if c:IsA("CharacterAppearance") then c.Parent=base end end local head=base:FindFirstChild("Head") local face=src:FindFirstChild("face") if head and face then for _,d in ipairs(head:GetChildren()) do if d:IsA("Decal") then d:Destroy() end end face.Parent=head end for _,a in ipairs(src:GetChildren()) do if a:IsA("Accoutrement") then attachByAttachments01(base,a) end end pcall(function() src:Destroy() end) return base end
local function lowestLeg01(model) local root=model:FindFirstChild("HumanoidRootPart") if not root then return nil end local cf={[root]=CFrame.identity} local joints={} for _,d in ipairs(model:GetDescendants()) do if d:IsA("Motor6D") and d.Part0 and d.Part1 then joints[#joints+1]=d end end local changed,guard=true,0 while changed and guard<30 do changed=false guard=guard+1 for _,j in ipairs(joints) do local a,b=j.Part0,j.Part1 if cf[a] and not cf[b] then cf[b]=cf[a]*j.C0*j.C1:Inverse() changed=true elseif cf[b] and not cf[a] then cf[a]=cf[b]*j.C1*j.C0:Inverse() changed=true end end end local low for p,c in pairs(cf) do if LEG_NAMES_01ROXHUB[p.Name] and p.Parent==model then local s=p.Size local ext=0.5*(math.abs(c.RightVector.Y)*s.X+math.abs(c.UpVector.Y)*s.Y+math.abs(c.LookVector.Y)*s.Z) local y=c.Position.Y-ext if not low or y<low then low=y end end end return low end
local function hideReal01(char) local function hide(p) if State01.hidden[p]==nil then State01.hidden[p]=p.Transparency end if p.Transparency~=1 then p.Transparency=1 end end for _,c in ipairs(char:GetChildren()) do if c:IsA("BasePart") and c.Name~="HumanoidRootPart" then hide(c) elseif c:IsA("Accoutrement") then for _,d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then hide(d) end end end end end
local function setShellLTM01(v) for _,p in ipairs(State01.shellParts) do pcall(function() p.LocalTransparencyModifier=v end) end end
local function unmount01() for _,c in ipairs(State01.conns) do pcall(function() c:Disconnect() end) end State01.conns={} if State01.shell then pcall(function() State01.shell:Destroy() end) end for inst,t in pairs(State01.hidden) do if inst.Parent then pcall(function() inst.Transparency=t end) end end State01.shell,State01.sRoot,State01.char=nil,nil,nil State01.shellParts,State01.hidden,State01.pairList={},{},{} State01.mirror,State01.sAnimator,State01.animActive,State01.c0Dirty={},nil,false,false State01.fp=false end
local function noCollide01() for _,p in ipairs(State01.shellParts) do if p.CanCollide then p.CanCollide=false end if p.CanTouch then p.CanTouch=false end if p.CanQuery then p.CanQuery=false end end end
local function poseTransform01(rm) local p0,p1=rm.Part0,rm.Part1 if p0 and p1 then return (p0.CFrame*rm.C0):Inverse()*(p1.CFrame*rm.C1) end return rm.Transform end
local function resetC001() for _,pr in ipairs(State01.pairList) do local sm=pr[2] if sm.Parent then sm.C0=pr[3] end end State01.c0Dirty=false end
local function syncPose01() local shell,char=State01.shell,State01.char if not shell or not char or not char.Parent then return end if State01.animActive then if State01.c0Dirty then resetC001() end return end for _,pr in ipairs(State01.pairList) do local rm,sm,baseC0=pr[1],pr[2],pr[3] if rm.Parent and sm.Parent then local ok,tr=pcall(poseTransform01,rm) if ok and tr then sm.C0=baseC0*tr end end end State01.c0Dirty=true end
local function mirrorAnimations01() local char,shell,sAnim=State01.char,State01.shell,State01.sAnimator if not char or not shell or not sAnim or not sAnim.Parent then State01.animActive=false return end local rHum=char:FindFirstChildOfClass("Humanoid") local rAnim=rHum and rHum:FindFirstChildOfClass("Animator") if not rAnim then State01.animActive=false return end local okT,tracks=pcall(function() return rAnim:GetPlayingAnimationTracks() end) if not okT or type(tracks)~="table" then State01.animActive=false return end local seen,count={},0 for _,rt in ipairs(tracks) do local anim=rt.Animation if anim and anim.AnimationId~="" then seen[rt]=true local m=State01.mirror[rt] if not m then local ok,st=pcall(function() return sAnim:LoadAnimation(anim) end) if ok and st then m=st State01.mirror[rt]=st pcall(function() st.Priority=rt.Priority st.Looped=rt.Looped st:Play(0.1,math.max(rt.WeightCurrent,0.01),rt.Speed) end) end end if m then pcall(function() if not m.IsPlaying then m:Play(0.1,math.max(rt.WeightCurrent,0.01),rt.Speed) end m.Priority=rt.Priority m.Looped=rt.Looped m:AdjustWeight(math.max(rt.WeightCurrent,0.01),0) m:AdjustSpeed(rt.Speed) local len=rt.Length if len and len>0 then local d=math.abs(m.TimePosition-rt.TimePosition) if rt.Looped then d=math.min(d,len-d) end if d>0.25 then m.TimePosition=rt.TimePosition end end end) count=count+1 end end end for rt,st in pairs(State01.mirror) do if not seen[rt] then pcall(function() st:Stop(0.1) end) State01.mirror[rt]=nil end end State01.animActive=count>0 end
local function onStep01() local shell,char,sRoot=State01.shell,State01.char,State01.sRoot if not shell or not char or not sRoot or not char.Parent then return end local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return end local want=workspace.CurrentCamera or workspace if shell.Parent~=want then shell.Parent=want end for inst in pairs(State01.hidden) do if inst.Parent and inst.Transparency~=1 then inst.Transparency=1 end end noCollide01() sRoot.CFrame=hrp.CFrame*State01.offset mirrorAnimations01() syncPose01() local now=os.clock() if now-State01.lastScan>0.3 then State01.lastScan=now hideReal01(char) end local cam=workspace.CurrentCamera local head=char:FindFirstChild("Head") if cam and head then local fp=(cam.CFrame.Position-head.Position).Magnitude<1.6 if fp~=State01.fp then State01.fp=fp setShellLTM01(fp and 1 or 0) end end end
local function mount01(char,hum,template) unmount01() local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return false end local shell=template:Clone() shell.Name=SHELL_NAME_01ROXHUB local sRoot=shell:FindFirstChild("HumanoidRootPart") if not sRoot then shell:Destroy() return false end local sh=shell:FindFirstChildOfClass("Humanoid") local sAnimator if sh then pcall(function() sh.WalkSpeed=0 end) pcall(function() sh.JumpPower=0 end) pcall(function() sh.AutoRotate=false end) pcall(function() sh.PlatformStand=true end) sAnimator=sh:FindFirstChildOfClass("Animator") if not sAnimator then sAnimator=Instance.new("Animator") sAnimator.Parent=sh end end local list={} for _,rm in ipairs(char:GetDescendants()) do if rm:IsA("Motor6D") and rm.Parent and rm.Parent.Parent==char then local sp=shell:FindFirstChild(rm.Parent.Name) local sm=sp and sp:FindFirstChild(rm.Name) if sm and sm:IsA("Motor6D") then list[#list+1]={rm,sm,sm.C0} end end end local dy=0 local lowR,lowS=lowestLeg01(char),lowestLeg01(shell) if lowR and lowS then dy=math.clamp(lowR-lowS,-8,8) end State01.offset=CFrame.new(0,dy,0) sRoot.Anchored=true shell.PrimaryPart=sRoot shell:PivotTo(hrp.CFrame*State01.offset) local parts={} for _,d in ipairs(shell:GetDescendants()) do if d:IsA("BasePart") then pcall(function() d.CanCollide=false d.CanTouch=false d.CanQuery=false d.Massless=true end) parts[#parts+1]=d end end State01.shell,State01.sRoot,State01.char=shell,sRoot,char State01.sAnimator,State01.mirror,State01.animActive,State01.c0Dirty=sAnimator,{},false,false State01.shellParts,State01.pairList=parts,list State01.fp=false shell.Parent=workspace.CurrentCamera or workspace hideReal01(char) State01.lastScan=os.clock() State01.conns[#State01.conns+1]=RunService01.RenderStepped:Connect(onStep01) State01.conns[#State01.conns+1]=RunService01.Stepped:Connect(function() noCollide01() syncPose01() end) State01.conns[#State01.conns+1]=RunService01.Heartbeat:Connect(function() noCollide01() syncPose01() end) return true end
local function buildTemplate01(desc,rig,char) local template,mode=templateFromDescription01(desc,rig),"model" if not template then template,mode=templateFromAssets01(desc,char),"assets" end if not template then return nil end prepShell01(template) preload01(template) return template,mode end
local function evictBuilds01() while #BuildOrder01>MAX_BUILDS_01 do local victim for i,id in ipairs(BuildOrder01) do local b=Build01[id] if b and b.state~="building" and b.template~=State01.template then victim=i break end end if not victim then return end local id=table.remove(BuildOrder01,victim) local b=Build01[id] Build01[id]=nil if b and b.template then pcall(function() b.template:Destroy() end) end end end
local function ensureBuild01(entry) local char=LocalPlayer01.Character local hum=char and char:FindFirstChildOfClass("Humanoid") if not hum then return nil end local rig=hum.RigType local b=Build01[entry.id] if b and b.rig==rig and b.state~="failed" then return b end if b then local i=table.find(BuildOrder01,entry.id) if i then table.remove(BuildOrder01,i) end if b.template and b.template~=State01.template then pcall(function() b.template:Destroy() end) end end b={state="building",rig=rig} Build01[entry.id]=b BuildOrder01[#BuildOrder01+1]=entry.id task.spawn(function() local ok,t,mode=pcall(buildTemplate01,entry.desc,rig,char) if ok and t then b.template,b.mode,b.state=t,mode,"ready" else b.state="failed" end evictBuilds01() end) return b end
local current01=nil local busy01=false local applying01=false
local function resolveUser01(text) text=string.match(text or "","^%s*(.-)%s*$") if text=="" then return nil end local id,name if text:match("^%d+$") then id=tonumber(text) local ok,n=pcall(Players01.GetNameFromUserIdAsync,Players01,id) if ok then name=n else local ok2,id2=pcall(Players01.GetUserIdFromNameAsync,Players01,text) if ok2 then id=id2 else return nil end end else local ok,uid=pcall(Players01.GetUserIdFromNameAsync,Players01,text) if not ok then return nil end id=uid end if not name then local ok,n=pcall(Players01.GetNameFromUserIdAsync,Players01,id) name=ok and n or text end return id,name end
local function search01(text) if busy01 then return false end busy01=true local id,name=resolveUser01(text) if not id then busy01=false return false end local desc for _=1,3 do local ok,d=pcall(Players01.GetHumanoidDescriptionFromUserId,Players01,id) if ok and d then desc=d break end task.wait(0.3) end if not desc then busy01=false return false end current01={id=id,name=name,desc=desc} ensureBuild01(current01) busy01=false return true end
local function applyAvatar01(entry) local char=LocalPlayer01.Character local hum=char and char:FindFirstChildOfClass("Humanoid") local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hum or not hrp then return false end local b=ensureBuild01(entry) if not b then return false end if b.state=="building" then while b.state=="building" do task.wait(0.1) end end if b.state~="ready" or not b.template then Build01[entry.id]=nil return false end local template=b.template char=LocalPlayer01.Character hum=char and char:FindFirstChildOfClass("Humanoid") if not hum then return false end State01.template=template State01.desc=entry.desc return mount01(char,hum,template) end
local function copyCurrent01() if applying01 then return end if not current01 then return end applying01=true local cur=current01 local ok,success=pcall(applyAvatar01,cur) applying01=false return success end
local function restoreAvatar01() unmount01() State01.template,State01.desc=nil,nil end
LocalPlayer01.CharacterAdded:Connect(function(char)
    unmount01()
    local hum=char:WaitForChild("Humanoid",15) if not hum then return end
    char:WaitForChild("HumanoidRootPart",15) task.wait(0.4)
    if LocalPlayer01.Character~=char or not State01.template then return end
    while applying01 do task.wait(0.2) end
    local th=State01.template:FindFirstChildOfClass("Humanoid") if not th or th.RigType~=hum.RigType then return end
    mount01(char,hum,State01.template)
end)

local function LoadHub()
    local oldGui = PlayerGui:FindFirstChild("01ROXHUB")
    if oldGui then oldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "01ROXHUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    local Theme = {
        Bg      = Color3.fromRGB(8, 12, 22),
        Panel   = Color3.fromRGB(12, 18, 32),
        Card    = Color3.fromRGB(16, 24, 44),
        Line    = Color3.fromRGB(34, 52, 90),
        Accent    = Color3.fromRGB(80, 150, 255),
        AccentDim = Color3.fromRGB(44, 88, 165),
        Text    = Color3.fromRGB(226, 233, 246),
        Dim     = Color3.fromRGB(125, 139, 168),
        Off     = Color3.fromRGB(24, 34, 58),
        Green   = Color3.fromRGB(110, 190, 120),
        Orange  = Color3.fromRGB(214, 140, 70),
        Red     = Color3.fromRGB(200, 70, 80),
        Link    = Color3.fromRGB(120, 175, 255),
    }
    local FONT_TITLE = Enum.Font.Garamond
    local FONT       = Enum.Font.GothamMedium
    local FONT_BOLD  = Enum.Font.GothamBold

    local DISCORD_URL = "https://discord.gg/Tahsfsmgv7"

    local function make(class, props, parent)
        local o = Instance.new(class)
        if class == "TextLabel" or class == "TextButton" or class == "TextBox" then o.AutoLocalize = false end
        for k, v in pairs(props) do o[k] = v end
        if parent then o.Parent = parent end
        return o
    end
    local function corner(o, r)
        return make("UICorner", {CornerRadius = UDim.new(0, r)}, o)
    end
    local function stroke(o, color, thickness, transparency)
        return make("UIStroke", {
            Color = color, Thickness = thickness or 1, Transparency = transparency or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        }, o)
    end
    local function line(parent, props, mode, rotation)
        props.BorderSizePixel = 0
        local l = make("Frame", props, parent)
        local keys
        if mode == "center" then
            keys = {NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)}
        else
            keys = {NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
        end
        make("UIGradient", {Transparency = NumberSequence.new(keys), Rotation = rotation or 0}, l)
        return l
    end
    local function diamond(parent, x, y, size, color)
        return make("Frame", {
            Size = UDim2.new(0, size, 0, size), Position = UDim2.new(x[1], x[2], y[1], y[2]),
            BackgroundColor3 = color or Theme.Accent, BorderSizePixel = 0, Rotation = 45, ZIndex = 4,
        }, parent)
    end
    local function nextOrder(parent)
        local n = (parent:GetAttribute("_n") or 0) + 1
        parent:SetAttribute("_n", n)
        return n
    end

    -- Imágenes incrustadas (se guardan como archivos locales y se cargan con getcustomasset)
    local GUIIMG = {
        original = "rbxassetid://120887660443421",
        logo = "rbxassetid://120887660443421",
        bgLogo = nil, bgAnime = nil, bgManga = nil, intro = nil,
    }
    do
        local B64_ICON = [==[
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
AGx9oPKhYtsZAAAAAElFTkSuQmCC]==]
        local B64_LOGO = [==[
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]==]
        local B64_ANIME = [==[
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]==]
        local B64_MANGA = [==[
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]==]
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        local map = {}
        for i = 1, #chars do map[chars:byte(i)] = i - 1 end
        local fastDecode = nil
        pcall(function()
            if crypt and crypt.base64decode then fastDecode = crypt.base64decode
            elseif crypt and crypt.base64 and crypt.base64.decode then fastDecode = crypt.base64.decode
            elseif base64_decode then fastDecode = base64_decode
            elseif base64 and base64.decode then fastDecode = base64.decode end
        end)
        local function decode(b64)
            b64 = b64:gsub("%s", "")
            if fastDecode then
                local ok, res = pcall(fastDecode, b64)
                if ok and type(res) == "string" and #res > 0 then return res end
            end
            local out, n = {}, 0
            local len = #b64
            for i = 1, len - 3, 4 do
                local c1, c2, c3, c4 = b64:byte(i, i + 3)
                local v = map[c1] * 262144 + map[c2] * 4096 + (map[c3] or 0) * 64 + (map[c4] or 0)
                local b1 = math.floor(v / 65536)
                local b2 = math.floor(v / 256) % 256
                local b3 = v % 256
                n = n + 1
                if c4 == 61 then
                    out[n] = string.char(b1, b2)
                    if c3 == 61 then out[n] = string.char(b1) end
                else
                    out[n] = string.char(b1, b2, b3)
                end
                if n % 20000 == 0 then task.wait() end
            end
            return table.concat(out)
        end
        local function makeAsset(fileName, b64)
            local ok, res = pcall(function()
                writefile(fileName, decode(b64))
                return (getcustomasset or getsynasset)(fileName)
            end)
            if ok and res then return res end
            return nil
        end
        GUIIMG.makeAsset = makeAsset
        GUIIMG.logo = makeAsset("jxz1_hub_logo.png", B64_ICON) or GUIIMG.logo
        GUIIMG.bgLogo = makeAsset("jxz1_hub_bg_logo.png", B64_LOGO)
        GUIIMG.bgAnime = makeAsset("jxz1_hub_bg_anime.png", B64_ANIME)
        GUIIMG.bgManga = makeAsset("jxz1_hub_bg_manga.jpg", B64_MANGA)
    end
    local LOGO_IMG = GUIIMG.logo

    -- INTRO JXZ1 HUB (7 segundos, basada en la intro CSN DUELS)
    task.spawn(function()
        local introGui
        local introSound
        local introAlive = true
        local TweenService = game:GetService("TweenService")
        local SoundService = game:GetService("SoundService")

        local FRAME_URLS = {
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/1bc10233-9b3b-4859-a487-3b5fc4e14bb6/intro_f_01.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/6b27913b-f67f-4e58-8975-832867b4af5d/intro_f_02.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/14fa130a-ea07-46a8-b252-4d7c5d2996b5/intro_f_03.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/5646c27c-3674-4393-bc72-772b3a542170/intro_f_04.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/4ef24902-6e6f-45a2-9625-5737b1c482fd/intro_f_05.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/4795329c-c90a-477c-a6a6-9c0e33c3f67a/intro_f_06.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/13d406b3-db87-4971-bc1c-2a0b020bc841/intro_f_07.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/c88fe055-01d8-4c6d-b07f-54282e4df819/intro_f_08.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/fe0fa616-37af-491f-8cca-567d6682d28b/intro_f_09.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/e1ae74f8-6c0c-416d-805b-05cc9719bc0e/intro_f_10.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/f63d9d64-f309-40ea-b572-f2934673b82d/intro_f_11.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/57cf6040-0e8b-4119-8349-95252579fe51/intro_f_12.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/fd558668-521a-4d71-ad4b-d29acda34892/intro_f_13.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/1f1b69c9-fde6-4dbf-80e9-8dc6ec7d0099/intro_f_14.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/ac193f6a-dac6-45b6-a637-a8ca01774fde/intro_f_15.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/93c57d41-1ec5-4254-8801-3b065d226601/intro_f_16.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/891118c3-de59-41db-88b6-0c18fcbf9c30/intro_f_17.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/154fd1cd-5c98-474a-b157-0ffb53a0a88f/intro_f_18.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/bb8efe58-c5c9-4e98-9a91-b3929df54165/intro_f_19.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/c389b78c-a64b-43a0-af0d-fcf6f157ff3a/intro_f_20.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/a6a0445b-183f-4e24-bf57-a2ccec43647e/intro_f_21.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/dc27a6df-02a8-41fe-9bd2-9ebc8de6387c/intro_f_22.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/de6f17ad-3aee-451d-8e0f-39afd92830c0/intro_f_23.jpg",
            "https://project--851dd5ec-9e9c-43bf-90a7-8a1fe531d35f-dev.lovable.app/__l5e/assets-v1/d27cc486-ec31-4305-92e9-1e3a4728176c/intro_f_24.jpg",
        }

        local function introAsset(url, fileName)
            local asset
            pcall(function()
                if type(isfile) == "function" and isfile(fileName) then
                    asset = (getcustomasset or getsynasset)(fileName)
                end
            end)
            if asset then return asset end
            local ok, data = pcall(function() return game:HttpGet(url) end)
            if ok and type(data) == "string" and #data > 1000 then
                pcall(function() writefile(fileName, data) end)
                pcall(function() asset = (getcustomasset or getsynasset)(fileName) end)
            end
            return asset
        end

        local ok = pcall(function()
            introGui = Instance.new("ScreenGui")
            introGui.Name = "JXZ1_INTRO"
            introGui.ResetOnSpawn = false
            introGui.IgnoreGuiInset = true
            introGui.DisplayOrder = 2147483647
            introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            local placed = pcall(function() introGui.Parent = gethui() end)
            if not placed or not introGui.Parent then
                placed = pcall(function() introGui.Parent = game:GetService("CoreGui") end)
            end
            if not placed or not introGui.Parent then introGui.Parent = PlayerGui end

            local root = Instance.new("Frame")
            root.Size = UDim2.fromScale(1, 1)
            root.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            root.BorderSizePixel = 0
            root.ClipsDescendants = true
            root.Parent = introGui

            local picture = Instance.new("ImageLabel")
            picture.AnchorPoint = Vector2.new(0.5, 0.5)
            picture.Position = UDim2.fromScale(0.5, 0.5)
            picture.Size = UDim2.fromScale(1.08, 1.08)
            picture.BackgroundTransparency = 1
            picture.ImageTransparency = 1
            picture.ScaleType = Enum.ScaleType.Crop
            picture.Parent = root

            local shade = Instance.new("Frame")
            shade.Size = UDim2.fromScale(1, 1)
            shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            shade.BackgroundTransparency = 0.38
            shade.BorderSizePixel = 0
            shade.ZIndex = 2
            shade.Parent = root

            local title = Instance.new("TextLabel")
            title.AnchorPoint = Vector2.new(0.5, 0.5)
            title.Position = UDim2.fromScale(0.5, 0.49)
            title.Size = UDim2.fromScale(0.9, 0.2)
            title.BackgroundTransparency = 1
            title.Text = "JXZ1 HUB"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextTransparency = 1
            title.TextScaled = true
            title.Font = Enum.Font.GothamBlack
            title.ZIndex = 5
            title.Parent = root
            local outline = Instance.new("UIStroke")
            outline.Color = Color3.fromRGB(0, 0, 0)
            outline.Thickness = 3
            outline.Transparency = 1
            outline.Parent = title

            local skip = Instance.new("TextButton")
            skip.AnchorPoint = Vector2.new(1, 0)
            skip.Position = UDim2.new(1, -14, 0, 14)
            skip.Size = UDim2.fromOffset(76, 30)
            skip.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            skip.BackgroundTransparency = 0.2
            skip.BorderSizePixel = 0
            skip.Text = "SKIP"
            skip.TextColor3 = Color3.new(1, 1, 1)
            skip.TextSize = 12
            skip.Font = Enum.Font.GothamBold
            skip.ZIndex = 10
            skip.Parent = introGui
            Instance.new("UICorner", skip).CornerRadius = UDim.new(0, 7)

            local frames, loaded = {}, 0
            for i, url in ipairs(FRAME_URLS) do
                task.spawn(function()
                    local asset = introAsset(url, string.format("JXZ1_Intro_%02d.jpg", i))
                    if asset and introAlive then frames[i] = asset end
                    loaded = loaded + 1
                end)
            end

            task.spawn(function()
                local musicAsset = introAsset("https://files.catbox.moe/2dkt89.mp3", "JXZ1_Intro_Music.mp3")
                if musicAsset and introAlive then
                    introSound = Instance.new("Sound")
                    introSound.Name = "JXZ1IntroMusic"
                    introSound.SoundId = musicAsset
                    introSound.Volume = 0.55
                    introSound.Parent = SoundService
                    pcall(function() introSound:Play() end)
                end
            end)

            local skipped = false
            local started = os.clock()
            skip.MouseButton1Click:Connect(function() skipped = true end)

            -- Espera a que terminen las descargas antes de reproducir:
            -- cambiar Image mientras Roblox aún carga cada JPG causa destellos.
            local preloadStarted = os.clock()
            while introAlive and not skipped and loaded < #FRAME_URLS
                and os.clock() - preloadStarted < 4 do
                task.wait(0.05)
            end

            -- Construye una secuencia compacta con los fotogramas realmente cargados.
            local readyFrames = {}
            for i = 1, #FRAME_URLS do
                if frames[i] then
                    readyFrames[#readyFrames + 1] = frames[i]
                end
            end

            local playDuration = math.max(0.5, 6.15 - (os.clock() - started))
            if #readyFrames > 0 then
                picture.Image = readyFrames[1]
            end

            TweenService:Create(picture, TweenInfo.new(0.45), {
                ImageTransparency = 0
            }):Play()
            TweenService:Create(picture, TweenInfo.new(playDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.fromScale(1.16, 1.16)
            }):Play()

            -- Reproduce cada imagen una sola vez, a intervalos uniformes.
            -- No vuelve al primer fotograma ni intenta mostrar imágenes no cargadas.
            if #readyFrames > 1 then
                local frameDuration = playDuration / #readyFrames
                for i = 2, #readyFrames do
                    if not introAlive or skipped then break end
                    local nextAt = started + (i - 1) * frameDuration
                    while introAlive and not skipped and os.clock() < nextAt do
                        task.wait(0.01)
                    end
                    if introAlive and not skipped then
                        picture.Image = readyFrames[i]
                    end
                end
            end

            while introAlive and not skipped and os.clock() - started < playDuration do
                task.wait(0.02)
            end

            if not skipped then
                TweenService:Create(title, TweenInfo.new(0.45), {TextTransparency = 0}):Play()
                TweenService:Create(outline, TweenInfo.new(0.45), {Transparency = 0}):Play()
                task.wait(math.max(0, 6.55 - (os.clock() - started)))
            end

            introAlive = false
            if introSound then
                pcall(function()
                    TweenService:Create(introSound, TweenInfo.new(0.35), {Volume = 0}):Play()
                end)
                task.delay(0.4, function()
                    pcall(function() introSound:Stop(); introSound:Destroy() end)
                end)
            end
            if introGui then
                local fade = Instance.new("Frame")
                fade.Size = UDim2.fromScale(1, 1)
                fade.BackgroundColor3 = Color3.new(0, 0, 0)
                fade.BackgroundTransparency = 1
                fade.BorderSizePixel = 0
                fade.ZIndex = 20
                fade.Parent = root
                TweenService:Create(fade, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()
                task.wait(0.42)
                introGui:Destroy()
            end
        end)

        if not ok then
            introAlive = false
            pcall(function() if introSound then introSound:Stop(); introSound:Destroy() end end)
            pcall(function() if introGui then introGui:Destroy() end end)
        end
    end)

    local MainButton = make("ImageButton", {
        Name = "MainButton", Size = UDim2.new(0, 46, 0, 46), Position = UDim2.new(0.5, -23, 0, 12),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Image = GUIIMG.original,
        ScaleType = Enum.ScaleType.Crop, Active = true, Draggable = true,
    }, ScreenGui)
    corner(MainButton, 8)
    stroke(MainButton, Theme.AccentDim, 1, 0.1)
    make("UIPadding", {
        PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0),
        PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0),
    }, MainButton)

    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local baseScale = math.clamp(math.min((vp.X - 24) / 600, (vp.Y - 90) / 410), 0.5, 1)

    local MainFrame = make("Frame", {
        Name = "MainFrame", Size = UDim2.new(0, 600, 0, 410), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 18), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
        Visible = false, Active = true, Draggable = true, ClipsDescendants = true,
    }, ScreenGui)
    corner(MainFrame, 6)
    stroke(MainFrame, Theme.AccentDim, 1, 0.35)
    local uiScale = make("UIScale", {Scale = baseScale}, MainFrame)

    local Backdrop = make("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Image = "rbxassetid://120887660443421",
        ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.35, ImageColor3 = Color3.fromRGB(150, 170, 225), ZIndex = 0,
    }, MainFrame)
    corner(Backdrop, 6)

    local Header = make("Frame", {
        Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.35,
        BorderSizePixel = 0, ZIndex = 3,
    }, MainFrame)
    local HeaderIcon = make("ImageLabel", {
        Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(0, 16, 0, 12), BackgroundTransparency = 1,
        Image = GUIIMG.original, ScaleType = Enum.ScaleType.Crop, ZIndex = 4,
    }, Header)
    make("TextLabel", {
        Size = UDim2.new(1, -120, 0, 28), Position = UDim2.new(0, 60, 0, 6), BackgroundTransparency = 1,
        Text = "JXZ1 HUB", Font = FONT_TITLE, TextSize = 23, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
    }, Header)
    make("TextLabel", {
        Size = UDim2.new(1, -120, 0, 14), Position = UDim2.new(0, 60, 0, 34), BackgroundTransparency = 1,
        Text = "BY: JXZ1 HUB",
        Font = FONT, TextSize = 9, TextTruncate = Enum.TextTruncate.AtEnd, TextColor3 = Theme.AccentDim,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
    }, Header)

    local CloseBtn = make("TextButton", {
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -42, 0, 14), BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.2, Text = "", AutoButtonColor = false, ZIndex = 5,
    }, Header)
    corner(CloseBtn, 6)
    local closeStroke = stroke(CloseBtn, Theme.Line, 1, 0.1)
    local closeBars = {}
    for _, rot in ipairs({45, -45}) do
        local bar = make("Frame", {
            Size = UDim2.new(0, 12, 0, 2), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Rotation = rot, BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, ZIndex = 6,
        }, CloseBtn)
        corner(bar, 1)
        closeBars[#closeBars + 1] = bar
    end
    local function closeHover(on)
        local info = TweenInfo.new(0.15)
        TweenService:Create(CloseBtn, info, {
            BackgroundColor3 = on and Theme.Red or Theme.Card, BackgroundTransparency = on and 0.1 or 0.2,
        }):Play()
        TweenService:Create(closeStroke, info, {Color = on and Theme.Red or Theme.Line}):Play()
        for _, b in ipairs(closeBars) do
            TweenService:Create(b, info, {BackgroundColor3 = on and Theme.Text or Theme.Dim}):Play()
        end
    end
    CloseBtn.MouseEnter:Connect(function() closeHover(true) end)
    CloseBtn.MouseLeave:Connect(function() closeHover(false) end)

    line(MainFrame, {
        Size = UDim2.new(1, -40, 0, 1), Position = UDim2.new(0, 20, 0, 58),
        BackgroundColor3 = Theme.Accent, ZIndex = 3,
    }, "center")
    diamond(MainFrame, {0.5, -3}, {0, 55}, 7)

    local SIDE_W, TOP_H, FOOT_H = 168, 62, 12
    local SEARCH_H = 38
    make("Frame", {
        Size = UDim2.new(0, SIDE_W, 1, -(TOP_H + FOOT_H)), Position = UDim2.new(0, 0, 0, TOP_H),
        BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0.4, BorderSizePixel = 0, ZIndex = 1,
    }, MainFrame)
    local Side = make("ScrollingFrame", {
        Position = UDim2.new(0, 0, 0, TOP_H + SEARCH_H), Size = UDim2.new(0, SIDE_W, 1, -(TOP_H + SEARCH_H + FOOT_H)),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 2,
    }, MainFrame)
    make("UIListLayout", {
        Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, Side)
    make("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8)}, Side)

    local SearchFrame = make("Frame", {
        Size = UDim2.new(0, SIDE_W - 24, 0, 28), Position = UDim2.new(0, 12, 0, TOP_H + 6),
        BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 3,
    }, MainFrame)
    corner(SearchFrame, 6)
    local searchStroke = stroke(SearchFrame, Theme.Line, 1, 0.1)
    local lens = make("Frame", {
        Size = UDim2.new(0, 9, 0, 9), Position = UDim2.new(0, 10, 0, 8), BackgroundTransparency = 1, ZIndex = 4,
    }, SearchFrame)
    corner(lens, 5)
    stroke(lens, Theme.Dim, 1.5, 0)
    make("Frame", {
        Size = UDim2.new(0, 5, 0, 2), Position = UDim2.new(0, 18, 0, 17), Rotation = 45,
        BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, ZIndex = 4,
    }, SearchFrame)
    local SearchBox = make("TextBox", {
        Size = UDim2.new(1, -38, 1, 0), Position = UDim2.new(0, 32, 0, 0), BackgroundTransparency = 1,
        Text = "", PlaceholderText = "Search", PlaceholderColor3 = Theme.Dim, TextColor3 = Theme.Text,
        Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 4,
    }, SearchFrame)
    SearchBox.Focused:Connect(function()
        TweenService:Create(searchStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play()
    end)
    SearchBox.FocusLost:Connect(function()
        TweenService:Create(searchStroke, TweenInfo.new(0.15), {Color = Theme.Line}):Play()
    end)

    line(MainFrame, {
        Size = UDim2.new(0, 1, 1, -(TOP_H + FOOT_H + 16)), Position = UDim2.new(0, SIDE_W, 0, TOP_H + 8),
        BackgroundColor3 = Theme.Line, ZIndex = 2,
    }, "center", 90)

    local Content = make("Frame", {
        Position = UDim2.new(0, SIDE_W + 1, 0, TOP_H), Size = UDim2.new(1, -(SIDE_W + 1), 1, -(TOP_H + FOOT_H)),
        BackgroundColor3 = Theme.Panel, BackgroundTransparency = 0.85, BorderSizePixel = 0,
        ClipsDescendants = true, ZIndex = 1,
    }, MainFrame)

    local panels = {}
    local searchIndex = {}
    local function NewPanel(name)
        local p = make("ScrollingFrame", {
            Name = name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.AccentDim, ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
        }, Content)
        make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, p)
        make("UIPadding", {
            PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 18),
        }, p)
        panels[name] = p
        return p
    end

    local function Section(parent, text)
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = nextOrder(parent),
        }, parent)
        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = text, Font = FONT_TITLE,
            TextSize = 18, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left,
        }, f)
        line(f, {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = Theme.AccentDim,
        }, "left")
        return f
    end

    local function Row(parent, h)
        local r = make("Frame", {
            Size = UDim2.new(1, 0, 0, h or 42), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
            BorderSizePixel = 0, LayoutOrder = nextOrder(parent),
        }, parent)
        corner(r, 4)
        stroke(r, Theme.Line, 1, 0.3)
        return r
    end

    local function RowLabel(row, text, reserve, y)
        return make("TextLabel", {
            Size = UDim2.new(1, -(reserve or 84), 0, 20), Position = UDim2.new(0, 14, y and 0 or 0.5, y or -10),
            BackgroundTransparency = 1, Text = text, Font = FONT, TextSize = 12, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)
    end

    local ConfigControls = {}
    local ApplyingHubConfig = false
    local CONFIG_FILE = "JXZ1_HUB_config.json" -- archivo antiguo (compatibilidad)
    local CONFIG_PREFIX = "JXZ1_HUB_cfg_"
    local AUTO_FILE = "JXZ1_HUB_auto.txt"
    local function RegisterConfig(title, kind, api)
        ConfigControls[title .. "|" .. kind] = api
        return api
    end
    local function SanitizeConfigName(text)
        text = tostring(text or ""):gsub("[^%w%-_ ]", "")
        text = text:gsub("^%s+", "")
        text = text:gsub("%s+$", "")
        if text == "" or text:sub(1, 1) == "_" then return nil end
        return text:sub(1, 30)
    end
    local function ConfigPath(name) return CONFIG_PREFIX .. name .. ".json" end
    local function SaveHubConfig(name, autoLoad)
        if ApplyingHubConfig then return true end
        if type(writefile) ~= "function" or not name then return false end
        local data = {autoLoad = autoLoad == true, values = {}}
        for title, api in pairs(ConfigControls) do
            if api.Get then
                local ok, value = pcall(api.Get)
                if ok and (type(value) == "boolean" or type(value) == "number" or type(value) == "string") then
                    data.values[title] = value
                end
            end
        end
        local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
        if not ok then return false end
        local wrote = pcall(writefile, ConfigPath(name), encoded)
        if not wrote then return false end
        -- configuración que se ejecuta sola al abrir el script
        if autoLoad then
            pcall(writefile, AUTO_FILE, name)
        elseif type(readfile) == "function" and type(isfile) == "function" then
            local okA, existsA = pcall(isfile, AUTO_FILE)
            if okA and existsA then
                local okR, current = pcall(readfile, AUTO_FILE)
                if okR and current == name then pcall(writefile, AUTO_FILE, "") end
            end
        end
        return true
    end
    local function ReadHubConfig(path)
        path = path or CONFIG_FILE
        if type(readfile) ~= "function" or type(isfile) ~= "function" then return nil end
        local ok, exists = pcall(isfile, path)
        if not ok or not exists then return nil end
        local readOk, raw = pcall(readfile, path)
        if not readOk then return nil end
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if decodeOk and type(data) == "table" then return data end
        return nil
    end
    local function ListHubConfigs()
        local names = {}
        if type(listfiles) ~= "function" then return names end
        local ok, files = pcall(listfiles, "")
        if not ok or type(files) ~= "table" then
            ok, files = pcall(listfiles, ".")
        end
        if not ok or type(files) ~= "table" then return names end
        for _, path in ipairs(files) do
            local n = tostring(path):match(CONFIG_PREFIX .. "(.+)%.json$")
            if n and n:sub(1, 1) ~= "_" then names[#names + 1] = n end
        end
        table.sort(names)
        return names
    end
    local function ApplyHubConfig(data)
        if type(data) ~= "table" or type(data.values) ~= "table" then return end
        ApplyingHubConfig = true
        for title, value in pairs(data.values) do
            local api = ConfigControls[title]
            if api and api.Set then pcall(api.Set, value) end
        end
        ApplyingHubConfig = false
    end

    local function Toggle(parent, title, default, onChange)
        local row = Row(parent, 42)
        searchIndex[#searchIndex + 1] = {title = title, tab = parent.Name}
        RowLabel(row, title)
        local pill = make("TextButton", {
            Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -56, 0.5, -11),
            BackgroundColor3 = Theme.Off, Text = "", AutoButtonColor = false,
        }, row)
        corner(pill, 11)
        local pillStroke = stroke(pill, Theme.Line, 1, 0.1)
        local knob = make("Frame", {
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = Theme.Dim, BorderSizePixel = 0,
        }, pill)
        corner(knob, 8)

        local state = false
        local api = {}
        local function render(animate)
            local info = TweenInfo.new(animate and 0.2 or 0, Enum.EasingStyle.Quad)
            TweenService:Create(pill, info, {BackgroundColor3 = state and Theme.AccentDim or Theme.Off}):Play()
            TweenService:Create(pillStroke, info, {Color = state and Theme.Accent or Theme.Line}):Play()
            TweenService:Create(knob, info, {
                Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = state and Theme.Text or Theme.Dim,
            }):Play()
        end
        function api.Set(v, silent)
            state = v and true or false
            render(true)
            if onChange and not silent then onChange(state) end
        end
        function api.Get() return state end
        pill.MouseButton1Click:Connect(function() api.Set(not state) end)
        state = default and true or false
        render(false)
        return RegisterConfig(title, "TOGGLE", api)
    end

    local function bindDrag(hit, bar, cb)
        local dragging = false
        local function update(input)
            local a = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            cb(a)
        end
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function Slider(parent, title, minV, maxV, defaultV, callback)
        local row = Row(parent, 56)
        searchIndex[#searchIndex + 1] = {title = title, tab = parent.Name}
        RowLabel(row, title, 90, 8)
        local valueLabel = make("TextLabel", {
            Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -74, 0, 8), BackgroundTransparency = 1,
            Text = tostring(defaultV), Font = FONT_BOLD, TextSize = 12, TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        local bar = make("Frame", {
            Size = UDim2.new(1, -28, 0, 4), Position = UDim2.new(0, 14, 0, 38),
            BackgroundColor3 = Theme.Off, BorderSizePixel = 0,
        }, row)
        corner(bar, 2)
        local fill = make("Frame", {
            Size = UDim2.new((defaultV - minV) / (maxV - minV), 0, 1, 0),
            BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
        }, bar)
        corner(fill, 2)
        local knob = make("Frame", {
            Size = UDim2.new(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            BackgroundColor3 = Theme.Text, BorderSizePixel = 0, ZIndex = 3,
        }, fill)
        corner(knob, 6)
        stroke(knob, Theme.Accent, 1, 0)
        local hit = make("TextButton", {
            Size = UDim2.new(1, 0, 1, -24), Position = UDim2.new(0, 0, 0, 24),
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        }, row)
        local currentValue = defaultV
        local api = {}
        function api.Set(value, silent)
            local val = math.clamp(tonumber(value) or defaultV, minV, maxV)
            currentValue = val
            local alpha = (val - minV) / math.max(maxV - minV, 0.0001)
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(val * 10 + 0.5) / 10)
            if callback and not silent then callback(val) end
        end
        function api.Get() return currentValue end
        bindDrag(hit, bar, function(alpha) api.Set(minV + (maxV - minV) * alpha) end)
        return RegisterConfig(title, "SLIDER", api)
    end

    local function Dropdown(parent, title, options, default, callback)
        local row = Row(parent, 42)
        searchIndex[#searchIndex + 1] = {title = title, tab = parent.Name}
        row.ZIndex = 5
        RowLabel(row, title, 170)
        local btn = make("TextButton", {
            Size = UDim2.new(0, 130, 0, 26), Position = UDim2.new(1, -144, 0.5, -13),
            BackgroundColor3 = Theme.Off, Text = tostring(default or options[1]), TextColor3 = Theme.Accent,
            TextSize = 11, Font = FONT_BOLD, AutoButtonColor = false, ZIndex = 6,
        }, row)
        corner(btn, 4)
        stroke(btn, Theme.Line, 1, 0.1)
        make("TextLabel", {
            Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new(1, -18, 0, 0), BackgroundTransparency = 1,
            Text = "›", Font = FONT_BOLD, TextSize = 16, TextColor3 = Theme.AccentDim, Rotation = 90, ZIndex = 7,
        }, btn)

        local list = make("Frame", {
            Size = UDim2.new(0, 150, 0, #options * 26 + 8), AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -14, 1, 4), BackgroundColor3 = Theme.Panel, BorderSizePixel = 0,
            Visible = false, ZIndex = 20,
        }, row)
        corner(list, 4)
        stroke(list, Theme.Accent, 1, 0.4)
        make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)}, list)
        make("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, list)

        local api = {}
        local currentValue = default or options[1]
        function api.Set(v, silent)
            local valid = false
            for _, option in ipairs(options) do if option == v then valid = true break end end
            if not valid then return end
            currentValue = v
            btn.Text = tostring(v)
            if callback and not silent then callback(v) end
        end
        function api.Get() return currentValue end
        for i, opt in ipairs(options) do
            local o = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "  " .. tostring(opt),
                TextColor3 = Theme.Dim, TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false, LayoutOrder = i, ZIndex = 21,
            }, list)
            o.MouseEnter:Connect(function()
                o.TextColor3 = Theme.Accent
                o.BackgroundTransparency = 0.9
                o.BackgroundColor3 = Theme.Accent
            end)
            o.MouseLeave:Connect(function()
                o.TextColor3 = Theme.Dim
                o.BackgroundTransparency = 1
            end)
            o.MouseButton1Click:Connect(function()
                list.Visible = false
                api.Set(opt)
            end)
        end
        btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
        return RegisterConfig(title, "DROPDOWN", api)
    end

    local function ColorPicker(parent, title, defaultColor, callback)
        local row = Row(parent, 136)
        searchIndex[#searchIndex + 1] = {title = title, tab = parent.Name}
        RowLabel(row, title, 70, 8)
        local H, S, V = defaultColor:ToHSV()
        local preview = make("Frame", {
            Size = UDim2.new(0, 32, 0, 20), Position = UDim2.new(1, -46, 0, 8),
            BackgroundColor3 = defaultColor, BorderSizePixel = 0,
        }, row)
        corner(preview, 4)
        stroke(preview, Theme.Text, 1, 0.6)

        local knobs, sGrad, vGrad = {}, nil, nil
        local function refresh(fire)
            local c = Color3.fromHSV(H, S, V)
            preview.BackgroundColor3 = c
            if sGrad then sGrad.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(H, 1, 1)) end
            if vGrad then vGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(H, S, 1)) end
            if knobs.h then knobs.h.Position = UDim2.new(H, 0, 0.5, 0) end
            if knobs.s then knobs.s.Position = UDim2.new(S, 0, 0.5, 0) end
            if knobs.v then knobs.v.Position = UDim2.new(V, 0, 0.5, 0) end
            if fire and callback then callback(c) end
        end

        -- Colores rápidos de la paleta
        local swatchColors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 140, 0), Color3.fromRGB(255, 230, 0),
            Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 110, 255),
            Color3.fromRGB(160, 60, 255), Color3.fromRGB(255, 60, 200), Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(5, 5, 5),
        }
        local holder = make("Frame", {
            Size = UDim2.new(1, -28, 0, 22), Position = UDim2.new(0, 14, 0, 34), BackgroundTransparency = 1,
        }, row)
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, holder)
        for i, col in ipairs(swatchColors) do
            local sw = make("TextButton", {
                Size = UDim2.new(0, 22, 0, 22), BackgroundColor3 = col, Text = "", AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = i,
            }, holder)
            corner(sw, 11)
            stroke(sw, Theme.Text, 1, 0.6)
            sw.MouseButton1Click:Connect(function()
                H, S, V = col:ToHSV()
                refresh(true)
            end)
        end

        local function strip(y, label, setter)
            make("TextLabel", {
                Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 14, 0, y), BackgroundTransparency = 1,
                Text = label, Font = FONT_BOLD, TextSize = 10, TextColor3 = Theme.Dim,
            }, row)
            local bar = make("Frame", {
                Size = UDim2.new(1, -62, 0, 12), Position = UDim2.new(0, 34, 0, y + 1),
                BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
            }, row)
            corner(bar, 6)
            local grad = make("UIGradient", {}, bar)
            local knob = make("Frame", {
                Size = UDim2.new(0, 8, 1, 6), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = Theme.Text, BorderSizePixel = 0, ZIndex = 3,
            }, bar)
            corner(knob, 4)
            stroke(knob, Color3.new(0, 0, 0), 1, 0.3)
            local hit = make("TextButton", {
                Size = UDim2.new(1, -48, 0, 18), Position = UDim2.new(0, 30, 0, y - 2),
                BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
            }, row)
            bindDrag(hit, bar, function(alpha)
                setter(alpha)
                refresh(true)
            end)
            return grad, knob
        end

        local hGrad, hKnob = strip(66, "H", function(a) H = a end)
        local sG, sKnob = strip(88, "S", function(a) S = a end)
        local vG, vKnob = strip(110, "V", function(a) V = a end)
        sGrad, vGrad = sG, vG
        knobs.h, knobs.s, knobs.v = hKnob, sKnob, vKnob
        local hueKeys = {}
        for i = 0, 6 do hueKeys[#hueKeys + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(math.min(i / 6, 0.9999), 1, 1)) end
        hGrad.Color = ColorSequence.new(hueKeys)
        refresh(false)
    end

    local Home = NewPanel("HOME")
    Section(Home, "PERFIL")

    local card = make("Frame", {
        Size = UDim2.new(1, 0, 0, 132), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
        BorderSizePixel = 0, LayoutOrder = nextOrder(Home),
    }, Home)
    corner(card, 4)
    stroke(card, Theme.Line, 1, 0.2)

    local avatar = make("Frame", {
        Size = UDim2.new(0, 96, 0, 96), Position = UDim2.new(0, 16, 0, 18),
        BackgroundColor3 = Theme.Bg, BorderSizePixel = 0,
    }, card)
    corner(avatar, 4)
    stroke(avatar, Theme.Accent, 1.5, 0.1)
    local avatarImg = make("ImageLabel", {
        Size = UDim2.new(1, -6, 1, -6), Position = UDim2.new(0, 3, 0, 3), BackgroundTransparency = 1,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150",
        ScaleType = Enum.ScaleType.Fit,
    }, avatar)
    corner(avatarImg, 3)

    local function Field(y, label, value, font, size)
        make("TextLabel", {
            Size = UDim2.new(1, -140, 0, 12), Position = UDim2.new(0, 130, 0, y), BackgroundTransparency = 1,
            Text = label, Font = FONT_BOLD, TextSize = 9, TextColor3 = Theme.AccentDim,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        make("TextLabel", {
            Size = UDim2.new(1, -140, 0, 22), Position = UDim2.new(0, 130, 0, y + 12), BackgroundTransparency = 1,
            Text = value, Font = font, TextSize = size, TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, card)
    end
    Field(16, "USUARIO", Player.DisplayName .. "  @" .. Player.Name, FONT_TITLE, 20)
    Field(52, "ID", tostring(Player.UserId), FONT, 13)

    make("TextLabel", {
        Size = UDim2.new(0, 60, 0, 12), Position = UDim2.new(0, 130, 0, 90), BackgroundTransparency = 1,
        Text = "ESTADO", Font = FONT_BOLD, TextSize = 9, TextColor3 = Theme.AccentDim,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local statusDot = make("Frame", {
        Size = UDim2.new(0, 8, 0, 8), Position = UDim2.new(0, 130, 0, 108),
        BackgroundColor3 = Theme.Green, BorderSizePixel = 0,
    }, card)
    corner(statusDot, 4)
    make("TextLabel", {
        Size = UDim2.new(0, 80, 0, 16), Position = UDim2.new(0, 145, 0, 104), BackgroundTransparency = 1,
        Text = "Activo", Font = FONT_BOLD, TextSize = 12, TextColor3 = Theme.Green,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    make("TextLabel", {
        Size = UDim2.new(0, 120, 0, 12), Position = UDim2.new(1, -134, 1, -20), BackgroundTransparency = 1,
        Text = "BETA  ·  OFICIAL", Font = FONT, TextSize = 9, TextColor3 = Theme.Dim,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, card)

    task.spawn(function()
        while statusDot.Parent do
            TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.6}):Play()
            task.wait(1)
            if not statusDot.Parent then break end
            TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine), {BackgroundTransparency = 0}):Play()
            task.wait(1)
        end
    end)

    local statRow = make("Frame", {
        Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 1, LayoutOrder = nextOrder(Home),
    }, Home)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, statRow)
    local function StatCard(order, title, value, color)
        local c = make("Frame", {
            Size = UDim2.new(1 / 3, -6, 1, 0), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
            BorderSizePixel = 0, LayoutOrder = order,
        }, statRow)
        corner(c, 4)
        stroke(c, Theme.Line, 1, 0.3)
        make("TextLabel", {
            Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 12, 0, 9), BackgroundTransparency = 1,
            Text = title, Font = FONT_BOLD, TextSize = 9, TextColor3 = Theme.AccentDim,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c)
        return make("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 25), BackgroundTransparency = 1,
            Text = value, Font = FONT_BOLD, TextSize = 14, TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, c)
    end
    StatCard(1, "STATUS", "ONLINE", Theme.Green)
    local pingValue = StatCard(2, "PING", "...", Theme.Accent)
    StatCard(3, "BUILD", "STABLE", Theme.Accent)

    task.spawn(function()
        while pingValue.Parent do
            local ping = 0
            pcall(function() ping = math.floor(Player:GetNetworkPing() * 1000) end)
            if ping > 0 then
                pingValue.Text = ping .. " ms"
                pingValue.TextColor3 = (ping < 60 and Theme.Green) or (ping < 100 and Theme.Accent)
                    or (ping < 180 and Theme.Orange) or Theme.Red
            else
                pingValue.Text = "—"
                pingValue.TextColor3 = Theme.Dim
            end
            task.wait(1)
        end
    end)

    Section(Home, "COMUNIDAD")
    local discordRow = Row(Home, 66)
    make("TextLabel", {
        Size = UDim2.new(1, -150, 0, 18), Position = UDim2.new(0, 14, 0, 12), BackgroundTransparency = 1,
        Text = "Únete al Discord: soporte y updates", Font = FONT, TextSize = 12, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, discordRow)
    make("TextLabel", {
        Size = UDim2.new(1, -150, 0, 16), Position = UDim2.new(0, 14, 0, 34), BackgroundTransparency = 1,
        Text = DISCORD_URL, Font = FONT, TextSize = 11, TextColor3 = Theme.Link,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    }, discordRow)
    local discordBtn = make("TextButton", {
        Size = UDim2.new(0, 116, 0, 30), Position = UDim2.new(1, -130, 0.5, -15), BackgroundColor3 = Theme.Off,
        Text = "COPIAR ENLACE", Font = FONT_BOLD, TextSize = 11, TextColor3 = Theme.Accent, AutoButtonColor = false,
    }, discordRow)
    corner(discordBtn, 4)
    local discordStroke = stroke(discordBtn, Theme.AccentDim, 1, 0.1)
    local copied = false
    discordBtn.MouseEnter:Connect(function()
        if not copied then TweenService:Create(discordStroke, TweenInfo.new(0.15), {Color = Theme.Accent}):Play() end
    end)
    discordBtn.MouseLeave:Connect(function()
        if not copied then TweenService:Create(discordStroke, TweenInfo.new(0.15), {Color = Theme.AccentDim}):Play() end
    end)
    discordBtn.MouseButton1Click:Connect(function()
        if copied then return end
        pcall(function() setclipboard(DISCORD_URL) end)
        copied = true
        discordBtn.Text = "COPIADO"
        discordBtn.TextColor3 = Theme.Green
        discordStroke.Color = Theme.Green
        task.wait(1.5)
        copied = false
        discordBtn.Text = "COPIAR ENLACE"
        discordBtn.TextColor3 = Theme.Accent
        discordStroke.Color = Theme.AccentDim
    end)

    local autoShootEnabled = false
    local autoShootAgresivoEnabled = false
    local autoShootTargetPart = "Cabeza"
    local silentAimManualEnabled = false
    local silentAimFovEnabled = false
    local silentAimTargetPart = "Cabeza"
    local fovVisiblePreference = false
    local fovRadius = 120
    local equipGunEnabled = false
    local espEnabled = false
    local espColor = Color3.fromRGB(5, 5, 5)
    local espGlow = true

    getgenv().RoxHubTargetPart = nil

    local function refreshMonitor()
        if autoShootEnabled or autoShootAgresivoEnabled or silentAimManualEnabled
            or silentAimFovEnabled or equipGunEnabled or espEnabled then
            startTargetMonitor()
        else
            stopTargetMonitor()
        end
    end

    -- Botones movibles (mismo diseño que el de INVISIBLE): fondo de la GUI equipada, ON/OFF
    local FloatBtn = {}
    function FloatBtn.Remove(name)
        local old = ScreenGui:FindFirstChild(name)
        if old then old:Destroy() end
    end
    function FloatBtn.Create(name, text, pos, isActive, onPress)
        FloatBtn.Remove(name)
        local btn = make("TextButton", {
            Name = name, Size = UDim2.new(0, 112, 0, 48), Position = pos,
            BackgroundColor3 = Theme.Bg, Text = "", AutoButtonColor = false, Active = true, Draggable = true,
            ClipsDescendants = true, ZIndex = 30,
        }, ScreenGui)
        corner(btn, 10)
        stroke(btn, Theme.Accent, 1.5, 0.1)
        local bg = make("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, ZIndex = 30,
        }, btn)
        corner(bg, 10)
        local function syncBg()
            bg.Image = Backdrop.Image
            bg.ImageColor3 = Backdrop.ImageColor3
            bg.ImageTransparency = Backdrop.ImageTransparency
        end
        syncBg()
        for _, prop in ipairs({"Image", "ImageColor3", "ImageTransparency"}) do
            Backdrop:GetPropertyChangedSignal(prop):Connect(syncBg)
        end
        local label = make("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = FONT_BOLD, TextSize = 13,
            TextColor3 = Theme.Text, TextStrokeTransparency = 0.4, ZIndex = 31,
        }, btn)
        local function refreshLabel()
            if isActive() then
                label.Text = text .. "\nON"
                label.TextColor3 = Color3.fromRGB(80, 255, 120)
            else
                label.Text = text .. "\nOFF"
                label.TextColor3 = Color3.fromRGB(255, 90, 90)
            end
        end
        refreshLabel()
        local downPos
        btn.MouseButton1Down:Connect(function() downPos = btn.AbsolutePosition end)
        btn.MouseButton1Click:Connect(function()
            if downPos and (btn.AbsolutePosition - downPos).Magnitude > 6 then return end
            onPress()
            refreshLabel()
        end)
    end

    local Aim = NewPanel("AIMBOT")
    Section(Aim, "AUTO SHOOT")

    -- HITBOX EXPANDER (integrado desde JXZ1_HUB)
    Section(Aim, "HITBOX EXPANDER")
    local aimHitboxEnabled = false
    local aimHitboxInvisible = false
    local aimHitboxSize = 3.5
    local aimHitboxColor = Color3.fromRGB(255, 0, 0)

    local function limpiarAimHitboxes()
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            local character = targetPlayer.Character
            if character then
                local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
                if hitbox then hitbox:Destroy() end
            end
        end
    end

    Toggle(Aim, "HITBOX [VISIBLE]", false, function(value)
        aimHitboxEnabled = value
        if not value then limpiarAimHitboxes() end
    end)
    Toggle(Aim, "HITBOX [INVISIBLE]", false, function(value)
        aimHitboxInvisible = value
    end)
    Slider(Aim, "TAMAÑO HITBOX", 1, 18, 3.5, function(value)
        aimHitboxSize = math.clamp(value, 1, 18)
    end)
    ColorPicker(Aim, "COLOR DE LA HITBOX", aimHitboxColor, function(color)
        aimHitboxColor = color
    end)

    task.spawn(function()
        while task.wait(0.2) do
            if not aimHitboxEnabled then
                limpiarAimHitboxes()
                continue
            end
            if not IsInMatchStrict() then
                limpiarAimHitboxes()
                continue
            end

            local targetSize = Vector3.new(aimHitboxSize, aimHitboxSize, aimHitboxSize)
            local targetTransparency = aimHitboxInvisible and 1 or 0.6

            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                local character = targetPlayer.Character
                if targetPlayer ~= Player and esEnemigoValido(targetPlayer) and character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 then
                        local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
                        if not hitbox then
                            hitbox = Instance.new("Part")
                            hitbox.Name = "01ROXHUB_HITBOX"
                            hitbox.Size = targetSize
                            hitbox.Transparency = targetTransparency
                            hitbox.Color = aimHitboxColor
                            hitbox.CanCollide = false
                            hitbox.Massless = true
                            hitbox.CanQuery = true
                            hitbox.CFrame = rootPart.CFrame
                            hitbox.Parent = character

                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = rootPart
                            weld.Part1 = hitbox
                            weld.Parent = hitbox
                        else
                            if hitbox.Size ~= targetSize then hitbox.Size = targetSize end
                            if hitbox.Transparency ~= targetTransparency then hitbox.Transparency = targetTransparency end
                            if hitbox.Color ~= aimHitboxColor then hitbox.Color = aimHitboxColor end
                            if not hitbox.CanQuery then hitbox.CanQuery = true end
                        end
                    else
                        local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
                        if hitbox then hitbox:Destroy() end
                    end
                elseif character then
                    local hitbox = character:FindFirstChild("01ROXHUB_HITBOX")
                    if hitbox then hitbox:Destroy() end
                end
            end
        end
    end)
    Toggle(Aim, "AUTO SHOOT NORMAL", false, function(v)
        autoShootEnabled = false
        refreshMonitor()
        if not v then
            FloatBtn.Remove("AutoShotButton")
            return
        end
        FloatBtn.Create("AutoShotButton", "AUTO SHOT", UDim2.new(0.5, -126, 0.85, 0),
            function() return autoShootEnabled end,
            function()
                autoShootEnabled = not autoShootEnabled
                refreshMonitor()
            end)
    end)
    Toggle(Aim, "AUTO SHOOT AGRESIVO", false, function(v)
        autoShootAgresivoEnabled = false
        refreshMonitor()
        if not v then
            FloatBtn.Remove("AutoShotAgresivoButton")
            return
        end
        FloatBtn.Create("AutoShotAgresivoButton", "AUTO SHOT\nAGRESIVO", UDim2.new(0.5, 14, 0.85, 0),
            function() return autoShootAgresivoEnabled end,
            function()
                autoShootAgresivoEnabled = not autoShootAgresivoEnabled
                refreshMonitor()
            end)
    end)

    local partMap = {["CABEZA"] = "Cabeza", ["TORSO"] = "Torso", ["CUERPO COMPLETO"] = "Cuerpo"}
    Dropdown(Aim, "TARGET PARTE DEL CUERPO", {"CABEZA", "TORSO", "CUERPO COMPLETO"}, "CABEZA", function(v)
        autoShootTargetPart = partMap[v] or "Cabeza"
        silentAimTargetPart = autoShootTargetPart
    end)

    local equipWorkerRunning = false
    local function startEquipWorker()
        if equipWorkerRunning or not equipGunEnabled then return end
        equipWorkerRunning = true
        task.spawn(function()
            local gunRayParams = RaycastParams.new()
            gunRayParams.FilterType = Enum.RaycastFilterType.Exclude
            while equipGunEnabled do
                task.wait(0.1)
                if not equipGunEnabled then break end
                if not IsInMatchStrict() then continue end
                local char = Player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hum then continue end
                if hum.Health <= 0 then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if not hrp then continue end
                local originPos = head and head.Position or hrp.Position
                local hayEnemigoVisible = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Player and esEnemigoValido(p) then
                        local pChar = p.Character
                        if pChar then
                            local targetPart = pChar:FindFirstChild("Head") or pChar:FindFirstChild("UpperTorso")
                                or pChar:FindFirstChild("Torso") or pChar:FindFirstChild("HumanoidRootPart")
                            if targetPart and targetPart:IsA("BasePart") then
                                gunRayParams.FilterDescendantsInstances = {char, pChar}
                                local result = workspace:Raycast(originPos, targetPart.Position - originPos, gunRayParams)
                                if not result and IsInMatchStrict() then
                                    hayEnemigoVisible = true
                                    break
                                end
                            end
                        end
                    end
                end
                if not hayEnemigoVisible then continue end
                local pistola = obtenerPistola()
                if not pistola then continue end
                char = Player.Character
                hum = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hum then continue end
                pistola = obtenerPistola()
                if not pistola then continue end
                if pistola.Parent ~= char then pcall(function() hum:EquipTool(pistola) end) end
                task.wait(0.35)
                if not equipGunEnabled then break end
                char = Player.Character
                hum = char and char:FindFirstChildOfClass("Humanoid")
                if char and hum then pcall(function() hum:UnequipTools() end) end
                task.wait(1.9)
            end
            equipWorkerRunning = false
        end)
    end
    Toggle(Aim, "EQUIPA LA ARMA AUTOMÁTICAMENTE", false, function(v)
        equipGunEnabled = v
        refreshMonitor()
        if v then startEquipWorker() end
    end)

    Section(Aim, "SILENT AIM")
    Toggle(Aim, "SILENT AIM", false, function(v) silentAimManualEnabled = v; refreshMonitor() end)
    Toggle(Aim, "SILENT AIM (CON FOV)", false, function(v) silentAimFovEnabled = v; refreshMonitor() end)
    Toggle(Aim, "MOSTRAR FOV", false, function(v) fovVisiblePreference = v end)
    Slider(Aim, "TAMAÑO DEL FOV", 10, 200, 120, function(v) fovRadius = v end)

    local Vis = NewPanel("VISUALS")
    local espFolder = Instance.new("Folder")
    espFolder.Name = "01ROXHUB"
    espFolder.Parent = ScreenGui

    Section(Vis, "ESP")
    Toggle(Vis, "ESP HIGHLIGHT", false, function(v) espEnabled = v; refreshMonitor() end)
    ColorPicker(Vis, "COLOR DEL ESP", Color3.fromRGB(5, 5, 5), function(c) espColor = c end)
    Toggle(Vis, "ACTIVAR ESP", true, function(v) espGlow = v end)

    local activeESPs = {}
    local function cleanAllESPs()
        for p, hl in pairs(activeESPs) do
            if hl then hl:Destroy() end
            activeESPs[p] = nil
        end
    end
    Players.PlayerRemoving:Connect(function(p)
        if activeESPs[p] then
            activeESPs[p]:Destroy()
            activeESPs[p] = nil
        end
    end)
    task.spawn(function()
        while task.wait(0.2) do
            if espEnabled and IsInMatchStrict() then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Player and isEnemy(p) then
                        local char = p.Character
                        if char and char:FindFirstChild("Head") then
                            local hl = activeESPs[p]
                            if not hl or hl.Adornee ~= char or hl.Parent ~= espFolder then
                                if hl then hl:Destroy() end
                                hl = Instance.new("Highlight")
                                hl.Name = "01ROXHUB" .. p.Name
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 1
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Adornee = char
                                hl.Parent = espFolder
                                activeESPs[p] = hl
                            end
                            hl.Enabled = espGlow
                            hl.FillColor = espColor
                            hl.OutlineColor = espColor
                        elseif activeESPs[p] then
                            activeESPs[p]:Destroy()
                            activeESPs[p] = nil
                        end
                    elseif activeESPs[p] then
                        activeESPs[p]:Destroy()
                        activeESPs[p] = nil
                    end
                end
            else
                cleanAllESPs()
            end
        end
    end)

    Section(Vis, "AVATAR")
    local avatarInputRow = Row(Vis, 42)
    RowLabel(avatarInputRow, "USUARIO / ID", 150)
    local avatarInput = make("TextBox", {
        Size = UDim2.new(0, 132, 0, 26), Position = UDim2.new(1, -146, 0.5, -13),
        BackgroundColor3 = Theme.Off, Text = "Loser", PlaceholderText = "Nombre o ID",
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.Dim, Font = FONT, TextSize = 11,
        ClearTextOnFocus = false, BorderSizePixel = 0,
    }, avatarInputRow)
    corner(avatarInput, 4)
    stroke(avatarInput, Theme.Line, 1, 0.1)

    local copyAvatarRow = Row(Vis, 42)
    local copyAvatarButton = make("TextButton", {
        Size = UDim2.new(1, -16, 1, -8), Position = UDim2.new(0, 8, 0, 4),
        BackgroundColor3 = Theme.Off, Text = "COPIAR AVATAR", TextColor3 = Theme.Accent,
        Font = FONT_BOLD, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0,
    }, copyAvatarRow)
    corner(copyAvatarButton, 4)
    stroke(copyAvatarButton, Theme.AccentDim, 1, 0.1)
    copyAvatarButton.MouseButton1Click:Connect(function()
        userParaCopiar01 = avatarInput.Text
        if userParaCopiar01 == "" then return end
        task.spawn(function()
            if search01(userParaCopiar01) then copyCurrent01() end
        end)
    end)

    local restoreAvatarRow = Row(Vis, 42)
    local restoreAvatarButton = make("TextButton", {
        Size = UDim2.new(1, -16, 1, -8), Position = UDim2.new(0, 8, 0, 4),
        BackgroundColor3 = Theme.Off, Text = "QUITAR AVATAR", TextColor3 = Theme.Accent,
        Font = FONT_BOLD, TextSize = 12, AutoButtonColor = false, BorderSizePixel = 0,
    }, restoreAvatarRow)
    corner(restoreAvatarButton, 4)
    stroke(restoreAvatarButton, Theme.Line, 1, 0.1)
    restoreAvatarButton.MouseButton1Click:Connect(function() restoreAvatar01() end)

    local Move = NewPanel("MOVEMENT")

    local PlatformActive = false
    local platformSpawned = false
    local activePlatforms = {}

    local function StartPlatforms()
        if platformSpawned then return end
        platformSpawned = true
        task.spawn(function()
            while PlatformActive do
                task.wait(0.05)
                local char = Player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    if hum.MoveDirection.Magnitude > 0 or char.HumanoidRootPart.AssemblyLinearVelocity.Y ~= 0 then
                        local platform = Instance.new("Part")
                        platform.Size = Vector3.new(6, 0.6, 6)
                        platform.Anchored = true
                        platform.CanCollide = true
                        platform.Color = Color3.fromRGB(5, 5, 5)
                        platform.Material = Enum.Material.Neon
                        platform.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, -3.3, 0)
                        platform.Parent = workspace
                        table.insert(activePlatforms, platform)
                        if #activePlatforms > 3 then
                            local oldPlatform = table.remove(activePlatforms, 1)
                            if oldPlatform then oldPlatform:Destroy() end
                        end
                    end
                end
            end
        end)
    end
    local function StopPlatforms()
        PlatformActive = false
        platformSpawned = false
        for _, plat in ipairs(activePlatforms) do
            if plat then plat:Destroy() end
        end
        activePlatforms = {}
    end

    Section(Move, "MOVIMIENTO")
    Toggle(Move, "FIXED PLATFORM", false, function(v)
        StopPlatforms()
        if not v then
            FloatBtn.Remove("PlatformButton")
            return
        end
        FloatBtn.Create("PlatformButton", "PLATFORM", UDim2.new(0.5, -56, 0.45, 0),
            function() return PlatformActive end,
            function()
                if PlatformActive then
                    StopPlatforms()
                else
                    PlatformActive = true
                    StartPlatforms()
                end
            end)
    end)

    -- INVISIBLE V6: al activarlo solo aparece el botón movible; la invisibilidad se prende/apaga con el botón
    do
    local function StopInvisible()
        local lp = game:GetService("Players").LocalPlayer
        if _G.InvisCon then _G.InvisCon:Disconnect() _G.InvisCon = nil end
        _G.InvisActive = false
        if lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 0
                end
            end
        end
    end
    local function StartInvisible()
        local RunService = game:GetService("RunService")
        local lp = game:GetService("Players").LocalPlayer
        local DISTANCIA = 50
        local TRANSPARENCIA = 0.6
        if _G.InvisCon then _G.InvisCon:Disconnect() _G.InvisCon = nil end
        _G.InvisActive = true
        if lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = (v.Name == "HumanoidRootPart") and 1 or TRANSPARENCIA
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = TRANSPARENCIA
                end
            end
        end
        _G.InvisCon = RunService.Heartbeat:Connect(function()
            if not _G.InvisActive then return end
            local Char = lp.Character
            if not Char then return end
            local Root = Char:FindFirstChild("HumanoidRootPart")
            local Hum = Char:FindFirstChild("Humanoid")
            if not Root or not Hum or Hum.Health <= 0 then return end
            local oldCF = Root.CFrame
            local oldCamOffset = Hum.CameraOffset
            local invisCF = oldCF * CFrame.new(0, -DISTANCIA, 0)
            Root.CFrame = invisCF
            Hum.CameraOffset = invisCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
            RunService.RenderStepped:Wait()
            if Root and Root.Parent and Hum.Health > 0 then
                Root.CFrame = oldCF
                Hum.CameraOffset = oldCamOffset
            end
        end)
    end
    Toggle(Move, "INVISIBLE V6", false, function(state)
        StopInvisible()
        if not state then
            FloatBtn.Remove("InvisibleButton")
            return
        end
        FloatBtn.Create("InvisibleButton", "INVISIBLE", UDim2.new(0.5, -56, 0.35, 0),
            function() return _G.InvisActive == true end,
            function()
                if _G.InvisActive then StopInvisible() else StartInvisible() end
            end)
    end)
    end

    -- FLY SPEED V1 (extraído del módulo original)
Toggle(Move, "FLY SPEED V1", false, function(state)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local lp = Players.LocalPlayer
        local PlayerGui = lp:WaitForChild("PlayerGui")
        if not state then
            local old = PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED")
            if old then old:Destroy() end
            if _G.FlyCon1 then _G.FlyCon1:Disconnect() _G.FlyCon1 = nil end
            if _G.FlyCon2 then _G.FlyCon2:Disconnect() _G.FlyCon2 = nil end
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            return
        end
        if PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED") then
            PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED"):Destroy()
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "01ROXHUB_FLYSPEED"
        gui.ResetOnSpawn = false
        gui.Parent = PlayerGui
        local SPEED = 0.75
        local V_SPEED = 1.1
        local mov = {W=false,A=false,S=false,D=false,Up=false,Down=false}
        local presionando = false
        local pad = Instance.new("Frame", gui)
        pad.Name = "01ROXHUB_FLYSPEED"
        pad.Size = UDim2.fromOffset(128,185)
        pad.AnchorPoint = Vector2.new(0.5,0.5)
        pad.Position = UDim2.fromScale(0.5,0.65)
        pad.BackgroundColor3 = Color3.fromRGB(12,18,32)
        pad.BackgroundTransparency = 0.3
        Instance.new("UICorner", pad).CornerRadius = UDim.new(0,16)
        local stroke = Instance.new("UIStroke", pad)
        stroke.Color = Color3.fromRGB(80,150,255)
        stroke.Thickness = 2
        pad.Active = true
        pad.Draggable = true
        pad.ClipsDescendants = true
        local padBg = Instance.new("ImageLabel", pad)
        padBg.Name = "FondoGUI"
        padBg.Size = UDim2.new(1, 0, 1, 0)
        padBg.BackgroundTransparency = 1
        padBg.ScaleType = Enum.ScaleType.Crop
        padBg.ZIndex = 0
        Instance.new("UICorner", padBg).CornerRadius = UDim.new(0, 16)
        local function syncPadBg()
            padBg.Image = Backdrop.Image
            padBg.ImageColor3 = Backdrop.ImageColor3
            padBg.ImageTransparency = Backdrop.ImageTransparency
        end
        syncPadBg()
        for _, prop in ipairs({"Image", "ImageColor3", "ImageTransparency"}) do
            Backdrop:GetPropertyChangedSignal(prop):Connect(syncPadBg)
        end
        local function crearAzul(pos, txt, sx, sy, name)
            local b = Instance.new("TextButton", pad)
            b.Name = name
            b.Size = UDim2.fromOffset(sx or 30, sy or 30)
            b.Position = pos
            b.Text = txt
            b.TextScaled = true
            b.Font = Enum.Font.GothamBold
            b.TextColor3 = Color3.new(1,1,1)
            b.BackgroundColor3 = Color3.fromRGB(16,24,44)
            b.AutoButtonColor = false
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
            local grad = Instance.new("UIGradient", b)
            grad.Color = ColorSequence.new(Color3.fromRGB(80,150,255), Color3.fromRGB(44,88,165))
            grad.Rotation = 90
            return b
        end
        local up = crearAzul(UDim2.fromOffset(49,8), "▲", 30, 30, "01ROXHUB")
        local left = crearAzul(UDim2.fromOffset(10,42), "◄", 30, 30, "01ROXHUB")
        local right = crearAzul(UDim2.fromOffset(88,42), "►", 30, 30, "01ROXHUB")
        local down = crearAzul(UDim2.fromOffset(49,76), "▼", 30, 30, "01ROXHUB")
        local upV = crearAzul(UDim2.fromOffset(10,110), "⬆", 30, 30, "01ROXHUB")
        local downV = crearAzul(UDim2.fromOffset(88,110), "⬇", 30, 30, "01ROXHUB")
        local bajar = crearAzul(UDim2.fromOffset(6,148), "BAJAR", 54, 28, "01ROXHUB")
        local subir = crearAzul(UDim2.fromOffset(68,148), "SUBIR", 54, 28, "01ROXHUB")
        bajar.BackgroundColor3 = Color3.fromRGB(34,52,90)
        subir.BackgroundColor3 = Color3.fromRGB(80,150,255)
        local function estaEnPartida()
            local rs = game:GetService("ReplicatedStorage")
            if rs:FindFirstChild("GameInProgress") or rs:FindFirstChild("InGame") then
                local v = rs:FindFirstChild("GameInProgress") or rs:FindFirstChild("InGame")
                if v and v:IsA("BoolValue") then
                    return v.Value
                end
            end
            local char = lp.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if (char.HumanoidRootPart.Position - Vector3.new(0,10,0)).Magnitude > 150 then
                    return true
                end
            end
            return false
        end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.IgnoreWater = true
        local function noclipPared()
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            rayParams.FilterDescendantsInstances = {char}
            local dir = Vector3.new(0,0,0)
            if mov.W then dir += workspace.CurrentCamera.CFrame.LookVector end
            if mov.S then dir -= workspace.CurrentCamera.CFrame.LookVector end
            if mov.A then dir -= workspace.CurrentCamera.CFrame.RightVector end
            if mov.D then dir += workspace.CurrentCamera.CFrame.RightVector end
            if mov.Up then dir += Vector3.new(0,1,0) end
            if mov.Down then dir += Vector3.new(0,-1,0) end
            if dir.Magnitude == 0 then return end
            local ray = workspace:Raycast(hrp.Position, dir.Unit * 4, rayParams)
            if ray and ray.Instance and ray.Instance.CanCollide then
                local pared = ray.Instance
                pared.CanCollide = false
                task.delay(0.4, function()
                    pcall(function() pared.CanCollide = true end)
                end)
            end
        end
        local function conectar(b, k)
            b.MouseButton1Down:Connect(function()
                mov[k] = true
                presionando = true
            end)
            b.MouseButton1Up:Connect(function()
                mov[k] = false
                if not mov.W and not mov.A and not mov.S and not mov.D and not mov.Up and not mov.Down then
                    presionando = false
                end
            end)
            b.MouseLeave:Connect(function()
                mov[k] = false
                if not mov.W and not mov.A and not mov.S and not mov.D and not mov.Up and not mov.Down then
                    presionando = false
                end
            end)
        end
        conectar(up,"W")
        conectar(left,"A")
        conectar(right,"D")
        conectar(down,"S")
        conectar(upV,"Up")
        conectar(downV,"Down")
        bajar.MouseButton1Click:Connect(function()
            SPEED = math.clamp(SPEED - 0.1, 0.2, 3)
            V_SPEED = math.clamp(V_SPEED - 0.1, 0.2, 3)
        end)
        subir.MouseButton1Click:Connect(function()
            SPEED = math.clamp(SPEED + 0.1, 0.2, 3)
            V_SPEED = math.clamp(V_SPEED + 0.1, 0.2, 3)
        end)
        if _G.FlyCon1 then _G.FlyCon1:Disconnect() end
        if _G.FlyCon2 then _G.FlyCon2:Disconnect() end
        _G.FlyCon1 = RunService.RenderStepped:Connect(function()
            if not PlayerGui:FindFirstChild("01ROXHUB_FLYSPEED") then return end
            if not estaEnPartida() then
                pad.Visible = false
                return
            end
            pad.Visible = true
            if not presionando then return end
            local char = lp.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            if mov.Up or mov.Down or mov.W or mov.A or mov.S or mov.D then
                hum:ChangeState(Enum.HumanoidStateType.Flying)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X * 0.1, 0, hrp.AssemblyLinearVelocity.Z * 0.1)
            end
            noclipPared()
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.new(0,0,0)
            if mov.W then dir += Vector3.new(cam.LookVector.X,0,cam.LookVector.Z) end
            if mov.S then dir -= Vector3.new(cam.LookVector.X,0,cam.LookVector.Z) end
            if mov.A then dir -= Vector3.new(cam.RightVector.X,0,cam.RightVector.Z) end
            if mov.D then dir += Vector3.new(cam.RightVector.X,0,cam.RightVector.Z) end
            if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + dir.Unit * SPEED end
            if mov.Up then hrp.CFrame = hrp.CFrame + Vector3.new(0, V_SPEED, 0) end
            if mov.Down then hrp.CFrame = hrp.CFrame - Vector3.new(0, V_SPEED, 0) end
        end)
        _G.FlyCon2 = RunService.Heartbeat:Connect(function()
            if not presionando then
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum:GetState() == Enum.HumanoidStateType.Flying then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    end)

    -- FLY ALTURA + SPEED CFRAME (adaptado del módulo original)
    local EL01ROXHUB_flying = false
    local EL01ROXHUB_frozen = false
    local EL01ROXHUB_cframeOn = false
    local EL01ROXHUB_flyConn = nil
    local EL01ROXHUB_altura = 100
    local EL01ROXHUB_baseY = 0
    local EL01ROXHUB_speed = 1.2
    local EL01ROXHUB_keys = {W=false, A=false, S=false, D=false, Space=false, Shift=false}

    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.W then EL01ROXHUB_keys.W = true end
        if i.KeyCode == Enum.KeyCode.S then EL01ROXHUB_keys.S = true end
        if i.KeyCode == Enum.KeyCode.A then EL01ROXHUB_keys.A = true end
        if i.KeyCode == Enum.KeyCode.D then EL01ROXHUB_keys.D = true end
        if i.KeyCode == Enum.KeyCode.Space then EL01ROXHUB_keys.Space = true end
        if i.KeyCode == Enum.KeyCode.LeftShift then EL01ROXHUB_keys.Shift = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then EL01ROXHUB_keys.W = false end
        if i.KeyCode == Enum.KeyCode.S then EL01ROXHUB_keys.S = false end
        if i.KeyCode == Enum.KeyCode.A then EL01ROXHUB_keys.A = false end
        if i.KeyCode == Enum.KeyCode.D then EL01ROXHUB_keys.D = false end
        if i.KeyCode == Enum.KeyCode.Space then EL01ROXHUB_keys.Space = false end
        if i.KeyCode == Enum.KeyCode.LeftShift then EL01ROXHUB_keys.Shift = false end
    end)

    local function EL01ROXHUB_Noclip(char, dir)
        if dir.Magnitude == 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local head = char:FindFirstChild("Head")
        local alturaCabeza = head and head.Position.Y or (hrp.Position.Y + 2)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        params.IgnoreWater = true
        local result = workspace:Raycast(hrp.Position, (dir + Vector3.new(0, 0.6, 0)).Unit * 4, params)
        if not result then result = workspace:Raycast(hrp.Position, Vector3.new(0, 5, 0), params) end
        if result and result.Instance and result.Instance.CanCollide then
            local pared = result.Instance
            if pared.Position.Y < alturaCabeza or pared.Name == "Baseplate" or pared.Name == "Floor" then return end
            pared.CanCollide = false
            task.delay(0.35, function()
                pcall(function() if pared and pared.Parent then pared.CanCollide = true end end)
            end)
        end
    end

    local function EL01ROXHUB_StartFly()
        if EL01ROXHUB_flying then return end
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        EL01ROXHUB_flying = true
        EL01ROXHUB_baseY = root.Position.Y
        if EL01ROXHUB_flyConn then EL01ROXHUB_flyConn:Disconnect() end
        EL01ROXHUB_flyConn = RunService.RenderStepped:Connect(function()
            if not EL01ROXHUB_flying then return end
            local c = Player.Character
            if not c then return end
            local r = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not r or not h then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local speed = EL01ROXHUB_cframeOn and EL01ROXHUB_speed or 0.6
            local dir = Vector3.zero
            if EL01ROXHUB_keys.W then dir += Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z) end
            if EL01ROXHUB_keys.S then dir -= Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z) end
            if EL01ROXHUB_keys.A then dir -= Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z) end
            if EL01ROXHUB_keys.D then dir += Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z) end
            if h.MoveDirection.Magnitude > 0.1 then dir += h.MoveDirection end
            if dir.Magnitude > 0 then dir = dir.Unit end
            local y = 0
            if EL01ROXHUB_keys.Space then y = 1.25 end
            if EL01ROXHUB_keys.Shift then y = -1.25 end
            EL01ROXHUB_Noclip(c, dir)
            if EL01ROXHUB_frozen then
                r.Anchored = true
                local move = Vector3.new(dir.X * speed, y, dir.Z * speed)
                local rot = r.CFrame - r.CFrame.Position
                r.CFrame = CFrame.new(r.Position + move) * rot
            else
                r.Anchored = false
                local targetY = EL01ROXHUB_baseY + EL01ROXHUB_altura
                local diff = targetY - r.Position.Y
                local upAuto = 0
                if math.abs(diff) > 0.5 then upAuto = math.clamp(diff * 0.08, -1.2, 1.2) end
                local move = Vector3.new(dir.X * speed, upAuto + y, dir.Z * speed)
                local rot = r.CFrame - r.CFrame.Position
                r.CFrame = CFrame.new(r.Position + move) * rot
            end
            r.AssemblyLinearVelocity = Vector3.zero
        end)
    end

    local function EL01ROXHUB_StopFly()
        EL01ROXHUB_flying = false
        EL01ROXHUB_frozen = false
        if EL01ROXHUB_flyConn then EL01ROXHUB_flyConn:Disconnect() EL01ROXHUB_flyConn = nil end
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        hrp.Anchored = false
        hum.PlatformStand = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    Toggle(Move, "FLY ALTURA", false, function(state)
        EL01ROXHUB_StopFly()
        if not state then
            FloatBtn.Remove("FlyAlturaButton")
            return
        end
        FloatBtn.Create("FlyAlturaButton", "FLY ALTURA", UDim2.new(0.5, -56, 0.55, 0),
            function() return EL01ROXHUB_flying end,
            function()
                if EL01ROXHUB_flying then EL01ROXHUB_StopFly() else EL01ROXHUB_StartFly() end
            end)
    end)
    Slider(Move, "FLY ALTURA", 10, 5000, 100, function(value)
        EL01ROXHUB_altura = math.clamp(value, 10, 5000)
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if EL01ROXHUB_flying and root then EL01ROXHUB_baseY = root.Position.Y end
    end)
    Toggle(Move, "SPEED CFRAME", false, function(state)
        EL01ROXHUB_cframeOn = state
    end)
    Slider(Move, "SPEED CFRAME", 0.5, 5, 1.2, function(value)
        EL01ROXHUB_speed = math.clamp(value, 0.5, 5)
    end)

    local Anim = NewPanel("ANIMATIONS")
    local animSelected = {}

    local function ApplyAnims(ids)
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local Animate = char:FindFirstChild("Animate")
        if not Animate or not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
        local function setAnimId(parentName, childName, newId)
            local parentObj = Animate:FindFirstChild(parentName)
            if parentObj then
                local animObj = parentObj:FindFirstChild(childName)
                if animObj and animObj:IsA("Animation") then
                    animObj.AnimationId = newId or "rbxassetid://0"
                end
            end
        end
        setAnimId("idle", "Animation1", ids.idle1)
        setAnimId("idle", "Animation2", ids.idle2)
        setAnimId("walk", "WalkAnim", ids.walk)
        setAnimId("run", "RunAnim", ids.run)
        setAnimId("jump", "JumpAnim", ids.jump)
        setAnimId("fall", "FallAnim", ids.fall)
        Animate.Enabled = false
        task.wait(0.03)
        Animate.Enabled = true
        if hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Landed)
        end
    end

    local animData = {
        {"Astronaut", 891621366, 891633237, 891667138, 891636393, 891627522, 891617961},
        {"Bubbly", 910004836, 910009958, 910034870, 910025107, 910016857, 910001910},
        {"Cartoony", 742637544, 742638445, 742640026, 742638842, 742637942, 742637151},
        {"Elder", 845397899, 845400520, 845403856, 845386501, 845398858, 845396048},
        {"Knight", 657595757, 657568135, 657552124, 657564596, 658409194, 657600338},
        {"Levitation", 616006778, 616008087, 616013216, 616010382, 616008936, 616005863},
        {"Mage", 707742142, 707855907, 707897309, 707861613, 707853694, 707829716},
        {"Ninja", 656117400, 656118341, 656121766, 656118852, 656117878, 656115606},
        {"Pirate", 750781874, 750782770, 750785693, 750783738, 750782230, 750780242},
        {"Robot", 616088211, 616089559, 616095330, 616091570, 616090535, 616087089},
        {"Stylish", 616136790, 616138447, 616146177, 616140816, 616139451, 616134815},
        {"SuperHero", 616111295, 616113536, 616122287, 616117076, 616115533, 616108001},
        {"Toy", 782841498, 782845736, 782843345, 782842708, 782847020, 782846423},
        {"Vampire", 1083445855, 1083450166, 1083473930, 1083462077, 1083455352, 1083443587},
        {"Werewolf", 1083195517, 1083214717, 1083178339, 1083216690, 1083218792, 1083189019},
        {"Zombie", 616158929, 616160636, 616168032, 616163682, 616161997, 616157476},
        {"Patrol", 1149612882, 1150842221, 1151231493, 1150967949, 1148811837, 1148863382},
        {"Confident", 1069977950, 1069987858, 1070017263, 1070001516, 1069984524, 1069973677},
        {"Popstar", 1212900985, 1150842221, 1212980338, 1212980348, 1212954642, 1212900995},
        {"Cowboy", 1014390418, 1014398616, 1014421541, 1014401683, 1014394726, 1014384571},
        {"Ghost", 616006778, 616008087, 616013216, 616010382, 616008936, 616005863},
        {"Sneaky", 1132473842, 1132477671, 1132510133, 1132494274, 1132489853, 1132469004},
        {"Princess", 941003647, 941013098, 941028902, 941015281, 941008832, 941000007},
        {"None", 0, 0, 0, 0, 0, 0},
        {"Anthro (Default)", 2510196951, 2510197257, 2510202577, 2510198475, 2510197830, 2510195892},
    }
    local function asset(id) return "http://www.roblox.com/asset/?id=" .. id end

    Section(Anim, "ANIMACIONES")
    local AnimList
    Toggle(Anim, "ANIMACIONES", false, function(on)
        animSelected = {}
        if on then
            AnimList.Visible = true
        else
            AnimList.Visible = false
            local char = Player.Character
            local animate = char and char:FindFirstChild("Animate")
            if animate then
                animate.Enabled = false
                task.wait(0.05)
                animate.Enabled = true
            end
        end
    end)
    AnimList = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Visible = false, LayoutOrder = nextOrder(Anim),
    }, Anim)
    make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, AnimList)

    for i, a in ipairs(animData) do
        local ids = {
            idle1 = asset(a[2]), idle2 = asset(a[3]), walk = asset(a[4]),
            run = asset(a[5]), jump = asset(a[6]), fall = asset(a[7]),
        }
        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
            Text = "", AutoButtonColor = false, LayoutOrder = i,
        }, AnimList)
        corner(btn, 4)
        local btnStroke = stroke(btn, Theme.Line, 1, 0.3)
        local label = make("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1,
            Text = a[1], Font = FONT, TextSize = 12, TextColor3 = Theme.Dim,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, btn)
        local arrow = make("TextLabel", {
            Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1,
            Text = "›", Font = FONT_BOLD, TextSize = 20, TextColor3 = Theme.AccentDim,
        }, btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btnStroke, TweenInfo.new(0.18), {Color = Theme.Accent, Transparency = 0.1}):Play()
            TweenService:Create(label, TweenInfo.new(0.18), {TextColor3 = Theme.Text}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.18), {TextColor3 = Theme.Accent}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btnStroke, TweenInfo.new(0.18), {Color = Theme.Line, Transparency = 0.3}):Play()
            TweenService:Create(label, TweenInfo.new(0.18), {TextColor3 = Theme.Dim}):Play()
            TweenService:Create(arrow, TweenInfo.new(0.18), {TextColor3 = Theme.AccentDim}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            animSelected = ids
            ApplyAnims(ids)
        end)
    end

    local Farm = NewPanel("HIGH FARM")
    Section(Farm, "EVENTO")
    Toggle(Farm, "AUTO FARM HALLOWEEN", false, function(v)
        getgenv().RoxHubAutoEventFarm = v
    end)

    local AtrasEnabled = false
    local function GetCercanoAtras()
        local char = Player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
        if estaEnLobby() or not IsInMatchStrict() then return nil end
        local myRoot = char.HumanoidRootPart
        local cercano, distMin = nil, 200
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                and plr.Character:FindFirstChild("Humanoid") then
                local hum = plr.Character.Humanoid
                if hum.Health > 0 and esEnemigoValido(plr) then
                    local d = (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                    if d < distMin then distMin, cercano = d, plr end
                end
            end
        end
        return cercano
    end
    local function LoopAtrasSolo()
        while AtrasEnabled do
            if estaEnLobby() then task.wait(0.5) continue end
            local char = Player.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            if not char or not myRoot then task.wait(0.2) continue end
            local target = GetCercanoAtras()
            if target and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = target.Character:FindFirstChild("Humanoid")
                if targetRoot and targetHum and targetHum.Health > 0 then
                    while AtrasEnabled and targetHum.Health > 0 and targetRoot.Parent do
                        if estaEnLobby() or not esEnemigoValido(target) then break end
                        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if not root then break end
                        local behind = (targetRoot.CFrame * CFrame.new(0, 0, 6)).Position
                        root.CFrame = CFrame.lookAt(behind, targetRoot.Position)
                        root.AssemblyLinearVelocity = Vector3.zero
                        RunService.Heartbeat:Wait()
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end


    -- SONIDOS DE KILL
    local KillSoundEnabled = false
    local SelectedKillSound = "ES HACKER"
    local KillSoundVolume = 1
    local KillSounds = {
        { Name = "ES HACKER", Id = "126835547301650" },
        { Name = "DOMIDIOS VOLVÍ", Id = "75227901457581" },
        { Name = "BOYKA APLICACIÓN", Id = "74574513441326" },
        { Name = "AGÁRRATE DOMIDIOS", Id = "132837271823305" },
        { Name = "MAMBO", Id = "131928826207735" },
        { Name = "SUAVE SUAVE", Id = "107166596193919" },
        { Name = "ESTRELLA", Id = "109296938403067" },
    }
    local KillSoundPlayer = Instance.new("Sound")
    KillSoundPlayer.Name = "01ROXHUB_KillSound"
    KillSoundPlayer.Volume = KillSoundVolume
    KillSoundPlayer.Looped = false
    KillSoundPlayer.Parent = game:GetService("SoundService")

    local function GetKillSoundIdByName(soundName)
        for _, soundData in ipairs(KillSounds) do
            if soundData.Name == soundName then return soundData.Id end
        end
        return KillSounds[1].Id
    end

    local function PlayKillSound()
        if not KillSoundEnabled then return end
        KillSoundPlayer:Stop()
        KillSoundPlayer.SoundId = "rbxassetid://" .. GetKillSoundIdByName(SelectedKillSound)
        KillSoundPlayer.Volume = KillSoundVolume
        KillSoundPlayer:Play()
    end

    local lastKillSoundTime = 0
    local function TryPlayKillSound()
        if not KillSoundEnabled then return end
        local now = tick()
        if now - lastKillSoundTime < 0.08 then return end
        lastKillSoundTime = now
        PlayKillSound()
    end

    local function SetupKillSoundDetector()
        local killStatNames = { kos = true, kills = true, kill = true, ko = true, killed = true, eliminations = true, kills_count = true }
        local function hookStat(stat)
            if not stat or not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then return end
            if not killStatNames[string.lower(stat.Name)] or stat:GetAttribute("RoxhubKOHooked") then return end
            stat:SetAttribute("RoxhubKOHooked", true)
            local lastValue = stat.Value
            stat:GetPropertyChangedSignal("Value"):Connect(function()
                if stat.Value > lastValue then TryPlayKillSound() end
                lastValue = stat.Value
            end)
        end
        local function hookLeaderstats(container)
            if not container then return end
            for _, stat in ipairs(container:GetChildren()) do hookStat(stat) end
            container.ChildAdded:Connect(hookStat)
        end
        for _, attrName in ipairs({"KOs", "Kills", "kos", "kills", "KO", "killed", "Eliminations"}) do
            local lastValue = tonumber(Player:GetAttribute(attrName))
            Player:GetAttributeChangedSignal(attrName):Connect(function()
                local newValue = tonumber(Player:GetAttribute(attrName))
                if newValue and lastValue and newValue > lastValue then TryPlayKillSound() end
                lastValue = newValue
            end)
        end
        local stats = Player:FindFirstChild("leaderstats")
        if stats then hookLeaderstats(stats) end
        Player.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then hookLeaderstats(child) end
        end)
        local function hookCharacter(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not humanoid then return end
            humanoid.Died:Connect(function()
                local creator = humanoid:FindFirstChild("creator")
                if creator and creator.Value == Player then TryPlayKillSound() end
            end)
        end
        local function hookTarget(targetPlayer)
            if targetPlayer == Player then return end
            if targetPlayer.Character then task.spawn(hookCharacter, targetPlayer.Character) end
            targetPlayer.CharacterAdded:Connect(hookCharacter)
        end
        for _, targetPlayer in ipairs(Players:GetPlayers()) do hookTarget(targetPlayer) end
        Players.PlayerAdded:Connect(hookTarget)
    end
    SetupKillSoundDetector()

    local Kills = NewPanel("HIGH KILLS")
    Section(Kills, "SONIDOS DE KILL")
    Toggle(Kills, "SONIDO DE KILL", false, function(enabled)
        KillSoundEnabled = enabled
        if not enabled then KillSoundPlayer:Stop() end
    end)
    local killSoundOptions = {}
    for _, soundData in ipairs(KillSounds) do table.insert(killSoundOptions, soundData.Name) end
    Dropdown(Kills, "SONIDO DE MUERTE", killSoundOptions, SelectedKillSound, function(selected)
        SelectedKillSound = selected
    end)
    Slider(Kills, "VOLUMEN SONIDO", 1, 3, 1, function(value)
        KillSoundVolume = value
        KillSoundPlayer.Volume = value
    end)
    Section(Kills, "KILL ALL")
    do
        -- Al activar el toggle solo aparece el botón movible; el efecto se prende/apaga con el botón
        local telekillRunning = false
        local function SetTelekill(v)
            telekillRunning = v
            AtrasEnabled = v
            autoShootEnabled = v
            autoShootAgresivoEnabled = v
            refreshMonitor()
            if v then task.spawn(LoopAtrasSolo) else getgenv().RoxHubTargetPart = nil end
        end
        Toggle(Kills, "TELEKILL [SOLO ARMA]", false, function(v)
            if telekillRunning then SetTelekill(false) end
            if not v then
                FloatBtn.Remove("TelekillButton")
                return
            end
            FloatBtn.Create("TelekillButton", "TELEKILL", UDim2.new(0.5, -56, 0.65, 0),
                function() return telekillRunning end,
                function() SetTelekill(not telekillRunning) end)
        end)

        local killAllRunning = false
        local function SetKillAll(on)
            killAllRunning = on
            if on then RoxKillAllInstance:Start() else RoxKillAllInstance:Stop() end
        end
        Toggle(Kills, "KILL ALL", false, function(on)
            if killAllRunning then SetKillAll(false) end
            if not on then
                FloatBtn.Remove("KillAllButton")
                return
            end
            FloatBtn.Create("KillAllButton", "KILL ALL", UDim2.new(0.5, -56, 0.75, 0),
                function() return killAllRunning end,
                function() SetKillAll(not killAllRunning) end)
        end)
    end
    Slider(Kills, "VIBRACIÓN", 0.0, 3.0, 0.8, function(v) KILLALL_JITTER_AMPLITUDE = v end)
    Slider(Kills, "RADIO DE ACTIVACIÓN", 2.75, 9.0, 6.0, function(v) KILLALL_TRIGGER_RADIUS = v end)

    local Settings = NewPanel("SETTINGS")
    Section(Settings, "RENDIMIENTO")
    local lagRow = Row(Settings, 54)
    RowLabel(lagRow, "LIMPIAR LAG / MEMORIA", 120, 7)
    local lagButton = make("TextButton", {
        Size = UDim2.new(0, 92, 0, 28), Position = UDim2.new(1, -106, 0, 13),
        BackgroundColor3 = Theme.AccentDim, Text = "LIMPIAR", TextColor3 = Theme.Text,
        Font = FONT_BOLD, TextSize = 10, AutoButtonColor = false,
    }, lagRow)
    corner(lagButton, 5)
    lagButton.MouseButton1Click:Connect(function()
        pcall(function() collectgarbage("collect") end)
        pcall(function() if evictBuilds01 then evictBuilds01() end end)
        lagButton.Text = "LISTO"
        task.delay(1.2, function() if lagButton and lagButton.Parent then lagButton.Text = "LIMPIAR" end end)
    end)

    Section(Settings, "APARIENCIA")
    local bgOptions = {"ORIGINAL", "JXZ1 HUB", "ANIME", "MANGA"}
    Dropdown(Settings, "FONDO DE LA GUI", bgOptions, "ORIGINAL", function(choice)
        MainButton.ScaleType = Enum.ScaleType.Crop
        HeaderIcon.ScaleType = Enum.ScaleType.Crop
        if choice == "JXZ1 HUB" and GUIIMG.bgLogo then
            MainButton.Image = GUIIMG.bgLogo
            HeaderIcon.Image = GUIIMG.bgLogo
            Backdrop.Image = GUIIMG.bgLogo
            Backdrop.ImageColor3 = Color3.fromRGB(255, 255, 255)
            Backdrop.ImageTransparency = 0.45
        elseif choice == "ANIME" and GUIIMG.bgAnime then
            MainButton.Image = GUIIMG.bgAnime
            MainButton.ScaleType = Enum.ScaleType.Crop
            HeaderIcon.Image = GUIIMG.bgAnime
            HeaderIcon.ScaleType = Enum.ScaleType.Crop
            Backdrop.Image = GUIIMG.bgAnime
            Backdrop.ImageColor3 = Color3.fromRGB(255, 255, 255)
            Backdrop.ImageTransparency = 0.5
        elseif choice == "MANGA" and GUIIMG.bgManga then
            MainButton.Image = GUIIMG.bgManga
            MainButton.ScaleType = Enum.ScaleType.Crop
            HeaderIcon.Image = GUIIMG.bgManga
            HeaderIcon.ScaleType = Enum.ScaleType.Crop
            Backdrop.Image = GUIIMG.bgManga
            Backdrop.ImageColor3 = Color3.fromRGB(255, 255, 255)
            Backdrop.ImageTransparency = 0.65
        else
            MainButton.Image = GUIIMG.original
            HeaderIcon.Image = GUIIMG.original
            Backdrop.Image = GUIIMG.original
            Backdrop.ImageColor3 = Color3.fromRGB(150, 170, 225)
            Backdrop.ImageTransparency = 0.35
        end
    end)

    Section(Settings, "CONFIGURACIÓN")
    local autoConfigToggle = Toggle(Settings, "AUTO EJECUTAR CONFIGURACIÓN GUARDADA", false, function() end)
    local function SettingsButton(title, buttonText, callback)
        local row = Row(Settings, 46)
        RowLabel(row, title, 112)
        local button = make("TextButton", {
            Size = UDim2.new(0, 92, 0, 28), Position = UDim2.new(1, -106, 0.5, -14),
            BackgroundColor3 = Theme.AccentDim, Text = buttonText, TextColor3 = Theme.Text,
            Font = FONT_BOLD, TextSize = 10, AutoButtonColor = false,
        }, row)
        corner(button, 5)
        button.MouseButton1Click:Connect(function() callback(button) end)
        return button
    end

    -- Nombre de la configuración (tú eliges cómo se llama)
    local nameRow = Row(Settings, 46)
    RowLabel(nameRow, "NOMBRE DE CONFIG", 176)
    local nameBox = make("TextBox", {
        Size = UDim2.new(0, 150, 0, 28), Position = UDim2.new(1, -164, 0.5, -14),
        BackgroundColor3 = Theme.Off, Text = "config", PlaceholderText = "escribe un nombre",
        PlaceholderColor3 = Theme.Dim, TextColor3 = Theme.Text, Font = FONT, TextSize = 12,
        ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
    }, nameRow)
    corner(nameBox, 5)
    stroke(nameBox, Theme.Line, 1, 0.1)

    -- Lista de configuraciones guardadas (toca una para elegir su nombre)
    local listHolder = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        LayoutOrder = nextOrder(Settings),
    }, Settings)
    make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, listHolder)
    local function RefreshConfigList()
        for _, child in ipairs(listHolder:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        local names = ListHubConfigs()
        if #names == 0 then
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Font = FONT, TextSize = 11,
                Text = "Sin configuraciones guardadas", TextColor3 = Theme.Dim, LayoutOrder = 1,
            }, listHolder)
            return
        end
        for i, n in ipairs(names) do
            local item = make("TextButton", {
                Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
                Text = "  " .. n, TextColor3 = Theme.Text, Font = FONT, TextSize = 12, AutoButtonColor = false,
                TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i,
            }, listHolder)
            corner(item, 4)
            stroke(item, Theme.Line, 1, 0.3)
            item.MouseButton1Click:Connect(function() nameBox.Text = n end)
        end
    end

    SettingsButton("GUARDAR CONFIGURACIÓN", "GUARDAR", function(button)
        local name = SanitizeConfigName(nameBox.Text)
        if not name then
            button.Text = "PON NOMBRE"
        else
            nameBox.Text = name
            local ok = SaveHubConfig(name, autoConfigToggle.Get())
            button.Text = ok and "GUARDADO" or "ERROR"
            RefreshConfigList()
        end
        task.delay(1.5, function() if button.Parent then button.Text = "GUARDAR" end end)
    end)
    SettingsButton("CARGAR CONFIGURACIÓN", "CARGAR", function(button)
        local name = SanitizeConfigName(nameBox.Text)
        local data = name and ReadHubConfig(ConfigPath(name))
        if data then
            ApplyHubConfig(data)
            button.Text = "CARGADO"
        else
            button.Text = name and "SIN ARCHIVO" or "PON NOMBRE"
        end
        task.delay(1.5, function() if button.Parent then button.Text = "CARGAR" end end)
    end)
    SettingsButton("CONFIGS GUARDADAS", "ACTUALIZAR", function() RefreshConfigList() end)
    RefreshConfigList()

    -- Ejecutar sola al abrir el script: la última configuración guardada con "auto ejecutar"
    do
        local autoName
        if type(readfile) == "function" and type(isfile) == "function" then
            local okA, existsA = pcall(isfile, AUTO_FILE)
            if okA and existsA then
                local okR, raw = pcall(readfile, AUTO_FILE)
                if okR then autoName = SanitizeConfigName(raw) end
            end
        end
        local savedConfig = autoName and ReadHubConfig(ConfigPath(autoName))
        if savedConfig then
            nameBox.Text = autoName
            autoConfigToggle.Set(true, true)
            ApplyHubConfig(savedConfig)
        else
            -- compatibilidad con la configuración antigua
            local legacy = ReadHubConfig(CONFIG_FILE)
            if legacy and legacy.autoLoad == true then
                autoConfigToggle.Set(true, true)
                ApplyHubConfig(legacy)
            end
        end
    end

    local Credits = NewPanel("CREDITS")
    Section(Credits, "CREDITOS")

    -- Créditos del desarrollador: imagen + JXZ1 HUB + Discord con botón de copiar
    do
        local DEV_DISCORD = "https://discord.gg/3V9FDQATn"
        local devCard = make("Frame", {
            Size = UDim2.new(1, 0, 0, 152), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
            BorderSizePixel = 0, LayoutOrder = nextOrder(Credits),
        }, Credits)
        corner(devCard, 4)
        stroke(devCard, Theme.Line, 1, 0.2)
        local devImg = make("ImageLabel", {
            Size = UDim2.new(0, 118, 0, 66), Position = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Color3.new(0, 0, 0),
            Image = GUIIMG.bgLogo or GUIIMG.original, ScaleType = Enum.ScaleType.Fit,
        }, devCard)
        corner(devImg, 6)
        stroke(devImg, Theme.AccentDim, 1, 0.1)
        make("TextLabel", {
            Size = UDim2.new(1, -158, 0, 24), Position = UDim2.new(0, 146, 0, 14), BackgroundTransparency = 1,
            Text = "JXZ1 HUB", Font = FONT_TITLE, TextSize = 20, TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, devCard)
        make("TextLabel", {
            Size = UDim2.new(1, -158, 0, 40), Position = UDim2.new(0, 146, 0, 40), BackgroundTransparency = 1,
            Text = "Developer, creador del script. Créditos en su Discord:", Font = FONT, TextSize = 12,
            TextColor3 = Theme.Text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }, devCard)
        make("TextLabel", {
            Size = UDim2.new(1, -28, 0, 16), Position = UDim2.new(0, 14, 0, 92), BackgroundTransparency = 1,
            Text = DEV_DISCORD, Font = FONT, TextSize = 12, TextColor3 = Theme.Link,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
        }, devCard)
        local devBtn = make("TextButton", {
            Size = UDim2.new(0, 130, 0, 30), Position = UDim2.new(0, 14, 0, 114), BackgroundColor3 = Theme.Off,
            Text = "COPIAR ENLACE", Font = FONT_BOLD, TextSize = 11, TextColor3 = Theme.Accent, AutoButtonColor = false,
        }, devCard)
        corner(devBtn, 4)
        local devStroke = stroke(devBtn, Theme.AccentDim, 1, 0.1)
        local devCopied = false
        devBtn.MouseButton1Click:Connect(function()
            if devCopied then return end
            local ok = pcall(function() setclipboard(DEV_DISCORD) end)
            if not ok then pcall(function() toclipboard(DEV_DISCORD) end) end
            devCopied = true
            devBtn.Text = "COPIADO"
            devBtn.TextColor3 = Theme.Green
            devStroke.Color = Theme.Green
            task.wait(1.5)
            devCopied = false
            devBtn.Text = "COPIAR ENLACE"
            devBtn.TextColor3 = Theme.Accent
            devStroke.Color = Theme.AccentDim
        end)
    end

    local function tintIcon(parts, color, animate)
        local info = TweenInfo.new(animate and 0.15 or 0)
        for _, part in ipairs(parts) do
            if part:IsA("UIStroke") then
                TweenService:Create(part, info, {Color = color}):Play()
            else
                TweenService:Create(part, info, {BackgroundColor3 = color}):Play()
            end
        end
    end

    local function BuildIcon(name, parent)
        local box = make("Frame", {
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 14, 0.5, -8), BackgroundTransparency = 1, ZIndex = 4,
        }, parent)
        local parts = {}
        local function fill(x, y, w, h, rot, r)
            local f = make("Frame", {
                Size = UDim2.new(0, w, 0, h), Position = UDim2.new(0, x, 0, y), Rotation = rot or 0,
                BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, ZIndex = 4,
            }, box)
            if r then corner(f, r) end
            parts[#parts + 1] = f
            return f
        end
        local function outline(x, y, w, h, r, th, host)
            local f = make("Frame", {
                Size = UDim2.new(0, w, 0, h), Position = UDim2.new(0, x, 0, y), BackgroundTransparency = 1, ZIndex = 4,
            }, host or box)
            if r then corner(f, r) end
            parts[#parts + 1] = stroke(f, Theme.Dim, th or 1.5, 0)
            return f
        end

        if name == "HOME" then
            outline(3, 8, 10, 6, 1, 1.5)
            fill(1.5, 4.5, 8, 1.5, -38, 1)
            fill(6.5, 4.5, 8, 1.5, 38, 1)
            fill(7, 10.5, 2, 3.5, 0, 1)
        elseif name == "AIMBOT" then
            outline(3, 3, 10, 10, 5, 1.5)
            fill(7.25, 0, 1.5, 4, 0, 1)
            fill(7.25, 12, 1.5, 4, 0, 1)
            fill(0, 7.25, 4, 1.5, 0, 1)
            fill(12, 7.25, 4, 1.5, 0, 1)
            fill(7, 7, 2, 2, 0, 1)
        elseif name == "VISUALS" then
            outline(1, 4, 14, 8, 4, 1.5)
            fill(5.5, 5.5, 5, 5, 0, 3)
        elseif name == "MOVEMENT" then
            fill(1.5, 7.25, 11, 1.5, 0, 1)
            fill(9, 5.25, 6, 1.5, 45, 1)
            fill(9, 9.25, 6, 1.5, -45, 1)
        elseif name == "ANIMATIONS" then
            outline(2, 3, 12, 10, 2, 1.5)
            fill(5, 3, 1.5, 10, 0, 1)
            fill(10, 3, 1.5, 10, 0, 1)
        elseif name == "HIGH FARM" then
            fill(7.25, 7, 1.5, 8, 0, 1)
            fill(2, 4.5, 6, 3.2, -25, 2)
            fill(8, 2.5, 6, 3.2, 25, 2)
        elseif name == "HIGH KILLS" then
            outline(2.5, 1.5, 11, 9, 5, 1.5)
            outline(5.5, 9.5, 5, 4.5, 1, 1.5)
            fill(5, 5.5, 2, 2, 0, 1)
            fill(9, 5.5, 2, 2, 0, 1)
        elseif name == "SETTINGS" then
            outline(4.5, 4.5, 7, 7, 4, 1.5)
            for k = 0, 7 do
                local a = k * 45
                local cx = 8 + math.cos(math.rad(a)) * 6
                local cy = 8 + math.sin(math.rad(a)) * 6
                fill(cx - 1.75, cy - 1, 3.5, 2, a, 0)
            end
        elseif name == "CREDITS" then
            outline(5.5, 1.5, 5, 5, 3, 1.5)
            local clip = make("Frame", {
                Size = UDim2.new(0, 12, 0, 6), Position = UDim2.new(0, 2, 0, 9), BackgroundTransparency = 1,
                ClipsDescendants = true, ZIndex = 4,
            }, box)
            outline(0, 0, 12, 12, 6, 1.5, clip)
        end
        return parts
    end

    local navs = {}
    local current
    local function Select(name)
        current = name
        for n, d in pairs(navs) do
            local on = (n == name)
            d.deco.Visible = on
            TweenService:Create(d.btn, TweenInfo.new(0.15), {TextColor3 = on and Theme.Text or Theme.Dim}):Play()
            tintIcon(d.icon, on and Theme.Accent or Theme.Dim, true)
        end
        for n, p in pairs(panels) do p.Visible = (n == name) end
    end

    local function NavItem(text, order)
        local item = make("Frame", {
            Size = UDim2.new(1, -16, 0, 28), BackgroundTransparency = 1, LayoutOrder = order,
        }, Side)
        local deco = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 1,
        }, item)
        local glow = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, ZIndex = 1,
        }, deco)
        make("UIGradient", {Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.86), NumberSequenceKeypoint.new(1, 1),
        })}, glow)
        line(deco, {Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Theme.Accent, ZIndex = 1}, "center")
        line(deco, {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Theme.Accent, ZIndex = 1,
        }, "center")
        diamond(deco, {1, -17}, {0.5, -3}, 5)

        local btn = make("TextButton", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, Font = FONT_TITLE,
            TextSize = 17, TextColor3 = Theme.Dim, AutoButtonColor = false, ZIndex = 3,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, item)
        make("UIPadding", {PaddingLeft = UDim.new(0, 40)}, btn)
        local iconParts = BuildIcon(text, item)
        navs[text] = {btn = btn, deco = deco, item = item, icon = iconParts}
        btn.MouseEnter:Connect(function()
            if current ~= text then
                TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(190, 205, 235)}):Play()
                tintIcon(iconParts, Color3.fromRGB(190, 205, 235), true)
            end
        end)
        btn.MouseLeave:Connect(function()
            if current ~= text then
                TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Theme.Dim}):Play()
                tintIcon(iconParts, Theme.Dim, true)
            end
        end)
        btn.MouseButton1Click:Connect(function()
            if SearchBox.Text ~= "" then SearchBox.Text = "" end
            Select(text)
        end)
    end

    local tabOrder = {"HOME", "AIMBOT", "VISUALS", "MOVEMENT", "ANIMATIONS", "HIGH FARM", "HIGH KILLS", "SETTINGS", "CREDITS"}
    for i, name in ipairs(tabOrder) do NavItem(name, i) end
    Select("HOME")

    local SearchPanel = NewPanel("SEARCH")
    Section(SearchPanel, "SEARCH")
    local resultRows = {}
    local function runSearch()
        local q = string.lower(string.match(SearchBox.Text, "^%s*(.-)%s*$"))
        for name, d in pairs(navs) do
            d.item.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
        for _, r in ipairs(resultRows) do r:Destroy() end
        resultRows = {}
        if q == "" then
            for n, p in pairs(panels) do p.Visible = (n == current) end
            return
        end
        for n, p in pairs(panels) do p.Visible = (n == "SEARCH") end
        local found = 0
        for _, e in ipairs(searchIndex) do
            if string.find(string.lower(e.title), q, 1, true) then
                found = found + 1
                local b = make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.3,
                    Text = "", AutoButtonColor = false, LayoutOrder = nextOrder(SearchPanel),
                }, SearchPanel)
                corner(b, 4)
                local bs = stroke(b, Theme.Line, 1, 0.3)
                make("TextLabel", {
                    Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1,
                    Text = e.title, Font = FONT, TextSize = 12, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                }, b)
                make("TextLabel", {
                    Size = UDim2.new(0, 110, 1, 0), Position = UDim2.new(1, -122, 0, 0), BackgroundTransparency = 1,
                    Text = e.tab, Font = FONT_TITLE, TextSize = 14, TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, b)
                b.MouseEnter:Connect(function() bs.Color = Theme.Accent end)
                b.MouseLeave:Connect(function() bs.Color = Theme.Line end)
                b.MouseButton1Click:Connect(function()
                    SearchBox.Text = ""
                    Select(e.tab)
                end)
                resultRows[#resultRows + 1] = b
            end
        end
        if found == 0 then
            resultRows[1] = make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "No results",
                Font = FONT, TextSize = 12, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = nextOrder(SearchPanel),
            }, SearchPanel)
        end
    end
    SearchBox:GetPropertyChangedSignal("Text"):Connect(runSearch)

    local GRIP_ANGLE = -20
    local MIN_W, MIN_H = 480, 320
    local MAX_W, MAX_H = 900, 620

    local Grip = make("TextButton", {
        Name = "ResizeGrip", Size = UDim2.new(0, 30, 0, 30), AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -2, 1, -2), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 10,
    }, MainFrame)
    local gripLines = {}
    do
        local rad = math.rad(GRIP_ANGLE)
        local nx, ny = -math.sin(rad), math.cos(rad)
        local lengths = {16, 12, 8}
        for i = 1, 3 do
            local off = (i - 2) * 5
            gripLines[i] = make("Frame", {
                Size = UDim2.new(0, lengths[i], 0, 2), AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 4 + nx * off, 0.5, 4 + ny * off), Rotation = GRIP_ANGLE,
                BackgroundColor3 = Theme.Dim, BorderSizePixel = 0, ZIndex = 11,
            }, Grip)
            corner(gripLines[i], 1)
        end
    end
    local function gripColor(c)
        for _, l in ipairs(gripLines) do
            TweenService:Create(l, TweenInfo.new(0.12), {BackgroundColor3 = c}):Play()
        end
    end

    local resizing = false
    local rStartInput, rStartW, rStartH, rStartPos
    Grip.MouseEnter:Connect(function() if not resizing then gripColor(Theme.Accent) end end)
    Grip.MouseLeave:Connect(function() if not resizing then gripColor(Theme.Dim) end end)
    Grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            rStartInput = Vector2.new(input.Position.X, input.Position.Y)
            rStartW, rStartH = MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset
            rStartPos = MainFrame.Position
            gripColor(Theme.Accent)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local s = uiScale.Scale
            local d = (Vector2.new(input.Position.X, input.Position.Y) - rStartInput) / s
            local cam2 = workspace.CurrentCamera
            local v = cam2 and cam2.ViewportSize or Vector2.new(1280, 720)
            local w = math.clamp(rStartW + d.X, MIN_W, math.max(MIN_W, math.min(MAX_W, (v.X - 12) / s)))
            local h = math.clamp(rStartH + d.Y, MIN_H, math.max(MIN_H, math.min(MAX_H, (v.Y - 12) / s)))
            MainFrame.Size = UDim2.new(0, w, 0, h)
            MainFrame.Position = UDim2.new(
                rStartPos.X.Scale, rStartPos.X.Offset + s * (w - rStartW) / 2,
                rStartPos.Y.Scale, rStartPos.Y.Offset + s * (h - rStartH) / 2
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            resizing = false
            gripColor(Theme.Dim)
        end
    end)

    local function AnimateOpen()
        uiScale.Scale = baseScale * 0.94
        TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = baseScale,
        }):Play()
    end
    MainButton.MouseButton1Click:Connect(function()
        MainButton.Visible = false
        MainFrame.Visible = true
        AnimateOpen()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MainButton.Visible = true
    end)

    Player.CharacterAdded:Connect(function(char)
        local animate = char:WaitForChild("Animate", 5)
        if animate and animSelected and animSelected.idle1 then
            task.wait(0.2)
            ApplyAnims(animSelected)
        end
    end)

    local oldNamecall
    if hookmetamethod and getnamecallmethod and checkcaller then
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and getgenv().RoxHubTargetPart then
                if method == "Raycast" and self == workspace then
                    local target = getgenv().RoxHubTargetPart
                    if target and target.Parent then
                        local origin, direction, p3 = ...
                        if typeof(direction) == "Vector3" and direction.Magnitude > 20 then
                            local camOrigin = workspace.CurrentCamera.CFrame.Position
                            if (origin - camOrigin).Magnitude >= 1 then
                                local newDir = (target.Position - origin).Unit * 5000
                                return oldNamecall(self, origin, newDir, p3)
                            end
                        end
                    else
                        getgenv().RoxHubTargetPart = nil
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end

    task.spawn(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        while task.wait(0.1) do
            if (autoShootEnabled or autoShootAgresivoEnabled) then
                if estaEnLobby() then
                    getgenv().RoxHubTargetPart = nil
                    continue
                end
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    getgenv().RoxHubTargetPart = nil
                    continue
                end
                local arma = char:FindFirstChildOfClass("Tool")
                if not arma or not esPistola(arma) then
                    getgenv().RoxHubTargetPart = nil
                    continue
                end
                local bestPart, bestDist = nil, math.huge
                local myPos = char.HumanoidRootPart.Position
                local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Player and isEnemy(p) then
                        local ec = p.Character
                        if ec then
                            local eHum = ec:FindFirstChildOfClass("Humanoid")
                            if eHum and eHum.Health > 0 then
                                params.FilterDescendantsInstances = { char, ec }
                                local function try(part)
                                    if not part or not part:IsA("BasePart") then return end
                                    local d = (part.Position - myPos).Magnitude
                                    if d < bestDist then
                                        local dir = (part.Position - headPos)
                                        if not workspace:Raycast(headPos, dir, params) then
                                            bestDist = d
                                            bestPart = part
                                        end
                                    end
                                end
                                if autoShootAgresivoEnabled then
                                    for _, part in ipairs(ec:GetChildren()) do
                                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then try(part) end
                                    end
                                else
                                    if autoShootTargetPart == "Cabeza" then
                                        try(ec:FindFirstChild("Head"))
                                    elseif autoShootTargetPart == "Torso" then
                                        try(ec:FindFirstChild("UpperTorso"))
                                        try(ec:FindFirstChild("Torso"))
                                        try(ec:FindFirstChild("HumanoidRootPart"))
                                    else
                                        for _, part in ipairs(ec:GetChildren()) do
                                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then try(part) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if bestPart then
                    getgenv().RoxHubTargetPart = bestPart
                    pcall(function()
                        arma:Activate()
                        task.delay(0.05, function() if arma.Parent == char then arma:Deactivate() end end)
                    end)
                    task.wait(0.15)
                else
                    getgenv().RoxHubTargetPart = nil
                end
            end
        end
    end)

    task.spawn(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        while task.wait(0.1) do
            if (silentAimManualEnabled or silentAimFovEnabled) then
                if estaEnLobby() then
                    if not autoShootEnabled and not autoShootAgresivoEnabled then
                        getgenv().RoxHubTargetPart = nil
                    end
                    continue
                end
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
                local bestPart, bestDistCenter, bestDistFis = nil, math.huge, math.huge
                local myPos = char.HumanoidRootPart.Position
                local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Player and isEnemy(p) then
                        local ec = p.Character
                        if ec then
                            local eHum = ec:FindFirstChildOfClass("Humanoid")
                            if eHum and eHum.Health > 0 then
                                local parts = {}
                                if silentAimTargetPart == "Cabeza" then
                                    local h = ec:FindFirstChild("Head")
                                    if h then table.insert(parts, h) end
                                elseif silentAimTargetPart == "Torso" then
                                    for _, n in ipairs({"UpperTorso","Torso","HumanoidRootPart"}) do
                                        local pp = ec:FindFirstChild(n)
                                        if pp then table.insert(parts, pp) end
                                    end
                                else
                                    for _, part in ipairs(ec:GetChildren()) do
                                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then table.insert(parts, part) end
                                    end
                                end
                                params.FilterDescendantsInstances = { char, ec }
                                for _, part in ipairs(parts) do
                                    local distFis = (part.Position - myPos).Magnitude
                                    local pos2D, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                                    local distCenter = (Vector2.new(pos2D.X, pos2D.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
                                    local pass = false
                                    if silentAimFovEnabled and onScreen and distCenter <= fovRadius and distCenter < bestDistCenter then
                                        pass = true
                                    elseif silentAimManualEnabled and distFis < bestDistFis then
                                        pass = true
                                    end
                                    if pass then
                                        if not workspace:Raycast(headPos, part.Position - headPos, params) then
                                            if silentAimFovEnabled then bestDistCenter = distCenter else bestDistFis = distFis end
                                            bestPart = part
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if bestPart then
                    getgenv().RoxHubTargetPart = bestPart
                else
                    if not autoShootEnabled and not autoShootAgresivoEnabled then
                        getgenv().RoxHubTargetPart = nil
                    end
                end
            end
        end
    end)

    local FOVCircle = nil
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
        FOVCircle.Radius = fovRadius
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        FOVCircle.Visible = false
        FOVCircle.Thickness = 1
    end

    RunService.RenderStepped:Connect(function()
        if fovVisiblePreference and FOVCircle then
            FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
            FOVCircle.Radius = fovRadius
            FOVCircle.Visible = true
            FOVCircle.Color = (silentAimFovEnabled and getgenv().RoxHubTargetPart) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        elseif FOVCircle then
            FOVCircle.Visible = false
        end
    end)
end

LoadHub()