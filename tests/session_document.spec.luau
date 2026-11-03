--!strict

_G.LUNE = true

local Check = require("./check")
local Schema = require("../src/shared/Logic/Schema")
local SessionDocument = require("../src/shared/Logic/SessionDocument")
local Retry = require("../src/shared/Logic/Retry")

Check.test("retry budget is three attempts with 1s then 2s backoff", function()
	Check.eq(Retry.backoffSeconds(1), 1)
	Check.eq(Retry.backoffSeconds(2), 2)
	Check.eq(Retry.backoffSeconds(3), nil)
end)

Check.test("new document is created only when the key is empty", function()
	local createdProfile = Schema.newProfile(100, "starter-a")
	local decoy = Schema.newProfile(100, "starter-b")
	decoy.cash = 9999
	local document, status = SessionDocument.buildWrite(nil, "job-a", 1000, 90, createdProfile)
	Check.eq(status, "created")
	Check.truthy(document)
	Check.eq(document.lockJobId, "job-a")
	Check.eq(document.lockExpiresAt, 1090)
	Check.eq(document.profile.cash, 25)
	Check.eq(document.profile.pads["1"], "starter-a")

	local denied, deniedStatus = SessionDocument.buildWrite(document, "job-b", 1010, 90, decoy)
	Check.eq(denied, nil)
	Check.eq(deniedStatus, "locked")

	local stolen, stolenStatus = SessionDocument.buildWrite(document, "job-b", 1090, 90, decoy)
	Check.eq(stolenStatus, "loaded")
	Check.truthy(stolen)
	Check.eq(stolen.profile.cash, 25)
	Check.eq(stolen.profile.pads["1"], "starter-a")
	Check.eq(stolen.lockJobId, "job-b")
end)

Check.test("corrupt profiles are not replaced", function()
	local junk, status = SessionDocument.buildWrite({
		lockJobId = "",
		lockExpiresAt = 0,
		profile = { dataVersion = 1 },
	}, "job-c", 50, 90, Schema.newProfile(1, "starter"))
	Check.eq(junk, nil)
	Check.eq(status, "corrupt")

	local broken, brokenStatus = SessionDocument.buildWrite("nope", "job-c", 50, 90, Schema.newProfile(1, "starter"))
	Check.eq(broken, nil)
	Check.eq(brokenStatus, "corrupt")
end)

Check.test("save refreshes our lock and release clears it", function()
	local profile = Schema.newProfile(10, "starter")
	local created = SessionDocument.buildWrite(nil, "job-a", 10, 90, profile)
	profile.cash = 40
	local saved, savedStatus = SessionDocument.buildSave(created, "job-a", 20, 90, profile)
	Check.eq(savedStatus, "saved")
	Check.eq(saved.profile.cash, 40)
	Check.eq(saved.lockExpiresAt, 110)
	local blocked = SessionDocument.buildSave(saved, "job-b", 30, 90, profile)
	Check.eq(blocked, nil)
	local released, releaseStatus = SessionDocument.buildRelease(saved, "job-a", profile)
	Check.eq(releaseStatus, "released")
	Check.eq(released.lockJobId, "")
	Check.eq(released.profile.cash, 40)
	local otherRelease = SessionDocument.buildRelease(saved, "job-b", profile)
	Check.eq(otherRelease, nil)
end)

Check.test("a missing document is not recreated by a save", function()
	local profile = Schema.newProfile(10, "starter")
	local missing, status = SessionDocument.buildSave(nil, "job-a", 10, 90, profile)
	Check.eq(missing, nil)
	Check.eq(status, "lost")
end)
