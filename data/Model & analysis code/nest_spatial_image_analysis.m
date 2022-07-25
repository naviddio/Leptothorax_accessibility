clear all; close all

cd 'C:\...\Empirical data\img_RN23' %location of image sequence of interest

dinfo = dir;
A = {dinfo.name};

A = A(~cellfun('isempty', strfind(A,'.jpg')));

A=sort_nat(A)
activity = [];

file=[char(A(1))];  % Set filename of 1st frame in pair
image=imread(file);
% rect = [67.5 5.5 271 271]; % Uncomment for RN22, comment out this line when processing other colonies: crops nest in images of colony RN22
% rect = [92.5 10 271 271]; % Uncomment for RN19, comment out this line when processing other colonies: crops nest in images of colony RN19
% rect = [88.5 10 271 271]; % Uncomment for RN6, comment out this line when processing other colonies: crops nest in images of colony RN6
rect = [129.5 7.5 271 271]; % Uncomment for RN23, comment out this line when processing other colonies: crops nest in images of colony RN23
 parfor m=1:length(A)-1 %loop though all image pairs
%  for m=1:length(A)-1

    m

    file=[char(A(m))];  % Set filename of 1st frame in pair
    file2=[char(A(m+1))];  % Set filename of 2nd frame in pair

    image=imread(file);
    image=rgb2gray(image); % convert 1st frame to grayscale   
    image=imcrop(image,rect);
    is=image;
    image=imbinarize(image, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 1st image
    image=imcomplement(image);

    image2=imread(file2); % process 2nd image in the same way as 1st image
    image2=rgb2gray(image2);
    image2=imcrop(image2,rect);
    is2=image2;
    image2=imbinarize(image2, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); % threshold 2nd image
    image2=imcomplement(image2);

    s = bwareaopen(image,50,8); % filter noise from 1st image   
    e = bwareaopen(image2,50,8); % filter noise from 2nd image 
     
    start=sum(s(:)); % count number of pixels in 1st image 
    % pixel difference between images
    p=e-s; 
    p(p<0) = 0; 
    
    p = bwareaopen(p,50,8); % filter noise
    ia= e & s; % find pixels that were classified as being part of ants that did not move between the current pair of frames
    
    % optional plotting of nest images and segmented ants 
    %     figure(1) 
    %     imshow(is)
    %     figure(2)
    %     imshow(s)
    %     figure(3)
    %     imshow(is2)
    %     figure(4)
    %     imshow(e)
    %     figure(5)
    %     imshow(p)
    %     figure(6)
    %     imshow(ia)

    
    activity(m)=sum(p(:))/start; % estimate proportion of ants that have moved
     
    %partition the segmented nest image of inactive ants into a regular grid with sectors of equal area 
    mfun = @(block_struct) sum(sum(block_struct.data));
    block_inactiveants = blockproc(ia, [68 68], mfun);

    %determine maximum local density (MLD) by finding the number of ant classified pixels in the sector with the most ants. When plotting the data, this value can be divided by the approx. number of pixels that comprise an ant (see main text).    
    mld(m)=max(max(block_inactiveants));


    hours(seconds((m)*30))
end

v=array2table(horzcat(mld',activity'));
v.Properties.VariableNames ={'MLD' 'activity'}

% save data

% writetable(v, 'activity_MLD_RN23.csv') 
