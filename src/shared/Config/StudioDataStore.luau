--!strict

local StudioDataStore = {
	UNPUBLISHED_PLACE_ID = 0,
	MOCK_WARNING = "[Cryptid:DataStore] Studio has no DataStore API access. Using an in-memory mock store. This session is not saved to a live DataStore.",
	STUDIO_WORD = "studio",
	DENIED_MARKERS = table.freeze({
		"studioaccesstoapisnotallowed",
		"studio access to apis",
		"api access is not",
		"enable studio access",
		"cannot write to datastore",
		"not published",
		"must be published",
		"must publish",
		"place has to be published",
		"publish the place",
		"publish this place",
		"http 403",
		"403 forbidden",
	}),
	STUDIO_CONTEXT_MARKERS = table.freeze({
		"datastore",
		"api",
		"publish",
		"403",
	}),
}

return table.freeze(StudioDataStore)
