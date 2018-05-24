%% Check Image statistics
% szes = zeros(3, 2);
% ratios = zeros(3,1);
% j=1;
% for c=1:length(images)
%     for i=length(images{c}):-1:1
%         sz = size(images{c}{i});
%         szes(j,:) = sz(1:2);
%         if sz(1) > sz(2)
%             ratios(j) = sz(1)/sz(2);
%         else
%             ratios(j) = sz(2)/sz(1);
%         end
% %         if ratios(j) > 2
% %             %print(c)
% %             images{c}(i)=[];
% %         end
%         j=j+1;
%     end
% end


%% get sizes of each class
% nr_classes = length(occluded_images{1});
% classsizes = zeros(nr_classes,1);
% for c=1:nr_classes
%     classsizes(c) = length(occluded_images{1}{c});
% end


%% Resize big images to smaller ones
% clear all
% close all
% load Occluded_C101.mat
% %%%%%%occimgs = cell(length(occluder_masks), length(occluder_masks{1}));
% dasz = 320;
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
% save('Occluded_C101.mat', 'occluded_images', 'occluder_masks', 'radi','-v7.3');


%% Evaluate with alexnet
% nr_classes = 28;
% label = cell(nr_classes,1);
% for c=1:nr_classes
%     labels{c} = classify(net,occluded_images{1}{c}{1});
%     for i=2:length(occluded_images{1}{c})
%         disp(class(classify(net,occluded_images{1}{c}{i})))
%         disp(labels{c})
%         disp(categories(labels{c}))
%         disp(c)
%         disp(i)
%         labels{c} = addcats(labels{c}, {classify(net,occluded_images{1}{c}{i})});
%     end
% end


%% Count number of images
% nr_imgs = 0;
% nrclasses = length(occluded_images{1});
% for c=1:nrclasses
%     nr_imgs = nr_imgs + length(occluded_images{1}{c});
% end


%% Check occlusion area for simple occluder
% nr_radi = length(occluded_images);
% visibility = zeros(nr_radi, nr_imgs);
% for r=1:nr_radi
%     n = 0;
%     for c=1:nrclasses
%         for i=1:length(occluded_images{r}{c})
%             n = n + 1;
% %             a = ~occluder_masks{r}{c}{i};
% %             b = masks{c}{i};
% %             d = nnz(a & b) / nnz(b);
% %             visibility{r, n} = d;
%             visibility(r, n) = 1 - double(nnz(~occluder_masks{r}{c}{i} & masks{c}{i})) / double(nnz(masks{c}{i}));
%         end
%     end
% end


%% Plot alexnet accuracy for occluded and regenerated images
% plot(0:0.1:0.9, totalaccu)
% hold on
% plot(0:0.1:0.9, gen_totalaccu)
% legend('occluded', 'regenerated')
% xlabel('occluder size')
% ylabel('performance')



%% CHeck alexnet labels 
clc
clear all
close all
net = alexnet;
labels = {{'plane', 'warplane', 'airliner'}
    {'monarch', 'ringlet', 'lycaenid'}
    {'rock crab', 'Dungeness crab', 'king crab', 'fiddler crab'}
    {'American lobster', 'crayfish', 'spiny lobster'}
    {'dalmatian'}
    {'vase', 'whiskey jug', 'pitcher', 'water jug', 'teapot'} % 6
    {'grand piano'}
    {'loggerhead', 'leatherback turtle', 'terrapin'}
    {'black stork', 'spoonbill', 'hornbill', 'goose', 'white stork', 'vulture', 'dowitcher', 'redshank', 'crane', 'little blue heron', 'magpie', 'coucal', 'limpkin', 'sulphur-crested cockatoo', 'flamingo', 'American egret', 'house finch', 'macaw'}
    {'wallaby'} % 10
    {'catamaran', 'yawl', 'schooner', 'trimaran'} % 11
    {'notebook', 'laptop', 'screen', 'space bar', 'hand-held computer', 'desktop computer', 'iPod'}
    {'cheetah', 'leopard', 'jaguar'}
    {'llama'} % 14
    {'tricycle', 'moped', 'bicycle-built-for-two', 'mountain bike', 'motor scooter'}
    {'revolver', 'rifle', 'assault rifle'}
    {'starfish'} % 17
    {'trilobite', 'chiton'}
    {'umbrella'} % 19
    {'analog clock', 'stopwatch', 'digital watch', 'wall clock', 'digital clock'}
    };
load SimpleOccluded320/info.mat
c = 11;
r = 2;
for i=1:classsizes(c)
    img = imresize(imread(strcat('SimpleOccluded320/gen_deepoutshape_', int2str(r), '_', int2str(c), '_', int2str(i), '.jpg')), [227, 227]);
    l = classify(net,img);
    if ~any(strcmp(labels{c},char(l(1))))
       disp(l);
   end
end
