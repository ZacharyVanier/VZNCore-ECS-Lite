-- Chainable query builder with all/any/none filters
-- VZNZach | Licensed client use only | Discord @botheringmeagain
-- GitHub-managed: do not modify in Roblox Studio.

--##========== PUBLIC API ==========##--

local Query = {}
Query.__index = Query

--##========== PRIVATE FUNCTIONS ==========##--

local function _clone(self: QueryImpl): QueryImpl
	local cloned = setmetatable({}, Query)

	cloned._all = table.clone(self._all)
	cloned._any = table.clone(self._any)
	cloned._none = table.clone(self._none)

	return cloned
end

local function _appendAll(target: { string }, ...: string): ()
	local count = select("#", ...)

	for i = 1, count do
		local name = select(i, ...)
		table.insert(target, name)
	end
end

local function _createEmpty(): QueryImpl
	local self = setmetatable({}, Query)

	self._all = {}
	self._any = {}
	self._none = {}

	return self
end

function Query.all(self: QueryImpl, ...: string): QueryImpl
	local isStaticCall = self == nil or type(self) == "string" or self == Query

	if isStaticCall then
		local q = _createEmpty()

		if type(self) == "string" then
			table.insert(q._all, self)
		end

		_appendAll(q._all, ...)

		return q
	end

	local q = _clone(self)

	_appendAll(q._all, ...)

	return q
end

function Query.any(self: QueryImpl, ...: string): QueryImpl
	local isStaticCall = self == nil or type(self) == "string" or self == Query

	if isStaticCall then
		local q = _createEmpty()

		if type(self) == "string" then
			table.insert(q._any, self)
		end

		_appendAll(q._any, ...)

		return q
	end

	local q = _clone(self)

	_appendAll(q._any, ...)

	return q
end

function Query.none(self: QueryImpl, ...: string): QueryImpl
	local isStaticCall = self == nil or type(self) == "string" or self == Query

	if isStaticCall then
		local q = _createEmpty()

		if type(self) == "string" then
			table.insert(q._none, self)
		end

		_appendAll(q._none, ...)

		return q
	end

	local q = _clone(self)

	_appendAll(q._none, ...)

	return q
end

function Query.matches(self: QueryImpl, componentSet: { [string]: any }): boolean
	for _, name in self._all do
		if componentSet[name] == nil then
			return false
		end
	end

	local found = #self._any == 0

	for _, name in self._any do
		if componentSet[name] ~= nil then
			found = true
			break
		end
	end

	if not found then
		return false
	end

	for _, name in self._none do
		if componentSet[name] ~= nil then
			return false
		end
	end

	return true
end

return Query
