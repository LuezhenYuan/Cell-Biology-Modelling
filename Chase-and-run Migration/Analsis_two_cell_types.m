%% Modelling the Neural Crest and Placode Cells Chase-and-run Migration
% Author: Luezhen
% Date: Nov 20 2017
% Description: This script read the movie data, 

%% Read movie data
fname = 'ncb2772-sv5-first75frames.tif';
info = imfinfo(fname);
num_images = numel(info);

%% test and explore the data
img_test = double(imread(fname, 1, 'Info', info));
figure, imshow(img_test,[]);

red_channel = img_test(:,:,1);
green_channel = img_test(:,:,2);
blue_channel = img_test(:,:,3);

figure, imshow(red_channel(26:190,15:185),[]); %use 90 as threshold
figure, imshow(green_channel,[]); %use 50 as threshold
red_channel(26:190,15:185)*((1:171)')
% ROI y: 26~190
% ROI x: 15~185

%% Get the center of two cell groups in each frame
red_center = [];
green_center = [];
for k = 1:num_images
    img_bf_tmp = double(imread(fname, k, 'Info', info));
%     sum(img_bf_tmp(26:190,15:185,1)*((1:171)'),1)/sum(sum(img_bf_tmp)); x
%     sum((1:165)*img_bf_tmp(26:190,15:185,1),2)/sum(sum(img_bf_tmp)); y
    red_center = [red_center; sum(img_bf_tmp(26:190,15:185,1)*((1:171)'),1)/sum(sum(img_bf_tmp(26:190,15:185,1) )), sum((1:165)*img_bf_tmp(26:190,15:185,1),2)/sum(sum(img_bf_tmp(26:190,15:185,1) ))];
    green_center = [green_center; sum(img_bf_tmp(26:190,15:185,2)*((1:171)'),1)/sum(sum(img_bf_tmp(26:190,15:185,2) )), sum((1:165)*img_bf_tmp(26:190,15:185,2),2)/sum(sum(img_bf_tmp(26:190,15:185,2) ))];
end

figure,
plot(red_center(:,1),red_center(:,2));
hold on;
plot(green_center(:,1),green_center(:,2));
legend('Placode cells','Neural crest cells');
xlabel('x position (px)');
ylabel('y position (px)');
title('Chase-and-run collective cell migration');

%% Calculate velocity
red_v = red_center(2:size(red_center,1),:)-red_center(1:size(red_center,1)-1,:);

green_v = green_center(2:size(green_center,1),:)-green_center(1:size(green_center,1)-1,:);

figure,
plot(1:size(red_center,1)-1,red_v(:,1));
title('Velocity x component');

figure,
plot(1:size(red_center,1)-1,red_v(:,2));
title('Velocity y component');

figure,
plot(1:size(red_center,1)-1,red_v(:,1).^2 + red_v(:,2).^2);
title('Velocity square');
%% Kinetic energy
% mass is reflected by fluorescence intensity.
red_kinetic = sum(sum(red_channel(26:190,15:185)))*0.5.*(red_v(:,1).^2 + red_v(:,2).^2);
green_kinetic = sum(sum(green_channel(26:190,15:185)))*0.5.*(green_v(:,1).^2 + green_v(:,2).^2);

figure,
plot(1:size(red_center,1)-1,red_kinetic+green_kinetic);
title('Kinetic energy of both cell types');
xlabel('NO. frame');
ylabel('Sum of kinetic energy (AU)');
legend(['Kinetic energy', 'Linear fitting']);

%% pre-collision velocity (calculate the initial velocity of two cell groups)

% first 1 ~ 14 frames

% Assume the vecolity at each time point comes from two compoenets: 1) the
% constant initial velocity, 2) random gaussian distribution vecolity. The
% mean of the velocities from all time points is the estimate of constant
% initial velocity.
% In the specific context, the constant intial velocity of the NC cells
% contains two components: 1) the true initial velocity, 2) the velocity of
% chemotaxis.

mean(red_v(1:14,:),1); %-0.0657, 0.0910
mean(green_v(1:14,:),1); % 0.2231    0.4069

% mean velocity of chemotaxis

% initial direction of force: This is the direction of chemotaxis velocity.
red_green_distance = red_center(1:14,:) - green_center(1:14,:);
red_green_dis = red_green_distance./sqrt(sum(red_green_distance.^2,2));
mean(red_green_dis,1); % 0.1967    0.9796

% Here I assume that the direction of the initial velocity of green groups
% is just parallel with x axis. The reason is that: velocity in y axis
% should be mainly from the chemotaxis.

% Initial velocity of green: [mean(green_v(1:14,:),1)*[1;0] - (mean(red_green_dis,1)*[1;0]) * ( mean(green_v(1:14,:),1)*[0;1])/(mean(red_green_dis,1)*[0;1]),0];
% Mean velocity of chemotaxis: sqrt( sum((mean(red_green_dis,1).*14.3275).^2) ) = 0.4150
% Initial velocity of red: mean(red_v(1:14,:),1); %-0.0657, 0.0910

%% Simulation

% given initial position:
red_v0 = mean(red_v(1:14,:),1);
green_v0 = [mean(green_v(1:14,:),1)*[1;0] - (mean(red_green_dis,1)*[1;0]) * ( mean(green_v(1:14,:),1)*[0;1])/(mean(red_green_dis,1)*[0;1]),0];
chemotaxis_v = sqrt( sum((mean(red_green_dis,1).*( mean(green_v(1:14,:),1)*[0;1])/(mean(red_green_dis,1)*[0;1])).^2) );
kinetic_energy = mean(red_kinetic+green_kinetic);
m_green = sum(sum(green_channel(26:190,15:185)));
m_red = sum(sum(red_channel(26:190,15:185)));

%% Start simulation
red_sim = zeros(size(red_center));
green_sim = zeros(size(green_center));

red_sim(1,:) = red_center(1,:);
green_sim(1,:) = green_center(1,:);
green_last = green_v0;
red_last = red_v0;
friction = 0.99;
for i=2:200
    % longer than the given data. This will test whether the model will get
    % the unreasonable result: the NC cells move away from the placode
    % cells.
    
    % calculate chemotaxis velocity (mainly the direction)
    tmp_red_green_dis = red_sim(i-1,:) - green_sim(i-1,:);
    tmp_red_green_dis_vec = tmp_red_green_dis./(sqrt(sum(tmp_red_green_dis.^2,2)) );
    tmp_red_green_dis_vec = tmp_red_green_dis_vec.*chemotaxis_v;
    
    % calculate vecolity of green
    tmp_green_v = green_last + tmp_red_green_dis_vec;
    tmp_red_v = red_last;
    % test whether collision occur
    if sqrt(sum(tmp_red_green_dis.^2,2)) < min(sqrt(sum(red_green_distance.^2,2)))
        % 2D perfect elastic collision.
        tmp_green_v_af = tmp_green_v - 2*m_red/(m_red+m_green)*dot(tmp_green_v - tmp_red_v,-tmp_red_green_dis)/sum(tmp_red_green_dis.^2)*(-tmp_red_green_dis);
        tmp_red_v_af = tmp_red_v - 2*m_green/(m_red+m_green)*dot(tmp_red_v - tmp_green_v,tmp_red_green_dis)/sum(tmp_red_green_dis.^2)*(tmp_red_green_dis);
        % equation from: https://www.mathworks.com/matlabcentral/answers/uploaded_files/61940/Elastic%20collision%20-%20Wikipedia.pdf
        
        tmp_green_v = tmp_green_v_af;
        tmp_red_v = tmp_red_v_af;
    end
    
    red_sim(i,:) = red_sim(i-1,:) + tmp_red_v;
    green_sim(i,:) = green_sim(i-1,:) + tmp_green_v;
    
    green_last = friction*(tmp_green_v - tmp_red_green_dis_vec);
    red_last = friction*tmp_red_v;
end


figure,
plot(red_sim(:,1),red_sim(:,2));
hold on;
plot(green_sim(:,1),green_sim(:,2));

% end