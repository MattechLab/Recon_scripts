function replace_var_tag(oldTag, newTag)
oldTag = '_bern_';
newTag = '_chuv_';

vList = who(['*' oldTag '*']);          % all variables that contain the tag
if isempty(vList)
    warning('No variables with "%s" found.', oldTag);
else
    for k = 1:numel(vList)
        oldName = vList{k};
        newName = strrep(oldName, oldTag, newTag);

        % copy data to the new variable name
        assignin('base', newName, evalin('base', oldName));

        % remove the old variable
        evalin('base', ['clear ' oldName]);

        fprintf('Renamed  %s  →  %s\n', oldName, newName);
    end
    fprintf('Done. Renamed %d variables.\n', numel(vList));
end