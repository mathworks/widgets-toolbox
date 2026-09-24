classdef ThumbnailCache
    % Manages a cache of image thumbnails given a folder or file list

    %% Public properties
    properties (AbortSet)

        % List of files that get converted to thumbnails
        SourceFiles (:,1) string {mustBeFile}

        % Thumbnail size
        DefSize (1,1) double {mustBePositive,mustBeFinite} = 200
    end

    %% Calculated properties
    properties (Dependent = true)
        HighlightColor  % Color of the highlight around the selected image
    end % Calculated properties

    %% Private properties
    properties (SetAccess='private', GetAccess='private')

        % Indicates if each thumbnail is loaded from cache
        IsLoaded (1,:) logical

        %indicates if each thumbnail is queued as a future
        IsQueued (1,:) logical

        ThumbCacheFile char = '';

        ThumbCacheMap (1,1) struct = struct();

        % Timer for background scanning of thumbnails
        ThumbTimer

        % parallel futures for thumbnail creation
        ThumbFutures

        TimerPeriod (1,1) double {mustBePositive,mustBeFinite} = 0.2; %TimerPeriod

        ImagesPerBatch (1,1) double {mustBePositive,mustBeFinite} = 10; %ImagesPerBatch

        UseParallel(1,1) logical = false; %UseParallel

    end % Private properties


    %% Constant properties
    properties (Constant, GetAccess='private')
        PngReadPath = fullfile(matlabroot,'toolbox','matlab','imagesci','private');
    end % Constant properties


    %% Constructor / Destructor
    methods

        function obj = ThumbnailCache(root)

            % Define arguments
            arguments
                root (1,1) string = ""
            end

            % Prep thumbnail caching
            obj.initiateThumbCache();

            % Start timer to update thumbnails
            start(obj.ThumbTimer);

        end % constructor


        function delete(obj)
            % Destroy the ThumbTimer
            if ~isempty(obj.ThumbTimer) && isvalid(obj.ThumbTimer)
                stop(obj.ThumbTimer);
                delete(obj.ThumbTimer);
            end

            % Store the thumbnail map cache file
            thumbMap = obj.ThumbCacheMap;
            save( obj.ThumbCacheFile, '-struct', 'thumbMap' );
        end

    end %constructor/destructor methods


    %% Protected methods
    methods (Access=protected)

        function initiateThumbCache(obj)

            % Define the thumbnail cache
            filename = sprintf('ImageSelectorThumbnails_%d.mat',obj.DefSize);
            obj.ThumbCacheFile = fullfile( tempdir(), filename );

            % Grab the thumbnail map cache file, if one exists
            MakeNewMap = true;
            if exist( obj.ThumbCacheFile, 'file' ) == 2
                thumbMap = load( obj.ThumbCacheFile );
                if isstruct(thumbMap) &&...
                        isfield(thumbMap,'ThumbFile') && isa(thumbMap.ThumbFile,'containers.Map') &&...
                        isfield(thumbMap,'Size') && isa(thumbMap.Size,'containers.Map') &&...
                        isfield(thumbMap,'Date') && isa(thumbMap.Size,'containers.Map')
                    obj.ThumbCacheMap = thumbMap;
                    MakeNewMap = false;
                end
            end
            if MakeNewMap
                obj.ThumbCacheMap = struct(...
                    'ThumbFile', containers.Map('KeyType','char','ValueType','char'),...
                    'Date', containers.Map('KeyType','char','ValueType','double'),...
                    'Size', containers.Map('KeyType','char','ValueType','double') );
            end

            % Create the thumbnail timer, which scans for thumbnails as a
            % periodic background task
            obj.ThumbTimer = timer(...
                'Name', 'ImageSelectorThumbnailUpdateTimer', ...
                'ExecutionMode', 'fixedSpacing', ...
                'BusyMode', 'Drop', ...
                'TimerFcn', @(t,s)getThumbnails(obj,t,s), ...
                'ObjectVisibility', 'off', ...
                'StartDelay', obj.TimerPeriod, ...
                'Period', obj.TimerPeriod);
            %'ErrorFcn', @(h,e)assignin('base','errInfo',e),...

        end


        function getThumbnails( obj, thisTimer, ~ )

            % Check whether construction is complete and there are
            % remaining thumbnails to load
            if obj.IsConstructed && all(obj.IsLoaded)

                % We can stop the timer now - everything is loaded
                stop(thisTimer);

            elseif obj.IsConstructed

                % First, check for any PCT futures that completed
                if ~isempty(obj.ThumbFutures)

                    IsComplete = strcmp({obj.ThumbFutures.State}, 'finished');
                    idxToFetch = find(IsComplete);

                    for idx = 1:numel(idxToFetch)

                        % Get the result
                        [thumbFileName, cdata, srcFileName] = obj.ThumbFutures(idxToFetch(idx)).fetchOutputs();

                        % Match up the index of this image
                        idxThisImage = strcmp( obj.SourceFiles, srcFileName );

                        % Update the thumbnail map
                        if ~isempty(thumbFileName)
                            obj.ThumbCacheMap.ThumbFile(srcFileName) = thumbFileName;
                            obj.IsLoaded(idxThisImage) = true;
                            obj.IsQueued(idxThisImage) = false;
                        end

                        % Store original CData in appdata (for enable/disable)
                        setappdata( obj.h.Images(idxThisImage), 'CData', cdata );

                        % If widget disabled, move color towards background
                        if strcmpi( obj.Enable, 'off' )
                            bgcol = obj.BackgroundColor;
                            cdata(:,:,1) = 0.5*bgcol(1) + 0.5*cdata(:,:,1);
                            cdata(:,:,2) = 0.5*bgcol(2) + 0.5*cdata(:,:,2);
                            cdata(:,:,3) = 0.5*bgcol(3) + 0.5*cdata(:,:,3);
                        end

                        % Update the image cdata to display it
                        set( obj.h.Images(idxThisImage), 'CData', cdata );

                    end %for idx = 1:numel(idxToFetch)

                    % Remove these futures
                    delete( obj.ThumbFutures(IsComplete) );
                    obj.ThumbFutures(IsComplete) = [];

                end %if ~isempty(obj.ThumbFutures)

                % Which next N number of thumbnails should be loaded?
                NumThisBatch = obj.ImagesPerBatch - sum(obj.IsQueued);
                if NumThisBatch <= 0
                    return
                end
                CheckToLoad = ~obj.IsLoaded & ~obj.IsQueued;
                idxToLoad = find(CheckToLoad, NumThisBatch);

                % Quickest way to load existing PNG thumbnails is to call the
                % mex file pngreadc directly. But we need to cd to the private
                % folder to be able to call it.
                currentDir = pwd;
                cd(obj.PngReadPath);

                % Are any of these thumbnails cached already?
                IsCached = false(size(idxToLoad));
                for idx = 1:numel(idxToLoad)

                    ii = idxToLoad(idx);
                    srcFileName = obj.SourceFiles{ii};

                    % Confirm date and size
                    fInfo = dir(srcFileName);
                    if isscalar(fInfo)
                        srcFileSize = fInfo.bytes;
                        srcFileDate = fInfo.datenum;
                    else
                        warning('Unable to scan thumbnail image: %s',srcFileName);
                        srcFileSize = 0;
                        srcFileDate = 0;
                    end

                    % Is it cached?
                    IsCached(idx) = ( ...
                        obj.ThumbCacheMap.ThumbFile.isKey(srcFileName) &&...
                        exist(obj.ThumbCacheMap.ThumbFile(srcFileName),'file')==2 &&...
                        obj.ThumbCacheMap.Size(srcFileName) == srcFileSize &&...
                        obj.ThumbCacheMap.Date(srcFileName) == srcFileDate );

                    % Depending on cache, we load or create it
                    if IsCached(idx)

                        % Load an existing thumbnail
                        thumbname = obj.ThumbCacheMap.ThumbFile(obj.SourceFiles{ii});

                        % Load the thumbnail cache. Use internal mex file pngreadc
                        % for speed, since we know the format.
                        cdata = pngreadc(thumbname, [], false);
                        cdata = permute(cdata, ndims(cdata):-1:1);
                        obj.IsLoaded(ii) = true;

                        % Store original CData in appdata (for enable/disable)
                        setappdata( obj.h.Images(ii), 'CData', cdata );

                        % If widget disabled, move color towards background
                        if strcmpi( obj.Enable, 'off' )
                            bgcol = obj.BackgroundColor;
                            cdata(:,:,1) = 0.5*bgcol(1) + 0.5*cdata(:,:,1);
                            cdata(:,:,2) = 0.5*bgcol(2) + 0.5*cdata(:,:,2);
                            cdata(:,:,3) = 0.5*bgcol(3) + 0.5*cdata(:,:,3);
                        end

                        % Update the image cdata to display it
                        set( obj.h.Images(ii), 'CData', cdata );

                    else
                        % If not cached yet, we will cache it but we also
                        % need to store the source file's size and date to
                        % check if it changes later
                        obj.ThumbCacheMap.Size(srcFileName) = srcFileSize;
                        obj.ThumbCacheMap.Date(srcFileName) = srcFileDate;

                    end %if IsCached(idx)

                end %for ii = idxToLoad

                % Navigate back to the user's current directory
                cd(currentDir);

                % Do we need to create thumbnails from this set?
                if any(~IsCached)

                    % Which ones should be created?
                    idxToCreate = idxToLoad(~IsCached);

                    % Can we use PCT?
                    if obj.UseParallel

                        % Use parfeval to create thumbnails as background tasks
                        for idx = 1:numel(idxToCreate)
                            srcFileName = obj.SourceFiles{idxToCreate(idx)};
                            if isempty(obj.ThumbFutures)
                                obj.ThumbFutures = parfeval(@uiw.utility.createThumbnail, 3, srcFileName, obj.DefSize);
                            else
                                obj.ThumbFutures(end+1) = parfeval(@uiw.utility.createThumbnail, 3, srcFileName, obj.DefSize);
                            end
                        end

                        % Mark them as queued in a future
                        obj.IsQueued(idxToCreate) = true;

                    else

                        % NO - create just one thumbnail now in this timer loop
                        idx = 1;
                        ii = idxToCreate(idx);
                        srcFileName = obj.SourceFiles{idxToCreate(idx)};

                        % Create the thumbnail
                        try
                            [thumbFileName, cdata] = uiw.utility.createThumbnail( srcFileName, obj.DefSize );
                        catch err
                            obj.IsLoaded(ii) = true;
                            warning('ImageSelector:createThumbnailError',...
                                'Unable to create thumbnail for ''%s''. Error: %s',...
                                srcFileName, err.message);
                            return
                        end

                        % Update the thumbnail map
                        if ~isempty(thumbFileName) && isscalar(fInfo)
                            obj.ThumbCacheMap.ThumbFile(srcFileName) = thumbFileName;
                            obj.IsLoaded(ii) = true;
                        end

                        % Store original CData in appdata (for enable/disable)
                        setappdata( obj.h.Images(ii), 'CData', cdata );

                        % If widget disabled, move color towards background
                        if strcmpi( obj.Enable, 'off' )
                            bgcol = obj.BackgroundColor;
                            cdata(:,:,1) = 0.5*bgcol(1) + 0.5*cdata(:,:,1);
                            cdata(:,:,2) = 0.5*bgcol(2) + 0.5*cdata(:,:,2);
                            cdata(:,:,3) = 0.5*bgcol(3) + 0.5*cdata(:,:,3);
                        end

                        % Update the image cdata to display it
                        set( obj.h.Images(ii), 'CData', cdata );

                    end %if obj.UseParallel

                end %if any(~IsCached)

            end %if obj.IsConstructed && ~all(obj.IsLoaded)

        end % getThumbnails

    end % Protected methods



    %% Private methods
    methods (Access='private')



        function addImage( obj, filename, caption )
            %addImage: add a new image to the list
            %
            %   obj.addImage(FILENAME,CAPTION)
            if nargin<3
                caption = repmat("",size(filename));
            end
            numAdds = numel(filename);

            % For blank thumbnails
            cdata(obj.DefSize, obj.DefSize, 3) = uint8(0);

            % Note the new indices that will need thumbnails
            idxThumbnails = numel(obj.h.Images) + (1:numAdds);

            % Get the state of files and captions
            imageFiles = obj.SourceFiles;
            captions = obj.Captions;

            % Append items to lists, and create the UI components
            for ii=1:numAdds

                % Get the index of the next image
                idx = idxThumbnails(ii);

                % Append the image and caption to the list, if not already
                % done
                if numel(imageFiles)<idx || isempty(imageFiles{idx})
                    imageFiles{idx} = filename{ii};
                end
                if numel(captions)<idx || isempty(captions{idx})
                    captions{idx} = caption{ii};
                end

                % Mark the image as not cached or queued yet
                obj.IsLoaded(idx) = false;
                obj.IsQueued(idx) = false;

                % Create the components for displaying the image
                if numel(obj.h.Images)<idx || ~ishandle(obj.h.Images(idx))

                    % Create the UI components
                    obj.h.Images(idx) = image( nan, ...
                        'Parent', obj.h.Axes, ...
                        'CData', cdata, ...
                        'Tag', 'uiw:widget:ImageSelector:Image', ...
                        'UIContextMenu', obj.UIContextMenu, ...
                        'ButtonDownFcn', @obj.onClicked );
                    obj.h.Texts(idx) = text( 0, 0, cellstr(caption), ...
                        'Parent', obj.h.Axes, ...
                        'HorizontalAlignment', 'Center', ...
                        'VerticalAlignment', 'Top', ...
                        'BackgroundColor','none',...
                        'Interpreter', 'none', ...
                        'Clipping', 'on', ...
                        'UIContextMenu', obj.UIContextMenu, ...
                        'Tag', 'uiw:widget:ImageSelector:CaptionText' );

                    % Store original CData in appdata (for enable/disable)
                    setappdata( obj.h.Images(idx), 'CData', cdata );

                end %if numel(obj.h.Images)<idx || ~ishandle(obj.h.Images(idx))

            end %for ii=1:numAdds

            % Set the state of files and captions
            obj.SourceFiles = imageFiles;
            obj.Captions = captions;

            % Redo the sizing
            obj.onResized();

            % Start timer to update thumbnails
            if obj.IsConstructed
                IsTimerRunning = strcmpi(obj.ThumbTimer.Running, 'on');
                if ~IsTimerRunning
                    start(obj.ThumbTimer);
                end
            end

        end % addImage


        function obj = clearImages( obj, filenames )
            %clearImages: remove one or more images from the list
            %
            %   THIS = CLEARICONS(THIS) removes all icons from the list
            %
            %   THIS = CLEARICONS(THIS,FILENAMES) removes the specified icons from the
            %   list, where FILENAMES is a string or a cell array of strings.
            if nargin<2
                filenames = obj.SourceFiles;
            else
                if ischar(filenames)
                    filenames = {filenames};
                end
            end

            % Stop the timer
            IsTimerRunning = false;
            if obj.IsConstructed
                IsTimerRunning = strcmpi(obj.ThumbTimer.Running, 'on');
                if IsTimerRunning
                    stop(obj.ThumbTimer);
                    wait(obj.ThumbTimer);
                end
            end

            % Find those on our list that are specified
            obj.SourceFiles = setdiff( obj.SourceFiles, filenames );
            % set method for SourceFiles does cleanup

            % Update and redraw
            obj.onResized();

            % Restart timer to update thumbnails
            if obj.IsConstructed && IsTimerRunning
                start(obj.ThumbTimer);
            end

        end % clearImages

    end % Private methods



    %% Data access methods
    methods

        function set.SourceFiles(obj,names)
            % Find those on our list that are no longer required

            % Which ones should be removed?
            toremove = ~iStrIsMember(obj.SourceFiles,names);

            %obj.pRemoveWidgets( toremove );

            % Clear the arrays
            obj.SourceFiles(toremove) = [];
            %obj.Captions(toremove) = []; %#ok<MCSUP>
            obj.IsLoaded(toremove) = []; %#ok<MCSUP>
            obj.IsQueued(toremove) = []; %#ok<MCSUP>

            % Now add the new ones
            toadd = ~iStrIsMember( names, obj.SourceFiles );
            obj.SourceFiles = horzcat(obj.SourceFiles, names(toadd));
            obj.addImage( names(toadd) );

        end % set.SourceFiles


    end % Data access methods


end % classdef



%% Now some helper functions

%-------------------------------------------------------------------------%
function tf = iStrIsMember( strsToLookFor, strSet )
% This is faster than ismember
n = numel(strsToLookFor);
tf = false(size(strsToLookFor));
for idx=1:n
    tf(idx) = any(strcmp(strsToLookFor{idx},strSet));
end
end %iStrIsMember

%-------------------------------------------------------------------------%
function tf = iIsEqualMember( itemsToLookFor, fullSet )
% This is faster than ismember
n = numel(itemsToLookFor);
tf = false(size(itemsToLookFor));
for idx=1:n
    tf(idx) = any(itemsToLookFor(idx) == fullSet);
end
end %iIsEqualMember