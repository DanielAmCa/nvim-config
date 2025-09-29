local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local snippetTypes = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key
local ts_utils = require("nvim-treesitter.ts_utils")

function TableConcat(t1, t2)
    for j = 1, #t2 do
        t1[#t1 + 1] = t2[j]
    end
    return t1
end

local get_visual = function(_, parent)
    if #parent.snippet.env.LS_SELECT_RAW > 0 then
        return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
    else -- If LS_SELECT_RAW is empty, return a blank insert node
        return sn(nil, i(1))
    end
end

local math = function()
    local node = ts_utils.get_node_at_cursor()
    while node do
        local type = node:type()
        if
            type == "inline_math"
            or type == "inline_formula"
            or type == "displayed_equation"
            or type == "math_block"
        then
            return true
        end
        node = node:parent()
    end
end

local not_math = function()
    return not math()
end

local math_snippets = {

    -- Math Zones

    s({
        trig = "mii",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = not_math,
    }, {
        t("$"),
        d(1, get_visual),
        t("$"),
    }),

    s({
        trig = "(.)mzz",
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = not_math,
    }, {
        f(function(_, snip)
            return snip.captures[1]
        end),
        t({ "", "", "$$", "" }),
        d(1, get_visual),
        t({ "", "$$", "" }),
    }),

    s({
        trig = "^mzz",
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
    }, {
        t({ "$$", "" }),
        d(1, get_visual),
        t({ "", "$$", "" }),
    }),

    -- Delimiters

    s(
        {
            trig = [[lr([Vabcpv])]],
            wordTrig = false,
            regTrig = true,
            snippetType = "autosnippet",
            condition = math,
        },
        fmta([[\left<> <> \right<> <>]], {
            f(function(_, snip)
                local choice = snip.captures[1]
                if choice == "a" then
                    return "<"
                elseif choice == "b" then
                    return "["
                elseif choice == "c" then
                    return "\\{"
                elseif choice == "p" then
                    return "("
                elseif choice == "v" then
                    return "|"
                elseif choice == "V" then
                    return "\\|"
                end
            end),
            d(1, get_visual),
            f(function(_, snip)
                local choice = snip.captures[1]
                if choice == "a" then
                    return ">"
                elseif choice == "b" then
                    return "]"
                elseif choice == "c" then
                    return "\\}"
                elseif choice == "p" then
                    return ")"
                elseif choice == "v" then
                    return "|"
                elseif choice == "V" then
                    return "\\|"
                end
            end),
            i(0),
        })
    ),

    -- Greek Alphabet

    s({
        trig = [[([^A-Za-z])alp]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\alpha}"
    end) }),

    s({
        trig = [[^alp]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\alpha}") }),

    s({
        trig = [[([^A-Za-z])bet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\beta}"
    end) }),

    s({
        trig = [[^bet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\beta}") }),

    s({
        trig = [[([^A-Za-z])gam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\gamma}"
    end) }),

    s({
        trig = [[^gam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\gamma}") }),

    s({
        trig = [[([^A-Za-z])dgam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\digamma}"
    end) }),

    s({
        trig = [[^dgam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\digamma}") }),

    s({
        trig = [[([^A-Za-z])del]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\delta}"
    end) }),

    s({
        trig = [[^del]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\delta}") }),

    s({
        trig = [[([^A-Za-z])eps]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\epsilon}"
    end) }),

    s({
        trig = [[^eps]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\epsilon}") }),

    s({
        trig = [[([^A-Za-z])veps]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varepsilon}"
    end) }),

    s({
        trig = [[^veps]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varepsilon}") }),

    s({
        trig = [[([^A-Za-z])zet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\zeta}"
    end) }),

    s({
        trig = [[^zet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\zeta}") }),

    s({
        trig = [[([^A-Za-z])eta]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\eta}"
    end) }),

    s({
        trig = [[^eta]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\eta}") }),

    s({
        trig = [[([^A-Za-z])the]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\theta}"
    end) }),

    s({
        trig = [[^the]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\theta}") }),

    s({
        trig = [[([^A-Za-z])vthe]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\theta}"
    end) }),

    s({
        trig = [[^vthe]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\theta}") }),

    s({
        trig = [[([^A-Za-z])iot]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\iota}"
    end) }),

    s({
        trig = [[^iot]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\iota}") }),

    s({
        trig = [[([^A-Za-z])kap]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\kappa}"
    end) }),

    s({
        trig = [[^kap]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\kappa}") }),

    s({
        trig = [[([^A-Za-z])vkap]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varkappa}"
    end) }),

    s({
        trig = [[^vkap]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varkappa}") }),

    s({
        trig = [[([^A-Za-z])lam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\lambda}"
    end) }),

    s({
        trig = [[^lam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\lambda}") }),

    s({
        trig = [[([^A-Za-z])muu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\mu}"
    end) }),

    s({
        trig = [[^muu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\mu}") }),

    s({
        trig = [[([^A-Za-z])nuu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\nu}"
    end) }),

    s({
        trig = [[^nuu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\nu}") }),

    s({
        trig = [[([^A-Za-z])xii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\xi}"
    end) }),

    s({
        trig = [[^xii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\xi}") }),

    s({
        trig = [[([^A-Za-z])omi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\omicrom}"
    end) }),

    s({
        trig = [[^omi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\omicrom}") }),

    s({
        trig = [[([^A-Za-z])pii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\pi}"
    end) }),

    s({
        trig = [[^pii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\pi}") }),

    s({
        trig = [[([^A-Za-z])vpii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\vpi}"
    end) }),

    s({
        trig = [[^vpii]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\vpi}") }),

    s({
        trig = [[([^A-Za-z])rho]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\rho}"
    end) }),

    s({
        trig = [[^rho]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\rho}") }),

    s({
        trig = [[([^A-Za-z])vrho]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varho}"
    end) }),

    s({
        trig = [[^vrho]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varho}") }),

    s({
        trig = [[([^A-Za-z])sig]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\sigma}"
    end) }),

    s({
        trig = [[^sig]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\sigma}") }),

    s({
        trig = [[([^A-Za-z])vsig]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varsigma}"
    end) }),

    s({
        trig = [[^vsig]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varsigma}") }),

    s({
        trig = [[([^A-Za-z])tau]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\tau}"
    end) }),

    s({
        trig = [[^tau]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\tau}") }),

    s({
        trig = [[([^A-Za-z])ups]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\upsilon}"
    end) }),

    s({
        trig = [[^ups]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\upsilon}") }),

    s({
        trig = [[([^A-Za-z])phi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\phi}"
    end) }),

    s({
        trig = [[^phi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\phi}") }),

    s({
        trig = [[([^A-Za-z])vphi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varphi}"
    end) }),

    s({
        trig = [[^vphi]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varphi}") }),

    s({
        trig = [[([^A-Za-z])chi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\chi}"
    end) }),

    s({
        trig = [[^chi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\chi}") }),

    s({
        trig = [[([^A-Za-z])psi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\psi}"
    end) }),

    s({
        trig = [[^psi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\psi}") }),

    s({
        trig = [[([^A-Za-z])ome]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\omega}"
    end) }),

    s({
        trig = [[^ome]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\omega}") }),

    s({
        trig = [[([^A-Za-z])Alp]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Alpha}"
    end) }),

    s({
        trig = [[^Alp]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Alpha}") }),

    s({
        trig = [[([^A-Za-z])Bet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Beta}"
    end) }),

    s({
        trig = [[^Bet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Beta}") }),

    s({
        trig = [[([^A-Za-z])Gam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Gamma}"
    end) }),

    s({
        trig = [[^Gam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Gamma}") }),

    s({
        trig = [[([^A-Za-z])vGam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varGamma}"
    end) }),

    s({
        trig = [[^vGam]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varGamma}") }),

    s({
        trig = [[([^A-Za-z])Del]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Delta}"
    end) }),

    s({
        trig = [[^Del]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Delta}") }),

    s({
        trig = [[([^A-Za-z])vDel]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varDelta}"
    end) }),

    s({
        trig = [[^vDel]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varDelta}") }),

    s({
        trig = [[([^A-Za-z])Eps]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Epsilon}"
    end) }),

    s({
        trig = [[^Eps]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Epsilon}") }),

    s({
        trig = [[([^A-Za-z])Zet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Zeta}"
    end) }),

    s({
        trig = [[^Zet]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Zeta}") }),

    s({
        trig = [[([^A-Za-z])Eta]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Eta}"
    end) }),

    s({
        trig = [[^Eta]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Eta}") }),

    s({
        trig = [[([^A-Za-z])The]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Theta}"
    end) }),

    s({
        trig = [[^The]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Theta}") }),

    s({
        trig = [[([^A-Za-z])vThe]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varTheta}"
    end) }),

    s({
        trig = [[^vThe]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varTheta}") }),

    s({
        trig = [[([^A-Za-z])Iot]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Iota}"
    end) }),

    s({
        trig = [[^Iot]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Iota}") }),

    s({
        trig = [[([^A-Za-z])Kap]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Kappa}"
    end) }),

    s({
        trig = [[^Kap]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Kappa}") }),

    s({
        trig = [[([^A-Za-z])Lam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Lambda}"
    end) }),

    s({
        trig = [[^Lam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Lambda}") }),

    s({
        trig = [[([^A-Za-z])vLam]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\vLambda}"
    end) }),

    s({
        trig = [[^vLam]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\vLambda}") }),

    s({
        trig = [[([^A-Za-z])Muu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Mu}"
    end) }),

    s({
        trig = [[^Muu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Mu}") }),

    s({
        trig = [[([^A-Za-z])Nuu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Nu}"
    end) }),

    s({
        trig = [[^Nuu]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Nu}") }),

    s({
        trig = [[([^A-Za-z])Xii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Xi}"
    end) }),

    s({
        trig = [[^Xii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Xi}") }),

    s({
        trig = [[([^A-Za-z])vXii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varXi}"
    end) }),

    s({
        trig = [[^vXii]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varXi}") }),

    s({
        trig = [[([^A-Za-z])Omi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Omicron}"
    end) }),

    s({
        trig = [[^Omi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Omicron}") }),

    s({
        trig = [[([^A-Za-z])Pii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Pi}"
    end) }),

    s({
        trig = [[^Pii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Pi}") }),

    s({
        trig = [[([^A-Za-z])vPii]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\vPi}"
    end) }),

    s({
        trig = [[^vPii]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\vPi}") }),

    s({
        trig = [[([^A-Za-z])Rho]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Rho}"
    end) }),

    s({
        trig = [[^Rho]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Rho}") }),

    s({
        trig = [[([^A-Za-z])Sig]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Sigma}"
    end) }),

    s({
        trig = [[^Sig]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Sigma}") }),

    s({
        trig = [[([^A-Za-z])vSig]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varSigma}"
    end) }),

    s({
        trig = [[^vSig]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varSigma}") }),

    s({
        trig = [[([^A-Za-z])Tau]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Tau}"
    end) }),

    s({
        trig = [[^Tau]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Tau}") }),

    s({
        trig = [[([^A-Za-z])Ups]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Upsilon}"
    end) }),

    s({
        trig = [[^Ups]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Upsilon}") }),

    s({
        trig = [[([^A-Za-z])vUps]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varUpsilon}"
    end) }),

    s({
        trig = [[^vUps]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varUpsilon}") }),

    s({
        trig = [[([^A-Za-z])Phi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Phi}"
    end) }),

    s({
        trig = [[^Phi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Phi}") }),

    s({
        trig = [[([^A-Za-z])vPhi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varPhi}"
    end) }),

    s({
        trig = [[^vPhi]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varPhi}") }),

    s({
        trig = [[([^A-Za-z])Chi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Chi}"
    end) }),

    s({
        trig = [[^Chi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Chi}") }),

    s({
        trig = [[([^A-Za-z])Psi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Psi}"
    end) }),

    s({
        trig = [[^Psi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Psi}") }),

    s({
        trig = [[([^A-Za-z])vPsi]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varPsi}"
    end) }),

    s({
        trig = [[^vPsi]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varPsi}") }),

    s({
        trig = [[([^A-Za-z])Ome]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\Omega}"
    end) }),

    s({
        trig = [[^Ome]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Omega}") }),

    s({
        trig = [[([^A-Za-z])vOme]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "{\\varOmega}"
    end) }),

    s({
        trig = [[^vOme]],
        priority = 2000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varOmega}") }),

    -- Other Symbols

    s({
        trig = "ell",
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\ell}") }),

    s({
        trig = "qed",
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\blacksquare}") }),

    s({
        trig = "ooo",
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\infty}") }),

    -- Logic & Set Theory

    s({
        trig = "AA",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\forall ") }),

    s({
        trig = "EE",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\exists ") }),

    s({
        trig = "nEE",
        priority = 2000,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\nexists ") }),

    s({
        trig = "inn",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\in ") }),

    s({
        trig = "ninn",
        priority = 2000,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\notin ") }),

    s({
        trig = "subset",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\subset ") }),

    s({
        trig = "supset",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\supset ") }),

    s({
        trig = "land",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\land ") }),

    s({
        trig = "lor",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\lor ") }),

    s({
        trig = "lnot",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\lnot ") }),

    s({
        trig = "maps",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\mapsto ") }),

    s({
        trig = "too",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\to ") }),

    s({
        trig = "alr",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\leftrightarrow ") }),

    s({
        trig = "imp",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\implies ") }),

    s({
        trig = "iby",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\impliedby ") }),

    s({
        trig = "iff",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\iff ") }),

    s({
        trig = "set",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\ ") }),

    -- Named sets

    s({
        trig = "NN",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\N}") }),

    s({
        trig = "ZZ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Z}") }),

    s({
        trig = "RR",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\R}") }),

    s({
        trig = "CC",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Complex}") }),

    s({
        trig = "R([a-z0-9])",
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("{\\R}^{"),
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("}"),
    }),

    s({
        trig = "C([a-z0-9])",
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("{\\Complex}^{"),
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("}"),
    }),

    s({
        trig = "empty",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\varnothing}") }),

    -- Binary Operators

    s({
        trig = "sor",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\cup ") }),

    s({
        trig = "sand",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\cap ") }),

    s({
        trig = "snot",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\setminus ") }),

    s({
        trig = "c. ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\cdot ") }),

    s({
        trig = "xx",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\times ") }),

    s({
        trig = "o+ ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\oplus ") }),

    s({
        trig = "o- ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\ominus ") }),

    s({
        trig = "o. ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\odot ") }),

    s({
        trig = "oxx",
        wordTrig = false,
        snippetType = "autosnippet",
        priority = 2000,
        condition = math,
    }, { t("\\otimes ") }),

    s({
        trig = "o/ ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\oslash ") }),

    s({
        trig = "mod",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\mod ") }),

    s({
        trig = "+-",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\pm ") }),

    s({
        trig = "(.)-[+]",
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "\\mp "
    end) }),

    s({
        trig = "[(]([^(]+)[)]/",
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\frac{"),
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("}{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "ff",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\frac{"),
        d(1, get_visual),
        t("}{"),
        i(2),
        t("}"),
    }),

    s({
        trig = "rd",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("^{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "sr",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("^{2}"),
    }),

    s({
        trig = "cb",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("^{3}"),
    }),

    s({
        trig = "invs",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("^{-1}"),
    }),

    -- Math Operators

    s({
        trig = "sin",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\sin{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "cos",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\cos{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "tan",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\tan{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "asin",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\arcsin{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "acos",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\arccos{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "atan",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\arctan{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "hsin",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\sinh{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "hcos",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\cosh{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "htan",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\tanh{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "log",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\log_{"),
        i(1, "2"),
        t("}{"),
        d(2, get_visual),
        t("}"),
    }),

    s({
        trig = "lg",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\lg{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "ln",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\ln{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "lim",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\lim_{"),
        i(1, "x"),
        t(" \\to "),
        i(2, "\\infty"),
        t("}{"),
        d(3, get_visual),
        t("}"),
    }),

    s({
        trig = "max",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\max{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "min",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\min{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "dett",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\det{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "ker",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\ker{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "img",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\operatorname{im}{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "sqr([a-su-z0-9])",
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\sqrt["),
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("]{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "sqq",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\sqrt{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "bigo",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\operatorname{\\mathcal{O}}{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "vbigo",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\operatorname{\\mathcal{\\pmb{O}}}{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "lito",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\operatorname{\\scriptstyle \\mathcal{O}}{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "vlito",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\operatorname{\\scriptstyle \\mathcal{\\pmb{O}}}{"),
        d(1, get_visual),
        t("}"),
    }),

    -- Matrices

    s({
        trig = [[([%d]+)arr([%d]+) ]],
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t({ "\\begin{matrix}", "" }),
        d(1, function(_, snip)
            local rr = tonumber(snip.captures[1])
            local cc = tonumber(snip.captures[2])
            local nodes = {}
            for c_r = 1, rr do
                for c_c = 1, cc do
                    local idx = (c_r - 1) * cc + c_c
                    vim.list_extend(nodes, { i(idx, "·") })
                    if c_c < cc then
                        vim.list_extend(nodes, { t(" & ") })
                    end
                end
                if c_r < rr then
                    vim.list_extend(nodes, { t({ " \\\\", "" }) })
                end
            end
            return sn(nil, nodes)
        end),
        t({ "", "\\end{matrix}" }),
    }),

    s({
        trig = [[([%d]+)mat([%d]+) ]],
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t({ "\\begin{bmatrix}", "" }),
        d(1, function(_, snip)
            local rr = tonumber(snip.captures[1])
            local cc = tonumber(snip.captures[2])
            local nodes = {}
            for c_r = 1, rr do
                for c_c = 1, cc do
                    local idx = (c_r - 1) * cc + c_c
                    vim.list_extend(nodes, { i(idx, "·") })
                    if c_c < cc then
                        vim.list_extend(nodes, { t(" & ") })
                    end
                end
                if c_r < rr then
                    vim.list_extend(nodes, { t({ " \\\\", "" }) })
                end
            end
            return sn(nil, nodes)
        end),
        t({ "", "\\end{bmatrix}" }),
    }),

    s({
        trig = [[([%d]+)det([%d]+) ]],
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t({ "\\begin{vmatrix}", "" }),
        d(1, function(_, snip)
            local rr = tonumber(snip.captures[1])
            local cc = tonumber(snip.captures[2])
            local nodes = {}
            for c_r = 1, rr do
                for c_c = 1, cc do
                    local idx = (c_r - 1) * cc + c_c
                    vim.list_extend(nodes, { i(idx, "·") })
                    if c_c < cc then
                        vim.list_extend(nodes, { t(" & ") })
                    end
                end
                if c_r < rr then
                    vim.list_extend(nodes, { t({ " \\\\", "" }) })
                end
            end
            return sn(nil, nodes)
        end),
        t({ "", "\\end{vmatrix}" }),
    }),

    s({
        trig = "...",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\dots ") }),

    s({
        trig = "v...",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\vdots ") }),

    s({
        trig = "c...",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\cdots ") }),

    s({
        trig = "d...",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\ddots ") }),

    s({
        trig = "Tr",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("^{\\mathrm{T}}") }),

    -- Vectors

    postfix({
        trig = "vec",
        snippetType = "autosnippet",
        condition = math,
    }, { l("\\mathbf{" .. l.POSTFIX_MATCH .. "}") }, { condition = math }),

    -- Subscript

    s({
        trig = [[([A-Za-z\{\}]+)([0-9]+) ]],
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, {
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("_{"),
        f(function(_, snip)
            return snip.captures[2]
        end),
        t("}"),
    }, { condition = math }),

    s({
        trig = "_",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("_{"),
        i(1),
        t("}"),
    }),

    -- Analysis

    s({
        trig = "dif",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\mathrm{d}") }),

    s({
        trig = "pdif",
        priority = 2000,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\partial ") }),

    s({
        trig = "(\\mathrm{d}[A-Za-z])dif",
        priority = 3000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, {
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("\\,\\mathrm{d}"),
    }),

    s({
        trig = "(\\partial [A-Za-z])pdif",
        priority = 3000,
        wordTrig = false,
        regTrig = true,
        snippetType = "autosnippet",
        condition = math,
    }, {
        f(function(_, snip)
            return snip.captures[1]
        end),
        t("\\,\\partial "),
    }),

    s({
        trig = "der",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\frac{\\mathrm{d}"),
        i(1),
        t("}{\\mathrm{d}"),
        i(2),
        t("}"),
    }),

    s({
        trig = "pder",
        priority = 2000,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\frac{{\\partial "),
        i(1),
        t("}{{\\partial }"),
        i(2),
        t("}"),
    }),

    s({
        trig = [[([\\]frac[^%s]+)eval]],
        regTrig = true,
        wordTrig = false,
        priority = 2000,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\left. "),
        f(function(_, snip)
            return snip.captures[1]
        end),
        t(" \\right|_{"),
        i(1),
        t("}"),
    }),

    s({
        trig = "eval",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\left. "),
        d(1, get_visual),
        t(" \\right|_{"),
        i(2),
        t("}"),
    }),

    s({
        trig = "sum",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\sum_{"),
        i(1),
        t("}^{"),
        i(2),
        t("}"),
    }),

    s({
        trig = "prod",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\prod_{"),
        i(1),
        t("}^{"),
        i(2),
        t("}"),
    }),

    s({
        trig = "int",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\int "),
        i(1),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "dint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\int_{"),
        i(1),
        t("}^{"),
        i(2),
        t("} "),
        i(3),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "iint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\iint "),
        i(1),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "oint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, {
        t("\\oint_{"),
        i(1),
        t("} "),
        i(2),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "diint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 3000,
    }, {
        t("\\iint_{"),
        i(1),
        t("} "),
        i(2),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "iiint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 3000,
    }, {
        t("\\iiint "),
        i(1),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "oiint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 3000,
    }, {
        t("\\oiint_{"),
        i(1),
        t("} "),
        i(2),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "diiint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 4000,
    }, {
        t("\\iiint_{"),
        i(1),
        t("} "),
        i(2),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "oiiint",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 4000,
    }, {
        t("\\oiiint_{"),
        i(1),
        t("} "),
        i(2),
        t(" \\,\\mathrm{d}"),
    }),

    s({
        trig = "gra",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\nabla ") }),

    -- Relations

    s({
        trig = "lt",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("<") }),

    s({
        trig = "gt",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t(">") }),

    s({
        trig = "leq",
        wordTrig = false,
        priority = 2000,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\leq ") }),

    s({
        trig = "geq",
        priority = 2000,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\geq ") }),

    s({
        trig = "lll",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\lll ") }),

    s({
        trig = "ggg",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\ggg ") }),

    s({
        trig = "approx",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\approx ") }),

    s({
        trig = ":=",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\coloneqq ") }),

    s({
        trig = "tri",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\equiv ") }),

    s({
        trig = "sim",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\sim ") }),

    s({
        trig = "par",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\parallel ") }),

    s({
        trig = "perp",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("\\perp ") }),

    s({
        trig = "neq",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
        priority = 2000,
    }, { t("\\neq ") }),

    -- Environments

    s({
        trig = "sst",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\substack{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "llap",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\mathllap{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "clap",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\mathclap{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "rlap",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\mathrlap{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "box",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\boxed{"),
        d(1, get_visual),
        t("}"),
    }),

    s({
        trig = "ove",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\overbrace{"),
        d(1, get_visual),
        t("}^{"),
        i(2),
        t("}"),
    }),

    s({
        trig = "und",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\underbrace{"),
        d(1, get_visual),
        t("}_{"),
        i(2),
        t("}"),
    }),

    -- Spacing

    s({
        trig = "quad",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\quad "),
    }),

    s({
        trig = "qquad",
        wordTrig = false,
        priority = 2000,
        snippetType = "autosnippet",
        condition = math,
    }, {
        t("\\qquad "),
    }),
}

return math_snippets
