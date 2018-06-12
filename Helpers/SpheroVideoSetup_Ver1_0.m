function SpheroState = SpheroVideoSetup_Ver1_0(SpheroState)

rec  = SpheroState.Video.Record;
Name = SpheroState.Video.VideoName;

if rec
    
    frameRate = 10;   % Video frame rate
    vidQuality = 100; % A value between 0 to 100
    
    fileName = strcat(Name,'_cam');
    currentFolder = pwd;
    address =  strcat(currentFolder,'\SavedData\');
    fileType = '.avi';
    fullAddress = strcat(address,fileName,fileType); 
    vid = VideoWriter(fullAddress);
    vid.Quality = vidQuality; 
    vid.FrameRate = frameRate;
    %     set(gcf,'Renderer','zbuffer');
    
    % Raw video
    fileName = strcat(Name,'_raw');
    fullAddress = strcat(address,fileName,fileType);
    vidRaw = VideoWriter(fullAddress);
    vidRaw.Quality = vidQuality;
    vidRaw.FrameRate = frameRate;
    
    %%% 3D reconstruction video
    fileName = strcat(Name,'_reconst');
    fullAddress = strcat(address,fileName,fileType);
    vid2 = VideoWriter(fullAddress);
    vid2.Quality = vidQuality;
    vid2.FrameRate = frameRate;
else
    
    vid = [];
    vidRaw = [];
    vid2 = [];
    
end

SpheroState.Video.vid     = vid;
SpheroState.Video.vidRaw  = vidRaw;
SpheroState.Video.vid2    = vid2;



























































































