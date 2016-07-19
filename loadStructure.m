function loadStructure(varargin)

global OutputFile Trees

load('save.mat');

elementsToCreate = getElementsToCreate(OutputFile);

fields = fieldnames(OutputFile);
% for each tree
for i=1:length(fields)
     % If the current element has required children, add them as well
     for j=1:length(elementsToCreate{i})
        pathFields = strsplit(elementsToCreate{i}{j},'.');
        schemaFields = getSchemaPathFieldsFromActualPathFields(pathFields);
        lastElement = schemaFields{end};
        % find the parent's treePath
        jtree = Trees.jTrees{i};
        parentNode = getParentNode(jtree, pathFields);
        populateStructure(parentNode, pathFields, lastElement); % add each required child
     end
end
end

function elementsToCreate = getElementsToCreate(s)

fields = fieldnames(s);
for i=1:length(fields)
    elementsToCreate{i} = getSubFields(s.(fields{i}), fields(i));
    elementsToCreate{i}(1) = [];
end


end

function elementsToCreate = getSubFields(s, elementsToCreate)

if ~isempty(s)    
    parentFields = getSchemaPathFieldsFromActualPathFields(strsplit(elementsToCreate{1},'.'));
    if iscell(s)
        initialElementPath = elementsToCreate;
        for j=1:length(s)
            switch j
                case 1
                    elementsToCreate = [getSubFields(s{j}, {[initialElementPath{1} '{' num2str(j) '}']})];
                otherwise
                    elementsToCreate = [elementsToCreate; getSubFields(s{j}, {[initialElementPath{1} '{' num2str(j) '}']})];
            end
               
            
        end
    elseif ischar(s)
        %         elementsToCreate = {[elementsToCreate '.' s]};
    elseif isstruct(s)
        fields = fieldnames(s);
        fields(ismember(fields, {'Attributes', 'Text'})) = [];
        for i=1:length(fields)
            if ~strcmp('vector', parentFields{end})
                elementsToCreate = [elementsToCreate; getSubFields(s.(fields{i}), {[elementsToCreate{1} '.' fields{i}]})];
            end
        end
    else
        %         elementsToCreate = elementsToCreate;
    end
end
end

function parentNode = getParentNode(jtree, pathFields)
import javax.swing.tree.TreePath
rootPath = jtree.getPathForRow(0);
path = rootPath.getPath;
parentNode = bc(path(1), pathFields(2:end));

end

function parentTreePath = bc(parentTreePath, pathFields)

schemaPathFields = getSchemaPathFieldsFromActualPathFields(pathFields);
childName = schemaPathFields{1};
if ~strcmp(childName, pathFields{1})
    childInd = strrep(pathFields{1},childName, '');
    childInd = strrep(strrep(childInd,'{',''),'}','');
    childInd = str2double(childInd);
else
    childInd = 1;
end
ind = 0;
if length(pathFields)>1
    for i=1:parentTreePath(end).getChildCount
        if strcmp(parentTreePath.getChildAt(i-1).toString,childName)
            ind = ind+1;
            if childInd==ind
                parentTreePath = bc(parentTreePath.getChildAt(i-1),pathFields(2:end));
            end
        end
    end
    
end

end