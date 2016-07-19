function remove(varargin)

global OutputFile Trees

import javax.swing.tree.DefaultMutableTreeNode;

switch length(varargin)
    
    case 1
        treePath = varargin{1};
        realPath = getRealPathFromTreePath(treePath);
        pathFields = strsplit(realPath, '.');
        elementName = getSchemaPathFieldsFromActualPathFields(pathFields(end));
        pathFields{end} = strrep(strrep(pathFields{end}, '{', '('), '}', ')');
        realPath = strjoin(pathFields, '.');
        firstChildName = pathFields{1};
        % Delete element from outputFile
        evalc(['OutputFile.',realPath,' = []']);
        % Check if the element type is empty, if true, remove field
        [~, elementEmpty] = evalc(['isempty(OutputFile.',strjoin([pathFields(1:end-1), elementName], '.'),')']);
        if elementEmpty
            evalc(['OutputFile.',strjoin(pathFields(1:end-1), '.'),' = rmfield(OutputFile.',strjoin(pathFields(1:end-1), '.'),',''',elementName{:},''');']);
        end
        jtree = Trees.jTrees{ismember(fieldnames(OutputFile), {firstChildName})};
        treeModel = jtree.getModel;
        % Find the correct node
        childNode = treePath.getLastPathComponent;
        treeModel.removeNodeFromParent(childNode);
    case 2
        
end



end

% function  childNode = findChildNode(treeModel, pathFields)
% 
% childNode = treeModel.getRoot;
% for i=2:length(pathFields)
%     for j=1:treeModel.getChildCount(childNode)
%         if strcmp(treeModel.getChild(childNode, j-1).toString, pathFields{i})
%             childNode = treeModel.getChild(childNode, j-1);
%             break;
%         end
%     end
% end
% 
% end