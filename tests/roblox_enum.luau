--!strict

-- Lune stand-in for a Roblox EnumItem. In Studio these are userdata and typeof() is "EnumItem".

local RobloxEnum = {}

function RobloxEnum.item(enumName: string, itemName: string): any
	local item = newproxy(true)
	local meta = getmetatable(item)
	meta.__index = {
		Name = itemName,
		EnumType = enumName,
		Value = 0,
	}
	meta.__tostring = function(): string
		return "Enum." .. enumName .. "." .. itemName
	end
	meta.__eq = function(left: any, right: any): boolean
		if rawequal(left, right) then
			return true
		end
		local okLeft, leftName = pcall(function()
			return left.Name
		end)
		local okRight, rightName = pcall(function()
			return right.Name
		end)
		local okLeftType, leftType = pcall(function()
			return left.EnumType
		end)
		local okRightType, rightType = pcall(function()
			return right.EnumType
		end)
		return okLeft
			and okRight
			and okLeftType
			and okRightType
			and type(leftName) == "string"
			and leftName == rightName
			and leftType == rightType
	end
	return item
end

function RobloxEnum.library(accept: ((string, string) -> boolean)?): any
	return setmetatable({}, {
		__index = function(self, enumName)
			local bucket = setmetatable({}, {
				__index = function(items, itemName)
					if accept ~= nil and accept(enumName, itemName) ~= true then
						error(tostring(itemName) .. " is not a valid member of Enum." .. tostring(enumName), 2)
					end
					local item = RobloxEnum.item(enumName, itemName)
					rawset(items, itemName, item)
					return item
				end,
			})
			rawset(self, enumName, bucket)
			return bucket
		end,
	})
end

function RobloxEnum.typeof(native: (any) -> string): (any) -> string
	return function(value: any): string
		if type(value) == "userdata" then
			local okName, name = pcall(function()
				return value.Name
			end)
			local okType, enumType = pcall(function()
				return value.EnumType
			end)
			if okName and okType and type(name) == "string" and type(enumType) == "string" then
				return "EnumItem"
			end
		end
		return native(value)
	end
end

function RobloxEnum.name(value: any): string?
	if type(value) == "string" then
		return value
	end
	if value == nil then
		return nil
	end
	local kind = type(value)
	if kind ~= "table" and kind ~= "userdata" then
		return nil
	end
	local ok, name = pcall(function()
		return value.Name
	end)
	if ok and type(name) == "string" then
		return name
	end
	return nil
end

return RobloxEnum
