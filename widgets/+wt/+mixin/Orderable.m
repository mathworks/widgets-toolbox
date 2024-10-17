classdef (HandleCompatible) Orderable
    % Implements functionality for orderable lists


    %% Internal Static methods
    methods (Static, Access = protected)

        function [idxNew, idxSelAfter] = shiftListIndices(shift, numItems, idxSel)
            % Shift the selected indices up/down within a list

            % Define arguments
            arguments (Input)
                % Shift amount and direction (typically 1 or -1)
                shift (1,1) double {mustBeInteger}

                % Total number of items in the list
                numItems (1,1) double {mustBeInteger, mustBeNonnegative}

                % Selected indices to move
                idxSel (1,:) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(idxSel,numItems)}
            end

            arguments (Output)
                % Indices of the complete list after re-ordering
                idxNew (1,:) double {mustBeInteger, mustBePositive}

                % Indices where the selected data end up after the move
                idxSelAfter (1,:) double {mustBeInteger, mustBePositive}
            end

            % Make indices to all items as they are now
            idxNew = 1:numItems;

            % Allocate the final indices
            idxSelAfter = idxSel;

            % Find the last stable item that doesn't move
            [~,idxStable] = setdiff(idxNew, idxSel, 'stable');
            if ~isempty(idxStable)
                idxFirstStable = idxStable(1);
                idxLastStable = idxStable(end);
            else
                idxFirstStable = inf;
                idxLastStable = 0;
            end

            % Which way do we loop?
            if shift > 0 %Shift to end

                for idxToMove = numel(idxSel):-1:1

                    % Calculate if there's room to move this item
                    idxThisBefore = idxSel(idxToMove);
                    thisShift = max( min(idxLastStable-idxThisBefore, shift), 0 );

                    % Where does this item move from/to
                    idxThisAfter = idxThisBefore + thisShift;
                    idxSelAfter(idxToMove) = idxThisAfter;

                    % Where do other items move from/to
                    idxOthersBefore = idxSel(idxToMove)+1:1:idxThisAfter;
                    idxOthersAfter = idxOthersBefore - thisShift;

                    % Move the items
                    idxNew([idxThisAfter idxOthersAfter]) = idxNew([idxThisBefore idxOthersBefore]);

                end

            elseif shift < 0 %Shift to start

                for idxToMove = 1:numel(idxSel)

                    % Calculate if there's room to move this item
                    idxThisBefore = idxSel(idxToMove);
                    thisShift = min( max(idxFirstStable-idxThisBefore, shift), 0 );

                    % Where does this item move from/to
                    idxThisAfter = idxThisBefore + thisShift;
                    idxSelAfter(idxToMove) = idxThisAfter;

                    % Where do other items move from/to
                    idxOthersBefore = idxThisAfter:1:idxSel(idxToMove)-1;
                    idxOthersAfter = idxOthersBefore - thisShift;

                    % Move the items
                    idxNew([idxThisAfter idxOthersAfter]) = idxNew([idxThisBefore idxOthersBefore]);

                end

            end %if shift > 0

        end %function


        function [backEnabled, fwdEnabled] = areOrderButtonsEnabled(numItems, idxSel, allowSortItem)
            % Determine whether back/forward (down/up) buttons should be
            % enabled or not given the selection index

            % Define arguments
            arguments (Input)
                % Total number of items in the list
                numItems (1,1) double {mustBeInteger, mustBeNonnegative}

                % Selected indices
                idxSel (1,:) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(idxSel,numItems)}

                % Indicates whether each individual item may be sorted
                allowSortItem (1,:) logical = true(1, numItems);
            end

            arguments (Output)
                % Should back (up) button be enabled?
                backEnabled (1,1) logical

                % Should forward (down) button be enabled?
                fwdEnabled (1,1) logical
            end

            % How many items selected?
            numSel = numel(idxSel);

            % Only sortable items selected
            selIsSortable = (numSel > 0) && all( allowSortItem(idxSel) );

            % Enable back (up)?
            idxMinSortable = find(allowSortItem,1,"first");
            backEnabled = selIsSortable && (max(idxSel) > (numSel + idxMinSortable - 1) );

            % Enable forward (down)?
            idxMaxSortable = find(allowSortItem,1,"last");
            fwdEnabled  = selIsSortable && (min(idxSel) <= (idxMaxSortable - numSel));

        end %function

    end %methods


end %classdef