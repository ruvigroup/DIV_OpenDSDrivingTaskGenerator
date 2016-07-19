function a = addStructIntoStructArray(a)

% To add one struct add the end of the input struct array
if isstruct(a)
    C = reshape(fieldnames(a), 1, []); %// Field names
    C(2, :) = {[]};                    %// Empty values
    b = struct(C{:});
    a =[a,b];
end

end