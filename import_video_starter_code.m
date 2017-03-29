%% READ THE AVI
close all
mov=VideoReader('v4.avi');

FIRST_TIME = 1;


while(hasFrame(mov))
%% Read Frame
video = readFrame(mov);

%% Apply Filter(gaus)
%v_gaus =imgaussfilt(video);
v_gaus = video;
%% Recieve Target
% imshow(v_gaus);
% hold on %%What the keep image up so user can select below
% pause;
% [x,y] = ginput(1); %%Takes users input where the pixel worm is
% hold on
% plot(x,y,'r.','MarkerSize',20) %%Draws redot of where user selected
% close all;

%% Track
%%% Filter out background 

%Might need to edit 68 value
M =(v_gaus <= 68); %%Mask to find worms(got 68 from imtool) 

if(FIRST_TIME == 1)
    max_val = 293;
    row_top = 867;
    row_bot = 946;
    col_left = 1054;
    col_right = 1105;
    Target = M(row_top:row_bot,col_left:col_right);
    FIRST_TIME = 0;
end
    

%the ~ on the M is to make the worms black and the backgorund white
imshow(M) %%Binariezed image(shows worms in black)


imshow(Target);
pause;
close all
end

%%% Code for detecting Point of Interest might be useful
% % % hold on
% % % edges = detectMinEigenFeatures(M(350:420,723:776))
% % % close all;
% % % imshow(M(350:420,723:776))
% % % hold on
% % % plot(edges.selectStrongest(100));
% % % pause
hold on
plot(x,y,'r.','MarkerSize',20) %%Draws redot of where user selected

%%% Counter Finding 
%Need to round numbers for boundarytrace
x = round(x);
y = round(y);
contour = bwtraceboundary(M,[y x],'W',8,Inf,'counterclockwise'); %Note x and y are flipped bc of r and col def
plot(contour(:,2),contour(:,1),'g','LineWidth',2);
% v_new = v_gaus.* uint8(M);
% v_new = 255 - v_new;
% image(v_new);

% imagesc(video)
% colormap(gray)




