--!strict

_G.LUNE = true

require("./number_format.spec")
require("./economy_onboarding.spec")
require("./session_document.spec")
require("./theme_and_source.spec")
require("./plots.spec")
require("./town.spec")
require("./watchdog.spec")
require("./persistence.spec")
require("./skill_tree.spec")

local Check = require("./check")
Check.finish()
