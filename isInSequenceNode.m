function [isSequenceNode, sequenceOrder] = isInSequenceNode(s, fields)

[schemaFields, parent] = getRealSchemaPathFieldsFromActualPathFields(s, fields);
% for i=1:length(fields)
%     isSequenceNode = recursiveGetIsSequenceNode(s, 0, fields{i}, schemaFields{i});
% end
sequenceOrder = {''};
if length(schemaFields)>1
    isSequenceNode = strcmp(schemaFields{end-1}, 'sequence');
    if isSequenceNode
        sequenceOrder = fieldnames(parent);
    end
else
    isSequenceNode = NaN;
end

end


function [schemaFields, parent] = getRealSchemaPathFieldsFromActualPathFields(s, fields)
elementPath = '';
element = s;
for i=1:length(fields)
    [parent, element, elementPath] = recursivegetElementFromSchema(element, elementPath, fields{i});
end
schemaFields = strsplit(elementPath,'.');
end

function [parent, element, elementPath] = recursivegetElementFromSchema(element, elementPath, field)

if isfield(element, field)
    parent = element;
    element = element.(field);    
    elementPath = strjoin({elementPath, field}, '.');
elseif isfield(element, 'all')
    parent = element.all;
    element = element.all.(field);    
    elementPath = strjoin({elementPath, 'all', field}, '.');
elseif isfield(element, 'sequence')
    parent = element.sequence;
    element = element.sequence.(field);    
    elementPath = strjoin({elementPath, 'sequence', field}, '.');
elseif isfield(element, 'choice')
    parent = element.choice;
    element = element.choice.(field);    
    elementPath = strjoin({elementPath, 'choice', field}, '.');
elseif isfield(element, 'complexType')
    elementPath = strjoin({elementPath, 'complexType'}, '.');  
    [parent, element, elementPath] = recursivegetElementFromSchema(element.complexType, elementPath, field);
else
    parent = element;
end

end