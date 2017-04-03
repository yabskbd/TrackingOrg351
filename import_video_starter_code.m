%% READ THE AVI
close all
mov=VideoReader('v4.avi');
%%% X is Column and Y is ROW
FIRST_TIME = 1;
BOX_RANGE = 100;
CENTER_ROW = 0;
CENTER_COL = 0;
TARGET_RANGE = 40;

while(hasFrame(mov))
%% Read Frame
video = readFrame(mov);

%% Apply Filter(gaus)
%v_gaus =imgaussfilt(video);
v_gaus = video;


%% Track
%%% Filter out background 

%Might need to edit 68 value
M =(v_gaus <= 68); %%Mask to find worms(got 68 from imtool) 
M = double(M); %% NEEDS TO BE A DOUBLE FOR CONV


if(FIRST_TIME == 1)
    
%% Recieve Target
    imshow(~M);
    hold on %%What the keep image up so user can select below
    pause;
    [x,y] = ginput(1); %%Takes users input where the pixel worm is
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
    
    FIRST_TIME = 0;
end


%% Interest Area

% CHECK IF AT EDGE % 


%% convolution section

%imshow(Target)
M_conv1 = conv2(M,Target1,'same');
M_max1 = max(max(M_conv1(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

M_conv2 = conv2(M, Target2, 'same');
M_max2 =  max(max(M_conv2(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

M_conv3 = conv2(M, Target3, 'same');
M_max3 =  max(max(M_conv3(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

M_conv4 = conv2(M, Target4, 'same');
M_max4 =  max(max(M_conv4(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT)));

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


shift_col_by =  Max_idx_Col - 100;
shift_row_by = Max_idx_Row - 100;

imshow(M(BOX_ROW_TOP:BOX_ROW_BOTTOM,BOX_COL_LEFT:BOX_COL_RIGHT));
hold on

plot(Max_idx_Col,Max_idx_Row,'r.','MarkerSize',20);
%the ~ on the M is to make the worms black and the backgorund white
%imshow(M) %%Binariezed image(shows worms in black)

%box for the next iteration:

CENTER_ROW = CENTER_ROW + shift_row_by; 
CENTER_COL = CENTER_COL + shift_col_by;

 
BOX_ROW_TOP =  CENTER_ROW - BOX_RANGE;
BOX_ROW_BOTTOM = CENTER_ROW + BOX_RANGE;

BOX_COL_LEFT = CENTER_COL - BOX_RANGE;
BOX_COL_RIGHT = CENTER_COL + BOX_RANGE;


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




