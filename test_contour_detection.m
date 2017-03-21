BW = imread('blobs.png');
imshow(BW);


[c,r] = ginput(1); %%Takes users input where the pixel worm is
% r = 163;
% c = 37;
contour = bwtraceboundary(BW,[round(r) round(c)],'W',8,Inf,'counterclockwise');

hold on;
plot(c,r,'r.','MarkerSize',20) %%Draws redot of where user selected
plot(contour(:,2),contour(:,1),'r','LineWidth',2);



