--- GeminiConfig-1.0 wrapper library.
-- Based on AceConfig 3.0
-- Provides an API to register an options table with the config registry,
-- as well as associate it with a slash command.

--[[
GeminiConfig-1.0

Very light wrapper library that combines all the AceConfig subcomponents into one more easily used whole.

]]

local MAJOR, MINOR = "Gemini:Config-1.0", 1
local APkg = Apollo.GetPackage(MAJOR)
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade is needed
end
local GeminiConfig = APkg and APkg.tPackage or {}
local tLibError = Apollo.GetPackage("Gemini:LibError-1.0")

local cfgreg
local cfgcmd

local function GetBaseDirectory() 
   local strPrefix = Apollo.GetAssetFolder()
   local tToc = XmlDoc.CreateFromFile(strPrefix.."\\toc.xml"):ToTable()
   for k,v in ipairs(tToc) do
      local strPath = string.match(v.Name, "(.*)[\\/]GeminiConfig")
      if strPath ~= nil and strPath ~= "" then
	 strPrefix = strPrefix .. "\\" .. strPath .. "\\"
	 break
      end
   end
   Print(strPrefix)
   return strPrefix
end


-- Lua APIs
local pcall, error, type, pairs = pcall, error, type, pairs

-- -------------------------------------------------------------------
-- :RegisterOptionsTable(appName, options, slashcmd, persist)
--
-- - appName - (string) application name
-- - options - table or function ref, see GeminiConfigRegistry
-- - slashcmd - slash command (string) or table with commands, or nil to NOT create a slash command

--- Register a option table with the GeminiConfig registry.
-- You can supply a slash command (or a table of slash commands) to register with GeminiConfigCmd directly.
-- @paramsig appName, options [, slashcmd]
-- @param appName The application name for the config table.
-- @param options The option table (or a function to generate one on demand).  http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
-- @param slashcmd A slash command to register for the option table, or a table of slash commands.
-- @usage
-- local GeminiConfig = LibStub("GeminiConfig-3.0")
-- GeminiConfig:RegisterOptionsTable("MyAddon", myOptions, {"/myslash", "/my"})
function GeminiConfig:RegisterOptionsTable(appName, options, slashcmd)
	local ok,msg = pcall(cfgreg.RegisterOptionsTable, self, appName, options)
	if not ok then error(msg, 2) end
	
	if slashcmd then
		if type(slashcmd) == "table" then
			for _,cmd in pairs(slashcmd) do
				cfgcmd:CreateChatCommand(cmd, appName)
			end
		else
			cfgcmd:CreateChatCommand(slashcmd, appName)
		end
	end
end

local fnErrorHandler = tLibError and tLibError.tPackage and tLibError.tPackage.Error or Print

local function loadModule(pkg, mod)
   local func =  assert(loadfile(mod))
   if func then
      return xpcall(func, fnErrorHandler)
   end
end

function GeminiConfig:OnLoad()
   self.dir = GetBaseDirectory()
   cfgreg = loadModule("GeminiConfigRegistry-1.0.lua")
   cfgcmd = loadModule("GeminiConfigCmd-1.0.lua")
   loadModule("GeminiConfigDialog-1.0")
   self.cmd = cfgcmd
end
Apollo.RegisterPackage(GeminiConfig, MAJOR, MINOR, {})

