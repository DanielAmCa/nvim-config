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

local get_visual = function(args, parent)
    if #parent.snippet.env.LS_SELECT_RAW > 0 then
        return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
    else -- If LS_SELECT_RAW is empty, return a blank insert node
        return sn(nil, i(1))
    end
end

local function tables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
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

local rec_ls
rec_ls = function()
    return sn(nil, {
        c(1, {
            -- important!! Having the sn(...) as the first choice will cause infinite recursion.
            t({ "" }),
            -- The same dynamicNode as in the snippet (also note: self reference).
            sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
        }),
    })
end

local math_snippets = {

    -- Math Zones

    s({
        trig = "mii",
        wordTrig = false,
        snippetType = "autosnippet",
    }, {
        t("$"),
        i(1),
        t("$"),
    }),

    s(
        {
            trig = "mzz",
            wordTrig = false,
            snippetType = "autosnippet",
        },
        fmta(
            [[
            $$
            <>
            $$
            <>
            ]],
            { d(1, get_visual), i(0) }
        )
    ),

    -- Delimiters

    s(
        {
            trig = [[([^a-zA-Z0-9s])([^a-zA-Z0-9s])lr]],
            wordTrig = false,
            regTrig = true,
            snippetType = "autosnippet",
        },
        fmta([[\left<> <> \right<>]], {
            f(function(_, snip)
                return snip.captures[1]
            end),
            d(1, get_visual),
            f(function(_, snip)
                return snip.captures[2]
            end),
        }),
        { condition = math }
    ),

    s(
        {
            trig = [[([^a-zA-Z0-9s])([^a-zA-Z0-9s])([^a-zA-Z0-9s])lmr]],
            wordTrig = false,
            regTrig = true,
            snippetType = "autosnippet",
            condition = math,
        },
        fmta([[\left<> <> \middle<> <> \right<>]], {
            f(function(_, snip)
                return snip.captures[1]
            end),
            i(1),
            f(function(_, snip)
                return snip.captures[2]
            end),
            i(2),
            f(function(_, snip)
                return snip.captures[3]
            end),
        })
    ),

    s(
        {
            trig = [[([^a-zA-Z0-9s])([^a-zA-Z0-9s])([^a-zA-Z0-9s])lmr]],
            wordTrig = false,
            regTrig = true,
            snippetType = "autosnippet",
            condition = math,
        },
        fmta([[\left<> <> \middle<> <> \right<>]], {
            f(function(_, snip)
                return snip.captures[1]
            end),
            i(1),
            f(function(_, snip)
                return snip.captures[2]
            end),
            i(2),
            f(function(_, snip)
                return snip.captures[3]
            end),
        })
    ),

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
                    return "{"
                elseif choice == "p" then
                    return "("
                elseif choice == "v" then
                    return "|"
                elseif choice == "V" then
                    return "\\|"
                end
            end),
            i(1),
            f(function(_, snip)
                local choice = snip.captures[1]
                if choice == "a" then
                    return ">"
                elseif choice == "b" then
                    return "]"
                elseif choice == "c" then
                    return "}"
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
        trig = "RR",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\R}") }),

    s({
        trig = "NN",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\N}") }),

    s({
        trig = "CC",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Complex}") }),

    s({
        trig = "ZZ",
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { t("{\\Z}") }),

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
        trig = "(.)-+",
        regTrig = true,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = math,
    }, { f(function(_, snip)
        return snip.captures[1] .. "\\pm "
    end) }),

    --
}

return math_snippets
