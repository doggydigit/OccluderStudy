close all
clear all
load Images101

%% Precompute some occluder shapes to ease later computation
% maxsize = 200;
% radius = 0:maxrad;
% nr_rad = maxrad+1;
% circle_coordinates = cell(nr_rad,1);
% triup_coordinates = cell(nr_rad,1);
% trido_coordinates = cell(nr_rad,1);
% square_coordinates = cell(nr_rad,1);
% nr_pixels_per_radius = zeros(nr_rad,1);
% for k = 1:nr_rad
%     circle_coordinates{k} = {};
%     r = radius(k);
%     
%     %% Compute for circle and square
%     R = r^2;
%     for i = -r:r
%         for j = -r:r
%             if i^2 + j^2 <= R
%                 circle_coordinates{k}{end+1} = [i,j];
%                 nr_pixels_per_radius(k) = nr_pixels_per_radius(k) + 1;
%             end
%             square_coordinates{k}{end+1} = [i,j];
%         end
%     end
%     
%     %% Compute for triangles
%     h = sqrt(3)*r;
%     m = ceil(h);
%     n = 2*r;
%     tridomask = poly2mask([1, n, r],[1, 1, h],m,n);
%     triupmask = poly2mask([r, 1, n],[h, 1, 1],m,n);
%     h = round(h/2);
%     for i=1:n
%         for j=1:m
%             if tridomask(i,j)
%                 trido_coordinates{k}{end+1} = [i-r,j-h];
%             end
%             if triupmask(i,j)
%                 triup_coordinates{k}{end+1} = [i-r,j-h];
%             end
%         end
%     end
% end

%% Occlude Images
radi = linspace(0, 0.45, 10);
nr_radi = length(radi);
occluded_images = cell(nr_radi,1);
occluder_masks = cell(nr_radi,1);
occluded_images{1} = images;
for c = 1:length(images)
    for i = 1:length(images{c})
        imsize = size(images{c}{i});
        occluder_masks{1}{c}{i} = true(imsize(1), imsize(2));
    end
end
for r = 2:nr_radi
    %% Initialize/Predefine some stuff
    occluded_images{r} = images;
    occluder_masks{r} = cell(length(images),1);
    
    %% Occlude all images
    for c = 1:length(images)
        for i = 1:length(images{c})
            imsize = size(images{c}{i});
            color = length(imsize) == 3;
            rad = floor(min(imsize(1:2))*radi(r))-1;
            cx = randi([rad+1, imsize(2)-rad]);
            cy = randi([rad+1, imsize(1)-rad]);
            occshape = randi(4);
            switch occshape
                case 1
                    %% Occluding with Circle
                    occluder_masks{r}{c}{i} = true(imsize(1), imsize(2));
                    for y = 1:imsize(1)
                        for x = 1:imsize(2)
                            if (y-cy)^2 + (x-cx)^2 <= rad
                                occluder_masks{r}{c}{i}(y,x) = false;
                                if color
                                    occluded_images{r}{c}{i}(y,x,:) = 0;
                                else
                                    occluded_images{r}{c}{i}(y,x) = 0;
                                end
                            end
                        end
                    end
                case 2
                    %% Occluding with square
                    occluder_masks{r}{c}{i} = true(imsize(1), imsize(2));
                    for y = cy-rad:cy+rad
                        for x = cx-rad:cx+rad
                            occluder_masks{r}{c}{i}(y,x) = false;
                            if color
                                occluded_images{r}{c}{i}(y,x,:) = 0;
                            else
                                occluded_images{r}{c}{i}(y,x) = 0;
                            end
                        end
                    end
                case 3
                    %% Occluding with upward triangle
                    h = round(sqrt(3)*rad/4);
                    occluder_masks{r}{c}{i} = poly2mask([cx-rad, cx+rad, cx],[cy-h, cy-h, cy+h],imsize(1),imsize(2));
                    if color
                        occluded_images{r}{c}{i}(repmat(occluder_masks{r}{c}{i},1,1,3)) = 0;
                    else 
                        occluded_images{r}{c}{i}(occluder_masks{r}{c}{i}) = 0;
                    end
                case 4
                    %% Occluding with downward triangle
                    h = round(sqrt(3)*rad/4);
                    occluder_masks{r}{c}{i} = poly2mask([cx-rad, cx+rad, cx],[cy+h, cy+h, cy-h],imsize(1),imsize(2));
                    if color
                        occluded_images{r}{c}{i}(repmat(occluder_masks{r}{c}{i},1,1,3)) = 0;
                    else 
                        occluded_images{r}{c}{i}(occluder_masks{r}{c}{i}) = 0;
                    end
                otherwise
                    print('BUGGGG');
            end
        end
    end
end

%% Save occluded Images to mat 
save('Occluded_C101.mat', 'occluded_images', 'occluder_masks', 'radi','-v7.3');
% clear all

%% Save images and masks to jpg files
% load Occluded_C101
% for c=1:length(occluded_images{1})
%     for i=1:length(occluded_images{1}{c})
%         imwrite(masks{c}{i}, strcat('SimpleOccluded/imagemask_', int2str(c), '_', int2str(i), '.jpg'))
%         for r=1:length(occluded_images)
%             imwrite(occluded_images{r}{c}{i},strcat('SimpleOccluded/occluded_image_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg'))
%             imwrite(occluded_masks{r}{c}{i},strcat('SimpleOccluded/occluded_imagemask_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg'))
%         end     
%     end
% end