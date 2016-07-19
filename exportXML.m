function exportXML(varargin)

global OutputFile schema Settings

if isempty(Settings.drivingTaskName)
    prompt = 'Please insert driving task''s name:';
    dlg_title = 'Settings: Driving task name';
    answer = inputdlg(prompt,dlg_title);
    if ~isempty(answer)
        Settings.drivingTaskName = answer{1};
    end
end

% Generate driving task's main XML file

file = [ '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' ...
'<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">' ...
'<properties>'...
'<entry key="verbose">false</entry>'...
'<entry key="interaction">interaction.xml</entry>'...
'<entry key="task">task.xml</entry>'...
'<entry key="scenario">scenario.xml</entry>'...
'<entry key="settings">settings.xml</entry>'...
'<entry key="scene">scene.xml</entry>'...
'</properties>'];

fID = fopen([Settings.drivingTaskName, '.xml'],'w');
fprintf(fID, '%s', file);
fclose(fID);

out = OutputFile;
s = schema;

fields = fieldnames(out);

for f=1:length(fields)
    a.out = out.(fields{f});
    if ~isempty(a.out)
        xml = struct2xml(a);
    else
        xml = '';
    end
    file = '<?xml version="1.0" encoding="UTF-8"?>';
    % Create main node with XML attributes
    file = [file, sprintf('\n'), '<', fields{f}, ...
        ' xmlns="',s.Attributes.xmlns,fields{f},'"',sprintf('\n'),...
		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',sprintf('\n'),... 
        ' xsi:schemaLocation="',s.Attributes.targetNamespace,fields{f},' ../../Schema/',fields{f},'.xsd">',sprintf('\n')];
    file = [file, xml(49:end-6)];
    % Close main node
    file = [file, '</', fields{f},'>'];
    fID = fopen([fields{f}, '.xml'],'w');
    fprintf(fID, '%s', file);
    fclose(fID);
end

end

function str = convertToNode(out)
str = '';
fields = fieldnames(out);
for i=1:length(fields)
    
end
end