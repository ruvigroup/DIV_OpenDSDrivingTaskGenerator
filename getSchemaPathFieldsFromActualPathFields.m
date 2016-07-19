function schemaPathFields = getSchemaPathFieldsFromActualPathFields(pathFields)
schemaPathFields = pathFields;
regexField = regexp(pathFields, '.+?(?=\{)', 'match');
for i=1:length(pathFields)
    if ~isempty(regexField{i})
        schemaPathFields{i} = regexField{i}{1};
    end
end
end