%
% Ver 2_4:
%       
%       - Different inupt/outputs to the function
%
% Ver 2_3:
%
%       - Removed errosion and dilation of the blobs
%       - Can return more than 'numRob' number of blobs (does not use area 
%         to choose the best blobs. This will be done by the nearest 
%         neighbor search.)
%
% Ver 2_2:
%
%       - Uses CMYK color detection to detect the Soheros.
%
%
function [centers, bboxes, frame] = Detect_Sphero_Ver2_5(cam, numRob, col, erosion)
%% Grab a frame

if nargin == 3
    erosion = 0;
end

frame = snapshot(cam);    
frame = imresize(frame, [480,640]); % Resize the image
% figure; imshow(frame);

% col = [255 255 255]
% colorVec = double(rgb2cmyk(col)/255);
% colorVec(4) = 0;
% if all(col == [255 0 0])
%     colorVec = [0 0 1 0];
% elseif all(col == [0 0 255])
%     colorVec = [1 0 0 0];
% end

%% Detect Spheros usig color (based on CMYK)

% Map color from RGB to CMYK
frameCMYK = rgb2cmyk(frame);
frameK = 255 - frameCMYK(:,:,4);
if all(col == [255 0 0])
%     frameColor = (frameK./255) .*  frameCMYK(:,:,3);  % Red
    frameColor =  frameCMYK(:,:,3);  % Red
elseif all(col == [0 255 255])
%     frameColor = (frameK./255) .*  frameCMYK(:,:,1);  % Cyan
    frameColor = frameCMYK(:,:,1);  % Cyan
end
% frameColor = zeros(size(frame(:,:,1)));
% for ii = 1 : 4
%     frameColor = frameColor + double(frameCMYK(:,:,ii))* colorVec(ii);  % For red choose M and Y channels
% end
% figure; imshow(frameColor);

thresh = 0.3; % Threshold for binary image

% flag = true;

% Binarize image usign a threshold
M = max(frameColor(:));
frameBin = frameColor >= thresh*M;
% figure; imshow(frameBin);

% Fill Interior Gaps
framefill = imfill(frameBin, 'holes');
% figure; imshow(framefill);

% Erode the image to remove noise
erodeElt = strel('disk',erosion);
frameEr = imerode(framefill,erodeElt);
% figure; imshow(frameEr);
% frameEr = framefill;

% Dilate eroded image
dilateElt = strel('disk',1);
frameDil = imdilate(frameEr, dilateElt);
% figure; imshow(frameDil);

% % Detect large enough blobs
% whiteBlobs = bwpropfilt(frameDil, 'Area', [20, 100000]); % find white blobs
% % figure; imshow(whiteBlobs);

% whiteBlobs = frameEr;
whiteBlobs = frameDil;
% whiteBlobs = framefill;

%%

% Get blob properties
stats = regionprops (logical(whiteBlobs), 'BoundingBox', 'Centroid', 'Area');
nBlob = numel(stats); % Number of blobs 

% Organize data
centers = reshape([stats.Centroid]', 2, nBlob);
bboxes  = reshape([stats.BoundingBox]', 4, nBlob); % format: ULcorner(x,y), x-width, y-width
area    = reshape([stats.Area]', 1, nBlob);

% Check to see if all robots were detected
if (nBlob > numRob) % If more blobs are detected
%     [~,sIdx] = sort(area,'ascend');
%     centers = centers(:,sIdx(1:numRob)); % Choose bloc with largest area
%     bboxes = bboxes(:,sIdx(1:numRob));
    disp('Warning: More blobs detected than spheros.'); 
%     centers, bboxes
%     keyboard;
    return;
end
if (nBlob < numRob) % If less blobs are detected
    disp('Warning: Fewer blobs detected than spheros.');
%     keyboard;
    if nBlob == 0
        centers = NaN;  bboxes = NaN;
        return;
    end
    [centers, bboxes, frame] = Detect_Sphero_Ver2_5(cam, numRob, col, erosion+1);            
%     thresh = thresh / 1.5;
end




end
        
        
 
    
    