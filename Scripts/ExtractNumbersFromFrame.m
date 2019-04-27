function [foundNumbers] = ExtractNumbersFromFrame(colorImage)
%EXTRACTNUMBERFROMFRAME Extracts numbers found in a natural image
%   Supplied image must be color

foundNumbers = []; % Initialize output

% Wrap detection around try/catch to ensure any error is skipped rather
% than breaking execution. Unfortunately, there seems to be an error whener
% a single MSER region is found. I believe this is due to the quirk in
% matlab that single element arrays are "automagically" converted to plain
% elements, thus losing some of the indexing capabilities.
try
    %% Step 1 Detect MSER regions.
    I = rgb2gray(colorImage); % Convert to grayscale
    I = imerode(I, ones(4,4)); % Erode image to make stroke wider
    
    imageArea = prod(size(I));
    minimumArea = round(imageArea*0.0002);
    maximumArea = round(imageArea*0.002);
    [mserRegions, mserConnComp] = detectMSERFeatures(I, ... 
        'RegionAreaRange',[minimumArea maximumArea], ...
        'ThresholdDelta',4 ...
    );
    %% Step 2
    % Use regionprops to measure MSER properties
    mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
        'Solidity', 'Extent', 'Euler', 'Image');
    
    % If no regions were found, return prematurely
    if(isempty(mserStats))
        foundNumbers = []; % Ensure output exists
        return
    end
    % Compute the aspect ratio for all regions using bounding box data.
    bbox = vertcat(mserStats.BoundingBox);
    w = bbox(:,3);
    h = bbox(:,4);
    aspectRatio = w./h;

    % Threshold the data to determine which regions to remove. These thresholds
    % may need to be tuned for other images.
    filterIdx = aspectRatio' > 3; 
    filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;

    % Remove regions flagged by thresholds above
    mserStats(filterIdx) = [];
    mserRegions(filterIdx) = [];
    
    % If all regions have been removed, return prematurely
    if(isempty(mserStats))
        foundNumbers = []; % Ensure output exists
        return
    end

    %% Step 3 - Filter region list based on stroke width variation
    % In general, letters/digits then to have uniform stroke width. This is
    % partially true for the font used in the provided images, so the threshold
    % has to be a little higher, which fails to filter some non-text regions.
    % But it still manages to reduce the candidate regions while not removing
    % the target text region

    % Threshold tuned with test images from the provided images. Value is a
    % little higher than the default because the font used for printing the
    % numbers has some variation in stroke width in the curves.
    strokeWidthThreshold = 0.6; 
    strokeWidthFilterIdx = logical(zeros(numel(mserStats)));
    % Process each region, filtering regions in which the stroke with variation
    % is larger than an established threshold
    for j = 1:numel(mserStats)
        % during the stroke width computation.
        regionImage = mserStats(j).Image; % Get a binary image of the a region
        regionImage = padarray(regionImage, [1 1], 0); % Pad it to avoid any boundary effects

        % Calculate a skeleton image representing the "core" of the stroke.
        % Width (and width variation) is then calculated based on the distance
        % between the image region and its equivalent skeleton stroke
        distanceImage = bwdist(~regionImage);
        skeletonImage = bwmorph(regionImage, 'thin', inf);

        % Calculate variation in stroke width within the region
        strokeWidthValues = distanceImage(skeletonImage);
        strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

        % Flag for removal regions with stroke width variation larger than
        % threshold
        strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

    end

    % Remove regions based on the stroke width variation
    mserRegions(strokeWidthFilterIdx) = [];
    mserStats(strokeWidthFilterIdx) = [];

    % If all regions have been removed, return prematurely
    if(isempty(mserStats))
        foundNumbers = []; % Ensure output exists
        return
    end
    
    %% Step 4 - Merge bounding boxes to find contiguous text regions

    % Get bounding boxes for all the regions
    bboxes = vertcat(mserStats.BoundingBox);

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = bboxes(:,1);
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;

    % Expand the bounding boxes by a small amount.
    expansionAmount = 0.05;
    xmin = (1-expansionAmount) * xmin;
    ymin = (1-expansionAmount) * ymin;
    xmax = (1+expansionAmount) * xmax;
    ymax = (1+expansionAmount) * ymax;

    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(I,2));
    ymax = min(ymax, size(I,1));

    % Build bboxes matrix in [xmin ymin xmax ymax] format
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1); 
    overlapRatio(1:n+1:n^2) = 0;

    % Create the graph
    g = graph(overlapRatio);

    % Find the connected text regions within the graph
    componentIndices = conncomp(g);

    % Merge the boxes based on the minimum and maximum dimensions.
    xmin = accumarray(componentIndices', xmin, [], @min);
    ymin = accumarray(componentIndices', ymin, [], @min);
    xmax = accumarray(componentIndices', xmax, [], @max);
    ymax = accumarray(componentIndices', ymax, [], @max);

    % Compose the merged bounding boxes using the [x y width height] format.
    textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

    % Remove bounding boxes that only contain one text region
    numRegionsInGroup = histcounts(componentIndices);
    textBBoxes(numRegionsInGroup == 1, :) = [];


    %% Step 5 - Perform OCR on all boxes

    % Using TextLayout as a hint for OCR routine to look for individual words
    % instead of whole phrases. In the tests this helped identify better the
    % printed numbers. Matlab's OCR function accepts further hints in terms of
    % limiting the character set, after some tests with testing data, it was
    % decided not to use this capability as it didn't change much the true
    % positive, but tended to read as numbers noisy regions in the image. Since
    % the fact of only numbers being expected is used to our advantage in step
    % 6 to filter out noise interpreted as text.
    ocrtxt = ocr(I, textBBoxes, 'TextLayout','Word');
    % [ocrtxt.Text]

    %% Step 6 - Filter OCR results based on known constraints

    % At this stage we should have a reasonable accuracy in terms of finding 
    % candidate text regions and being able to extract text from them via
    % OCR. With the exception of some tuning in the stroke width variation, the
    % previous steps represent a general-use approach to extracting text from
    % natural images. This final stage in the process represents a final tuning
    % based on known constraints of the task at hand. That is, that the text 
    % should be a single integer number

    foundNumbersIdxs = [];
    foundNumbers = [];
    for ocrIdx = 1:size(ocrtxt, 1)
        ocrElem = ocrtxt(ocrIdx);
        
        %  Consider only elements with word confidence above 70%
        if(all(ocrElem.WordConfidences > 0.80))
        
            ocrTxt = ocrElem.Text;
            ocrTxt = strtrim(ocrTxt); % Trim whitespace
            [ocrNums, success] = str2num(ocrTxt); % Convert to number array

            % Even if string parse to number was successful, multiple errors may
            % still happen. The parsed values might not be integers at al, as 
            % matlab does not have parse to int, only parse to number :(. Also, OCR
            % may introduce whitespace between chars or digits, in this case, we 
            % check if array size is larger than 1 and rebuild a single number from 
            % the individual digits
            if (success)
                isInteger = true;
                numberValue = 0;
                for ocrDigitIdx = 1:size(ocrNums, 2)
                    ocrDigit = ocrNums(ocrDigitIdx);
                    isInteger = mod(ocrDigit, 1) == 0;
                    isPositive = ocrDigit >= 0;
                    if (isInteger && isPositive) % Checks if is integer using remainder of division by 1
                        % Shift accumulated number to the left
                        orderOfMagnitude = round(ocrDigit / 10);
                        numberValue = numberValue * (10 * orderOfMagnitude);

                        % Introduces text at least significant places
                        numberValue = numberValue + ocrDigit; 
                    else % Non integer digit found, consider this number as incorrect or "noise"
                        break;
                    end
                end

                % If number is valid, consider it as a found candidate, store in
                % found numbers list alog with index to map to original OCR
                % bounding boxes, if desired
                if (isInteger)
                    foundNumbersIdxs = [foundNumbersIdxs, ocrIdx];
                    foundNumbers = [foundNumbers, numberValue];
                end
            end
        end
    end
catch err
    foundNumbers = []; % Ensure output exists
    warning(err.message); % Repackage error as warning
end

% [foundNumbers]
end

