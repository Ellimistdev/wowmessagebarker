-- EW! Factory pattern is poop, need a more extensible way of creating objects
MessageFactory = {}

MessageBarker_MessageTypes = {
	Basic = 1,
	Sale = 2,
	Guild = 3,
}

do
	local messageTypes = tInvert(MessageBarker_MessageTypes)
	function MessageFactory:GetMessageTypeString(messageType)
		return messageTypes[messageType] or 'Unknown Message Type'
	end
end

function MessageFactory:LoadFactoryMethods()
	self.MessageFactoryMethods = {
		[MessageBarker_MessageTypes.Basic]	= MessageFactory.CreateMessage_Basic,
		[MessageBarker_MessageTypes.Sale]	= MessageFactory.CreateMessage_Sale,
		[MessageBarker_MessageTypes.Guild]	= MessageFactory.CreateMessage_Guild,
	}
end

function MessageFactory:CreateMessage(messageType, ...)
	if not self.MessageFactoryMethods then
		self:LoadFactoryMethods()
	end
	local factory = self.MessageFactoryMethods[messageType]
	assert(factory and type(factory) == "function", "Invalid Message Type: "..messageType)
	local message = factory(self, ...)
	message.id = MessageBarker:GetNextMessageID()
	message.type = messageType
	message.outputs = {} -- TODO load default outputs (configured by user under Interface Options) per messageType
	return message
end

-- NOTE: Messages are persistent data objects, meaning only data is saved and the methods/functions are not.
-- This means that (since we can't use polymorphism here) the functions to generate the text for output need
-- to be separate from the data objects and we need some logic to choose functions based on the message type.
-- Unfortunately, this is another unfriendly design pattern. At the very least, we can use a lookup table
-- instead of a series of if-else statements.
-- TODO: (Another option would be to mixin the generator functions upon loading/creating the message objects)
function MessageFactory:LoadTextGenerators()
	self.TextGenerators = {
		[MessageBarker_MessageTypes.Basic]	= MessageFactory.GenerateText_Basic,
		[MessageBarker_MessageTypes.Sale]	= MessageFactory.GenerateText_Sale,
		[MessageBarker_MessageTypes.Guild]	= MessageFactory.GenerateText_Guild,
	}
end

function MessageFactory:GenerateText(message)
	assert(message)
	if not self.TextGenerators then
		self:LoadTextGenerators()
	end	
	local generator = self.TextGenerators[message.type]
	assert(generator and type(generator) == "function", "Invalid Message Type: "..message.type)
	return generator(self, message)
end

function MessageFactory:CreateMessage_Basic()
	local newMessage = {
		name = "New Message",
		content = 'Write your message content here.',
	}
	return newMessage
end

function MessageFactory:GenerateText_Basic(message)
	return message.content
end

function MessageFactory:CreateMessage_Sale(itemId, itemLink)
	local newMessage = {
		name = 'New Item Sale',
		content = {
			prefix = "WTS",
			items = {},
			suffix = "",
		},
	}
	if itemId then
		local item = self:CreateItemContent(itemId, itemLink)
		newMessage.name = item.name
		table.insert(newMessage.content.items, item)
	end
	return newMessage
end

function MessageFactory:CreateItemContent(itemId, itemLink)
	local itemName, itemIcon;
	itemName = C_Item.GetItemNameByID(itemId)
	itemIcon = GetItemIcon(itemId)
	return { id = itemId, link = itemLink, name = itemName, icon = itemIcon, price = "" }
end

function MessageFactory:GenerateText_Sale(message)
	local text = message.content.prefix or ''
	for i, item in ipairs(message.content.items) do
		local delimeter = ', '
		if i == 1 then
			delimeter = ' '
		end
		text = text .. delimeter .. self:GenerateText_SaleItem(item)
	end
	if message.content.suffix and #message.content.suffix > 0 then
		text = text .. ' ' .. message.content.suffix
	end
	return text
end

function MessageFactory:GenerateText_SaleItem(item)
	local itemName = ''
	if item.link then
		itemName = item.link
	else
		if item.name and #item.name > 0 then
			itemName = '['..item.name..']'
		end
	end
	local itemPrice = ''
	if item.price and #item.price > 0 then
		--itemPrice = ':' .. item.price
		itemPrice = item.price
	end
	return itemName .. itemPrice
end

function MessageFactory:CreateMessage_Guild()
	local club = ClubFinderGetCurrentClubListingInfo(C_Club.GetGuildClubId());
	local newMessage = {
		name = "New Message",
		content = 'Join' .. GetClubFinderLink(club.clubFinderGUID, club.name) .. "!",
	}
	return newMessage
end

function MessageFactory:GenerateText_Guild(message)
	return message.content
end