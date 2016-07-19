function populateStructure(parentNode, pathFields, elementName)

global Trees OutputFile hMenu

import javax.swing.tree.DefaultMutableTreeNode;

realPath = strjoin([pathFields(1:end-1), elementName], '.');
pathFields = strsplit(realPath, '.');

firstChildName = pathFields{1};
lastChildName = pathFields{end};
jtree = Trees.jTrees{ismember(fieldnames(OutputFile), {firstChildName})};
treeModel = jtree.getModel;
childNode = DefaultMutableTreeNode(lastChildName);
treeModel.insertNodeInto(childNode, parentNode, treeModel.getChildCount(parentNode));
addContextMenu(jtree, hMenu.(firstChildName));


end