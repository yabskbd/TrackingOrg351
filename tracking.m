%% READ THE AVI
close all
mov=VideoReader('v4.avi');

minTime = 0;
now = 0;

%%% X is Column and Y is ROW
FIRST_TIME = 1;
BOX_RANGE = 40;
CENTER_ROW = 0;
CENTER_COL = 0;
TARGET_RANGE = 40;
CONV_BOX_BUF = 10;
v4_dataset = uint8(zeros(mov.Height,mov.Width,mov.Duration));

Centers_found_X = [];
Centers_found_Y = [];
i = 1;
while(hasFrame(mov))
%% Read Frame
video = readFrame(mov);


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
    close all;
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
    imshow(Target3)
    
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
    
    
    FIRST_TIME = 0;
end


%% Interest Area

% CHECK IF AT EDGE % 


%% convolution section

%Timing Stuff
% % tic;
% % tstart = tic;

%imshow(Target)
%%M_Conv_with = M(CONV_ROW_TOP:CONV_ROW_BOTTOM,CONV_COL_LEFT:CONV_COL_RIGHT);
M_Conv_with = M;
%imshow(M_Conv_with);
M_conv1 = conv2(M_Conv_with,Target1,'same');
M_max1 = max(max(M_conv1(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

M_conv2 = conv2(M_Conv_with, Target2, 'same');
M_max2 =  max(max(M_conv2(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

M_conv3 = conv2(M_Conv_with, Target3, 'same');
M_max3 =  max(max(M_conv3(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

M_conv4 = conv2(M_Conv_with, Target4, 'same');
M_max4 =  max(max(M_conv4(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

%Timing Stuff
% % telapsed = toc(tstart) + toc(tstart);
% % now = toc(tstart);
% % maxTime = max(now,minTime);

all_max = [M_max1,M_max2,M_max3,M_max4];

M_max_final = max(all_max);
conv_number = find(all_max == M_max_final);

switch(conv_number(1))
    case 1
        M_conv_final = M_conv1;
    case 2
        M_conv_final = M_conv2;
    case 3
        M_conv_final = M_conv3;
    case 4
        M_conv_final = M_conv4;
    otherwise
        disp('ERROR')
        
end


%Careful notice x and y are flipped
[Max_idx_Row, Max_idx_Col] = find(M_conv_final(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)==M_max_final);
%imshow(M_conv);
% Just incase there are muliple maxes
Max_idx_Row = Max_idx_Row(1);
Max_idx_Col = Max_idx_Col(1);


shift_col_by =  Max_idx_Col - BOX_RANGE;
shift_row_by = Max_idx_Row - BOX_RANGE;

%% Display Center dot
%imshow(M(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT));
%imshow(M_conv_final)

%Main Display
% figure (1)
% imshow(M);
% hold on
% plot(Max_idx_Col+BOX_COL_LEFT,Max_idx_Row+BOX_ROW_TOP,'r.','MarkerSize',20);
Centers_found_X = [Max_idx_Col+BOX_COL_LEFT,Centers_found_X];
Centers_found_Y = [Max_idx_Row+BOX_ROW_TOP,Centers_found_Y];

%plot(Max_idx_Col,Max_idx_Row,'r.','MarkerSize',20)
%the ~ on the M is to make the worms black and the backgorund white
%imshow(M) %%Binariezed image(shows worms in black)

%box for the next iteration:
%% ReCalculate Center of Next Box
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


end

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
% % x = round(x);
% % y = round(y);
% % contour = bwtraceboundary(M,[y x],'W',8,Inf,'counterclockwise'); %Note x and y are flipped bc of r and col def
% % plot(contour(:,2),contour(:,1),'g','LineWidth',2);
% v_new = v_gaus.* uint8(M);
% v_new = 255 - v_new;
% image(v_new);

% imagesc(video)
% colormap(gray)




