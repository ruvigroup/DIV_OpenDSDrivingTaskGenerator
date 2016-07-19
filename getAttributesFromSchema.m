function attributes = getAttributesFromSchema(s, fields)

attributes = [];

% special case for Choice nodes
[isChoiceNode, element] = isInChoiceNode(s, fields);
if ~isChoiceNode
    element = getElementFromSchema(s, fields);
end
if isfield(element, 'Attributes')
    attributes = element.Attributes;
end

end
