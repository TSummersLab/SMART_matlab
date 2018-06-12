function [pos, bboxes, InitFrames] = Detect_Sphero_Initial_Ver2_5(cam, sph, numRob, col)

% Preallocation of variables
b = [   0,    0,    0 ]; % Black == off

pos = zeros(2, numRob);
bboxes = zeros(4, numRob);
InitFrames = cell(numRob,1);

% Turn off all LEDs
for i = 1 : numRob    
    sph{i}.Color = b; 
end
pause(1);

% colorVec = rgb2cmyk(col/255);
% colorVec = double( rgb2cmyk(col) ./ 255 );
% colorVec(4) = 0;
% if all(col == [255 0 0])
%     colorVec = [0 0 1 0];
% elseif all(col == [0 255 255])
%     colorVec = [1 0 0 0];
% end

for i = 1 : numRob    
    % Grab a frame with i-th sphero ON
    sph{i}.Color = col;
    pause(1);
    
    frame = snapshot(cam); % Grab a frame 
    frame = imresize(frame, [480,640]);
    InitFrames{i} = frame;
    %figure; imshow(frame);
    
    %% Detect Sphero usig color (based on CMYK)

    % Map color from RGB to CMYK
    frameCMYK = rgb2cmyk(frame);     
    frameK = 255 - frameCMYK(:,:,4);
    if all(col == [255 0 0])
        frameColor = (frameK./255) .*  frameCMYK(:,:,3);  % Red
    elseif all(col == [0 255 255])
        frameColor = (frameK./255) .*  frameCMYK(:,:,1);  % Cyan
    end
    
%     frameColor = zeros(size(frame(:,:,1)));
%     for ii = 1 : 4
%         frameColor = frameColor + double(frameCMYK(:,:,ii))* colorVec(ii);  % For red choose M and Y channels
%     end
%     figure; imshow(frameColor);

    thresh = 0.3; % Threshold for binary image

    % Binarize image usign a threshold
    M = max(frameColor(:));
    frameBin = frameColor >= thresh*M;
%     figure; imshow(frameBin);

    % Fill Interior Gaps
    framefill = imfill(frameBin, 'holes');
    % figure; imshow(framefill);

    % Erode the image to remove noise
    % erodeElt = strel('disk',0);
    % frameEr = imerode(framefill,erodeElt);
    % figure; imshow(frameEr);
    frameEr = framefill;

    % Dilate eroded image
    dilateElt = strel('disk',1);
    frameDil = imdilate(frameEr, dilateElt);
    % figure; imshow(frameDil);
% 
%     % Detect large enough blobs
%     whiteBlobs = bwpropfilt(frameDil, 'Area', [20, 100000]); % find white blobs
% %     figure; imshow(whiteBlobs);

    whiteBlobs = frameDil;
%     whiteBlobs = framefill;

    %%  Get blob properties

    stats = regionprops (logical(whiteBlobs), 'BoundingBox', 'Centroid', 'Area');
    nBlob = numel(stats); % Number of blobs 
    
    % Organize data
    center = reshape([stats.Centroid]', 2, nBlob);
    bbox = reshape([stats.BoundingBox]', 4, nBlob); % format: ULcorner(x,y), x-width, y-width
    area = reshape([stats.Area]', 1, nBlob);

    % Check to see if a robot is detected
    if nBlob == 1
        pos(:,i) = center(:,1);
        bboxes(:,i) = bbox(:,1);
        sph{i}.Color = b; % Turn off LEDs of one Sphero
        continue;
    end
    if nBlob > 1 % If more than one blob is detected 
        [~,sIdx] = sort(area,'ascend');
        pos(:,i) = center(:,sIdx(1)); % Choose bloc with largest area
        bboxes(:,i) = bbox(:,sIdx(1));
        disp('Warning: More than one blob detected.'); % keyboard;
        sph{i}.Color = b; % Turn off LEDs of one Sphero
        continue;
    end
    if nBlob < 1 % If less blobs are detected
        disp('Error: No blob detected.');
        keyboard;
    end 
end

% Turn on all LEDs
for i = 1 : numRob    
    sph{i}.Color = col; 
end
pause(1);


































end













