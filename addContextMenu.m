function addContextMenu(jTree, hMenu)


import javax.swing.JMenuItem;
import javax.swing.JPopupMenu;

% hMenu is the main menu in figure's toolbar

% Prepare the context menu (note the use of HTML labels)
menuItem1 = JMenuItem('<html><b>Edit...');
menuItem2 = JMenuItem('Delete');

% Set the menu items' callbacks
set(menuItem1);
set(menuItem2);
% set(menuItem3,'ActionPerformedCallback','disp ''action #3...'' ');

% Add all menu items to the context menu (with internal separator)
JPopupMenu = handle(JPopupMenu, 'CallbackProperties'); % see http://undocumentedmatlab.com/blog/matlab-callbacks-for-java-events-in-r2014a
jmenu = JPopupMenu;
jmenu.add(menuItem1);
jmenu.add(menuItem2);
% jmenu.add(menuItem3);

% Set the tree mouse-click callback
% Note: MousePressedCallback is better than MouseClickedCallback
%       since it fires immediately when mouse button is pressed,
%       without waiting for its release, as MouseClickedCallback does
set(jTree, 'MousePressedCallback', {@mousePressedCallback,jmenu,hMenu});

end

% Set the mouse-press callback
function mousePressedCallback(jtree, eventData, jmenu, hMenu)

import java.awt.event.ActionEvent;
import javax.swing.JMenuItem;
import javax.swing.JSeparator;
% import javax.swing.SwingConstants;

   if eventData.isMetaDown  % right-click is like a Meta-button
      % Get the clicked node
      clickX = eventData.getX;
      clickY = eventData.getY;
      treePath = jtree.getPathForLocation(clickX, clickY);
      try
        % Select the node if none is selected beneath the cursor.
        if treePath ~= jtree.getSelectionPath
            jtree.setSelectionPath(treePath);
        end
        
        SubElements = jmenu.getSubElements;
        % Add Edit Callback
        menuDeleteItem = SubElements(1);
        set(menuDeleteItem, 'ActionPerformedCallback', {@editElement, treePath});
        % Add Delete Callback
        menuDeleteItem = SubElements(2);
        set(menuDeleteItem, 'ActionPerformedCallback', {@removeElement, treePath});
        % Modify the context menu or some other element
        % based on the clicked node.
        % Show the list of sublevel nodes that can be added
        str = Path2MenuString(treePath);       
        [~,fields]= evalc(['fieldnames(', str,')']);
        if length(fields)>1 % if == 1 it is the menu field
            menuAddItem = javax.swing.JMenu('Add');
            for j=2:length(fields) % from 2 because the one is menu
                menuItem = JMenuItem(fields{j});
                set(menuItem,'ActionPerformedCallback',{@addElement, treePath}); % To simplify the selection of data
                menuAddItem.add(menuItem);
            end
            item.Separator = jmenu.add(JSeparator);
            item.Add = jmenu.add(menuAddItem); 
            % Remove the specific Add item when the popupmenu disappears
            set(jmenu, 'PopupMenuWillBecomeInvisibleCallback', {@removeItem,jmenu,item});
        end
        jmenu.show(jtree, clickX, clickY);
        jmenu.repaint;
      catch
         % clicked location is NOT on top of any node
         % Note: can also be tested by isempty(treePath)
      end

      
   end
end

function str = Path2MenuString(Path)

objectArray = Path.getPath();
str{1} = 'hMenu';
for i=2:length(objectArray)
    str{i} = char( objectArray(i).toString);
end
str = getSchemaPathFieldsFromActualPathFields(str);
str = strjoin(str, '.');

end

function str = Path2String(Path)
objectArray = Path.getPath();
for i=1:length(objectArray)
    str{i} = char( objectArray(i).toString);
end
str = strjoin(str, '.');
end

% Remove the extra context menu item after display
function removeItem(~,~,jmenu,item)
    fields = fieldnames(item);
    for i=1:length(fields)
       jmenu.remove(item.(fields{i}));
    end
end

function editElement(~, ~, treePath)
openEditDialog(treePath);
end

function addElement(hObject, ~, treePath)
objectName= char(hObject.getLabel);
add(treePath, objectName);
end

function removeElement(~, ~, treePath)
remove(treePath);
end