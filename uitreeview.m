function hTreeNode = uitreeview(hTreeNode, Value, Description, Icon, Leaf)

if ~isequal(size(Value),size(Description), size(Icon), size(Leaf))
    error(message('The inputs should have the same size'));
elseif ~ishandle(hTreeNode)
    error(message('The first input should be a handle'));
end

switch hTreeNode.Type
    case 'figure'
%         h = uitree('v0', Description, root);
    case ''
    otherwise
        switch hTreeNode.getClass
            case {'com.mathworks.hg.peer.UITreePeer',...
                  'com.mathworks.hg.peer.UITreeNode' }
              for i=1:length(Value)
                hTreeNode.add(uitreenode('v0', Value{i},  Description{i},  Icon{i}, Leaf{i}));
              end
            otherwise
                
        end
end

end