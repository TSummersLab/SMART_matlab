function SpheroStopVideo(SpheroState)

rec         = SpheroState.Video.Record; % rec = 'false' or 'true'
vid         = SpheroState.Video.vid;    % Handel to webcam image video
vid2        = SpheroState.Video.vid2;   % Handel to 3D reconstruction plot

% Stop recording
if rec, close(vid); end
if rec, close(vid2); end



































