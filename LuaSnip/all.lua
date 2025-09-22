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

    -- Math zones

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
}

return math_snippets
