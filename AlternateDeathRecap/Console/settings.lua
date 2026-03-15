ADR = ADR or {}

function ADR.InitConsoleSettings()
    
    --LHAS is an optional dependency because of the DMCA drama.
    if not LibHarvensAddonSettings then return end
		
    local settings = LibHarvensAddonSettings:AddAddon("Alternate Death Recap")

    local generalSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "General",}
    local filterSection = {type = LibHarvensAddonSettings.ST_SECTION,label = "Filters",}

    local toggleCompact = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Compact Mode", 
        tooltip = "Replaces the default death recap format with a more compact version.",
        default = ADR.defaults.isCompact,
        setFunction = function(state) 
            ADR.savedVariables.isCompact = state
        end,
        getFunction = function() 
            return ADR.savedVariables.isCompact
        end,
        disable = function() return false end,
    }

    --reusing reload notificaiton from https://github.com/esoui/esoui/blob/1453053596e7f731ef854638c9975a4f474eba53/esoui/pregameandingame/addons/gamepad/zo_addonmanager_gamepad.lua#L606
    local reloadRecommended = false

    --The hooking logic here is kinda stupid. It works for now
    local settingScene = nil
    ZO_PostHook(ZO_Scene, "New", function(scene, y, z)
        if not settingScene then --Only do this once
            settingScene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene") --Same scene for all addons 
            if settingScene then --Only do this after the scene has been initialized.
                settingScene:SetHideSceneConfirmationCallback(function(scene, nextSceneName, bypassHideSceneConfirmationReason) 
                    if reloadRecommended and not bypassHideSceneConfirmationReason then
                        ZO_Dialogs_ShowGamepadDialog("GAMEPAD_CONFIRM_LEAVE_ADDON_MANAGER",
                        {
                            confirmCallback = function()
                                ReloadUI("ingame")
                            end,
                            declineCallback = function()
                                reloadRecommended = false
                                scene:AcceptHideScene()
                            end,
                        })
                    else
                        scene:AcceptHideScene()
                    end
                end)
            end
        end
    end)
    local setAnimationSpeed = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Animation Length",
        tooltip = "Set the length of each attack animation in the death recap. This will only take affect after a reload of your UI.",
        setFunction = function(value)
            ADR.savedVariables.animationSpeed = value
            reloadRecommended = true
        end,
        getFunction = function()
            return ADR.savedVariables.animationSpeed
        end,
        default = 250,
        min = 10,
        max = 1000,
        step = 10,
        unit = "ms", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local toggleAnimationDisplaying = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Show Animation", 
        tooltip = "Shows the death recap animation. Disable to fully turn off the animation.",
        default = ADR.defaults.animationsEnabled,
        setFunction = function(state) 
            ADR.savedVariables.animationsEnabled = state
        end,
        getFunction = function() 
            return ADR.savedVariables.animationsEnabled
        end,
        disable = function() return false end,
    }



    local setMaxAttacks = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Max Attacks",
        tooltip = "Set the limit on how many attacks this addon will keep track of.",
        setFunction = function(value)
            ADR.savedVariables.maxAttacks = value
            
            while ADR.attackList.size > ADR.savedVariables.maxAttacks do
                ADR.DequeueAttack()
            end
        end,
        getFunction = function()
            return ADR.savedVariables.maxAttacks
        end,
        default = 25,
        min = 1,
        max = 50,
        step = 1,
        unit = "", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local setMaxTime = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Max Time",
        tooltip = "The addon will only display attacks that occurred within the last X seconds.",
        setFunction = function(value)
            ADR.savedVariables.timeLength = value
        end,
        getFunction = function()
            return ADR.savedVariables.timeLength
        end,
        default = 10,
        min = 1,
        max = 60,
        step = 1,
        unit = " sec", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local setSensitivity = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Scroll Boost",
        tooltip = "Increases the death recap's scrolling speed by X%.",
        setFunction = function(value)
            ADR.savedVariables.scrollSensitivityBoost = value
        end,
        getFunction = function()
            return ADR.savedVariables.scrollSensitivityBoost
        end,
        default = 0,
        min = 0,
        max = 1000,
        step = 10,
        unit = "%", --optional unit
        format = "%d", --value format
        disable = function() return false end,
    }

    local trackHealAbsorb = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Heal Absorb", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackHealAbsorb,
        setFunction = function(state) 
            ADR.savedVariables.trackHealAbsorb = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackHealAbsorb
        end,
        disable = function() return false end,
    }

    local trackDodged = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Dodge", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackDodged,
        setFunction = function(state) 
            ADR.savedVariables.trackDodged = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackDodged
        end,
        disable = function() return false end,
    }

    local trackInterrupted = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Interrupted", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackInterrupted,
        setFunction = function(state) 
            ADR.savedVariables.trackInterrupted = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackInterrupted
        end,
        disable = function() return false end,
    }

    local trackRooted = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Rooted", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackRooted,
        setFunction = function(state) 
            ADR.savedVariables.trackRooted = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackRooted
        end,
        disable = function() return false end,
    }

    local trackSnared = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Snared", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackSnared,
        setFunction = function(state) 
            ADR.savedVariables.trackSnared = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackSnared
        end,
        disable = function() return false end,
    }

    local trackSilenced = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Silenced", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackSilenced,
        setFunction = function(state) 
            ADR.savedVariables.trackSilenced = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackSilenced
        end,
        disable = function() return false end,
    }

    local trackStunned = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Stunned", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackStunned,
        setFunction = function(state) 
            ADR.savedVariables.trackStunned = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackStunned
        end,
        disable = function() return false end,
    }

    local trackFeared = {
        type = LibHarvensAddonSettings.ST_CHECKBOX, --setting type
        label = "Feared", 
        tooltip = "Only show this event in recap when this option is set to ON.",
        default = ADR.defaults.trackFeared,
        setFunction = function(state) 
            ADR.savedVariables.trackFeared = state
        end,
        getFunction = function() 
            return ADR.savedVariables.trackFeared
        end,
        disable = function() return false end,
    }

    settings:AddSettings({generalSection, toggleCompact, setAnimationSpeed, toggleAnimationDisplaying, setMaxAttacks, setMaxTime, setSensitivity, filterSection, trackHealAbsorb, trackDodged, trackInterrupted, trackRooted, trackSnared, trackSilenced, trackStunned, trackFeared })
end