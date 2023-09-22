
local EXPLOIT_NAME = "Opium Executor"
local EXLPOIT_VERSION = "v1"

local genv = getgenv()
if genv[EXPLOIT_NAME] then
	return script:Remove()
end
genv[EXPLOIT_NAME] = true

--- Libraries
local HashIngLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/HashLib.lua"))()
local disassemble = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheSeaweedMonster/Luau/main/decompile.lua"))()

local localplayer=game:GetService'Players'.LocalPlayer
-------------

local hashlibalgs = {
	"sha1", "sha224"
}
local hashalgs = {
	"md5", "sha1", "sha224", "sha256", "sha384", "sha512", "sha3-256", "sha3-384", "sha3-512",
	"md2", "haval", "ripemd128", "ripemd160", "ripemd256", "ripemd320"
}
local ciphers = {
	['aes-cbc'] = "CBC",
	['aes-cfb'] = "CFB",
	['aes-ctr'] = "CTR",
	['aes-ofb'] = "OFB",
	['aes-gcm'] = "GCM"
}


function Export(name, value)
	getgenv()[name] = value
end

Export("identifyexecutor", function()
	return EXPLOIT_NAME, EXLPOIT_VERSION
end)
Export("getexecutorname", function()
	return EXPLOIT_NAME, EXLPOIT_VERSION
end)
Export("disassemble", disassemble)


local Oldcrypt = crypt
local NewCrypt = Oldcrypt

NewCrypt.encrypt = function(cipher, data, key, nonce)
	cipher = cipher:lower()
	if cipher:find("eax") or cipher:find("bf") then
		return ""
	end
	return crypt.custom_encrypt(data, key, nonce, ciphers[cipher:gsub("_", "-")])
end
NewCrypt.decrypt = function(cipher, data, key, nonce)
	cipher = cipher:lower()
	if cipher:find("eax") or cipher:find("bf") then
		return ""
	end
	return crypt.custom_decrypt(data, key, nonce, ciphers[cipher:gsub("_", "-")])
end
NewCrypt.hash = function(alg, data)
	alg = alg:lower():gsub("_", "-")

	local HashLib = table.find(hashlibalgs, alg)
	local SwLib = table.find(hashalgs, alg)
	assert(HashLib or SwLib, "#1 Unknown hash algorithm")

	if HashLib then
		return hash[alg:gsub("-", "_")](data)
	end
	if SwLib then
		return Oldcrypt.hash(data, alg):lower()
	end
end
NewCrypt.derive = function(_, len)
	return Oldcrypt.generatebytes(len)
end
NewCrypt.random = Oldcrypt.generatebytes 
NewCrypt.generatebytes = Oldcrypt.generatebytes

local oldRequest
oldRequest = hookfunction(request, function(Arguments)
    local Headers = Arguments.Headers or {}
    Headers['User-Agent'] = EXPLOIT_NAME
    return oldRequest({
        Url = Arguments.Url,
        Method = Arguments.Method or "GET",
        Headers = Headers,
        Cookies = Arguments.Cookies or {},
        Body = Arguments.Body or ""
    })
end)

Export("custom", NewCrypt)
Export("crypt", NewCrypt)
Export("crypto", NewCrypt)

setreadonly(crypt, true)
setreadonly(crypto, true)
setreadonly(custom, true)

local Functions={
	["messagebox"]="showmsg",
	["setDiscordRPC"]="setrpc",
	["rconsoleprint"]="rprintconsole",
	["rconsoleinfo"]="rconsoleinfo",
	["rconsolename"]="rconsolename",
	["rconsolewarn"]="rconsolewarn",
	["rconsoleerr"]="rconsoleerr",
	["toclipboard"]="toClipboard",
	["rconsoleclose"]="closeconsole",
	["rconsoleshow"]="showconsole",
	["rconsoleclear"]="consoleclear",
}

STDExport=function(text)
	writefile("LINJECTOR/LINJECTOR.li", text)
end

for name, func in pairs(Functions) do
	Export(name,function(...)
		local String, args="",table.pack(...)
		for i=1, args.n do
			String=("%s|||%s"):format(String, tostring(args[i]))
		end
		STDExport(('%s%s'):format(name, String))
	end)
end

Export("rprintconsole",rconsoleprint)
Export("setclipboard",toclipboard)
Export("set_clipboard",toclipboard)
Export("set_clipboard",toclipboard)
Export("Clipboard",{set=toclipboard})

pcall(function()
	SendFunction(('welcome|||%s|||%s'):format(localplayer.DisplayName, MarketplaceService:GetProductInfo(game.PlaceId).Name))
end)
 
