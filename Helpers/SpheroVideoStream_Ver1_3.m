function SpheroState = SpheroVideoStream_Ver1_3(iitr, SpheroState, CameraParam)

PosWorld    = SpheroState.PosWorld;     % Positions in world coordinate frame
PosPixel    = SpheroState.PosPixel;     % Positions in pixels
PosKalm     = SpheroState.PosKalm;      % Position of robots from Kalman filter(in world frame)
ThtKalm     = SpheroState.ThtKalm;      % Estimated headings from Kalman filter
MotionIndex = SpheroState.MotionIndex;  % Index to identify motion
ThtEst      = SpheroState.ThtEst;       % Estimated heading
ThtCtrl     = SpheroState.ThtCtrl;      % Control direction
Bboxes      = SpheroState.Bboxes;       % Bounding boxes
Frames      = SpheroState.Video.Frames; % Webcam images
InitFrames  = SpheroState.Video.InitFrames; % Initial images
numRob      = SpheroState.numRob;       % Number of robots
numItr      = SpheroState.numItr;       % Number of iterations

rec         = SpheroState.Video.Record; % rec = 'false' or 'true'
vid         = SpheroState.Video.vid;    % Handel to webcam image video
vid2        = SpheroState.Video.vid2;   % Handel to 3D reconstruction plot

Rot         = CameraParam.Rot;          % Rotation between image and world frames   
Tran        = CameraParam.Tran;         % Translation between image and world frames

%% Plot parameters

showHead    = true;     % Show heading vector in 3D reeconstruction plot
showCtrl    = true;     % Show control vector in 3D reeconstruction plot
tagFontSize = 20;       % Font size for tags shown in 3D recons. plot
ballSize    = 200;      % size of sphere in 3D recons. plot
arrowSize   = 100;      % size of aroow in 3D recons. plot
viewMat     = [0, 90];  % View direction for 3D recons plot


%% Display webcam image    

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if (iitr == 1)   % First iteration
%     
% if rec, open(vid); end
% 
% hdlImageFig   = figure;
% hdlImageAx    = gca; 
% 
% % axes(hdlImageAx);
% 
% frame  = InitFrames{end};
% hdlImg = imshow(frame);
% 
% % Adjust figure position
% position = hdlImageFig.Position;
% hdlImageFig.Position = [20, 50, position(3:4)];  
% 
% hold on;
% hdlScat = scatter(PosPixel(1,:,iitr) ,PosPixel(2,:,iitr), 'filled', 'LineWidth', 2); % display center on image
% 
% hdlRect = gobjects(numRob,1); % Initialize array for graphics object handels
% hdlTxt  = gobjects(numRob,1); 
% for j = 1 : numRob
%     hdlRect(j) = rectangle('Position',Bboxes(:,j,iitr),'LineWidth',1,'EdgeColor',[0 0 1]);
%     hdlTxt(j)  = text(PosPixel(1,j,iitr),PosPixel(2,j,iitr), ['   ',num2str(j)], ...
%         'FontSize',13, 'Color', [1 1 1]);
% end
% hold off;
% 
% SpheroState.Video.hdlImageFig   = hdlImageFig;
% SpheroState.Video.hdlImageAx    = hdlImageAx;
% SpheroState.Video.hdlImg        = hdlImg;
% SpheroState.Video.hdlScat       = hdlScat;
% SpheroState.Video.hdlRect       = hdlRect;
% SpheroState.Video.hdlTxt        = hdlTxt;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% else    % Update figure in the next iterations
% 
% hdlImageFig   = SpheroState.Video.hdlImageFig;
% hdlImg        = SpheroState.Video.hdlImg;
% hdlScat       = SpheroState.Video.hdlScat;
% hdlRect       = SpheroState.Video.hdlRect;
% hdlTxt        = SpheroState.Video.hdlTxt;
% 
% frame = Frames{iitr};
% 
% hdlImg.CData = frame;  % Update image
% view(0,90);
% 
% % Scatter plot
% hdlScat.XData = PosPixel(1,:,iitr);
% hdlScat.YData = PosPixel(2,:,iitr);
% 
% for j = 1 : numRob
%     % Bounding boxes
%     hdlRect(j).Position = Bboxes(:,j,iitr);
%     % Text
%     hdlTxt(j).Position = [PosPixel(1,j,iitr),PosPixel(2,j,iitr),0];
%     hdlTxt(j).String   =  strcat(['   ',num2str(j)]);
% end
% 
% SpheroState.Video.hdlImg        = hdlImg;
% SpheroState.Video.hdlScat       = hdlScat;
% SpheroState.Video.hdlRect       = hdlRect;
% SpheroState.Video.hdlTxt        = hdlTxt;
% 
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% drawnow;
% 
% if rec, writeVideo(vid, getframe(hdlImageFig)); end % Record video


