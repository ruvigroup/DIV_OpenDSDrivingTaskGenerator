function openEditDialog(treePath)

global OutputFile simplifiedSchema

realPath = getRealPathFromTreePath(treePath);
fields = strsplit(realPath, '.');
[element, elementPath] = getElementFromSchema(simplifiedSchema, fields);

% Special case for Rotation, if rotation another type of interface should
% be used
if strcmp(element.Attributes.name, 'rotation')
    % Ask the user if the vector is a quaternion or not (true or false)
    choiceList = {'quaternion', 'euler vector'};
    % check and load if a value already exists
    OutputFileText = ['OutputFile',elementPath,'.Attributes.quaternion'];
    [~, fieldPresence] = evalc(['isfield(','OutputFile',elementPath, '.Attributes,''quaternion'')']);
    if fieldPresence
        evalc(['elementValue = ', OutputFileText]);
        InitialValue = find([true, false] == elementValue);
    else
        evalc([OutputFileText, '= true']);
        InitialValue = 1;
    end
    [answer,choiceMade] = listdlg('PromptString','Rotation vector defined as:',...
        'SelectionMode','single',...
        'ListString',choiceList,...
        'InitialValue', InitialValue);
    
    if choiceMade && InitialValue~=answer
        booleanStr = {'true', 'false'};
        evalc([OutputFileText,' = ', booleanStr{answer},'']);
        % Reset Vector entries
        OutputFileTextForVectorEntries = ['OutputFile',elementPath,'.vector{1}.entry'];
        evalc([OutputFileTextForVectorEntries,'= []']);
        
        % Update Vector type
        OutputFileTextForVectorSize = ['OutputFile',elementPath,'.vector{1}.Attributes.size'];
        if answer==1
            evalc([OutputFileTextForVectorSize, '= 4']);
            defaultValue = [1 0 0 0];
        elseif answer==2
            evalc([OutputFileTextForVectorSize, '= 3']);
            defaultValue = [0 0 0];
        end
        for i=1:length(defaultValue)
            evalc([OutputFileTextForVectorEntries,'{', num2str(i), '}.Text = ', num2str(defaultValue(i))]);
        end
    end
% Special case for forward (within transmission node)
elseif strcmp(element.Attributes.name, 'forward')
    % Ask the user how many gears the car has
    choiceList = {'3', '4', '5', '6'};
    % check how many entry nodes exist
    OutputFileText = ['OutputFile',elementPath,'.vector{1}.entry'];
    [~, numberOfGears] = evalc(['length(',OutputFileText, ')']);
    if numberOfGears~=0
        InitialValue = find(ismember(choiceList, num2str(numberOfGears)));
    else
        InitialValue = 3;
    end
    [answer,choiceMade] = listdlg('PromptString','Select the number of gears:',...
        'SelectionMode','single',...
        'ListString',choiceList,...
        'InitialValue', InitialValue);
    
    if choiceMade && InitialValue~=answer
        
        % Reset Vector entries
        evalc([OutputFileText,'= []']);
        
        % Update Vector type
        OutputFileTextForVectorSize = ['OutputFile',elementPath,'.vector{1}.Attributes.size'];
        evalc([OutputFileTextForVectorSize, '=', choiceList{answer}]);

        for i=1:str2double(choiceList{answer})
            evalc([OutputFileText,'{', num2str(i), '}.Text = ', num2str(0)]);
        end
    end
elseif strcmp(element.Attributes.name, 'vector')
    %% Special case %%
    % Vector element should ask for its entries' value directly
    OutputFileText = ['OutputFile',elementPath,'.Attributes.size'];
    VectorSize = '';
    evalc(['VectorSize = ',OutputFileText]);
    options.Interpreter = 'tex';
    options.Resize = 'on';
    OutputFileText = ['OutputFile',elementPath,'.entry'];
    [ ~, VectorValue] = evalc(['cellfun(@(x)x.Text, ' OutputFileText ')']);
    defaultAns = strsplit(num2str(VectorValue),' ');
    % Get parent's name
    pathFields = strsplit(elementPath, '.');
    parentName = getSchemaPathFieldsFromActualPathFields(pathFields(end-1));
    if strcmp(parentName, 'forward')
        InputStart = cell(VectorSize, 1); [InputStart{:}] = deal('e_{');
        InputEnd = cell(VectorSize, 1); [InputEnd{:}] = deal('}');
        InputPrompt = cellstr([vertcat(InputStart{:}), num2str(cumsum(ones(VectorSize,1))), vertcat(InputEnd{:})]);
        answer = inputdlg(InputPrompt,['Vector ', num2str(VectorSize), 'dim'],1,defaultAns, options);
    else
        if VectorSize==3
            answer = inputdlg({'e_{1}','e_{2}', 'e_{3}'},'Vector 3 dim',1,defaultAns, options);
        elseif VectorSize==4
            answer = inputdlg({'s', 'i', 'j', 'k'},'Vector (Quaternion)',1,defaultAns, options);
        end
    end
    if ~isempty(answer)
        OutputFileText = ['OutputFile',elementPath,'.entry'];
        for i=1:length(answer)
            evalc([OutputFileText,'{',num2str(i),'}.Text = ', answer{i}]);
        end
    end
