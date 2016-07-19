function requiredChildrenPath = getRequiredChildrenPath(s, path)
requiredChildrenPath = {''};
% find the element in the schema structure
fields = strsplit(path, '.');
[element, ~] = getElementFromSchema(s, fields);
subfield = '';
if isfield(element, 'sequence')
    subfield = 'sequence';
elseif isfield(element, 'all')
    subfield = 'all';
elseif isfield(element, 'choice')
    subfield = 'choice';
elseif isfield(element, 'complexType')
    requiredChildrenPath = getRequiredChildrenPath(s, [path,'.complexType']);
    return;
end
if ~isempty(subfield)
    subFields = fieldnames(element.(subfield));
    subFields(ismember(subFields, 'Attributes')) = [];
    for i=1:length(subFields)
        if isfield(element.(subfield).(subFields{i}).Attributes, 'minOccurs')
            if str2double(element.(subfield).(subFields{i}).Attributes.minOccurs)>0
                requiredChildrenPath = [requiredChildrenPath(:); subFields{i}];
            end
        else %if minOccurs is not present, the default value is minOccurs = 1
            requiredChildrenPath = [requiredChildrenPath(:); subFields{i}];
        end
    end
end
requiredChildrenPath(1) = [];
end