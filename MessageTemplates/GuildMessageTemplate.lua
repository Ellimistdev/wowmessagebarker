GuildMessageTemplateMixin = {}

function GuildMessageTemplateMixin:Load() end

function GuildMessageTemplateMixin:SetMessage(message)
	MessageTemplateMixin.SetMessage(self, message)
	-- TODO test moving the anchors to Load
	self.MessageScrollFrame.MessageEditBox:SetPoint("LEFT")
	self.MessageScrollFrame.MessageEditBox:SetPoint("RIGHT")
	self.MessageScrollFrame.MessageEditBox:SetText(message.content or '')
end

function GuildMessageTemplateMixin:OnTextChanged()
	self.message.content = self.MessageScrollFrame.MessageEditBox:GetText()
end
