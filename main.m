function main()

global OutputFile Trees hRoots hMenu simplifiedSchema schema Settings
close all;
addpath('./XML_Structures');
load('schema.mat');
simplifiedSchema = rmfield(schema, {'Attributes', 'simpleType'});

% Initialize Global structures
Settings.drivingTaskName = '';
% Generate the general output file
fieldsFirstLevel = fieldnames(simplifiedSchema);
OutputFile = cell2struct(cell(size(fieldsFirstLevel)),fieldsFirstLevel,1);

% Create menu
hMenu.figure = figure('MenuBar', 'none',...
    'Visible', 'off');
hMenu.figure.Name = 'OpenDS driving task generator v0.2';
hMenu.figure.NumberTitle = 'off';
hMenu = createMenu(simplifiedSchema, hMenu);
fields = fieldnames(hMenu);
for i=2:length(fields)
hMenu.(fields{i}).menu.Visible = 'off';
end

% Initiate the trees
[Trees, hRoots] = generateGUI(hMenu, OutputFile);

% Ask the user if he/she want to load an existing or a new driving task

% Populate the trees
if exist('save.mat', 'file')
    answer = questdlg('Do you want to create a new driving task or load the saved task?',...
        'Launching...',...
        'New', 'Load', 'Load');
    if strcmp(answer, 'New')
    initializeTrees();
    elseif strcmp(answer, 'Load')
        loadStructure();
    end
else
    initializeTrees();
end



end

function hMenu = createMenu(s, hMenu, varargin)

if ~isempty(varargin)
    extraPath = [varargin{1}, '.'];
else
    extraPath = '';
end

if isstruct(s)
    fields = fieldnames(s);
    fields(ismember(fields, 'Attributes')) = [];
    for i=1:length(fields)
        switch fields{i}
            case {'all', 'complexType', 'sequence', 'choice'} % case where the field should be skipped
                hMenu = createMenu(s.(fields{i}), hMenu, fields{i});
            case {'annotation',...
                  'attribute'} % cases where the substruct should not be displayed
            otherwise
                if isfield(hMenu, 'figure')
                    hMenu.(fields{i}).menu = uimenu(hMenu.figure, 'Label', fields{i});
                    hMenu.(fields{i}).menu.UserData.realpath = ['schema.',extraPath,fields{i}];
                    hMenu.(fields{i}).menu.UserData.path = ['schema.',fields{i}];
                else
                    hMenu.(fields{i}).menu = uimenu(hMenu.menu, 'Label', fields{i});%, 'enable', 'off');
                    hMenu.(fields{i}).menu.UserData.realpath = [hMenu.menu.UserData.realpath,'.',extraPath,fields{i}];
                    hMenu.(fields{i}).menu.UserData.path = [hMenu.menu.UserData.path,'.',fields{i}];
                    hMenu.(fields{i}).menu.Callback = @addComponent;
                end
                if isstruct(s.(fields{i}))
                    hMenu.(fields{i}) = createMenu(s.(fields{i}), hMenu.(fields{i}));
                end
        end

    end
end

end
function [Trees, hRoots] = generateGUI(hMenu, f)

import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeSelectionModel;
import javax.swing.JTree;

hFig = hMenu.figure;
hMenu = rmfield(hMenu, 'figure');
hFigSize = hFig.Position;
fields = fieldnames(f);
fields_menu = fieldnames(hMenu);
fLength = length(fields);
% Create trees
Trees.hTrees = cell(fLength, 1);
Trees.jTrees = cell(fLength, 1);
hRoots = cell(fLength, 1);
for i=1:fLength
    % Create a treemodel
    hRoots{i} = DefaultMutableTreeNode(fields{i});
    treeModel = DefaultTreeModel(hRoots{i});
    
    %     jTrees{i} = javaObjectEDT('javax.swing.JTree');
    [jTrees, hTrees] = javacomponent('javax.swing.JTree', ...
        [(i-1)*hFigSize(3)/fLength 60 hFigSize(3)/fLength hFigSize(4)-60],...
        hFig);
    % Change Tree's units
    hTrees.Units = 'normalized'; %Set units to normalized so the trees are resized along with the figure
    % Set the tree model
    jTrees.setModel(treeModel)
    % Make the tree editable
%     jTrees.setEditable(true);
    jTrees.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
    jTrees.setShowsRootHandles(true);

    addContextMenu(jTrees, hMenu.(fields_menu{i}));
    Trees.hTrees{i} = hTrees;
    Trees.jTrees{i} = jTrees;
end

% Create uicontrols
% hButtonLoad = uicontrol(hFig, ...
%     'Position', [hFigSize(3)/2-250 10 100 40],...
%     'String', 'Load',...
%     'Callback', @loadStructure,...
%     'Units', 'normalized');
hButtonExport = uicontrol(hFig, ...
    'Position', [hFigSize(3)/2-50 10 100 40],...
    'String', 'Export to XML',...
    'Callback', @exportXML,...
    'Units', 'normalized');
hButtonSave = uicontrol(hFig, ...
    'Position', [hFigSize(3)/2+150 10 100 40],...
    'String', 'Save',...
    'Callback', @saveStructure,...
    'Units', 'normalized');

hFig.Visible = 'on';

end