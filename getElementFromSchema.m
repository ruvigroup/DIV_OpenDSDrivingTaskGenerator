function [element, elementPath] = getElementFromSchema(s, fields)

elementPath = '';
element = s;
schemaFields = getSchemaPathFieldsFromActualPathFields(fields);
for i=1:length(fields)
    [element, elementPath] = recursivegetElementFromSchema(element, elementPath, fields{i}, schemaFields{i});    
end

end

function [element, elementPath] = recursivegetElementFromSchema(element, elementPath, field, schemaField)

if isfield(element, schemaField)        
    element = element.(schemaField);
    elementPath = strjoin({elementPath, field}, '.');
elseif isfield(element, 'all')
    element = element.all.(schemaField);
    elementPath = strjoin({elementPath, field}, '.');
elseif isfield(element, 'choice')
    element = element.choice.(schemaField);
    elementPath = strjoin({elementPath, field}, '.');
elseif isfield(element, 'sequence')
    element = element.sequence.(schemaField);
    elementPath = strjoin({elementPath, field}, '.');
elseif isfield(element, 'complexType')
    [element, elementPath] = recursivegetElementFromSchema(element.complexType, elementPath, field, schemaField);
end

end