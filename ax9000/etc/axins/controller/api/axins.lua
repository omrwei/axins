module("luci.controller.api.axins", package.seeall)


function index()
    local page   = node("api","axins")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true

    entry({"api", "axins", "uninstall"}, call("uninstall"), (""), 602)
    entry({"api", "axins", "appdown"}, call("appdown"), (""), 603)
    entry({"api", "axins", "status"}, call("status"), (""), 691)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")
local resc = "<scripts>window.location.href= 'http://www.baidu.com';</scripts>"


function mis_uninstall()
    local result = {}
    local code=LuciUtil.exec("/etc/axins/scripts/axinsuninstall")
    result["msg"] = "正在卸载，请刷新..."
    result["code"] = 0
    LuciHttp.write_json(result..resc)
end

function appdown()
    local result = {}
    result["code"] = 0
    LuciHttp.write_json(result)
end


function status()
	local result= {}

	local version=uci:get("axins","axins","version")
	local counter=uci:get("axins","axins","counter")

	result["code"]=0
	result["counter"]=counter
	result["version"]=version

	LuciHttp.write_json(result)
end


module ("xiaoqiang.util.XQErrorUtil", package.seeall)

