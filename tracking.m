%% READ THE AVI
close all
%load('v4_dataset.mat');
frames = size(v4_dataset);
frames = frames(3);

minTime = 0;
now = 0;

%%% X is Column and Y is ROW
FIRST_TIME = 1;
SUM_TARGET = 0;
BOX_RANGE = 50;
CENTER_ROW = 0;
CENTER_COL = 0;
TARGET_RANGE = 40;
CONV_BOX_BUF = 10;
gaus_windo = fspecial('gaussian',(BOX_RANGE*2)+1,25);
gaus_windo = gaus_windo/max(max(gaus_windo));
equal_windo = ones((BOX_RANGE*2)+1);
weight = equal_windo;
%gaus_windo = ones(121);
Centers_found_X = zeros(1,frames);
Centers_found_Y = zeros(1,frames);
%Frame_out(frames) = struct();
used = 0;

i = 1;

while(i <= frames)
close all;  
%Timing Stuff

% tstart = tic;    
%% Read Frame
video = v4_dataset(:,:,i);


%% Apply Filter(gaus)

%% Track
%%% Filter out background 

%Might need to edit 68 value
M =(video <= 68); %%Mask to find worms(got 68 from imtool) 
M = double(M); %% NEEDS TO BE A DOUBLE FOR CONV


if(FIRST_TIME == 1)
%% Recieve Target
    imshow(~M);
    hold on %%What the keep image up so user can select below
    pause;
    [x,y] = ginput(1); %%Takes users input where the pixel worm is
    x = uint32(x);
    y = uint32(y);
    hold on
    plot(x,y,'r.','MarkerSize',20) %%Draws redot of where user selected
    row_top = y - TARGET_RANGE;
    row_bot = y + TARGET_RANGE;
    col_left = x - TARGET_RANGE;
    col_right = x + TARGET_RANGE;
    
% % %  max_val = 293;
% % %  row_top = 867;
% % %  row_bot = 946;
% % %  col_left = 1054;
% % %  col_right = 1105;
    Target1 = M(row_top:row_bot,col_left:col_right);
    Target2 = Target1';
    Target3 = flip(Target1);
    Target4 = flip(Target2);
%     hold off
%     figure
%     imshow(Target1);
%     figure
%     imshow(Target2);
%     
%     pause;
    %%% X is Column and Y is ROW
    CENTER_ROW = y;
    CENTER_COL = x;
    
    BOX_ROW_TOP =  CENTER_ROW - BOX_RANGE;
    BOX_ROW_BOTTOM = CENTER_ROW + BOX_RANGE;

    BOX_COL_LEFT = CENTER_COL - BOX_RANGE;
    BOX_COL_RIGHT = CENTER_COL + BOX_RANGE;
 % _------------------------------------%   
    CONV_ROW_TOP =  BOX_ROW_TOP - CONV_BOX_BUF;
    CONV_ROW_BOTTOM = BOX_ROW_BOTTOM + CONV_BOX_BUF;

    CONV_COL_LEFT = BOX_COL_LEFT - CONV_BOX_BUF;
    CONV_COL_RIGHT = BOX_COL_RIGHT + CONV_BOX_BUF;
    
    set(0,'DefaultFigureVisible','off');
    FIRST_TIME = 0;
    SUM_TARGET = sum(sum(Target1));
    continue;
end


%% Interest Area

% CHECK IF AT EDGE % 


%% convolution section

%imshow(Target)
%%M_Conv_with = M(CONV_ROW_TOP:CONV_ROW_BOTTOM,CONV_COL_LEFT:CONV_COL_RIGHT);
M_Conv_with = M;
M_compare = M(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT);
current_sum = sum(sum(M(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));


if((current_sum - SUM_TARGET) >= 0.80*SUM_TARGET)
    weight = fspecial('gaussian',(BOX_RANGE*2)+1,8);
    weight = weight/max(max(weight)); 
elseif((current_sum - SUM_TARGET) >= 0.40*SUM_TARGET)
    weight = fspecial('gaussian',(BOX_RANGE*2)+1,12);
    weight = weight/max(max(weight)); 
elseif ((current_sum - SUM_TARGET) >= 0.20*SUM_TARGET)
    weight = fspecial('gaussian',(BOX_RANGE*2)+1,20);
    weight = weight/max(max(weight));
else 
    weight = fspecial('gaussian',(BOX_RANGE*2)+1,25);
    weight = weight/max(max(weight));
end
%imshow(M_Conv_with);
M_conv1_n = conv2(M_Conv_with,Target1,'same');
% figure
% surf(M_conv1(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT));
M_conv1 = weight.*M_conv1_n(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT);
% figure
% surf(M_conv1);


M_conv2_n = conv2(M_Conv_with, Target2, 'same');
M_conv2 = weight.*M_conv2_n(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT);


% M_conv3_n = conv2(M_Conv_with, Target3, 'same');
% M_conv3 = weight.*M_conv3_n(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT);
% M_max3 =  max(max(M_conv3));
% 
% M_conv4_n = conv2(M_Conv_with, Target4, 'same');
% M_conv4 = weight.*M_conv4_n(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT);
% M_max4 =  max(max(M_conv4));

not_in_worm = 1; 

while (not_in_worm)
    
M_max1 = max(max(M_conv1)); %find max within convolution
M_max2 =  max(max(M_conv2));

all_max = [M_max1,M_max2];%,M_max3,M_max4];


M_max_final = max(all_max);
conv_number = find(all_max == M_max_final);

switch(conv_number(1))
    case 1
        M_conv_final = M_conv1;
    case 2
        M_conv_final = M_conv2;
