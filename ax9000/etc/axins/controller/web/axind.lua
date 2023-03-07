module("luci.controller.web.axins", package.seeall)
function index()
    local page   = node("web","axins")
        page.target  = firstchild()
        page.title   = ("")
        page.order   = 100
        page.sysauth = "admin"
        page.sysauth_authenticator = "jsonauth"
        page.index = true
        entry({"web", "axins", "index"}, template("web/axins"), _("axinsTools"), 81)
end