%% Plot 3D reconstruction 

pos = PosWorld(:,:,iitr);                           % Current positions    
H = [cosd(ThtEst(iitr,:));  sind(ThtEst(iitr,:))];  % Heading vectors
C = [cosd(ThtCtrl(iitr,:)); sind(ThtCtrl(iitr,:))]; % Control vectors


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (iitr == 1)   

if rec, open(vid2); end

hdlReconstFig   = figure;
hdlReconstAx    = gca;

sct_H = gobjects(numRob,1); % Initialize array for graphics object handels
num_H = gobjects(numRob,1);
hed_H = gobjects(numRob,1);
ctr_H = gobjects(numRob,1);
                
% Plot points
% axes(hdlReconstAx);    
hold on;
for j = 1 : numRob
    sct_H(j) = scatter3(pos(1,j),pos(2,j),0,ballSize,'fill');
    num_H(j) = text(pos(1,j),pos(2,j),0,['  ',num2str(j)], 'FontSize', tagFontSize);
end

% Plot camera
plotCamera('Location',-Tran.'*Rot,'Orientation',Rot,'Opacity',0, 'Size', 50);
hold off;
ax_h = gca;
view(viewMat);
axis equal
grid on
% set(gca,'CameraUpVector',[0 0 -1]);
% camorbit(gca,110,60);
xlabel('x (mm)');
ylabel('y (mm)');
zlabel('z (mm)');

% Heading arrows
if showHead
    Vh = H .* arrowSize;
    hold on
    for j = 1 : numRob
        % Red color for heading
        hed_H(j) = plot3([pos(1,j);pos(1,j)+Vh(1,j)], [pos(2,j);pos(2,j)+Vh(2,j)], [0;0], ...
            'Color', [0.9 0.0 0.0], 'LineWidth', 3);
    end
    hold off
end
        
% Control arrows
if showCtrl
    Vc = C .* arrowSize*0.5;
    hold on
    for j = 1 : numRob
        % Blue color for control
        ctr_H(j) = plot3([pos(1,j);pos(1,j)+Vc(1,j)], [pos(2,j);pos(2,j)+Vc(2,j)], [0;0], ...
            'Color', [0.0 0.0 0.9], 'LineWidth', 3);
    end
    hold off
end

% Adjust figure position
position = hdlReconstFig.Position;
hdlReconstFig.Position = [800, 50, position(3:4)];  

SpheroState.Video.hdlReconstFig   = hdlReconstFig;
SpheroState.Video.hdlReconstAx    = hdlReconstAx;
SpheroState.Video.ax_h            = ax_h;
SpheroState.Video.sct_H           = sct_H;
SpheroState.Video.num_H           = num_H;
SpheroState.Video.hed_H           = hed_H;
SpheroState.Video.ctr_H           = ctr_H;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else    
hdlReconstFig   = SpheroState.Video.hdlReconstFig;
hdlReconstAx    = SpheroState.Video.hdlReconstAx;
ax_h            = SpheroState.Video.ax_h;
sct_H           = SpheroState.Video.sct_H;
num_H           = SpheroState.Video.num_H;
hed_H           = SpheroState.Video.hed_H;
ctr_H           = SpheroState.Video.ctr_H;

for j = 1 : numRob % Update handels
    sct_H(j).XData = pos(1,j);
    sct_H(j).YData = pos(2,j);
    num_H(j).Position = [pos(1,j),pos(2,j),0];
    ax_h.View = viewMat;
    if showHead
%                 if itr == 15, keyboard, end
        Vh = H .* arrowSize;
        hed_H(j).XData = [pos(1,j);pos(1,j)+Vh(1,j)];
        hed_H(j).YData = [pos(2,j);pos(2,j)+Vh(2,j)];
    end
    if showCtrl
        Vc = C .* arrowSize*0.5;
        ctr_H(j).XData = [pos(1,j);pos(1,j)+Vc(1,j)];
        ctr_H(j).YData = [pos(2,j);pos(2,j)+Vc(2,j)];
    end
end

SpheroState.Video.hdlReconstFig   = hdlReconstFig;
SpheroState.Video.hdlReconstAx    = hdlReconstAx;
SpheroState.Video.ax_h            = ax_h;
SpheroState.Video.sct_H           = sct_H;
SpheroState.Video.num_H           = num_H;
SpheroState.Video.hed_H           = hed_H;
SpheroState.Video.ctr_H           = ctr_H;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


drawnow;
if rec, writeVideo(vid2, getframe(hdlReconstFig));  end % Record video
    
% keyboard;


%%
% 
% if iitr == numItr*numRobLocal
%     % Stop recording
%     if rec, close(SpheroState.Video.vid); end
%     if rec, close(SpheroState.Video.vid2); end
% end































































