%     case 3
%         M_conv_final = M_conv3;
%     case 4
%         M_conv_final = M_conv4;
    otherwise
        disp('ERROR')
        
end


%Careful notice x and y are flipped
[Max_idx_Row, Max_idx_Col] = find(M_conv_final==M_max_final);


%imshow(M_conv);
% Just incase there are muliple maxes
Max_idx_Row = Max_idx_Row(1);
Max_idx_Col = Max_idx_Col(1);

if (M_compare(Max_idx_Row, Max_idx_Col) == 0) %%%
    not_in_worm = 1; 
    switch(conv_number(1))
    case 1 
        M_conv1(Max_idx_Row, Max_idx_Col)= 0;
    case 2
        M_conv2(Max_idx_Row, Max_idx_Col)= 0;
%     case 3
%         M_conv_final = M_conv3;
%     case 4
%         M_conv_final = M_conv4;
    otherwise
        disp('ERROR')
    end    
else
    not_in_worm = 0;
end

end %end of while loop



Edge_Row = find(M_compare(:,Max_idx_Col),1,'first');
P = [ (Edge_Row) (Max_idx_Col)];
P = double(P);
contour = bwtraceboundary(M_compare,P,'N',8,Inf,'counterclockwise'); %Note x and y are flipped bc of r and col def
cont_size = size(contour);
if(cont_size(1) > 80 && cont_size(1) < 240)
% %     Max_idx_Row = min(contour(:,1)) + (max(contour(:,1)) - min(contour(:,1)))/2;
% %     Max_idx_Col =  min(contour(:,1)) + (max(contour(:,2)) - min(contour(:,2)))/2;
    Max_idx_Row = min(contour(:,1)) + (max(contour(:,1)) - min(contour(:,1)))/2;
    Max_idx_Col =  min(contour(:,2)) + (max(contour(:,2)) - min(contour(:,2)))/2;
    used = used + 1
end
Max_Col = Max_idx_Col+BOX_COL_LEFT;
Max_Row = Max_idx_Row+BOX_ROW_TOP;
% figure
% imshow(M_compare)
% hold on;
% plot(contour(:,2),contour(:,1),'g','LineWidth',2);
% pause;
% close all;
%box for the next iteration:
%% ReCalculate Center of Next Box
shift_col_by =  Max_idx_Col - BOX_RANGE;
shift_row_by = Max_idx_Row - BOX_RANGE;


CENTER_ROW = CENTER_ROW + shift_row_by; 
CENTER_COL = CENTER_COL + shift_col_by;

 
BOX_ROW_TOP =  CENTER_ROW - BOX_RANGE;
BOX_ROW_BOTTOM = CENTER_ROW + BOX_RANGE;

BOX_COL_LEFT = CENTER_COL - BOX_RANGE;
BOX_COL_RIGHT = CENTER_COL + BOX_RANGE;

% ------------------------------------------------ %

CONV_ROW_TOP =  BOX_ROW_TOP - CONV_BOX_BUF;
CONV_ROW_BOTTOM = BOX_ROW_BOTTOM + CONV_BOX_BUF;

CONV_COL_LEFT = BOX_COL_LEFT - CONV_BOX_BUF;
CONV_COL_RIGHT = BOX_COL_RIGHT + CONV_BOX_BUF;


%% Display Center dot
%imshow(M(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT));
%imshow(M_conv_final)

%Main Display
figure
imshow(video);
v_box = [BOX_COL_LEFT BOX_ROW_TOP;BOX_COL_RIGHT BOX_ROW_TOP;BOX_COL_RIGHT BOX_ROW_BOTTOM; BOX_COL_LEFT BOX_ROW_BOTTOM];
f_box = [1 2 3 4];
patch('Faces',f_box,'Vertices',v_box,...
    'EdgeColor','green','FaceColor','none','LineWidth',2);
hold on
plot(Max_Col,Max_Row,'r.','MarkerSize',20);
F = getframe;
Frame_out(i).cdata = F.cdata;
Frame_out(i).colormap = F.colormap;

Centers_found_X(i) = Max_Col;
Centers_found_Y(i) = Max_Row;
% pause;
% figure 
% imshow(M_compare);
% hold on
% plot(Max_idx_Col,Max_idx_Row,'r.','MarkerSize',20)
% pause;
%the ~ on the M is to make the worms black and the backgorund white
%imshow(M) %%Binariezed image(shows worms in black)


%Timing Stuff
% % telapsed = toc(tstart) + toc(tstart);
% % now = toc(tstart);
% % maxTime = max(now,minTime);
i = i + 1
end

imshow(M)
hold on
plot(Centers_found_X,Centers_found_Y,'r.','MarkerSize',20)


%%% Code for detecting Point of Interest might be useful
% % % hold on
% % % edges = detectMinEigenFeatures(M(350:420,723:776))
% % % close all;
% % % imshow(M(350:420,723:776))
% % % hold on
% % % plot(edges.selectStrongest(100));
% % % pause
% hold on
% plot(x,y,'r.','MarkerSize',20) %%Draws redot of where user selected

%%% Counter Finding 
%Need to round numbers for boundarytrace
% x = round(x);
% y = round(y);
% contour = bwtraceboundary(M,[y x],'W',8,Inf,'counterclockwise'); %Note x and y are flipped bc of r and col def
% plot(contour(:,2),contour(:,1),'g','LineWidth',2);
% v_new = v_gaus.* uint8(M);
% v_new = 255 - v_new;
% image(v_new);

% imagesc(video)
% colormap(gray)




