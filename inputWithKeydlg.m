function Answer = inputWithKeydlg(prompt, dlg_title, defaultAns)

EditHandle=[];
nInputs = length(prompt);
Pos = getPos(nInputs);

hFig = figure(...
    'Toolbar', 'none',...
    'MenuBar', 'none',...
    'NumberTitle', 'off',...
    'WindowStyle', 'modal',...
    'Name', dlg_title,...
    'Visible', 'off');

set(hFig,'Position',getNiceDialogLocation(Pos.hFig,get(hFig,'Units')));

for i=1:nInputs
    % Prompt
    uicontrol(hFig,...
        'Style', 'text',...
        'String', prompt{i},...
        'Position', Pos.hText{i});
    EditHandle(i) = uicontrol(hFig,...
        'Style', 'edit',...
        'String', defaultAns{i},...
        'Position', Pos.hEdit{i});
    if strcmp(prompt{i}, 'key')
     uicontrol(hFig,...
        'String', 'F',...
        'Position', [Pos.hEdit{i}(3)-Pos.hEdit{i}(4) Pos.hEdit{i}(2) Pos.hEdit{i}(4) Pos.hEdit{i}(4)],...
        'Callback', {@setEditHandle, EditHandle(i)});
    end
end

uicontrol(hFig     ,              ...
    'Position'   ,Pos.hButtonOk , ...
    'String'     ,getString(message('MATLAB:uistring:popupdialogs:OK'))        , ...
    'Callback'   ,@doCallback , ...
    'Tag'        ,'OK'        , ...
    'UserData'   ,'OK'          ...
    );

uicontrol(hFig     ,              ...
    'Position'   ,Pos.hButtonCancel           , ...
    'String'     ,getString(message('MATLAB:uistring:popupdialogs:Cancel'))    , ...
    'Callback'   ,@doCallback , ...
    'Tag'        ,'Cancel'    , ...
    'UserData'   ,'Cancel'       ...
    ); %#ok

% make sure we are on screen
movegui(hFig)

set(hFig,'Visible','on');
drawnow;

if ishghandle(hFig)
    % Go into uiwait if the figure handle is still valid.
    % This is mostly the case during regular use.
    uiwait(hFig);
end

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
if ishghandle(hFig)
    Answer={};
    if strcmp(get(hFig,'UserData'),'OK'),
        Answer=cell(nInputs,1);
        for lp=1:nInputs,
            Answer(lp)=get(EditHandle(lp),{'String'});
        end
    end
    delete(hFig);
else
    Answer={};
end
drawnow; % Update the view to remove the closed figure (g1031998)
end

function Pos = getPos(nInputs)

FigureSize = [400 nInputs*50+30];
Pos.hFig = [0 0 FigureSize];
for i=1:nInputs
    Pos.hText{i} = [0 50*(i-1)+60 FigureSize(1) 20];
    Pos.hEdit{i} = [0 50*(i-1)+30 FigureSize(1) 20];
end
Pos.hButtonOk = [0 0 FigureSize(1)/2 20];
Pos.hButtonCancel = [FigureSize(1)/2  0 FigureSize(1)/2 20];
end

function doCallback(obj, evd) %#ok
if ~strcmp(get(obj,'UserData'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end
end

function setEditHandle(~, ~, EditHandle)
%
[FileName,PathName] = uigetfile('*.j3o','Select the model file');
assestInd = strfind(PathName, 'assets');
if ~isempty(assestInd)
    key = [PathName(assestInd(end)+7:end), FileName];
    set(EditHandle, 'String', strrep(key,'\', '/'));
end

end