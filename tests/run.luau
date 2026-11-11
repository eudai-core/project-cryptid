--!strict

_G.LUNE = true

require("./number_format.spec")
require("./economy_onboarding.spec")
require("./session_document.spec")
require("./theme_and_source.spec")
require("./plots.spec")
require("./town.spec")
require("./town_v3.spec")
require("./townkits_longship.spec")
require("./townkits_well.spec")
require("./townkits_apothecary.spec")
require("./watchdog.spec")
require("./qa_args.spec")
require("./persistence.spec")
require("./studio_store.spec")
require("./skill_tree.spec")
require("./art_batch.spec")
require("./save_hardening.spec")
require("./studio_qa.spec")
require("./return.spec")
require("./monetisation.spec")
require("./rate_limit.spec")
require("./analytics.spec")

local Check = require("./check")
Check.finish()
