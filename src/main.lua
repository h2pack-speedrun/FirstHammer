local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
local chalk = mods['SGG_Modding-Chalk']
local reload = mods['SGG_Modding-ReLoad']
lib = mods['adamant-ModpackLib']

local dataDefaults = import("config.lua")
local config = chalk.auto('config.lua')

FirstHammerInternal = FirstHammerInternal or {}
local internal = FirstHammerInternal

public.definition = {
    id             = "FirstHammer",
    name           = "Hammer Selection",
    shortName      = "Hammer Selection",
    tooltip        = "Select the guaranteed first hammer for each weapon aspect.",
    default        = dataDefaults.Enabled,
    affectsRunData = false,
    modpack        = "speedrun",
}

public.store = nil
store = nil
internal.standaloneUi = nil

local function registerHooks()
    if internal.LocalizeHammerLabels then
        internal.LocalizeHammerLabels()
    end
    if internal.RegisterHooks then
        internal.RegisterHooks()
    end
    public.DrawTab = internal.DrawTab
    public.DrawQuickContent = internal.DrawQuickContent
end

local loader = reload.auto_single()

local function init()
    import_as_fallback(rom.game)
    import("data.lua")
    import("ui.lua")
    public.store = lib.store.create(config, public.definition, dataDefaults)
    store = public.store
    registerHooks()
    if lib.coordinator.isEnabled(store, public.definition.modpack) then
        lib.mutation.apply(public.definition, store)
    end
    internal.standaloneUi = lib.host.standaloneUI(
        public.definition,
        store,
        store.uiState,
        {
            getDrawTab = function()
                return public.DrawTab
            end,
        }
    )
end

modutil.once_loaded.game(function()
    loader.load(init, init)
end)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_imgui(function()
    if internal.standaloneUi and internal.standaloneUi.renderWindow then
        internal.standaloneUi.renderWindow()
    end
end)

---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(function()
    if internal.standaloneUi and internal.standaloneUi.addMenuBar then
        internal.standaloneUi.addMenuBar()
    end
end)
