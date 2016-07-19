function initializeTrees

global OutputFile simplifiedSchema Trees

fields = fieldnames(OutputFile);
% for each tree
for i=1:length(fields)
     % If the current element has required children, add them as well
    requiredChildrenPath = getRequiredChildrenPath(simplifiedSchema, fields{i});
    for c=1:length(requiredChildrenPath)
        add(Trees.jTrees{i}.getPathForRow(0), requiredChildrenPath{c}); % add each required child
    end
end

end