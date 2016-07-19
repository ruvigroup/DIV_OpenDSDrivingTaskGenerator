function add(varargin)

global OutputFile Trees hMenu simplifiedSchema

import javax.swing.tree.DefaultMutableTreeNode;

%%
numberOfElements = 0;
creationAllowed = true;

switch length(varargin)
    
    case 2 % case where the addition is  made from the context menu
        treePath = varargin{1};
        objectName = varargin{2};
        % TODO If it is loading use the realpath that we know already
        realPath = strjoin({getRealPathFromTreePath(treePath), objectName}, '.');
        parentNode = treePath.getLastPathComponent;
        pathFields = strsplit(realPath, '.');
        schemaPathFields = getSchemaPathFieldsFromActualPathFields(pathFields);
        %% Check if the element already exists, if it does, check if it is
        % allowed to have more than n elements
        % Check existence, this should not be done when loading saved data
        OutputFilePathText = ['OutputFile.',strjoin(pathFields(1:end-1), '.')];
        
        [~, existence] = evalc(['isfield(',OutputFilePathText, ', schemaPathFields{end})']);
        if existence
            % Check if allowed to have more than n elements
            elementAttributes = getAttributesFromSchema(simplifiedSchema, schemaPathFields);

            [~, numberOfElements] = evalc(['length(OutputFile.',realPath,')']);
            if strcmp(elementAttributes.maxOccurs, 'unbounded')
                maxOccurs = +inf;
            else
                maxOccurs = str2double(elementAttributes.maxOccurs);
            end
            
            if numberOfElements>=maxOccurs
                creationAllowed = false;
            else
                evalc(['OutputFile.',realPath,'{', num2str(numberOfElements+1),'} = struct;']);
            end
        else
            evalc(['OutputFile.', strjoin(pathFields(1:end), '.'),' = cell(1);']);
        end
        
        if creationAllowed
            firstChildName = pathFields{1};
            lastChildName = pathFields{end};
            jtree = Trees.jTrees{ismember(fieldnames(OutputFile), {firstChildName})};
            treeModel = jtree.getModel;
            childNode = DefaultMutableTreeNode(lastChildName);
            treeModel.insertNodeInto(childNode, parentNode, treeModel.getChildCount(parentNode));
            addContextMenu(jtree, hMenu.(firstChildName));
            
            %% Check if the element is in a sequence node, if so, the elements should be reordered
            % Check if sequence node present
            [isSequenceNode, sequenceOrder] = isInSequenceNode(simplifiedSchema, schemaPathFields);
            % Reorder elements
            if isSequenceNode
                OutputFileText = ['OutputFile.', strjoin(pathFields(1:end-1), '.')];
                sequenceOrder = ['Attributes'; sequenceOrder];
                evalc(['sequenceOrder = sequenceOrder(ismember(sequenceOrder, fieldnames(',OutputFileText,')))']);
                evalc([OutputFileText,' = orderfields(', OutputFileText ,',sequenceOrder)']);
            end
            
            % Initialize the element's attribute field in OutputFile
            [element, ~] = getElementFromSchema(simplifiedSchema, schemaPathFields);
            if isfield(element, 'attribute')
                [~, existence] = evalc(['isfield(OutputFile.',strjoin(pathFields, '.'), ', ''Attributes'');']);
                if ~existence
                    if numberOfElements~=0
                        evalc(['OutputFile.',strjoin(pathFields, '.'),'{',num2str(numberOfElements+1),'}.Attributes = [];']);
                    else
                        pathFields{end} = [pathFields{end},'{1}'];
                        evalc(['OutputFile.',strjoin(pathFields, '.'),'.Attributes = [];']);
                    end
                end
            end
            
            if ~strcmp(lastChildName, 'vector')% Do not create entry element trees
                % If the current element has required children, add them as well
                requiredChildrenPath = getRequiredChildrenPath(simplifiedSchema, strjoin(schemaPathFields, '.'));
                for i=1:length(requiredChildrenPath)
                    add(treePath.pathByAddingChild(childNode), requiredChildrenPath{i}); % add each required child                    
                end
            else % initialize vector
                if any(ismember(schemaPathFields{end-1}, {'rotation', 'color'}))
                    % Initialize the vector as quaternion
                    vectorSize = 4;
                    defautValue = [1 0 0 0];
                else
                    vectorSize = 3;
                    defautValue = [0 0 0];
                end
                for i=1:vectorSize
                    evalc(['OutputFile.',strjoin(pathFields, '.'),'.entry{',num2str(i),'}.Text = ',num2str(defautValue(i)),';']);
                end
                evalc(['OutputFile.',strjoin(pathFields, '.'),'.Attributes.jtype = ''java_lang_Float'';']);
                evalc(['OutputFile.',strjoin(pathFields, '.'),'.Attributes.size = vectorSize;']);
            end
        end
end


end

% function  parentNode = findParentNode(treeModel, pathFields)
%
% parentNode = treeModel.getRoot;
% for i=2:length(pathFields)
%     for j=1:treeModel.getChildCount(parentNode)
%         if strcmp(treeModel.getChild(parentNode, j-1).toString, pathFields{i})
%             parentNode = treeModel.getChild(parentNode, j-1);
%             break;
%         end
%     end
% end
%
% end

