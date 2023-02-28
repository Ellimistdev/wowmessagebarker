MessageTemplateMixin = {}
MESSAGEBARKER_BACKDROP_TOOLTIP_16_16_5555 = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileEdge = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
};

function MessageTemplateMixin:UpdateLayout() end

function MessageTemplateMixin:SetMessage(message)
	assert(message)
	self.message = message
end
