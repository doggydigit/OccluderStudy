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


%% 
% nr_classes = length(images);
% classsizes = zeros(nr_classes,1);
% for c=1:nr_classes
%     classsizes(c) = length(images{c});
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


%% Check occlusion area for simple occluder
nr_radi = length(occluded_images);
visibility = cell(nr_radi, nr_imgs);
for r=1:nr_radi
    n = 0;
    for c=1:nrclasses
        for i=1:length(occluded_images{r}{c})
            n = n + 1;
            a = ~occluder_masks{r}{c}{i};
            b = masks{c}{i};
            d = nnz(a & b) / nnz(b);
            visibility{r, n} = d;
%             visibility{r, n} = nnz(~occluder_masks{r}{c}{i} & masks{c}{i}) / nnz(masks{c}{i});
        end
    end
end


%% Count number of images
% nr_imgs = 0;
% nrclasses = length(occluded_images{1});
% for c=1:nrclasses
%     nr_imgs = nr_imgs + length(occluded_images{1}{c});
% end