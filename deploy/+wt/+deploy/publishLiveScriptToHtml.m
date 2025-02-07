function publishLiveScriptToHtml(srcFiles,dstFolder)
% Publish each *.mlx file from doc_input into doc as html

arguments
    srcFiles (:,1) string {mustBeFile}
    dstFolder (1,1) string {mustBeFolder} = fullfile(pwd,"html_output")
end

% Loop on source files
for idx = 1:numel(srcFiles)

    % Get thie current source file
    thisSrcFile = srcFiles(idx);
    [~,srcFileName,srcFileExt] = fileparts(thisSrcFile);

    % Must be .mlx format. Otherwise skip it.
    if matches(srcFileExt,".mlx")

        % Get the destination file
        thisDstFile = fullfile(dstFolder, srcFileName + ".html");

        % Get the timestamp on both
        srcFileInfo = dir(thisSrcFile);
        dstFileInfo = dir(thisDstFile);

        % If the output file does not already exist or is older, proceed
        if isempty(dstFileInfo) || dstFileInfo.datenum < srcFileInfo.datenum

            % Display a message
            fprintf('Publishing %s\n', thisDstFile);

            % Publish it
            % matlab.internal.liveeditor.openAndConvert(...
            %     char(thisSrcFile), thisDstFile);
            export(thisSrcFile, thisDstFile)

        end %if

    end %if

end %for