elseif isfield(element, 'attribute') % In case there is attributes attached to the element
    if iscell(element.attribute)
        for i=1:length(element.attribute)
            attribute = element.attribute{i};
            attributes(i).name = attribute.Attributes.name;
            attributes(i).type = strrep(attribute.Attributes.type, 'xs:', '');
        end
    else
        attributes.name = element.attribute.Attributes.name;
        attributes.type = strrep(element.attribute.Attributes.type, 'xs:', '');
    end
    
    prompt = {attributes(:).name};
    dlg_title = ['Submit ',element.Attributes.name,'''s attribute(s) value'];
    num_lines = 1;
    defaultAns = cell(size(attributes));
    for i=1:length(attributes)
        [~, fieldPresence] = evalc(['isfield(','OutputFile',elementPath, '.Attributes,''',attributes(i).name,''')']);
        if fieldPresence
            OutputFileText = ['OutputFile',elementPath,'.Attributes.', attributes(i).name];
            evalc(['defaultAns{i} = ',OutputFileText]);
        else
            defaultAns{i} = '';
        end
    end
    
    % Create dialog box to ask for the value except for key attribute, it
    % should be a model
    if any(ismember({attributes.name}, 'key'))
        answer = inputWithKeydlg(prompt,dlg_title,defaultAns);
    else
        answer = inputdlg(prompt,dlg_title, num_lines, defaultAns);
    end
    if ~isempty(answer)
        for i=1:length(attributes)
            OutputFileText = ['OutputFile',elementPath,'.Attributes.', attributes(i).name];
            evalc([OutputFileText,' = ''',answer{i},'''']);
        end
    end
end
% If the field "type" exists in the Attributes, then the element should
% have a value
if isfield(element.Attributes, 'type')
    % Create dialog box to ask for the value
    prompt = {['Enter ', element.Attributes.name, '''s value [',strrep(element.Attributes.type, 'xs:', ''),']']};
    dlg_title = ['Submit ',element.Attributes.name,'''s value'];
    num_lines = 1;
    OutputFileText = ['OutputFile',elementPath,'.Text'];
    [~, fieldPresence] = evalc(['isfield(','OutputFile',elementPath, ',''Text'')']);
    if fieldPresence
        evalc(['defaultAns = {',OutputFileText,'}']);
    else
        defaultAns = {''};
    end
    answer = inputdlg(prompt,dlg_title,num_lines, defaultAns);
    
    if ~isempty(answer)
        evalc([OutputFileText,' = ''',answer{1},'''']);
    end
elseif isfield(element, 'simpleType')%If restriction is a subelement of the current element, then show a drop-down menu
    if isfield(element.simpleType, 'restriction')
        choiceList = cell(size(element.simpleType.restriction.enumeration));
        for i=1:length(choiceList)
            choiceList{i} = element.simpleType.restriction.enumeration{i}.Attributes.value;
        end
        
        % check and load if a value already exists
        OutputFileText = ['OutputFile',elementPath,'.Text'];
        [~, fieldPresence] = evalc(['isfield(','OutputFile',elementPath, ',''Text'')']);
        if fieldPresence
            evalc(['elementValue = ', OutputFileText]);
            InitialValue = find(ismember(choiceList, elementValue));
        else
            InitialValue = 1;
        end
        [answer,choiceMade] = listdlg('PromptString','Select a choice:',...
            'SelectionMode','single',...
            'ListString',choiceList,...
            'InitialValue', InitialValue);
        if choiceMade
            evalc([OutputFileText,' = ''',choiceList{answer},'''']);
        end
    end
end

end
