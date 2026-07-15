classdef (HandleCompatible) Orderable
    % Implements functionality for orderable lists

    % Copyright 2025 The MathWorks Inc.


    %% Internal Static methods
    methods (Static, Access = protected)

        function [idxNew, idxSelAfter] = shiftListIndices(shift, numItems, idxSel)
            % shiftListIndices  Move selected item indices within 1:numItems and report new indices
            %
            % [idxNew, idxSelAfter] = shiftListIndices(shift, numItems, idxSel)
            %
            % Inputs
            %   shift     - integer shift (positive -> down/increase index, negative -> up/decrease)
            %               use +Inf to move to bottom, -Inf to move to top
            %   numItems  - total number of items (positive integer)
            %   idxSel    - vector of selected indices (1-based). May be unsorted; duplicates ignored.
            %
            % Outputs
            %   idxNew       - permutation vector 1:numItems after applying the move
            %   idxSelAfter  - vector of same length/order as unique(idxSel) input, giving the
            %                  positions (indices into idxNew) where each originally selected item now sits
            %
            % Notes
            %   - Preserves relative order of selected items and of remaining items.
            %   - Non-contiguous selections are supported.
            %   - Selections outside 1:numItems are ignored.

            arguments
                shift {mustBeNumeric}
                numItems (1,1) {mustBeInteger, mustBePositive}
                idxSel (:,1) {mustBeNumeric} = []
            end

            % Normalize selection: keep original order of unique entries
            idxSelOrig = idxSel(:).';
            if isempty(idxSelOrig)
                idxNew = 1:numItems;
                idxSelAfter = zeros(size(idxSelOrig));
                return
            end
            % Unique while preserving first-occurrence order:
            [~, ia] = unique(idxSelOrig, 'stable');
            idxSelOrig = idxSelOrig(sort(ia));   % now unique in original order

            % Clamp to valid range
            idxSelOrig = idxSelOrig(idxSelOrig >= 1 & idxSelOrig <= numItems);
            if isempty(idxSelOrig)
                idxNew = 1:numItems;
                idxSelAfter = zeros(size(idxSelOrig));
                return
            end
            if numel(idxSelOrig) == numItems
                idxNew = 1:numItems;
                idxSelAfter = (1:numItems);
                return
            end

            % Quick handle infinities
            if isinf(shift)
                if shift > 0
                    idxNew = [setdiff(1:numItems, idxSelOrig, 'stable'), idxSelOrig];
                else
                    idxNew = [idxSelOrig, setdiff(1:numItems, idxSelOrig, 'stable')];
                end
                % positions of original selected items in idxNew
                % For each original selected item, find its index in idxNew
                idxSelAfter = arrayfun(@(x) find(idxNew==x,1,'first'), idxSelOrig);
                return
            end

            k = round(shift);

            % Work with sorted selection for deterministic placement logic, but track originals
            selSorted = unique(idxSelOrig);  % ascending order
            % numSel = numel(selSorted);

            % Compute desired target positions for each selected item (clamped)
            targets = min(max(selSorted + k, 1), numItems);

            % Prepare result vector and occupancy map
            res = nan(1, numItems);
            occupied = false(1, numItems);

            % Determine assignment order to resolve collisions consistent with shift direction
            if k >= 0
                % for nonnegative shift, assign in increasing target order (tie-break by original index)
                [~, ord] = sortrows([targets(:), selSorted(:)]);
            else
                % for negative shift, assign in decreasing target order
                [~, ord] = sortrows([-targets(:), -selSorted(:)]);
            end
            ord = ord.';  % make row vector of indices into selSorted

            % Assign selected items to nearest available slot in shift direction
            for ii = ord
                t = targets(ii);
                if k >= 0
                    % first free position >= t
                    posRel = find(~occupied(t:end), 1, 'first');
                    if isempty(posRel)
                        % place at last free slot
                        p = find(~occupied, 1, 'last');
                        assignPos = p;
                    else
                        assignPos = t + posRel - 1;
                    end
                else
                    % last free position <= t
                    pos = find(~occupied(1:t), 1, 'last');
                    if isempty(pos)
                        p = find(~occupied, 1, 'first');
                        assignPos = p;
                    else
                        assignPos = pos;
                    end
                end
                res(assignPos) = selSorted(ii);
                occupied(assignPos) = true;
            end

            % Fill remaining slots with non-selected items in original order
            remItems = setdiff(1:numItems, selSorted, 'stable');
            remPtr = 1;
            for p = 1:numItems
                if isnan(res(p))
                    res(p) = remItems(remPtr);
                    remPtr = remPtr + 1;
                end
            end

            idxNew = res;

            % Map original selected items (in the order provided) to their new positions
            % Note: if input had duplicates or out-of-range entries removed earlier, idxSelOrig reflects uniques in-range
            idxSelAfter = arrayfun(@(x) find(idxNew==x,1,'first'), idxSelOrig);

        end



        function [backEnabled, fwdEnabled] = areOrderButtonsEnabled(numItems, idxSel, allowSortItem)
            % Determine whether back/forward (down/up) buttons should be
            % enabled or not given the selection index

            % Define arguments
            arguments %(Input)
                % Total number of items in the list
                numItems (1,1) double {mustBeInteger, mustBeNonnegative}

                % Selected indices
                idxSel (1,:) double {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(idxSel,numItems)}

                % Indicates whether each individual item may be sorted
                allowSortItem (1,:) logical = true(1, numItems);
            end

            % arguments (Output)
            %     % Should back (up) button be enabled?
            %     backEnabled (1,1) logical
            %
            %     % Should forward (down) button be enabled?
            %     fwdEnabled (1,1) logical
            % end

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