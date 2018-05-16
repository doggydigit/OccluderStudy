close all
clear all
disp('Loading Images')
load Images101

%% Occlude Images
disp('Occluding Images')
radi = linspace(0, 0.45, 10);
nr_radi = length(radi);
occluded_images = cell(nr_radi,1);
occluder_masks = cell(nr_radi,1);
occluded_images{1} = images;
for c = 1:length(images)
    for i = 1:length(images{c})
        imsize = size(images{c}{i});
        for r=1:nr_radi
            occluder_masks{r}{c}{i} = true(imsize(1), imsize(2));
        end
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
save(strcat('Occluded_C101_poriginal.mat'), 'occluded_images', 'masks', 'classes', 'occluder_masks', 'radi','-v7.3');

% %% Resize images to 227 x 227
% disp('Resizing Images')
% dasz = 227;
% for r=1:length(occluder_masks)
%     for c=1:length(occluded_images{r})
%         for i=length(occluded_images{r}{c}):-1:1
%             sz = size(occluded_images{r}{c}{i});
%             if max(sz) > dasz
%                 f = dasz/max(sz);
%                 occluded_images{r}{c}{i} =  imresize(occluded_images{r}{c}{i}, [round(f*sz(1)), round(f*sz(2))]);
%                 sz = size(occluded_images{r}{c}{i});
%             end
%             ys = ceil((dasz+1 - sz(1))/2);
%             xs = ceil((dasz+1 - sz(2))/2);
%             m = repmat(uint8(255), dasz, dasz, 3);
%             if length(sz) == 3
%                 m(ys:ys+sz(1)-1, xs:xs+sz(2)-1,:) = occluded_images{r}{c}{i};
%             else
%                 m(ys:ys+sz(1)-1, xs:xs+sz(2)-1,:) = repmat(occluded_images{r}{c}{i}, 1, 1, 3);
%             end
%             occluded_images{r}{c}{i} = m;
% 
%         end
%     end
% end
% 
% %% Save occluded Images to mat 
% disp('Saving Images to .mat files')
% save(strcat('Occluded_C101_p', int2str(dasz), '.mat'), 'occluded_images', 'masks', 'classes', 'occluder_masks', 'radi','-v7.3');
% % clear all
% 
% %% Save images and masks to jpg files
% %load Occluded_C101
% disp('Saving Images to .jpg files')
% for c=1:length(occluded_images{1})
%     for i=1:length(occluded_images{1}{c})
%         imwrite(masks{c}{i}, strcat('SimpleOccluded', int2str(dasz), '/imagemask_', int2str(c), '_', int2str(i), '.jpg'))
%         for r=1:length(occluded_images)
%             imwrite(occluded_images{r}{c}{i},strcat('SimpleOccluded', int2str(dasz), '/occluded_image_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg'))
%             imwrite(occluder_masks{r}{c}{i},strcat('SimpleOccluded', int2str(dasz), '/occluded_imagemask_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg'))
%         end     
%     end
% end