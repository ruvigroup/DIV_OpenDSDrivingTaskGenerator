function realPath = getRealPathFromTreePath(treePath)

treePathComponents = treePath.getPath;
realPath = char(treePathComponents(1).toString);
for i=2:treePath.getPathCount
    childInd = getLastPathComponentInd(treePathComponents(i-1:i));
    realPath = strjoin({realPath, [char(treePathComponents(i).toString),'{',num2str(childInd),'}']}, '.');
end

end

function childInd = getLastPathComponentInd(treePathComponents)

childInd = 1;
ind = 1;
parent = treePathComponents(1);
child = treePathComponents(2);
for i=1:parent.getChildCount
    if strcmp(parent.getChildAt(i-1).toString, child.toString)
        if parent.getChildAt(i-1).equals(child)
            childInd = ind;
            return;
        else
            ind = ind+1;
        end
    end
end

end